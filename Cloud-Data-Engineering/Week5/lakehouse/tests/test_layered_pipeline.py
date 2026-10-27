import unittest

from layered_pipeline import build_layers


_VALID_ROW = {"time": "2024-01-01T00:00:00Z", "latitude": "1", "longitude": "2", "mag": "3.0", "type": "earthquake"}


class LayeredPipelineTests(unittest.TestCase):
    def test_gold_layer_aggregates_by_date_and_type(self):
        rows = [
            {"time": "2024-01-01T00:00:00Z", "latitude": "1", "longitude": "2", "mag": "3.0", "type": "earthquake"},
            {"time": "2024-01-01T01:00:00Z", "latitude": "1", "longitude": "2", "mag": "4.5", "type": "earthquake"},
            {"time": "2024-01-01T02:00:00Z", "latitude": "1", "longitude": "2", "mag": "1.0", "type": "quarry blast"},
        ]

        _, silver, gold = build_layers(rows)

        self.assertEqual(len(silver), 3)
        self.assertEqual(
            gold,
            [
                {"event_date": "2024-01-01", "event_type": "earthquake", "event_count": 2, "maximum_magnitude": 4.5},
                {"event_date": "2024-01-01", "event_type": "quarry blast", "event_count": 1, "maximum_magnitude": 1.0},
            ],
        )

    def test_silver_layer_converts_numeric_fields(self):
        rows = [dict(_VALID_ROW)]
        _, silver, _ = build_layers(rows)
        self.assertIsInstance(silver[0]["latitude"], float)
        self.assertIsInstance(silver[0]["longitude"], float)
        self.assertIsInstance(silver[0]["mag"], float)

    def test_missing_required_column_raises(self):
        rows = [{"time": "2024-01-01T00:00:00Z", "latitude": "1", "longitude": "2", "mag": "3.0"}]
        with self.assertRaisesRegex(ValueError, "type"):
            build_layers(rows)

    def test_null_required_field_raises(self):
        rows = [{"time": "", "latitude": "1", "longitude": "2", "mag": "3.0", "type": "earthquake"}]
        with self.assertRaisesRegex(ValueError, "time"):
            build_layers(rows)

    def test_out_of_range_latitude_raises(self):
        rows = [{"time": "2024-01-01T00:00:00Z", "latitude": "999", "longitude": "2", "mag": "3.0", "type": "earthquake"}]
        with self.assertRaisesRegex(ValueError, "latitude"):
            build_layers(rows)

    def test_missing_mag_defaults_to_zero(self):
        rows = [{"time": "2024-01-01T00:00:00Z", "latitude": "1", "longitude": "2", "mag": "", "type": "earthquake"}]
        _, silver, _ = build_layers(rows)
        self.assertEqual(silver[0]["mag"], 0.0)


if __name__ == "__main__":
    unittest.main()
