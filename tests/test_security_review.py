import unittest

from scripts.security_review import collect_backend_inventory, run_security_assessment


class SecurityReviewTests(unittest.TestCase):
    def test_backend_inventory_detects_express_stack(self):
        inventory = collect_backend_inventory()
        self.assertEqual(inventory["framework"], "Node.js / Express")
        self.assertEqual(inventory["language"], "JavaScript")
        self.assertIn("MongoDB", inventory["database"])

    def test_security_assessment_generates_findings(self):
        report = run_security_assessment(output_dir="test-output")
        self.assertTrue(report["findings"])
        self.assertGreaterEqual(len(report["endpoints"]), 1)


if __name__ == "__main__":
    unittest.main()
