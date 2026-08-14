# Claude Code on Termux — Fix for Native Binary Issue

## Working Setup

```bash
# Stop Claude Code from force-migrating to the native binary (which has no Android build)
export DISABLE_AUTOUPDATER=1
echo 'export DISABLE_AUTOUPDATER=1' >> ~/.bashrc
source ~/.bashrc

# Clean out any broken/partial install
npm uninstall -g @anthropic-ai/claude-code
rm -rf ~/.claude ~/.claude.json

# Install the last version that still uses the JS entry point (pre-native-binary switch)
npm install -g @anthropic-ai/claude-code@2.1.112

# Launch
claude
```

## Why It Works

Starting at v2.1.113, Claude Code switched to a native glibc binary with no Android/Termux build, so `npm install -g @anthropic-ai/claude-code` alone fails on Termux. Pinning to `2.1.112` isn't enough by itself, though — Anthropic's backend enforces a minimum version and silently force-updates the client past that pin the moment it connects, which re-breaks it. Setting `DISABLE_AUTOUPDATER=1` *before* first launch stops that forced migration, so it stays on the working JS-based 2.1.112 build.
