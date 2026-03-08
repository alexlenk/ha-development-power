# Configuration Examples

This directory contains example configurations for the Home Assistant Development Power.

## MCP Server Configuration Examples

### 1. Environment Variables (Recommended)

**File**: `mcp-config-environment-variables.json`

Uses environment variables for HA_URL and HA_TOKEN. This is the recommended approach for security.

**Setup**:
1. Add environment variables to your shell configuration (see `shell-environment-setup.sh`)
2. Use this configuration in your power's mcp.json
3. Restart Kiro to pick up the environment variables

**Advantages**:
- Token not stored in configuration files
- Same variables work across multiple tools
- More secure for shared/version-controlled configs

### 2. Direct Values

**File**: `mcp-config-direct-values.json`

Uses direct values for HA_URL and HA_TOKEN in the configuration file.

**Setup**:
1. Replace the example values with your actual HA URL and token
2. Use this configuration in your power's mcp.json
3. Reconnect the MCP server in Kiro

**Advantages**:
- Works immediately without shell configuration
- No need to restart Kiro
- Simpler for single-use scenarios

**Security Note**: The token is stored in plain text. Keep it secure and don't share or commit this file.

### 3. With Auto-Approve

**File**: `mcp-config-with-auto-approve.json`

Includes auto-approve list for read-only tools to reduce approval prompts.

**Setup**:
1. Configure HA_URL and HA_TOKEN (using environment variables or direct values)
2. Use this configuration to auto-approve safe read-only operations
3. Reconnect the MCP server in Kiro

**Advantages**:
- Reduces approval prompts for safe operations
- Speeds up common workflows
- Still requires approval for write operations

**Tools in auto-approve list**:
- `get_states` - Read entity states
- `get_config` - Read HA configuration
- `list_services` - List available services
- `list_events` - List event types
- `render_template` - Render templates (read-only)
- `validate_template` - Validate templates (read-only)
- `list_config_files` - List files (read-only)
- `read_config_file` - Read files (read-only)
- `get_file_metadata` - Get metadata (read-only)
- `batch_get_metadata` - Get batch metadata (read-only)

## Home Assistant Integration Configuration Examples

### 1. Minimal Configuration

**File**: `ha-integration-config-minimal.yaml`

Minimal configuration with only core configuration files allowed.

**Use when**:
- You only need access to basic configuration files
- You want to minimize security surface area
- You're just getting started

**Allowed files**:
- configuration.yaml
- automations.yaml
- scripts.yaml
- scenes.yaml

### 2. Full Configuration

**File**: `ha-integration-config-full.yaml`

Comprehensive configuration with all common file patterns allowed.

**Use when**:
- You need access to packages, blueprints, and storage files
- You're doing extensive HA development
- You want full file management capabilities

**Allowed files**:
- All core configuration files
- Package-based configuration
- Blueprints and themes
- UI-managed storage files
- Addon configurations
- Custom component configurations

## Shell Environment Setup

**File**: `shell-environment-setup.sh`

Example shell script for setting up environment variables.

**Usage**:
1. Edit the file with your actual HA_URL and HA_TOKEN
2. Add the export commands to your `~/.zshrc` or `~/.bashrc`
3. Reload your shell: `source ~/.zshrc`
4. Restart Kiro to pick up the environment variables

## Creating a Long-Lived Access Token

For all configurations, you need a long-lived access token from Home Assistant:

1. Open Home Assistant
2. Click your profile (bottom left)
3. Scroll to "Long-Lived Access Tokens"
4. Click "Create Token"
5. Name it (e.g., "Kiro MCP Server")
6. Copy the token immediately (you won't see it again!)

## Security Best Practices

1. **Use environment variables** for tokens when possible
2. **Limit allowed_paths** to only necessary files
3. **Don't commit tokens** to version control
4. **Use admin tokens** only (required for API access)
5. **Rotate tokens** periodically
6. **Monitor access logs** in Home Assistant

## Testing Your Configuration

After setting up your configuration:

1. **Test MCP server connection**:
   ```
   Get the state of sun.sun
   ```

2. **Test file access** (requires custom integration):
   ```
   List my Home Assistant configuration files
   ```

3. **Test template rendering**:
   ```
   Test this template: {{ states('sensor.time') }}
   ```

If any of these fail, check:
- Environment variables are set correctly
- HA instance is accessible
- Custom integration is installed (for file access)
- Token has admin privileges

## Troubleshooting

### Environment Variables Not Working

**Check if variables are set**:
```bash
echo $HA_URL
echo $HA_TOKEN
```

If empty, add them to your shell configuration and reload.

### Connection Errors

**Test HA API directly**:
```bash
curl -H "Authorization: Bearer $HA_TOKEN" $HA_URL/api/
```

Should return: `{"message": "API running."}`

### File Access Errors (403)

**Check custom integration**:
1. Verify integration is installed
2. Check allowed_paths in configuration.yaml
3. Restart Home Assistant
4. Verify you're using an admin token

## Additional Resources

- **Power Documentation**: See main README.md
- **MCP Server**: https://github.com/username/ha-dev-tools-mcp
- **HA Integration**: https://github.com/username/ha-dev-tools
- **Steering Files**: See steering/ directory for detailed workflows
