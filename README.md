# claude-vm-sandbox-osx

Run Claude Code inside an isolated Apple Container VM on macOS.

Your project directory is mounted at `/workspace`. When the process exits, the VM is destroyed and project data is kept.

Supports both API keys and Oauth tokens (eg. Claude Pro subscription).

## Requirements

- [Apple container CLI](https://github.com/apple/container/releases)

## Install

```bash
git clone https://github.com/drez3000/claude-vm-sandbox-osx claude-vm-sandbox-osx
cd claude-vm-sandbox-osx
./install.sh
```

The installer handles everything: container image build, wrapper scripts and PATH setup.

## Usage

```bash
# Claude in an isolated VM
vmclaude
vmclaude -c          # continue last conversation
vmclaude "do stuff"  # start with a prompt

# Run arbitrary commands inside the container
vmclaude-container /bin/bash
vmclaude-container claude # same as running `vmclaude`
```

## How It Works

```
Host macOS
├── ~/.vm-claude/        Mounted as container's /home/claude
│
└── Apple Container (lightweight VM, dedicated kernel)
    ├── /usr/local/bin/claude   Claude Code (native binary)
    ├── /workspace              ← your project directory (mounted)
    ├── /home/claude            ← ~/.vm-claude (mounted)
    └── isolated processes (network egress open)
```

On first run, Claude will prompt for OAuth login inside the container. Credentials are stored in `~/.vm-claude/` (the container's home directory), so they persist across sessions.

NOTE:
Filesystem access is limited to whatever you mount into the machine (by default, it's the current directory `vmclaude` is being invoked from), network access is left open.

## Why Not Docker / Podman Containers?

- **Kernel sharing.** Docker containers on Linux share the host kernel via namespaces and cgroups. On macOS, Docker Desktop runs containers inside a single Linux VM — containers within that VM still share a kernel with each other.
- **Apple Containers use per-container VMs.** Apple's Containerization framework (macOS 26+) gives each container its own lightweight VM with a dedicated kernel. A process escaping the container is still confined to that VM.

## Why Not Just Claude Code's Built-in Sandbox?

Claude Code includes a built-in sandbox on macOS that uses Apple's Seatbelt (`sandbox-exec`). Some differences to consider:

- **Seatbelt is process-level sandboxing**, not virtualization. Claude still runs on the host kernel, shares its filesystem namespace, and operates under your user account. A sandbox profile escape gives direct host access.
- **VM isolation is a stronger boundary.** With Apple Containers, Claude runs inside a separate VM with its own kernel. Even if the process escapes its container, it remains inside the VM.
- **Seatbelt is well-tested and low-overhead.** It's the same technology used by apps distributed through the Mac App Store. It adds negligible performance cost and requires no separate image or service.
- **VM isolation adds operational complexity.** It requires building and maintaining a container image, running the Apple container service, and managing mounted volumes. Debugging is less straightforward when issues occur inside the VM.
- **Seatbelt profiles can be bypassed.** Historically, sandbox escapes have been found in macOS. VM escapes are also possible but are generally considered a higher bar.

## Important Security Considerations

Regardless of whether you use VM isolation, Seatbelt, or any other sandboxing approach:

- **Mounted directories are fully accessible.** The VM has read-write access to whatever directories are mounted into it (by default, the current working directory).
- **Network egress is open.** The container has unrestricted outbound network access.

## License

MIT
