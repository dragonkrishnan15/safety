#!/usr/bin/env node
/**
 * safety - Zero-Trust AI Agent Safety & Verification Engine CLI
 * Part of @dragonkrishnan15/safety
 */

const fs = require('fs');
const path = require('path');
const { execSync, spawnSync } = require('child_process');
const os = require('os');

const args = process.argv.slice(2);
const command = args[0] || 'help';

function printHelp() {
  console.log(`
🛡️  safety CLI (v5.2 Apex Zero-Trust Edition)

Usage:
  safety <command> [options]

Commands:
  gate              Execute pre-commit stop gate verification
  intercept <cmd>   Validate a command against zero-destruction policies
  contract init     Initialize a formal Task Contract (<tmp>/ct-contract.json)
  mesh <action>     Manage multi-agent lock arbitration (lock|unlock|status|clean)
  report            Generate audit scorecard from git status and diff
  version           Print safety engine version
  help              Display this help message

Examples:
  safety gate --test "npm test"
  safety intercept "git reset --hard HEAD"
  safety contract init --permitted "src/**,tests/**" --forbidden ".env*"
  safety mesh lock --agent "cursor" --paths "src/api/**" --task "Auth overhaul"
  safety mesh status
`);
}

// 1. Interceptor: Zero-Destruction Wall
function interceptCommand(cmdParts) {
  const fullCmd = cmdParts.join(' ').trim();
  if (!fullCmd) {
    console.error('Error: No command provided to intercept.');
    process.exit(1);
  }

  const forbiddenPatterns = [
    { regex: /git\s+reset\s+--hard/i, reason: 'Destructive git reset --hard discards uncommitted history' },
    { regex: /git\s+clean\s+-[a-zA-Z]*f/i, reason: 'Destructive git clean removes untracked files without recourse' },
    { regex: /git\s+(checkout|restore|switch)\s+(-f|--force|\.)/i, reason: 'Forced checkout or "." discards working tree changes' },
    { regex: /git\s+push\s+.*--force/i, reason: 'Force-push overwrites remote git history' },
    { regex: /git\s+stash(\s+drop|\s+clear)?/i, reason: 'Stashing or dropping changes can destroy user work' },
    { regex: /(rm\s+-rf\s+\/|Remove-Item\s+-Recurse\s+-Force\s+C:\\)/i, reason: 'Root destructive deletion forbidden' },
    { regex: /\b(DROP\s+DATABASE|DROP\s+TABLE|TRUNCATE\s+TABLE)\b/i, reason: 'Unsandboxed irreversible SQL destruction' }
  ];

  for (const rule of forbiddenPatterns) {
    if (rule.regex.test(fullCmd)) {
      console.error(JSON.stringify({
        status: 'BLOCKED',
        decision: 'DENIED',
        policy: 'ZERO_DESTRUCTION_WALL',
        reason: rule.reason,
        command: fullCmd
      }, null, 2));
      process.exit(1);
    }
  }

  // Secret scanner in command arguments
  const secretRegex = /(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{82}|sk-[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9\-_]{20,}|AIza[0-9A-Za-z-_]{35}|AKIA[0-9A-Z]{16})/;
  if (secretRegex.test(fullCmd)) {
    console.error(JSON.stringify({
      status: 'BLOCKED',
      decision: 'DENIED',
      policy: 'SECRET_SCANNER',
      reason: 'Detected potential plaintext API key or credential in command parameters',
      command: fullCmd.replace(secretRegex, '***REDACTED***')
    }, null, 2));
    process.exit(1);
  }

  console.log(JSON.stringify({
    status: 'ALLOWED',
    decision: 'PERMITTED',
    command: fullCmd
  }));
  process.exit(0);
}

// 2. Stop Gate Execution
function runStopGate(gateArgs) {
  let testCmd = '';
  let contractPath = '';

  for (let i = 0; i < gateArgs.length; i++) {
    if (gateArgs[i] === '--test' && gateArgs[i + 1]) {
      testCmd = gateArgs[i + 1];
      i++;
    } else if (gateArgs[i] === '--contract' && gateArgs[i + 1]) {
      contractPath = gateArgs[i + 1];
      i++;
    }
  }

  const isWindows = process.platform === 'win32';
  const scriptPath = isWindows
    ? path.join(__dirname, '..', 'scripts', 'stop_gate.ps1')
    : path.join(__dirname, '..', 'scripts', 'stop_gate.sh');

  let child;
  if (isWindows) {
    const cmdArgs = ['-ExecutionPolicy', 'Bypass', '-File', scriptPath];
    if (testCmd) { cmdArgs.push('-TestCommand', testCmd); }
    if (contractPath) { cmdArgs.push('-ContractPath', contractPath); }
    child = spawnSync('powershell', cmdArgs, { stdio: 'inherit' });
  } else {
    const cmdArgs = [scriptPath];
    if (testCmd) cmdArgs.push(testCmd);
    if (contractPath) cmdArgs.push(contractPath);
    child = spawnSync('bash', cmdArgs, { stdio: 'inherit' });
  }

  process.exit(child.status || 0);
}

// 3. Task Contract Initialization
function initContract(subArgs) {
  let permitted = ['src/**', 'tests/**'];
  let forbidden = ['.env*', 'config/secrets/**', 'package-lock.json'];
  let stopGateCmd = 'npm test';

  for (let i = 0; i < subArgs.length; i++) {
    if (subArgs[i] === '--permitted' && subArgs[i + 1]) {
      permitted = subArgs[i + 1].split(',').map(s => s.trim());
      i++;
    } else if (subArgs[i] === '--forbidden' && subArgs[i + 1]) {
      forbidden = subArgs[i + 1].split(',').map(s => s.trim());
      i++;
    } else if (subArgs[i] === '--test' && subArgs[i + 1]) {
      stopGateCmd = subArgs[i + 1];
      i++;
    }
  }

  const contractObj = {
    task_id: `CT-${new Date().toISOString().slice(0, 10).replace(/-/g, '')}-01`,
    created_at: new Date().toISOString(),
    invariants: [
      'Additive API changes only; no breaking signature changes',
      'Zero unhandled errors or swallowed catch blocks',
      'All pre-existing green tests must remain green',
      'Zero sensitive secrets or tokens committed'
    ],
    permitted_paths: permitted,
    forbidden_paths: forbidden,
    stop_gate_command: stopGateCmd
  };

  const targetPath = path.join(process.cwd(), 'ct-contract.json');
  fs.writeFileSync(targetPath, JSON.stringify(contractObj, null, 2), 'utf8');
  console.log(`[OK] Task Contract initialized at: ${targetPath}`);
  console.log(JSON.stringify(contractObj, null, 2));
}

// 4. Automated Workspace Onboarding Wizard
function runSetup(subArgs) {
  console.log('\n🚀 Initializing SAFETY Governance for Workspace...\n');
  const cwd = process.cwd();
  const adaptersDir = path.join(__dirname, '..', 'adapters');
  let installedAdapters = [];

  // Antigravity / Gemini
  const agyRulesDir = path.join(cwd, '.agents', 'rules');
  const agySkillDir = path.join(cwd, '.agents', 'skills', 'master-skill');
  if (fs.existsSync(path.join(cwd, '.agents')) || fs.existsSync(path.join(cwd, '.gemini'))) {
    fs.mkdirSync(agyRulesDir, { recursive: true });
    fs.copyFileSync(path.join(__dirname, '..', 'master-skill.md'), path.join(agyRulesDir, 'master-skill.md'));
    fs.mkdirSync(agySkillDir, { recursive: true });
    fs.copyFileSync(path.join(__dirname, '..', 'SKILL.md'), path.join(agySkillDir, 'SKILL.md'));
    installedAdapters.push('Google Antigravity / Gemini CLI (.agents/rules/master-skill.md)');
  }

  // Cursor
  if (fs.existsSync(path.join(cwd, '.cursor')) || fs.existsSync(path.join(cwd, '.cursorrules'))) {
    fs.copyFileSync(path.join(adaptersDir, '.cursorrules'), path.join(cwd, '.cursorrules'));
    installedAdapters.push('Cursor IDE (.cursorrules)');
  }

  // Windsurf
  if (fs.existsSync(path.join(cwd, '.windsurf')) || fs.existsSync(path.join(cwd, '.windsurfrules'))) {
    fs.copyFileSync(path.join(adaptersDir, '.windsurfrules'), path.join(cwd, '.windsurfrules'));
    installedAdapters.push('Windsurf IDE (.windsurfrules)');
  }

  // Claude Code
  if (fs.existsSync(path.join(cwd, '.claude')) || fs.existsSync(path.join(cwd, 'CLAUDE.md'))) {
    fs.copyFileSync(path.join(adaptersDir, 'CLAUDE.md'), path.join(cwd, 'CLAUDE.md'));
    installedAdapters.push('Claude Code (CLAUDE.md)');
  }

  // Fallback: Universal AGENTS.md
  if (installedAdapters.length === 0) {
    fs.copyFileSync(path.join(adaptersDir, 'AGENTS.md'), path.join(cwd, 'AGENTS.md'));
    installedAdapters.push('Universal Agent Spec (AGENTS.md)');
  }

  // Git Pre-Commit Hook
  const gitDir = path.join(cwd, '.git');
  let hookInstalled = false;
  if (fs.existsSync(gitDir)) {
    const hooksDir = path.join(gitDir, 'hooks');
    fs.mkdirSync(hooksDir, { recursive: true });
    const hookFile = path.join(hooksDir, 'pre-commit');
    const hookScript = `#!/bin/sh\n# safety pre-commit quality gate\nif command -v node >/dev/null 2>&1; then\n  node "${path.join(__dirname, 'safety.js').replace(/\\/g, '/')}" gate\n  exit $?\nfi\nexit 0\n`;
    fs.writeFileSync(hookFile, hookScript, { mode: 0o755 });
    hookInstalled = true;
  }

  // Initialize ct-contract.json if not present
  const contractPath = path.join(cwd, 'ct-contract.json');
  if (!fs.existsSync(contractPath)) {
    initContract(subArgs);
  }

  console.log('✅ Installed Adapters:');
  installedAdapters.forEach(a => console.log(`   - ${a}`));
  if (hookInstalled) {
    console.log('✅ Git Pre-Commit Quality Gate installed (.git/hooks/pre-commit)');
  }
  console.log('\n🛡️  SAFETY setup is complete! Run "safety gate" anytime to verify your invariants.\n');
}

// 4. Mesh Lock CLI Integration
function runMesh(subArgs) {
  const isWindows = process.platform === 'win32';
  const scriptPath = isWindows
    ? path.join(__dirname, '..', 'scripts', 'mesh_lock.ps1')
    : path.join(__dirname, '..', 'scripts', 'mesh_lock.sh');

  const action = subArgs[0] || 'status';
  let agent = '';
  let paths = [];
  let task = '';
  let ttl = 1800;

  for (let i = 1; i < subArgs.length; i++) {
    if ((subArgs[i] === '--agent' || subArgs[i] === '-a') && subArgs[i + 1]) {
      agent = subArgs[i + 1];
      i++;
    } else if ((subArgs[i] === '--paths' || subArgs[i] === '-p') && subArgs[i + 1]) {
      paths = subArgs[i + 1].split(',').map(s => s.trim());
      i++;
    } else if ((subArgs[i] === '--task' || subArgs[i] === '-t') && subArgs[i + 1]) {
      task = subArgs[i + 1];
      i++;
    } else if (subArgs[i] === '--ttl' && subArgs[i + 1]) {
      ttl = parseInt(subArgs[i + 1], 10);
      i++;
    }
  }

  let child;
  if (isWindows) {
    const cmdArgs = ['-ExecutionPolicy', 'Bypass', '-File', scriptPath, '-Action', action === 'lock' ? 'acquire' : (action === 'unlock' ? 'release' : action)];
    if (agent) cmdArgs.push('-AgentId', agent);
    if (paths.length) cmdArgs.push('-Paths', paths.join(','));
    if (task) cmdArgs.push('-Task', task);
    if (ttl) cmdArgs.push('-TtlSeconds', ttl.toString());
    child = spawnSync('powershell', cmdArgs, { stdio: 'inherit' });
  } else {
    const cmdArgs = [
      scriptPath,
      action === 'lock' ? 'acquire' : (action === 'unlock' ? 'release' : action),
      agent,
      paths.join(','),
      task,
      ttl.toString()
    ];
    child = spawnSync('bash', cmdArgs, { stdio: 'inherit' });
  }

  process.exit(child.status || 0);
}

// 5. Scorecard / Report
function runReport() {
  const isWindows = process.platform === 'win32';
  const scriptPath = isWindows
    ? path.join(__dirname, '..', 'scripts', 'scorecard.ps1')
    : path.join(__dirname, '..', 'scripts', 'scorecard.sh');

  let child;
  if (isWindows) {
    child = spawnSync('powershell', ['-ExecutionPolicy', 'Bypass', '-File', scriptPath], { encoding: 'utf8' });
  } else {
    child = spawnSync('bash', [scriptPath], { encoding: 'utf8' });
  }

  if (child.stdout) {
    try {
      const data = JSON.parse(child.stdout.trim());
      console.log('\n📊 SAFETY DIFF SCORECARD');
      console.log('====================================');
      console.log(`Files Changed:     ${data.files_changed}`);
      console.log(`Lines Added:       ${data.lines_added}`);
      console.log(`Lines Deleted:     ${data.lines_deleted}`);
      console.log(`Net Change:        ${data.net_change}`);
      console.log(`DEBUG-CT Leftover: ${data.debug_ct_count}`);
      console.log(`Untracked Files:   ${data.untracked_files}`);
      console.log('====================================\n');
    } catch {
      console.log(child.stdout);
    }
  }
}

switch (command) {
  case 'init':
  case 'setup':
    runSetup(args.slice(1));
    break;
  case 'gate':
  case 'stop-gate':
    runStopGate(args.slice(1));
    break;
  case 'intercept':
    interceptCommand(args.slice(1));
    break;
  case 'contract':
    if (args[1] === 'init') {
      initContract(args.slice(2));
    } else {
      console.log('Unknown contract command. Use: safety contract init');
    }
    break;
  case 'mesh':
    runMesh(args.slice(1));
    break;
  case 'report':
  case 'scorecard':
    runReport();
    break;
  case 'version':
  case '-v':
  case '--version':
    console.log('@dragonkrishnan15/safety v5.2.0');
    break;
  case 'help':
  default:
    printHelp();
    break;
}
