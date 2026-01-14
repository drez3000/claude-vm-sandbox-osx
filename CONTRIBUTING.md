# Contributing to macSandbox

Thanks for your interest in contributing to macSandbox!

## How to Contribute

### Reporting Issues

- Check existing issues first to avoid duplicates
- Include your macOS version, Apple Silicon chip, and container CLI version
- Provide steps to reproduce the problem
- Include relevant error messages or logs

### Suggesting Features

- Open an issue describing the feature
- Explain the use case and why it would be valuable
- Be open to discussion about implementation approaches

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Test thoroughly on macOS 26+ with Apple Silicon
5. Commit with clear messages
6. Push to your fork
7. Open a Pull Request

### Code Style

- Shell scripts: Use `shellcheck` for linting
- Keep it simple - this is a thin wrapper, not a framework
- Comment non-obvious logic
- Test on a clean system if possible

### What We're Looking For

- Bug fixes
- Documentation improvements
- Performance optimizations
- Support for additional use cases
- Better error handling and messages

### What We're Not Looking For

- Features that add significant complexity
- Support for non-Apple virtualization (Docker, etc.)
- Breaking changes to the simple `cldyo` interface

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/macSandbox.git
cd macSandbox

# Build the container image
container build -t cldyo-claude:latest .

# Test the wrapper
./cldyo --help
```

## Questions?

Open an issue with the "question" label.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
