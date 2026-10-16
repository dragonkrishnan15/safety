/**
 * Automated Test Suite for safety CLI & Core Engine
 */

const assert = require('assert');
const { spawnSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const CLI_PATH = path.join(__dirname, '..', 'bin', 'safety.js');

console.log('🧪 Running safety CLI Test Suite...');

let passed = 0;
let failed = 0;

function runTest(name, fn) {
  try {
    fn();
    console.log(`  ✅ [PASS] ${name}`);
    passed++;
  } catch (err) {
    console.error(`  ❌ [FAIL] ${name}: ${err.message}`);
    failed++;
  }
}

// 1. Zero-Destruction Wall: Dangerous Git Reset
runTest('Interceptor blocks "git reset --hard"', () => {
  const res = spawnSync('node', [CLI_PATH, 'intercept', 'git reset --hard HEAD'], { encoding: 'utf8' });
  assert.strictEqual(res.status, 1, 'Should exit with code 1');
  assert(res.stderr.includes('ZERO_DESTRUCTION_WALL'), 'Should cite policy ZERO_DESTRUCTION_WALL');
});

// 2. Zero-Destruction Wall: Destructive Clean
runTest('Interceptor blocks "git clean -fd"', () => {
  const res = spawnSync('node', [CLI_PATH, 'intercept', 'git clean -fd'], { encoding: 'utf8' });
  assert.strictEqual(res.status, 1, 'Should exit with code 1');
  assert(res.stderr.includes('ZERO_DESTRUCTION_WALL'), 'Should cite policy ZERO_DESTRUCTION_WALL');
});

// 3. Secret Scanner: Intercept plaintext API Key
runTest('Interceptor blocks plaintext secret in arguments', () => {
  const dummyKey = 'sk-' + 'A'.repeat(25);
  const res = spawnSync('node', [CLI_PATH, 'intercept', `curl https://api.openai.com -H "Authorization: Bearer ${dummyKey}"`], { encoding: 'utf8' });
  assert.strictEqual(res.status, 1, 'Should exit with code 1');
  assert(res.stderr.includes('SECRET_SCANNER'), 'Should cite policy SECRET_SCANNER');
});

// 4. Safe Command Allowed
runTest('Interceptor permits safe development command', () => {
  const res = spawnSync('node', [CLI_PATH, 'intercept', 'npm run build'], { encoding: 'utf8' });
  assert.strictEqual(res.status, 0, 'Should exit with code 0');
  const data = JSON.parse(res.stdout);
  assert.strictEqual(data.decision, 'PERMITTED');
});

// 5. Contract Init
runTest('Contract Init generates valid ct-contract.json', () => {
  const tempContract = path.join(process.cwd(), 'ct-contract.json');
  try {
    const res = spawnSync('node', [CLI_PATH, 'contract', 'init', '--permitted', 'src/**', '--forbidden', '.env*'], { encoding: 'utf8' });
    assert.strictEqual(res.status, 0, 'Should exit with code 0');
    assert(fs.existsSync(tempContract), 'ct-contract.json should be created');
    const parsed = JSON.parse(fs.readFileSync(tempContract, 'utf8'));
    assert(parsed.permitted_paths.includes('src/**'));
    assert(parsed.forbidden_paths.includes('.env*'));
  } finally {
    if (fs.existsSync(tempContract)) fs.unlinkSync(tempContract);
  }
});

// 6. Mesh Lock & Conflict Arbitration
runTest('Mesh Lock arbitration acquires and detects conflict', () => {
  // Acquire lock for agent-1
  const res1 = spawnSync('node', [CLI_PATH, 'mesh', 'lock', '--agent', 'test-agent-1', '--paths', 'src/auth.ts', '--task', 'Unit test'], { encoding: 'utf8' });
  assert.strictEqual(res1.status, 0, 'First agent should acquire lock');

  // Attempt conflicting lock for agent-2 on same path
  const res2 = spawnSync('node', [CLI_PATH, 'mesh', 'lock', '--agent', 'test-agent-2', '--paths', 'src/auth.ts', '--task', 'Conflicting task'], { encoding: 'utf8' });
  assert.strictEqual(res2.status, 1, 'Second agent should be rejected with conflict (exit 1)');

  // Release lock
  const res3 = spawnSync('node', [CLI_PATH, 'mesh', 'unlock', '--agent', 'test-agent-1'], { encoding: 'utf8' });
  assert.strictEqual(res3.status, 0, 'Agent-1 lock should release cleanly');
});

console.log(`\nResults: ${passed} passed, ${failed} failed.`);
if (failed > 0) {
  process.exit(1);
} else {
  process.exit(0);
}
