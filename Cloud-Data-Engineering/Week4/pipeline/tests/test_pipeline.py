import unittest

import pipeline


class FakeCursor:
    def __init__(self, error=None):
        self.closed = False
        self.error = error
        self.rowcount = 2
        self.sql = None
        self.rows = None

    def execute(self, sql, params=None):
        self.sql = sql

    def executemany(self, sql, rows):
        self.sql = sql
        self.rows = rows
        if self.error:
            raise self.error

    def close(self):
        self.closed = True


class FakeConnection:
    def __init__(self, cursor):
        self.closed = False
        self.committed = False
        self.cursor_instance = cursor
        self.rolled_back = False

    def cursor(self):
        return self.cursor_instance

    def commit(self):
        self.committed = True

    def rollback(self):
        self.rolled_back = True

    def close(self):
        self.closed = True


class FakeDeadlockError(Exception):
    def __init__(self, message="Deadlock found when trying to get lock"):
        super().__init__(message)
        self.errno = 1213


class FakeUnknownDatabaseError(Exception):
    def __init__(self, message="Unknown database 'imdb_data'"):
        super().__init__(message)
        self.errno = 1049


class PipelineDatabaseTests(unittest.TestCase):
    def get_writer(self):
        writer = getattr(pipeline, "write_movies", None)
        self.assertIsNotNone(writer, "pipeline.write_movies must be implemented")
        return writer

    def test_pipeline_module_has_writer(self):
        self.assertTrue(callable(getattr(pipeline, "write_movies", None)))

    def test_write_movies_uses_upsert_and_closes_resources(self):
        cursor = FakeCursor()
        connection = FakeConnection(cursor)
        configuration = {"database": "course"}
        rows = [("Movie", "2020", 8.0, 100)]

        inserted = self.get_writer()(lambda **kwargs: connection, configuration, rows)

        self.assertIn("ON DUPLICATE KEY UPDATE", cursor.sql)
        self.assertEqual(rows, cursor.rows)
        self.assertEqual(2, inserted)
        self.assertTrue(connection.committed)
        self.assertTrue(cursor.closed)
        self.assertTrue(connection.closed)

    def test_write_movies_rolls_back_and_propagates_execution_failure(self):
        cursor = FakeCursor(ValueError("insert failed"))
        connection = FakeConnection(cursor)

        with self.assertRaisesRegex(ValueError, "insert failed"):
            self.get_writer()(lambda **kwargs: connection, {}, [("Movie", "2020", 8.0, 100)])

        self.assertTrue(connection.rolled_back)
        self.assertTrue(cursor.closed)
        self.assertTrue(connection.closed)

    def test_write_movies_propagates_connection_failure(self):
        def fail_to_connect(**kwargs):
            raise RuntimeError("cannot connect")

        with self.assertRaisesRegex(RuntimeError, "cannot connect"):
            self.get_writer()(fail_to_connect, {}, [("Movie", "2020", 8.0, 100)], max_retries=1)

    def test_transient_error_detection(self):
        self.assertTrue(pipeline.is_transient_db_error(FakeDeadlockError()))
        self.assertTrue(pipeline.is_transient_db_error(RuntimeError("Lock wait timeout exceeded")))
        self.assertFalse(pipeline.is_transient_db_error(ValueError("Invalid column name")))

    def test_write_movies_retries_transient_deadlock_and_succeeds(self):
        attempts = 0

        def connect_with_transient_failure(**kwargs):
            nonlocal attempts
            attempts += 1
            if attempts == 1:
                cursor = FakeCursor(FakeDeadlockError())
            else:
                cursor = FakeCursor()
            return FakeConnection(cursor)

        inserted = self.get_writer()(
            connect_with_transient_failure,
            {},
            [("Inception", "2010", 8.8, 2000000)],
            max_retries=3,
            base_delay=0.001,
        )

        self.assertEqual(attempts, 2)
        self.assertEqual(inserted, 2)

    def test_write_movies_empty_rows_returns_zero(self):
        called = False

        def connect(**kwargs):
            nonlocal called
            called = True
            return FakeConnection(FakeCursor())

        inserted = self.get_writer()(connect, {}, [])
        self.assertEqual(inserted, 0)
        self.assertFalse(called)

    def test_write_movies_recovers_from_unknown_database_error(self):
        calls = 0

        def connect(**kwargs):
            nonlocal calls
            calls += 1
            if kwargs.get("database") == "imdb_data" and calls == 1:
                raise FakeUnknownDatabaseError()
            return FakeConnection(FakeCursor())

        inserted = self.get_writer()(
            connect,
            {"database": "imdb_data"},
            [("Inception", "2010", 8.8, 2000000)],
            max_retries=3,
            base_delay=0.001,
        )
        self.assertEqual(inserted, 2)

    def test_load_config_loads_default_yaml(self):
        config = pipeline.load_config()
        self.assertIn("database", config)
        self.assertIn("ingestion", config)
        self.assertIn("settings", config)
        self.assertIn("search_url_template", config["ingestion"])
        self.assertEqual(config["database"]["port"], 3306)

    def test_load_config_resolves_env_placeholders(self):
        import os
        import tempfile

        yaml_content = "test_db:\n  host: \"${TEST_ENV_HOST:-default_host}\"\n  user: \"${TEST_ENV_USER}\"\n"
        with tempfile.NamedTemporaryFile("w+", suffix=".yaml", delete=False) as tmp:
            tmp.write(yaml_content)
            tmp.flush()
            tmp_path = tmp.name

        try:
            # When env var not set, default is used
            loaded = pipeline.load_config(tmp_path)
            self.assertEqual(loaded["test_db"]["host"], "default_host")
            self.assertEqual(loaded["test_db"]["user"], "")

            # When env var is set, it overrides
            os.environ["TEST_ENV_HOST"] = "custom_host"
            os.environ["TEST_ENV_USER"] = "alice"
            loaded = pipeline.load_config(tmp_path)
            self.assertEqual(loaded["test_db"]["host"], "custom_host")
            self.assertEqual(loaded["test_db"]["user"], "alice")
        finally:
            os.environ.pop("TEST_ENV_HOST", None)
            os.environ.pop("TEST_ENV_USER", None)
            if os.path.exists(tmp_path):
                os.remove(tmp_path)


if __name__ == "__main__":
    unittest.main()
