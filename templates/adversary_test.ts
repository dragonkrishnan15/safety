/**
 * Test Adversary Template (TypeScript / JavaScript) - master-skill / safety
 * Stress-tests async code against concurrency races, boundary payloads, and latency drops.
 */

import { describe, it, expect } from 'vitest'; // Or jest / mocha

async function mockServiceMutation(userId: string, amount: number): Promise<{ userId: string; amount: number; status: string }> {
  if (amount < 0) {
    throw new Error('Amount must be non-negative');
  }
  await new Promise((resolve) => setTimeout(resolve, 5)); // Simulate network / DB latency
  return { userId, amount, status: 'CONFIRMED' };
}

describe('Test Adversary Suite', () => {
  it('handles 50 concurrent async mutations without race collisions', async () => {
    const workers = 50;
    const tasks = Array.from({ length: workers }, (_, i) =>
      mockServiceMutation(`user_${i}`, 100)
    );

    const results = await Promise.all(tasks);
    expect(results).toHaveLength(workers);
    results.forEach((res) => {
      expect(res.status).toBe('CONFIRMED');
    });
  });

  it('rejects poison inputs and boundary payloads with clean exceptions', async () => {
    const poisonInputs = [-1, -99999];
    for (const val of poisonInputs) {
      await expect(mockServiceMutation('bad_user', val)).rejects.toThrow('Amount must be non-negative');
    }
  });
});
