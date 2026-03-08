# HA Development Power v1.0.0 - Initial Release

## Overview

First public release of the Home Assistant Development Power for Kiro IDE. This power provides comprehensive development tools for Home Assistant, enabling seamless file management, template testing, entity queries, and system debugging directly from Kiro.

## Features

### 17 MCP Tools for Home Assistant Development

**File Management (6 tools)**
- `list_configuration_files` - List all config files with metadata
- `read_configuration_file` - Read file contents with pagination
- `validate_yaml_file` - Validate YAML syntax
- `get_file_metadata` - Get file size, permissions, modification time
- `search_configuration_files` - Search files by pattern
- `get_directory_structure` - View directory tree

**Template Testing (4 tools)**
- `render_template` - Render Jinja2 templates with HA context
- `validate_template` - Validate template syntax
- `test_template_with_entities` - Test templates with specific entity states
- `explain_template_error` - Get detailed error explanations

**Entity & State Management (4 tools)**
- `get_entity_state` - Query current entity state
- `list_entities` - List all entities with filtering
- `get_entity_history` - View entity state history
- `search_entities` - Search entities by name or domain

**System Information (3 tools)**
- `get_system_info` - HA version, config path, components
- `get_integration_status` - Check integration health
- `get_logs` - Access Home Assistant logs

### Intelligent Steering Guides

**7 comprehensive guides included:**
- `getting-started.md` - Quick setup and first steps
- `file-management.md` - File operations and workflows
- `template-testing.md` - Template development and debugging
- `debugging.md` - Troubleshooting and diagnostics
- `workflow-patterns.md` - Common development patterns
- `version-management.md` - Managing HA versions and updates
- `local-development.md` - Local development setup

### Auto-Configuration

- Automatically installs and configures the MCP server via uvx
- No manual MCP server setup required
- Seamless integration with Kiro IDE
- Works with both local and remote Home Assistant instances

## Installation

### Via Kiro Powers UI (Recommended)

1. Open Kiro IDE
2. Open the Powers panel (View → Powers)
3. Search for "Home Assistant Development"
4. Click "Install"
5. Activate the power
6. Configure your Home Assistant connection when prompted

### Manual Installation

1. Clone this repository to `~/.kiro/powers/ha-development-power/`
2. Restart Kiro IDE
3. Activate the power from the Powers panel

## Prerequisites

### Required

- **Kiro IDE** - Latest version
- **Home Assistant** - Version 2024.1.0 or later
- **HA Dev Tools Integration** - Must be installed in Home Assistant
  - Install via HACS: https://github.com/alexlenk/ha-dev-tools
- **Python 3.12+** - For MCP server (auto-installed via uvx)

### Optional

- **uvx** - For automatic MCP server installation (recommended)
- **pip** - Alternative installation method for MCP server

## Configuration

The power automatically configures the MCP server. You'll need to provide:

1. **Home Assistant URL** - e.g., `http://homeassistant.local:8123`
2. **Long-Lived Access Token** - Generate in HA Profile → Security

Configuration is stored in Kiro's MCP settings and persists across sessions.

## Quick Start

After installation:

```
1. Activate the power in Kiro
2. Ask: "List my Home Assistant configuration files"
3. Ask: "Show me the contents of configuration.yaml"
4. Ask: "Test this template: {{ states('sensor.temperature') }}"
```

## Example Workflows

### Template Development
```
1. "Render this template with current states: {{ states.sensor }}"
2. "Validate this template syntax: {% for entity in states %}"
3. "Test template with sensor.temperature = 25"
```

### Configuration Management
```
1. "Show me all YAML files in my config"
2. "Read automations.yaml"
3. "Validate the syntax of configuration.yaml"
```

### Debugging
```
1. "Show me the last 50 lines of Home Assistant logs"
2. "What's the status of the ha_dev_tools integration?"
3. "List all entities in the sensor domain"
```

## Related Projects

- **MCP Server**: [ha-dev-tools-mcp](https://github.com/alexlenk/ha-dev-tools-mcp) - The underlying MCP server (auto-installed)
- **HA Integration**: [ha-dev-tools](https://github.com/alexlenk/ha-dev-tools) - Required Home Assistant integration

## Documentation

- [POWER.md](POWER.md) - Complete power documentation
- [Steering Guides](steering/) - Detailed workflow guides
- [README](README.md) - Installation and setup
- [Examples](examples/) - Code snippets and patterns

## Support

- [GitHub Issues](https://github.com/alexlenk/ha-development-power/issues) - Bug reports and feature requests
- [GitHub Discussions](https://github.com/alexlenk/ha-development-power/discussions) - Questions and community support

## License

MIT License - See [LICENSE](LICENSE) for details

## Changelog

### v1.0.0 (2026-03-08)

**Initial Release**

- 17 MCP tools for Home Assistant development
- 7 comprehensive steering guides
- Auto-configuration of MCP server via uvx
- Support for local and remote HA instances
- File management with pagination
- Template testing and validation
- Entity state queries and history
- System information and diagnostics
- Comprehensive documentation
- Example workflows and patterns

## Acknowledgments

Built for the Kiro IDE ecosystem to enhance Home Assistant development workflows.
