"""
Example Test Adversary Suite: Red-Team Fault Injection & Concurrency Test
Demonstrates the 3 core Test Adversary attacks:
1. Concurrency Race Condition Attack
2. Poison Payload & Type Confusion Attack
3. Boundary & Off-by-One Overflow Attack
"""

import pytest
import concurrent.futures
import time

# Simulated token service for demonstration
class TokenService:
    def __init__(self):
        self.used_tokens = set()
        self.max_payload_bytes = 1024 * 1024  # 1 MB

    def refresh(self, token: str, payload_size: int = 100):
        if not isinstance(token, str) or not token:
            raise ValueError("Invalid token format")
        if payload_size > self.max_payload_bytes:
            raise ValueError("Payload size exceeds maximum limit (413)")
        if token in self.used_tokens:
            raise PermissionError("Replay attack detected: token already consumed (401)")
        # Simulate small latency to expose race conditions
        time.sleep(0.005)
        self.used_tokens.add(token)
        return {"access_token": f"new_jwt_{token}", "expires_in": 3600}


@pytest.fixture
def service():
    return TokenService()


# 1. Concurrency Race Attack: 50 threads attempting to refresh the exact same token simultaneously
def test_adversary_concurrency_race_condition(service):
    target_token = "single_use_refresh_token_xyz"
    success_count = 0
    replay_rejections = 0

    def attempt_refresh():
        try:
            service.refresh(target_token)
            return True
        except PermissionError:
            return False

    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        futures = [executor.submit(attempt_refresh) for _ in range(50)]
        results = [f.result() for f in futures]

    successes = sum(1 for r in results if r is True)
    # The Invariant: EXACTLY one refresh may succeed; all 49 other concurrent hits MUST be rejected.
    assert successes == 1, f"Expected exactly 1 success, but got {successes} (Race Condition Vulnerability!)"


# 2. Poison Payload Attack: Injects null bytes, SQL fragments, and non-string types
@pytest.mark.parametrize("poison_input", [
    None,
    "",
    "\x00admin_bypass",
    {"$gt": ""},
    "A" * 1000000,  # 1MB string
])
def test_adversary_poison_payload_handling(service, poison_input):
    with pytest.raises(ValueError):
        service.refresh(poison_input)


# 3. Boundary & Overflow Attack: Tests payload size right at the limit and above
def test_adversary_payload_boundary_limits(service):
    valid_token = "valid_token_abc"
    # Exactly at limit: must succeed
    res = service.refresh(valid_token, payload_size=1024 * 1024)
    assert res["access_token"] is not None

    # Limit + 1 byte: must be rejected
    with pytest.raises(ValueError, match="Payload size exceeds"):
        service.refresh("another_token", payload_size=(1024 * 1024) + 1)
