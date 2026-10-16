#!/usr/bin/env node
/**
 * safety-mcp - Zero-Trust Model Context Protocol (MCP) Server
 * Exposes deterministically enforced safety guardrails to AI agents.
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { spawnSync } = require('child_process');

const isWindows = process.platform === 'win32';
const SCRIPT_DIR = path.join(__dirname, '..', 'scripts');

// Available Tools Manifest
const TOOLS = [
  {
    name: 'safety_validate_command',
    description: 'Intercepts and validates a proposed terminal command against the Zero-Destruction Wall and Secret Scanner before execution.',
    inputSchema: {
      type: 'object',
      properties: {
        command: { type: 'string', description: 'The terminal command string to validate.' }
      },
      required: ['command']
    }
  },
  {
    name: 'safety_init_contract',
    description: 'Initializes a formal Task Contract (ct-contract.json) establishing invariant boundaries before writing code.',
    inputSchema: {
      type: 'object',
      properties: {
        objective: { type: 'string', description: 'Summary of the task goal.' },
        permitted_paths: { type: 'array', items: { type: 'string' }, description: 'Glob paths the agent is allowed to edit.' },
        forbidden_paths: { type: 'array', items: { type: 'string' }, description: 'Glob paths strictly off-limits.' },
        stop_gate_command: { type: 'string', description: 'Test command that must exit 0 before completion.' }
      },
      required: ['objective', 'permitted_paths']
    }
  },
  {
    name: 'safety_verify_gate',
    description: 'Executes the Programmatic Stop Gate, verifying 0 DEBUG-CT leftovers, 0 secrets, contract boundaries, and test suite passage.',
    inputSchema: {
      type: 'object',
      properties: {
        test_command: { type: 'string', description: 'Optional custom test command to execute.' },
        contract_path: { type: 'string', description: 'Optional path to ct-contract.json.' }
      }
    }
  },
  {
    name: 'safety_mesh_lock',
    description: 'Acquires a decentralized lock on specified paths to prevent collisions with other concurrent agents.',
    inputSchema: {
      type: 'object',
      properties: {
        agent_id: { type: 'string', description: 'Identifier of the requesting agent (e.g. cursor, claude-code).' },
        paths: { type: 'array', items: { type: 'string' }, description: 'Files or globs to lock.' },
        task: { type: 'string', description: 'Short summary of the work being done.' },
        ttl_seconds: { type: 'number', description: 'Lock duration in seconds (default 1800).' }
      },
      required: ['agent_id', 'paths']
    }
  },
  {
    name: 'safety_mesh_unlock',
    description: 'Releases previously acquired mesh locks for this agent.',
    inputSchema: {
      type: 'object',
      properties: {
        agent_id: { type: 'string', description: 'Identifier of the agent.' },
        paths: { type: 'array', items: { type: 'string' }, description: 'Optional specific paths to unlock.' }
      },
      required: ['agent_id']
    }
  },
  {
    name: 'safety_mesh_status',
    description: 'Lists all currently active multi-agent mesh locks across the repository.',
    inputSchema: {
      type: 'object',
      properties: {}
    }
  },
  {
    name: 'safety_scorecard',
    description: 'Returns git diff statistics, line additions/deletions, untracked count, and verification metrics.',
    inputSchema: {
      type: 'object',
      properties: {}
    }
  }
];

// Tool Executors
function handleValidateCommand(args) {
  const cmd = (args.command || '').trim();
  const forbiddenPatterns = [
    { regex: /git\s+reset\s+--hard/i, reason: 'Destructive git reset --hard discards uncommitted history' },
    { regex: /git\s+clean\s+-[a-zA-Z]*f/i, reason: 'Destructive git clean removes untracked files' },
    { regex: /git\s+(checkout|restore|switch)\s+(-f|--force|\.)/i, reason: 'Forced checkout discards working tree changes' },
    { regex: /git\s+push\s+.*--force/i, reason: 'Force-push overwrites remote git history' },
    { regex: /git\s+stash(\s+drop|\s+clear)?/i, reason: 'Stashing or dropping changes can destroy user work' },
    { regex: /(rm\s+-rf\s+\/|Remove-Item\s+-Recurse\s+-Force\s+C:\\)/i, reason: 'Root destructive deletion forbidden' },
    { regex: /\b(DROP\s+DATABASE|DROP\s+TABLE|TRUNCATE\s+TABLE)\b/i, reason: 'Irreversible database destruction' }
  ];

  for (const rule of forbiddenPatterns) {
    if (rule.regex.test(cmd)) {
      return {
        isError: true,
        text: JSON.stringify({ status: 'BLOCKED', policy: 'ZERO_DESTRUCTION_WALL', reason: rule.reason, command: cmd }, null, 2)
      };
    }
  }

  const secretRegex = /(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{82}|sk-[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9\-_]{20,}|AIza[0-9A-Za-z-_]{35}|AKIA[0-9A-Z]{16})/;
  if (secretRegex.test(cmd)) {
    return {
      isError: true,
      text: JSON.stringify({ status: 'BLOCKED', policy: 'SECRET_SCANNER', reason: 'Plaintext secret/token detected in command', command: cmd.replace(secretRegex, '***') }, null, 2)
    };
  }

  return { isError: false, text: JSON.stringify({ status: 'ALLOWED', command: cmd }) };
}

function handleInitContract(args) {
  const contract = {
    task_id: `CT-${Date.now()}`,
    objective: args.objective || 'Task execution',
    invariants: [
      'Additive changes only; no breaking public contracts',
      'Zero swallowed catch blocks or unhandled errors',
      'All pre-existing green tests remain green',
      'Zero secrets committed'
    ],
    permitted_paths: args.permitted_paths || ['src/**', 'tests/**'],
    forbidden_paths: args.forbidden_paths || ['.env*', 'config/secrets/**', 'package-lock.json'],
    stop_gate_command: args.stop_gate_command || 'npm test'
  };

  const targetPath = path.join(process.cwd(), 'ct-contract.json');
  fs.writeFileSync(targetPath, JSON.stringify(contract, null, 2), 'utf8');
  return { isError: false, text: JSON.stringify({ status: 'CREATED', contract_path: targetPath, contract }, null, 2) };
}

function handleVerifyGate(args) {
  const scriptPath = isWindows
    ? path.join(SCRIPT_DIR, 'stop_gate.ps1')
    : path.join(SCRIPT_DIR, 'stop_gate.sh');

  const cmdArgs = isWindows
    ? ['-ExecutionPolicy', 'Bypass', '-File', scriptPath]
    : [scriptPath];

  if (args.test_command) {
    if (isWindows) cmdArgs.push('-TestCommand', args.test_command);
    else cmdArgs.push(args.test_command);
  }
  if (args.contract_path) {
    if (isWindows) cmdArgs.push('-ContractPath', args.contract_path);
    else cmdArgs.push(args.contract_path);
  }

  const child = isWindows
    ? spawnSync('powershell', cmdArgs, { encoding: 'utf8' })
    : spawnSync('bash', cmdArgs, { encoding: 'utf8' });

  const exitCode = child.status || 0;
  return {
    isError: exitCode !== 0,
    text: child.stdout || child.stderr || `Stop gate exited with code ${exitCode}`
  };
}

function handleMesh(action, args) {
  const scriptPath = isWindows
    ? path.join(SCRIPT_DIR, 'mesh_lock.ps1')
    : path.join(SCRIPT_DIR, 'mesh_lock.sh');

  const cmdArgs = isWindows
    ? ['-ExecutionPolicy', 'Bypass', '-File', scriptPath, '-Action', action]
    : [scriptPath, action];

  if (args.agent_id) {
    if (isWindows) cmdArgs.push('-AgentId', args.agent_id);
    else cmdArgs.push(args.agent_id);
  } else if (!isWindows) cmdArgs.push('');

  if (args.paths && args.paths.length) {
    const pStr = args.paths.join(',');
    if (isWindows) cmdArgs.push('-Paths', pStr);
    else cmdArgs.push(pStr);
  } else if (!isWindows) cmdArgs.push('');

  if (args.task) {
    if (isWindows) cmdArgs.push('-Task', args.task);
    else cmdArgs.push(args.task);
  } else if (!isWindows) cmdArgs.push('');

  if (args.ttl_seconds) {
    if (isWindows) cmdArgs.push('-TtlSeconds', args.ttl_seconds.toString());
    else cmdArgs.push(args.ttl_seconds.toString());
  }

  const child = isWindows
    ? spawnSync('powershell', cmdArgs, { encoding: 'utf8' })
    : spawnSync('bash', cmdArgs, { encoding: 'utf8' });

  return {
    isError: (child.status || 0) !== 0,
    text: child.stdout || child.stderr || `Mesh lock exited with code ${child.status}`
  };
}

function handleScorecard() {
  const scriptPath = isWindows
    ? path.join(SCRIPT_DIR, 'scorecard.ps1')
    : path.join(SCRIPT_DIR, 'scorecard.sh');

  const child = isWindows
    ? spawnSync('powershell', ['-ExecutionPolicy', 'Bypass', '-File', scriptPath], { encoding: 'utf8' })
    : spawnSync('bash', [scriptPath], { encoding: 'utf8' });

  return {
    isError: false,
    text: child.stdout || '{}'
  };
}

// JSON-RPC stdio Transport Loop
const rl = readline.createInterface({ input: process.stdin, output: process.stdout, terminal: false });

rl.on('line', (line) => {
  if (!line || !line.trim()) return;
  let request;
  try {
    request = JSON.parse(line.trim());
  } catch (err) {
    return;
  }

  const { id, method, params } = request;

  if (method === 'initialize') {
    sendResponse(id, {
      protocolVersion: '2024-11-05',
      capabilities: { tools: {} },
      serverInfo: { name: 'safety-mcp', version: '5.2.0' }
    });
  } else if (method === 'notifications/initialized') {
    // Ack, no response needed
  } else if (method === 'tools/list') {
    sendResponse(id, { tools: TOOLS });
  } else if (method === 'tools/call') {
    const toolName = params && params.name;
    const toolArgs = (params && params.arguments) || {};
    let result;

    switch (toolName) {
      case 'safety_validate_command':
        result = handleValidateCommand(toolArgs);
        break;
      case 'safety_init_contract':
        result = handleInitContract(toolArgs);
        break;
      case 'safety_verify_gate':
        result = handleVerifyGate(toolArgs);
        break;
      case 'safety_mesh_lock':
        result = handleMesh('acquire', toolArgs);
        break;
      case 'safety_mesh_unlock':
        result = handleMesh('release', toolArgs);
        break;
      case 'safety_mesh_status':
        result = handleMesh('status', toolArgs);
        break;
      case 'safety_scorecard':
        result = handleScorecard();
        break;
      default:
        result = { isError: true, text: `Unknown tool: ${toolName}` };
        break;
    }

    sendResponse(id, {
      content: [{ type: 'text', text: result.text }],
      isError: result.isError
    });
  } else {
    sendResponse(id, null, { code: -32601, message: `Method not found: ${method}` });
  }
});

function sendResponse(id, result, error) {
  if (id === undefined || id === null) return;
  const resp = { jsonrpc: '2.0', id };
  if (error) resp.error = error;
  else resp.result = result;
  process.stdout.write(JSON.stringify(resp) + '\n');
}
