# Security Policy

## Purpose

claude-vm-sandbox-osx is designed to provide isolation when running Claude Code with elevated permissions. Security is fundamental to this project.

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please:

1. **Do not** open a public issue
2. Email the maintainer directly or use GitHub's private vulnerability reporting
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Security Model

claude-vm-sandbox-osx relies on:

- **Apple's Containerization framework** - Each container runs in a dedicated lightweight VM
- **Kernel isolation** - Separate kernel per container
- **Filesystem isolation** - Only mounted directories are accessible
- **Network isolation** - Containers have isolated network stacks

### What claude-vm-sandbox-osx Protects Against

- Accidental file deletion on host
- Runaway processes affecting host system
- Unintended system modifications

### What claude-vm-sandbox-osx Does NOT Protect Against

- Malicious modification of mounted directories (by design, `/workspace` is read-write)
- Exfiltration of data from mounted directories
- Vulnerabilities in Apple's Virtualization framework itself

## Best Practices

1. Only mount directories you intend Claude to access
2. Review Claude's actions in the mounted workspace
3. Keep your macOS and container CLI updated
4. Don't mount sensitive directories like `~/.ssh` or `~/.aws`
