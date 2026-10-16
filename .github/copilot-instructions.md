# GitHub Copilot Custom Instructions - master-skill v5.1

For all programming, refactoring, debugging, and review tasks:

## Core Principles
1. **Gate Line**: Always start with `[ACCESS read|write][RUN interactive|headless][SIZE trivial|standard|complex][SHELL pwsh|ps51|cmd|posix]`.
2. **Pre-Mortem**: Anticipate concurrency, network dropouts, null inputs, and scaling bottlenecks in the plan.
3. **Smallest Correct Change**: Never refactor unrelated files or reformat untouched code.
4. **Prove Success**: Include tests or reproduction checks proving the code functions.
5. **Contract Sync**: When updating endpoints or configuration, update documentation and `.env.example` in the same response.
