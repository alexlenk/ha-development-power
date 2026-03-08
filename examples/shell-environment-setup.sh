#!/bin/bash
# Shell environment setup for Home Assistant Development Power
# Add these lines to your ~/.zshrc or ~/.bashrc

# Home Assistant connection settings
export HA_URL="http://192.168.1.100:8123"
export HA_TOKEN="your-long-lived-access-token-here"

# Optional: Set Python path if needed
# export PYTHONPATH="/path/to/ha-dev-tools-mcp/src:$PYTHONPATH"

# After adding these lines, reload your shell:
# source ~/.zshrc  # or ~/.bashrc
