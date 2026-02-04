#!/bin/bash

set -e

echo "claude-vm-sandbox-osx Installation"
echo "==================================="
echo ""

if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script only works on macOS"
    exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
    echo "Warning: Works best on Apple Silicon (M1/M2/M3/M4)"
    read -p "Continue anyway? (y/N) " -r
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

echo "[1/6] Checking container CLI..."
if ! command -v container &> /dev/null; then
    echo "Error: Apple 'container' CLI not found"
    echo ""
    echo "Install from: https://github.com/apple/container/releases"
    echo "Then run: sudo installer -pkg container-installer-signed.pkg -target /"
    echo "          container system start"
    echo "          container system kernel set --recommended"
    exit 1
fi
if ! container system status &> /dev/null 2>&1; then
    echo "Starting container service..."
    container system start
    sleep 2
fi
echo "Container CLI ready"
echo ""

echo "[2/6] Setting up VM configuration..."
VM_CLAUDE_DIR="$HOME/.vm-claude"

if [[ -d "$VM_CLAUDE_DIR" ]]; then
    echo "VM config exists at ~/.vm-claude"
else
    echo "Creating isolated VM config directory at ~/.vm-claude"
    mkdir -p "$VM_CLAUDE_DIR"
fi
echo ""

echo "[3/6] Building container image..."
if container image list 2>/dev/null | grep -q "vmclaude-claude"; then
    read -p "Image exists. Rebuild? (y/N) " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        container build -t vmclaude-claude:latest .
    else
        echo "Using existing image"
    fi
else
    container build -t vmclaude-claude:latest .
fi
echo "Container image ready"
echo ""

echo "[4/6] Installing wrapper scripts..."
mkdir -p ~/.local/bin

cp vmclaude ~/.local/bin/vmclaude-container
chmod +x ~/.local/bin/vmclaude-container
echo "Installed: ~/.local/bin/vmclaude-container"

# Thin wrapper: vmclaude -> vmclaude-container claude
cat > ~/.local/bin/vmclaude <<'WRAPPER'
#!/bin/bash
exec vmclaude-container claude "$@"
WRAPPER
chmod +x ~/.local/bin/vmclaude
echo "Installed: ~/.local/bin/vmclaude"
echo ""

echo "[5/6] Configuring PATH..."
if [[ -n "${ZSH_VERSION:-}" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -n "${BASH_VERSION:-}" ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.zshrc"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo '' >> "$SHELL_RC"
    echo '# Added by claude-vm-sandbox-osx' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    echo "Updated $SHELL_RC"
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "PATH already configured"
fi
echo ""

echo "[6/6] VSCode extension integration (experimental)..."
echo "This replaces the Claude VSCode extension's native binary with our wrapper."
echo "WARNING: This is a work in progress. The Claude VSCode extension will overwrite"
echo "this change when it auto-updates, unless you disable auto-update manually."
read -p "Proceed with VSCode integration? (y/N) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    EXTENSION_BINARY=""
    for dir in "$HOME"/.vscode/extensions/anthropic.claude-code-*-darwin-arm64; do
        candidate="$dir/resources/native-binary/claude"
        if [[ -f "$candidate" ]]; then
            EXTENSION_BINARY="$candidate"
        fi
    done

    if [[ -n "$EXTENSION_BINARY" ]]; then
        if [[ ! -L "$EXTENSION_BINARY" ]]; then
            mv "$EXTENSION_BINARY" "${EXTENSION_BINARY}.bak"
            echo "Backed up original: ${EXTENSION_BINARY}.bak"
        fi
        ln -sf "$HOME/.local/bin/vmclaude" "$EXTENSION_BINARY"
        echo "Symlinked VSCode extension binary to wrapper"
        echo "Note: re-run install.sh after VSCode extension updates"
    else
        echo "VSCode Claude extension not found (skipping)"
        echo "If installed later, re-run install.sh or manually symlink:"
        echo "  ln -sf ~/.local/bin/vmclaude <extension-path>/resources/native-binary/claude"
    fi
else
    echo "Skipped"
fi
echo ""

echo ""
echo "Installation Complete"
echo "===================="
echo ""
echo "Test:  vmclaude --version"
echo ""
echo "Usage:"
echo "  vmclaude                          # Claude in container"
echo "  vmclaude-container claude -c      # Continue last conversation"
echo "  vmclaude-container /bin/bash      # Shell into container"
echo ""
echo "Restart terminal for PATH changes to take effect."
echo ""
