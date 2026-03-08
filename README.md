# Home Assistant Development Power

Complete development toolkit for Home Assistant with 17 MCP tools for file access, template testing, entity management, and system information. Eliminates copy/paste friction with direct HA API integration.

## Overview

This Kiro Power provides a comprehensive set of tools for Home Assistant development, enabling you to:

- **Manage Configuration Files**: Read, write, and list HA configuration files remotely
- **Test Templates**: Render and validate Jinja2 templates with entity checking
- **Query Entity States**: Get current and historical state data
- **Call Services**: Control devices and trigger automations
- **Access System Information**: View HA config, services, events, and diagnostics
- **Debug Issues**: Access logs, error logs, and logbook entries
- **Develop Locally**: Download files to your workspace, edit with your IDE, upload with validation

## Features

### 17 MCP Tools Included

**File Access Tools (6)**
- `list_config_files` - List configuration files in your HA instance
- `read_config_file` - Read configuration file content
- `get_file_metadata` - Get file metadata for version tracking
- `batch_get_metadata` - Get metadata for multiple files efficiently
- `write_config_file` - Write configuration files with validation
- `get_logs` - Retrieve HA logs with filtering

**Entity & State Tools (2)**
- `get_states` - Get current entity states
- `get_history` - Get historical state data

**Service & Control Tools (3)**
- `call_service` - Call Home Assistant services
- `render_template` - Render Jinja2 templates with HA context
- `validate_template` - Validate template syntax

**System Information Tools (4)**
- `get_config` - Get HA configuration details
- `list_events` - List available event types
- `list_services` - List available services with schemas
- `get_logbook` - Get logbook entries

**Configuration Tools (1)**
- `check_config` - Validate HA configuration

**Diagnostics Tools (1)**
- `get_error_log` - Retrieve error logs

### Key Capabilities

- **Direct API Integration**: No copy/paste needed - tools interact directly with your HA instance
- **Version Tracking**: Detect file conflicts before uploading changes
- **YAML Validation**: Automatic syntax validation before writing files
- **Entity Validation**: Check entity references in templates
- **Local Development**: Download files, edit locally, upload with safety checks
- **Comprehensive Debugging**: Access logs, errors, and state history

## Installation

### Prerequisites

1. **Python 3.12+** installed on your system
2. **Running Home Assistant instance** (local or remote)
3. **Long-lived access token** from Home Assistant
4. **Kiro IDE** installed

### Step 1: Install the Power

1. Open Kiro IDE
2. Open the Powers panel (Command Palette → "Kiro: Open Powers")
3. Search for "Home Assistant Development"
4. Click "Install"

### Step 2: Configure Home Assistant Connection

You need to provide your Home Assistant URL and access token. There are two methods:

#### Method A: Environment Variables (Recommended)

1. **Create a long-lived access token** in Home Assistant:
   - Go to your HA profile (click your name in sidebar)
   - Scroll to "Long-Lived Access Tokens"
   - Click "Create Token"
   - Name it (e.g., "Kiro MCP Server")
   - Copy the token immediately

2. **Add environment variables** to your shell configuration (`~/.zshrc` or `~/.bashrc`):
   ```bash
   export HA_URL="http://192.168.1.100:8123"
   export HA_TOKEN="your-long-lived-access-token-here"
   ```

3. **Reload your shell**:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

4. **Restart Kiro** to pick up the environment variables

#### Method B: Direct Configuration

1. **Create a long-lived access token** (same as Method A, step 1)

2. **Edit the MCP configuration**:
   - Open `~/.kiro/powers/installed/ha-development-power/mcp.json`
   - Replace the variable references with your actual values:
   ```json
   {
     "mcpServers": {
       "ha-dev-tools": {
         "command": "uvx",
         "args": ["--from", "ha-dev-tools-mcp", "ha-dev-tools-mcp"],
         "env": {
           "HA_URL": "http://192.168.1.100:8123",
           "HA_TOKEN": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
         }
       }
     }
   }
   ```

3. **Reconnect the MCP server** in Kiro

### Step 3: Install Custom Integration (Optional)

The custom integration is required for file access tools. Without it, you'll still have access to 11 official HA API tools (templates, states, services, etc.).

1. **Download the integration**:
   - Clone or download from: https://github.com/username/ha-dev-tools

2. **Copy to Home Assistant**:
   ```bash
   cp -r custom_components/ha_dev_tools /path/to/homeassistant/custom_components/
   ```

3. **Configure in `configuration.yaml`**:
   ```yaml
   ha_dev_tools:
     security:
       allowed_paths:
         - /config/configuration.yaml
         - /config/automations.yaml
         - /config/scripts.yaml
         - /config/packages/*
         - /config/.storage/lovelace*
   ```

4. **Restart Home Assistant**

## Quick Start

### Test the Connection

1. Activate the power in Kiro
2. Try a simple command:
   ```
   Get the state of sun.sun
   ```

3. Kiro will use the `get_states` tool to query your HA instance

### Common Use Cases

**Test a Template:**
```
Test this template: {{ states('sensor.temperature') | float + 5 }}
```

**List Configuration Files:**
```
List my Home Assistant configuration files
```

**Read a Configuration File:**
```
Show me my automations.yaml
```

**Check Entity State:**
```
What's the state of light.living_room?
```

**Turn On a Light:**
```
Turn on light.bedroom with brightness 200
```

## Usage Guide

### When to Use This Power

This power should be used when working with Home Assistant files and entities. Key indicators:

- User mentions "Home Assistant", "HA", or "homeassistant"
- User references HA files (configuration.yaml, automations.yaml, etc.)
- User wants to test templates or check entity states
- User needs to debug automations or scripts

### Tool Selection

**Use MCP tools from this power when:**
- Working with HA configuration files
- Testing Jinja2 templates
- Querying entity states
- Calling HA services
- Accessing HA logs or diagnostics

**Use local file tools when:**
- User explicitly says "local" or "locally"
- Working with non-HA files (package.json, README.md, etc.)
- The file is not part of your HA instance

### Example Workflows

**Workflow 1: Edit Configuration Locally**
1. Download file: "Download my automations.yaml"
2. Edit locally in your IDE
3. Upload with validation: "Upload my edited automations.yaml"
4. Verify: "Check my Home Assistant configuration"

**Workflow 2: Debug a Template**
1. Test template: "Test this template: {{ states('sensor.temp') }}"
2. Check entity: "Get the state of sensor.temp"
3. Fix and retest

**Workflow 3: Investigate Errors**
1. Check errors: "Show me recent Home Assistant errors"
2. Check logs: "Get logs with level ERROR"
3. Check state history: "Get history for light.living_room"

## Documentation

### Steering Files

This power includes comprehensive steering files with detailed workflows:

- **getting-started.md** - Setup and installation guide
- **file-management.md** - Working with configuration files
- **local-development.md** - Local workspace setup and workflows
- **version-management.md** - Version checking and conflict resolution
- **workflow-patterns.md** - Complete development workflow patterns
- **template-testing.md** - Template development and validation
- **debugging.md** - Troubleshooting automations and scripts

### Related Repositories

- **MCP Server**: [ha-dev-tools-mcp](https://github.com/username/ha-dev-tools-mcp) - The Python package that provides the MCP tools
- **HA Integration**: [ha-dev-tools](https://github.com/username/ha-dev-tools) - The custom integration for file access

## Troubleshooting

### Power Won't Activate

**Check environment variables:**
```bash
echo $HA_URL
echo $HA_TOKEN
```

If empty, set them and restart Kiro.

### Connection Errors

**Verify HA is accessible:**
```bash
curl -H "Authorization: Bearer $HA_TOKEN" $HA_URL/api/
```

Should return JSON with "message": "API running."

### File Access Errors (403 Forbidden)

**Check custom integration:**
1. Verify integration is installed in `custom_components/ha_dev_tools/`
2. Check `allowed_paths` in `configuration.yaml`
3. Restart Home Assistant

### Template Errors

**Use validation first:**
```
Validate this template: {{ states('sensor.temp') }}
```

Check for syntax errors before rendering.

## Security

### Access Control

- Only admin users can access the API
- Files must be explicitly allowed in `allowed_paths`
- Sensitive files are automatically blocked
- Write operations include automatic YAML validation
- Rate limiting prevents abuse

### Best Practices

- Use environment variables for tokens (don't commit to git)
- Limit `allowed_paths` to only necessary files
- Use `expected_hash` parameter when uploading to prevent conflicts
- Always validate configuration after making changes
- Keep your access token secure

## Support

### Getting Help

1. Check the steering files for detailed workflows
2. Review the troubleshooting section above
3. Check Home Assistant logs for integration errors
4. Verify environment variables are set correctly
5. Test with simple commands first

### Reporting Issues

If you encounter issues:
1. Check the MCP server logs
2. Check Home Assistant logs
3. Verify your configuration
4. Report issues to the appropriate repository:
   - Power issues: This repository
   - MCP server issues: [ha-dev-tools-mcp](https://github.com/username/ha-dev-tools-mcp)
   - Integration issues: [ha-dev-tools](https://github.com/username/ha-dev-tools)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Acknowledgments

Built for the Kiro IDE ecosystem to enhance Home Assistant development workflows.
