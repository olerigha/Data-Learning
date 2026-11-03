import json
import os
import unittest
from unittest.mock import patch

import lambda_function


class LambdaFunctionTest(unittest.TestCase):
    def setUp(self):
        os.environ.setdefault("RAW_BUCKET", "course-raw-fixtures")

    def test_objects_route_returns_read_only_s3_preview(self):
        event = {
            "requestContext": {"http": {"method": "GET"}},
            "rawPath": "/objects/earthquakes.csv",
            "queryStringParameters": {"limit": "2"},
        }

        with patch.object(
            lambda_function,
            "_read_s3_object",
            return_value="time,mag\n2024-10-31T01:44:01.866Z,0.5\n2024-10-31T01:32:40.503Z,4.4\n",
            create=True,
        ):
            response = lambda_function.lambda_handler(event, None)

        self.assertEqual(response["statusCode"], 200)
        body = json.loads(response["body"])
        self.assertEqual(body["data"]["bucket"], "course-raw-fixtures")
        self.assertEqual(body["data"]["key"], "earthquakes.csv")
        self.assertEqual(body["data"]["preview"], ["time,mag", "2024-10-31T01:44:01.866Z,0.5"])


if __name__ == "__main__":
    unittest.main()