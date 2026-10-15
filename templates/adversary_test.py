#!/usr/bin/env python3
"""
Test Adversary Template (Python) - master-skill / safety
Stress-tests code against concurrency races, poison inputs, and network latency.
"""

import concurrent.futures
import time
import unittest


def mock_service_mutation(user_id: str, amount: int) -> dict:
    """Target function being tested for concurrency & boundary resistance."""
    if amount < 0:
        raise ValueError("Amount must be non-negative")
    time.sleep(0.005)  # Simulate network / IO latency
    return {"user_id": user_id, "amount": amount, "status": "CONFIRMED"}


class TestAdversarySuite(unittest.TestCase):

    def test_adversary_concurrency_race(self):
        """Fault Injection: 30 concurrent workers performing rapid mutations."""
        workers = 30
        results = []
        with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
            futures = [
                executor.submit(mock_service_mutation, f"user_{i}", 100)
                for i in range(workers)
            ]
            for f in concurrent.futures.as_completed(futures):
                results.append(f.result())

        self.assertEqual(len(results), workers)
        for res in results:
            self.assertEqual(res["status"], "CONFIRMED")

    def test_adversary_poison_inputs(self):
        """Fault Injection: Malformed and boundary payload inputs."""
        poison_payloads = [-1, -9999999]
        for val in poison_payloads:
            with self.assertRaises(ValueError):
                mock_service_mutation("user_bad", val)


if __name__ == "__main__":
    unittest.main()
