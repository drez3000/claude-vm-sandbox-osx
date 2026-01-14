# macSandbox

Run Claude Code with `--dangerously-skip-permissions` inside an isolated VM - built by Claude itself.

## The Story

I wanted Claude to have full autonomy but didn't want it nuking my system. So I asked Claude to solve the problem by building its own cage.

Claude researched Apple's new Containerization framework (WWDC 2025), checked my system specs, installed the tooling, built a container image, wrote a wrapper script, and tested everything. I just approved a few `sudo` commands.

**Total time:** ~15 minutes of conversation.

## What You Get

```bash
claude                    # normal Claude (unchanged)
cldyo                     # Claude in isolated VM with --dangerously-skip-permissions
cldyo -n 4                # 4 parallel Claude instances in separate VMs
```

Each instance runs in its own lightweight VM. Your project directory is mounted at `/workspace`. Claude can do whatever it wants inside - when it exits, the VM is destroyed.

## Requirements

- macOS 26+ (Tahoe)
- Apple Silicon (M1/M2/M3/M4)
- [Apple container CLI](https://github.com/apple/container/releases)

## Installation

### 1. Install Apple's container CLI

```bash
# Download the latest .pkg from:
# https://github.com/apple/container/releases

sudo installer -pkg container-installer-signed.pkg -target /
container system start
container system kernel set --recommended
```

### 2. Build the Claude container image

```bash
cd macSandbox
container build -t cldyo-claude:latest .
```

### 3. Install the wrapper script

```bash
cp cldyo ~/.local/bin/
chmod +x ~/.local/bin/cldyo
```

## Usage

```bash
# Start Claude with dangerous permissions in isolated VM
cldyo

# Continue last conversation
cldyo -c

# Start with a prompt
cldyo "refactor this entire codebase"

# Spawn 4 parallel instances (opens Terminal windows)
cldyo -n 4
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ANTHROPIC_API_KEY` | (required) | Passed through to container |
| `CLDYO_MEMORY` | `4G` | Memory limit per instance |
| `CLDYO_CPUS` | `2` | CPU cores per instance |

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│  Host macOS                                             │
│                                                         │
│  ┌─────────────┐                                        │
│  │   claude    │  ← Normal, your existing setup         │
│  └─────────────┘                                        │
│                                                         │
│  ┌─────────────────────────────────────────────────────┐│
│  │  cldyo  →  Apple Container (Lightweight VM)         ││
│  │  ┌─────────────────────────────────────────────────┐││
│  │  │  Linux VM (dedicated kernel)                    │││
│  │  │  • claude --dangerously-skip-permissions        │││
│  │  │  • /workspace ← your project (mounted)          │││
│  │  │  • Isolated network, filesystem, processes      │││
│  │  └─────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

## Why Apple Containers vs Docker?

| Feature | Docker | Apple Containers |
|---------|--------|------------------|
| Isolation | Shared kernel (namespaces) | **Dedicated VM per container** |
| Startup | Fast | **Sub-second** |
| License | Commercial use requires license | **Free** |
| Native | Requires Docker Desktop | **Built into macOS 26** |

Apple's approach gives each container its own lightweight VM with a dedicated kernel. Even if Claude escapes the container, it's still trapped in a VM.

## Multi-Instance Use Cases

With 64GB RAM, you can run 8+ parallel Claude instances:

- **Parallel development** - Multiple features simultaneously
- **A/B testing** - Compare different approaches
- **Agent swarm** - Multiple agents on different tasks
- **Code review** - One instance writes, another reviews

## The Meta Part

Claude built this entire solution:
1. Researched Apple's Virtualization documentation
2. Discovered the new Containerization framework
3. Assessed system requirements
4. Installed dependencies
5. Wrote all the code
6. Tested the setup

It essentially built its own sandbox for running with elevated permissions.

## Files

- `Containerfile` - Container image definition
- `cldyo` - Wrapper script for transparent VM execution

## License

MIT

---

*Built by Claude, for Claude, with human supervision.*
