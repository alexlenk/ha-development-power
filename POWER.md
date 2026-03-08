---
name: "home-assistant-development"
displayName: "Home Assistant Development"
description: "Complete development toolkit for Home Assistant with 17 MCP tools for file access, template testing, entity management, and system information. Eliminates copy/paste friction with direct HA API integration."
keywords: ["home-assistant", "ha", "homeassistant", "hass", "templates", "jinja2", "automation", "smart-home", "development", "testing", "debugging", "configuration.yaml", "automations.yaml", "scripts.yaml", "packages", "configuration", "integration", "entity", "state", "service"]
author: "Alex Lenk"
---

# Home Assistant Development

## Overview

Complete development toolkit for Home Assistant with 17 MCP tools providing file access, template testing, entity management, and system information. Eliminates copy/paste friction by enabling direct interaction with your HA instance through authenticated API calls.

This power combines:
- **File Management**: Read/write configuration files, list directories, access logs, track file versions
- **Template Testing**: Render and validate Jinja2 templates with entity checking
- **Entity Management**: Query states, history, and validate entity references
- **System Information**: Access HA config, services, events, and diagnostics
- **Local Development**: Download files to local workspace, edit with IDE, upload with validation
- **Version Management**: Detect conflicts, compare versions, prevent data loss

Perfect for HA developers who want to:
- Test templates without restarting HA
- Debug automations and scripts
- Validate entity references
- Access configuration files programmatically
- Query system state and history
- Edit files locally with full IDE support
- Track file versions and prevent conflicts

## When to Use This Power

**IMPORTANT: This power provides remote access to your Home Assistant instance. Use the MCP tools from this power when working with Home Assistant files, NOT local file tools.**

### ✅ Use This Power's MCP Tools When:

**Home Assistant Context Indicators:**
- User mentions "Home Assistant", "HA", or "homeassistant" in their request
- User discusses HA configuration, automations, scripts, or integrations
- User references HA-specific concepts (entities, services, templates, dashboards)

**Home Assistant File Patterns:**
- `configuration.yaml` - Main HA configuration
- `automations.yaml` - Automation definitions
- `scripts.yaml` - Script definitions
- `scenes.yaml` - Scene definitions
- `packages/*.yaml` - Package-based configuration
- `.storage/lovelace*` - Dashboard configuration
- `.storage/automation`, `.storage/script` - UI-managed entities
- Any file in `/config/` directory on the HA instance

**Decision Tree for Tool Selection:**

```
User Request
    │
    ├─ Mentions "Home Assistant" + File? ──> YES ──> Use read_config_file (MCP tool)
    │                                                  NOT readFile (local tool)
    │
    ├─ Mentions HA file pattern? ──────────> YES ──> Use read_config_file (MCP tool)
    │  (configuration.yaml, automations.yaml)         NOT readFile (local tool)
    │
    ├─ Says "local" or "locally"? ─────────> YES ──> Use readFile (local tool)
    │                                                  Honor explicit local request
    │
    └─ Non-HA file? ───────────────────────> YES ──> Use readFile (local tool)
       (package.json, README.md, etc.)                Standard file operations
```

### ❌ Do NOT Use This Power's MCP Tools When:

- User explicitly requests "local" file operations (e.g., "read the local configuration.yaml")
- Working with non-HA files in the project (e.g., package.json, README.md, source code)
- The ha-development-power is not installed or configured
- HA_URL and HA_TOKEN environment variables are not set

### 🎯 Key Tool Selection Rules:

1. **Home Assistant + File = MCP Tools**
   - "Show me my Home Assistant configuration.yaml" → Use `read_config_file`
   - "Read my automations.yaml" → Use `read_config_file`
   - "List my packages directory" → Use `list_config_files`

2. **Explicit Local = Local Tools**
   - "Read the local configuration.yaml" → Use `readFile`
   - "Search locally for automations" → Use `fileSearch`

3. **Non-HA Files = Local Tools**
   - "Read package.json" → Use `readFile`
   - "Show me README.md" → Use `readFile`

4. **HA API Operations = MCP Tools**
   - "Test this template" → Use `render_template`
   - "Get entity states" → Use `get_states`
   - "Call a service" → Use `call_service`

### 📋 Context Recognition Examples:

**Example 1: Clear HA Context**
- User: "Show me my Home Assistant configuration.yaml"
- Action: Use `read_config_file` tool (NOT `readFile`)
- Reason: HA context + file pattern

**Example 2: HA File Pattern**
- User: "Read my automations.yaml"
- Action: Use `read_config_file` tool (NOT `readFile`)
- Reason: HA-specific file pattern

**Example 3: HA Directory**
- User: "List my packages directory"
- Action: Use `list_config_files` tool (NOT `listDirectory`)
- Reason: HA context + directory request

**Example 4: Explicit Local Override**
- User: "Read the local configuration.yaml"
- Action: Use `readFile` tool (NOT `read_config_file`)
- Reason: Explicit "local" keyword

**Example 5: Non-HA File**
- User: "Show me package.json"
- Action: Use `readFile` tool (NOT `read_config_file`)
- Reason: Not an HA file

**Example 6: Template Testing**
- User: "Test this template: {{ states('sensor.temperature') }}"
- Action: Use `render_template` tool
- Reason: HA template operation

### 🔑 Power Activation Keywords:

This power should be activated when the user's request contains:
- **HA Keywords**: "home assistant", "HA", "homeassistant", "hass"
- **Configuration Keywords**: "configuration", "automation", "script", "scene", "package"
- **File Keywords**: "configuration.yaml", "automations.yaml", "scripts.yaml", "packages/"
- **Template Keywords**: "template", "jinja2", "render"
- **Entity Keywords**: "entity", "state", "service", "integration"

When these keywords appear in combination with file operations, ALWAYS use this power's MCP tools for remote access.

## Tool Selection Examples

**CRITICAL: These examples show the CORRECT tool to use for each scenario. Always follow these patterns.**

### ✅ Correct Tool Usage

| User Request | Correct Tool | Wrong Tool | Reason |
|-------------|--------------|------------|---------|
| "Show me my Home Assistant configuration.yaml" | `read_config_file` | ~~`readFile`~~ | HA context + file |
| "Read my automations.yaml" | `read_config_file` | ~~`readFile`~~ | HA file pattern |
| "List my packages directory" | `list_config_files` | ~~`listDirectory`~~ | HA directory |
| "Download /config/packages/emhass.yaml" | `read_config_file` | ~~`readFile`~~ | HA file path |
| "Show me my HA scripts.yaml" | `read_config_file` | ~~`readFile`~~ | HA context + file |
| "Test this template: {{ states('sensor.temp') }}" | `render_template` | N/A | HA template |
| "Get the state of light.living_room" | `get_states` | N/A | HA entity |
| "Turn on light.bedroom" | `call_service` | N/A | HA service |

### ❌ When to Use Local Tools

| User Request | Correct Tool | Reason |
|-------------|--------------|---------|
| "Read the local configuration.yaml" | `readFile` | Explicit "local" keyword |
| "Show me package.json" | `readFile` | Non-HA file |
| "Read README.md" | `readFile` | Non-HA file |
| "Search locally for automations" | `fileSearch` | Explicit "locally" keyword |
| "List files in src/" | `listDirectory` | Non-HA directory |

### 🎯 Pattern Recognition

**Pattern 1: HA Context + File**
```
Input: "Show me my Home Assistant configuration.yaml"
Analysis:
  - Contains "Home Assistant" ✓
  - Contains file pattern "configuration.yaml" ✓
  - No "local" keyword ✓
Decision: Use read_config_file (MCP tool)
```

**Pattern 2: HA File Pattern Only**
```
Input: "Read my automations.yaml"
Analysis:
  - Contains HA file pattern "automations.yaml" ✓
  - No "local" keyword ✓
Decision: Use read_config_file (MCP tool)
```

**Pattern 3: Explicit Local Override**
```
Input: "Read the local configuration.yaml"
Analysis:
  - Contains "local" keyword ✓
  - User explicitly wants local file ✓
Decision: Use readFile (local tool)
```

**Pattern 4: Non-HA File**
```
Input: "Show me package.json"
Analysis:
  - No HA context ✗
  - Not an HA file pattern ✗
Decision: Use readFile (local tool)
```

## Available Steering Files

- **getting-started.md** - Setup and installation guide
- **local-development.md** - Local workspace setup and file management workflows
- **version-management.md** - Version checking and conflict resolution
- **workflow-patterns.md** - Complete development workflow patterns
- **template-testing.md** - Template development and validation workflows
- **debugging.md** - Troubleshooting automations and scripts
- **file-management.md** - Working with configuration files

---

## 🔄 Key Workflows

**IMPORTANT: All file management workflows are multi-step processes. You MUST follow all steps in the correct order for proper version tracking and conflict prevention.**

### Workflow Overview

This power provides structured workflows for common HA development tasks. Each workflow consists of multiple steps that must be completed in sequence.

### 1. Download Files Workflow

**Purpose**: Download HA configuration files to local workspace with version tracking

**Steps (DO NOT SKIP):**
1. **ALWAYS** get_file_metadata first (check version, size, hash)
2. **THEN** read_config_file (retrieve content)
3. **THEN** save locally to `~/ha-dev-workspace/`
4. **THEN** record metadata in `.ha-workflow/metadata.json`

**Why Each Step Matters:**
- Metadata enables conflict detection
- Local save enables IDE editing
- Metadata recording enables version tracking

**See**: `file-management.md` → Workflow 2 for detailed instructions

### 2. Upload Files Workflow

**Purpose**: Upload modified files to HA instance with validation and conflict checking

**Steps (DO NOT SKIP):**
1. **ALWAYS** validate YAML syntax first
2. **THEN** check for conflicts with get_file_metadata
3. **THEN** write_config_file with expected_hash
4. **THEN** verify upload succeeded

**Why Each Step Matters:**
- Validation prevents breaking HA configuration
- Conflict checking prevents overwriting others' changes
- Verification ensures upload completed successfully

**See**: `file-management.md` → Workflow 3 for detailed instructions

### 3. Version Checking Workflow

**Purpose**: Detect if files changed on server before editing

**Steps:**
1. Get local metadata from cache
2. Get remote metadata from HA instance
3. Compare hashes and timestamps
4. Decide action based on differences

**See**: `version-management.md` for conflict resolution strategies

### 4. Local Development Workflow

**Purpose**: Edit HA files locally with full IDE support

**Steps:**
1. Initialize workspace structure
2. Download files with metadata
3. Edit locally with IDE
4. Upload with validation

**See**: `local-development.md` for complete setup guide

### 5. Template Testing Workflow

**Purpose**: Test Jinja2 templates without restarting HA

**Steps:**
1. Extract template from automation/script
2. Render template with current state
3. Validate entity references
4. Fix issues and re-test

**See**: `template-testing.md` for template development patterns

### 📚 Detailed Workflow Documentation

For complete step-by-step instructions, see the steering files:

- **file-management.md** - All file operation workflows with verification checklists
- **local-development.md** - Workspace setup and local editing workflows
- **version-management.md** - Conflict detection and resolution workflows
- **workflow-patterns.md** - End-to-end development patterns
- **template-testing.md** - Template development and debugging workflows

**CRITICAL**: Always consult the steering files for the complete workflow steps. Skipping steps can lead to data loss, conflicts, or broken configurations.

---

## Prerequisites

### 1. Python Environment
- Python 3.12+ installed
- pip package manager

### 2. Home Assistant Instance
- Running HA instance (local or remote)
- HA version 2024.1.0 or later recommended
- Network access to HA instance

### 3. Long-Lived Access Token
Create a long-lived access token in Home Assistant:
1. Go to your HA profile (click your name in sidebar)
2. Scroll to "Long-Lived Access Tokens"
3. Click "Create Token"
4. Give it a name (e.g., "Kiro MCP Server")
5. Copy the token (you won't see it again!)

## Configuration

After installing this power, you need to configure your Home Assistant connection. There are two approaches:

### Option A: Environment Variables (Recommended for Security)

Set environment variables that Kiro will expand using `${VARIABLE_NAME}` syntax:

1. **Add to your shell configuration** (`~/.zshrc` or `~/.bashrc`):
   ```bash
   export HA_URL="http://192.168.1.100:8123"
   export HA_TOKEN="your-long-lived-access-token"
   ```

2. **Reload your shell configuration**:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

3. **Restart Kiro** to pick up the environment variables

4. **The mcp.json uses variable expansion** (default configuration):
   ```json
   {
     "env": {
       "HA_URL": "${HA_URL}",
       "HA_TOKEN": "${HA_TOKEN}"
     }
   }
   ```

**Advantages:**
- Token not stored in configuration files
- Same variables work across multiple tools
- More secure for shared/version-controlled configs

### Option B: Direct Configuration

Edit the mcp.json file directly with your credentials:

1. **Open the MCP configuration file** for this power
   - Kiro will prompt you on first use, or
   - Manually edit: `~/.kiro/powers/installed/home-assistant-development/mcp.json`

2. **Replace the variable references with actual values**:
   ```json
   {
     "mcpServers": {
       "ha-config-manager": {
         "env": {
           "HA_URL": "http://192.168.4.64:8123",
           "HA_TOKEN": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
         }
       }
     }
   }
   ```

3. **Save and reconnect** the MCP server in Kiro

**Advantages:**
- Works immediately without shell configuration
- No need to restart Kiro
- Simpler for single-use scenarios

**Security Note:** With Option B, the token is stored in plain text in the configuration file. Keep it secure and don't share or commit this file.

### Creating a Long-Lived Access Token

For either option, you need a token from Home Assistant:

1. Open Home Assistant
2. Click your profile (bottom left)
3. Scroll to "Long-Lived Access Tokens"
4. Click "Create Token"
5. Name it (e.g., "Kiro MCP Server")
6. Copy the token immediately (you won't see it again!)

### Example Configurations

**Using Environment Variables (Default):**
```json
{
  "mcpServers": {
    "ha-config-manager": {
      "command": "uvx",
      "args": ["--from", "ha-config-manager-mcp", "ha-config-manager"],
      "env": {
        "HA_URL": "${HA_URL}",
        "HA_TOKEN": "${HA_TOKEN}"
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

**Using Direct Values:**
```json
{
  "mcpServers": {
    "ha-config-manager": {
      "command": "uvx",
      "args": ["--from", "ha-config-manager-mcp", "ha-config-manager"],
      "env": {
        "HA_URL": "http://192.168.4.64:8123",
        "HA_TOKEN": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

### 4. Custom Integration (For File Access)
To enable file and log management tools, install the `ha_config_manager` custom integration:

**Installation:**
1. Copy `src/ha-integration/custom_components/ha_config_manager/` to your HA `custom_components/` directory
2. Add to `configuration.yaml`:
   ```yaml
   ha_config_manager:
     security:
       allowed_paths:
         - /config/configuration.yaml
         - /config/automations.yaml
         - /config/scripts.yaml
         - /config/packages/*
         - /config/.storage/lovelace*
   ```
3. Restart Home Assistant

**Note:** Without the custom integration, you'll still have access to 11 official HA API tools (templates, states, services, etc.). Only file/log tools require the integration.

## Available MCP Servers

This power uses a single MCP server: `ha-config-manager`

### MCP Tools (17 total)

**REMINDER: Use these MCP tools when working with Home Assistant files. Do NOT use local file tools (readFile, fileSearch, listDirectory) for HA configuration files.**

#### File Access Tools (6)
Requires custom integration installed.

**list_config_files**
- Lists configuration files in your HA instance
- Parameters:
  - `directory` (optional): Filter by directory (e.g., "packages")
- Returns: Array of file objects with path, type, size, last_modified

**read_config_file**
- Reads content of a configuration file
- Parameters:
  - `file_path` (required): Path to file (e.g., "configuration.yaml")
- Returns: File content as text

**get_file_metadata**
- Gets file metadata without reading full content
- Parameters:
  - `file_path` (required): Path to file
- Returns: Metadata object with path, size, modified_at, content_hash, exists, accessible
- Use for: Version checking, conflict detection

**batch_get_metadata**
- Gets metadata for multiple files in one request
- Parameters:
  - `file_paths` (required): Array of file paths
- Returns: Array of metadata objects
- Use for: Efficient version checking of multiple files

**write_config_file**
- Writes content to a configuration file
- Parameters:
  - `file_path` (required): Path to file
  - `content` (required): File content to write
  - `expected_hash` (optional): Expected current hash for conflict detection
  - `validate_before_write` (optional): Validate YAML syntax (default: true)
- Returns: New file metadata after write
- Use for: Uploading edited files with validation

**get_logs**
- Retrieves HA logs with filtering
- Parameters:
  - `log_source` (required): Log source ("core", "supervisor", "addon")
  - `lines` (optional): Number of lines (default: 100)
  - `level` (optional): Filter by level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
  - `search` (optional): Search term
  - `offset` (optional): Pagination offset
  - `limit` (optional): Max entries (default: 100)
- Returns: Array of log entries

#### Entity & State Tools (2)

**get_states**
- Get entity states from HA
- Parameters:
  - `entity_id` (optional): Specific entity (e.g., "light.living_room")
- Returns: Single entity state or array of all states

**get_history**
- Get historical state data
- Parameters:
  - `start_time` (optional): ISO 8601 format (default: 1 day ago)
  - `end_time` (optional): ISO 8601 format (default: now)
  - `entity_ids` (optional): Array of entity IDs
- Returns: Historical state data

#### Service & Control Tools (3)

**call_service**
- Call a Home Assistant service
- Parameters:
  - `domain` (required): Service domain (e.g., "light", "switch")
  - `service` (required): Service name (e.g., "turn_on", "turn_off")
  - `service_data` (optional): Service parameters
- Returns: Affected entity states

**render_template**
- Render a Jinja2 template with HA context
- Parameters:
  - `template` (required): Template string
  - `validate_entities` (optional): Validate entity references (default: false)
- Returns: Rendered output (string or object with warnings)

**validate_template**
- Validate template syntax without executing
- Parameters:
  - `template` (required): Template string to validate
  - `validate_entities` (optional): Also validate entities (default: false)
- Returns: Validation result with errors/warnings

#### System Information Tools (4)

**get_config**
- Get HA configuration details
- Returns: Version, location, components, etc.

**list_events**
- List all available event types
- Returns: Array of event type names

**list_services**
- List all available services with schemas
- Returns: Services organized by domain

**get_logbook**
- Get logbook entries (state changes and events)
- Parameters:
  - `start_time` (optional): ISO 8601 format
  - `end_time` (optional): ISO 8601 format
  - `entity_id` (optional): Filter by entity
- Returns: Logbook entries

#### Configuration Tools (1)

**check_config**
- Validate HA configuration without restarting
- Returns: Validation results

#### Diagnostics Tools (1)

**get_error_log**
- Retrieve all errors from current HA session
- Returns: Error log as plain text

## Tool Usage Examples

**NOTE: These examples demonstrate the MCP tools provided by this power. For Home Assistant file operations, use these tools instead of local file tools like readFile or fileSearch.**

### Example 1: Test a Template
```
Use render_template tool:
{
  "template": "{{ states('sensor.temperature') | float + 5 }}",
  "validate_entities": true
}

Result: "25.5" (if sensor.temperature is 20.5)
```

### Example 2: Check Entity State
```
Use get_states tool:
{
  "entity_id": "light.living_room"
}

Result: {
  "entity_id": "light.living_room",
  "state": "on",
  "attributes": {"brightness": 255},
  ...
}
```

### Example 3: List Configuration Files
```
Use list_config_files tool:
{
  "directory": "packages"
}

Result: [
  {"path": "packages/lights.yaml", "type": "configuration", ...},
  {"path": "packages/automations.yaml", "type": "configuration", ...}
]
```

### Example 4: Turn On a Light
```
Use call_service tool:
{
  "domain": "light",
  "service": "turn_on",
  "service_data": {
    "entity_id": "light.living_room",
    "brightness": 200
  }
}
```

### Example 5: Get Recent History
```
Use get_history tool:
{
  "entity_ids": ["sensor.temperature", "sensor.humidity"],
  "start_time": "2026-02-12T00:00:00"
}
```

## Common Workflows

**IMPORTANT: When working with Home Assistant files, always use the MCP tools from this power (read_config_file, list_config_files, write_config_file) instead of local file tools (readFile, fileSearch, fsWrite).**

### Workflow 1: Local Development with Version Checking
1. Use `get_file_metadata` to check file version
2. Use `read_config_file` to download file
3. Edit locally in your IDE
4. Use `get_file_metadata` again to detect conflicts
5. Use `write_config_file` with `expected_hash` to upload safely
6. Use `check_config` to validate

### Workflow 2: Debug a Broken Template
1. Use `render_template` with `validate_entities: true`
2. Check for entity validation warnings
3. Use `get_states` to verify entity exists
4. Fix template and test again

### Workflow 3: Investigate Automation Issues
1. Use `get_logbook` to see recent state changes
2. Use `get_logs` with level="ERROR" to find errors
3. Use `get_states` to check current entity states
4. Use `render_template` to test conditions

### Workflow 4: Validate Configuration Changes
1. Use `read_config_file` to view current config
2. Make changes locally
3. Use `check_config` to validate
4. Deploy if validation passes

### Workflow 5: Batch File Operations
1. Use `batch_get_metadata` to check versions of multiple files
2. Download files that need editing
3. Edit locally
4. Use `write_config_file` for each modified file
5. Use `check_config` to validate all changes

### Workflow 6: Explore Available Services
1. Use `list_services` to see all services
2. Use `get_config` to check HA version and components
3. Use `call_service` to test service calls

## Best Practices

**CRITICAL: Always use MCP tools for Home Assistant file access. When you see HA context (keywords like "Home Assistant", "configuration.yaml", "automations.yaml"), use read_config_file NOT readFile.**

### Local Development Workflow
- Always check file metadata before editing to detect conflicts
- Download files to a consistent local workspace (e.g., `~/ha-dev-workspace/`)
- Use your IDE for editing (syntax highlighting, validation, git integration)
- Test templates before uploading files
- Use `expected_hash` parameter when uploading to prevent overwriting changes
- Always validate configuration after uploading files

### Version Management
- Use `get_file_metadata` to track file versions
- Compare hashes before and after editing to detect conflicts
- Use `batch_get_metadata` for efficient multi-file version checking
- Keep local metadata cache to track downloaded file versions
- Always check for conflicts before uploading

### Template Development
- Always use `validate_entities: true` when testing templates
- Test templates with actual entity IDs from your HA instance
- Use `get_states` to verify entity availability before using in templates
- Check for undefined references in validation warnings

### Entity Management
- Use `get_states` without parameters to discover available entities
- Filter by domain using entity_id patterns (e.g., "light.*")
- Check `last_changed` and `last_updated` timestamps for debugging
- Verify entity attributes before using in automations

### File Access
- Always use relative paths (e.g., "configuration.yaml", not "/config/configuration.yaml")
- Check file permissions in custom integration configuration
- Use `list_config_files` to discover available files
- Read files before making changes to understand current state
- Use write operations with validation enabled

### Service Calls
- Use `list_services` to discover available services and their parameters
- Always include required service_data fields
- Test service calls with non-critical entities first
- Check return values for affected entity states

### Debugging
- Start with `get_error_log` to see recent errors
- Use `get_logs` with search parameter to find specific issues
- Check `get_logbook` for state change history
- Combine multiple tools to correlate events

## Troubleshooting

### Error: "Resource not found" (404)
**Cause:** Custom integration not installed or not loaded

**Solution:**
1. Verify integration is in `custom_components/ha_config_manager/`
2. Check `configuration.yaml` has `ha_config_manager:` entry
3. Restart Home Assistant
4. Check HA logs for integration errors

### Error: "Unauthorized" (401)
**Cause:** Invalid or expired access token

**Solution:**
1. Verify `HA_TOKEN` environment variable is set correctly
2. Create a new long-lived access token in HA
3. Update environment variable
4. Restart MCP server

### Error: "Forbidden" (403)
**Cause:** File not in allowed_paths or not admin user

**Solution:**
1. Check `allowed_paths` in `configuration.yaml`
2. Add the file path to allowed_paths
3. Restart Home Assistant
4. Verify you're using an admin user's token

### Error: "Template syntax error"
**Cause:** Invalid Jinja2 syntax in template

**Solution:**
1. Use `validate_template` tool first
2. Check for unmatched braces, quotes, or filters
3. Test with simpler template first
4. Refer to HA template documentation

### Error: "Entity not found"
**Cause:** Entity ID doesn't exist or is misspelled

**Solution:**
1. Use `get_states` without parameters to list all entities
2. Verify exact entity_id spelling
3. Check if entity is disabled in HA
4. Use `validate_entities: true` in render_template

### MCP Server Won't Start
**Cause:** Missing environment variables or Python dependencies

**Solution:**
1. Verify `HA_URL` and `HA_TOKEN` are set
2. Check Python version (3.12+ required)
3. Install dependencies: `pip install aiohttp pyyaml aiofiles`
4. Check MCP server logs for specific errors

## Configuration

### Environment Variables

**Required:**
- `HA_URL`: Your Home Assistant URL (e.g., "http://192.168.1.100:8123")
- `HA_TOKEN`: Long-lived access token from HA

**Optional:**
- `PYTHONPATH`: Set to MCP server source directory if needed

### Custom Integration Configuration

Add to your `configuration.yaml`:

```yaml
ha_config_manager:
  security:
    # Files you want to access (read and write)
    allowed_paths:
      # Core configuration files
      - /config/configuration.yaml
      - /config/automations.yaml
      - /config/scripts.yaml
      - /config/scenes.yaml
      
      # Configuration directories
      - /config/packages/*
      - /config/blueprints/*
      
      # Safe storage files (UI-managed)
      - /config/.storage/lovelace*
      - /config/.storage/automation
      - /config/.storage/script
      - /config/.storage/scene
      - /config/.storage/input_*
      - /config/.storage/timer
      - /config/.storage/counter
      
      # Addon configurations (optional)
      - /addon_configs/*/config.yaml
```

**Security Notes:**
- Only admin users can access the API
- Files must be explicitly allowed in `allowed_paths` for both read and write operations
- Sensitive files are automatically blocked (secrets.yaml, auth files, etc.)
- Use glob patterns (*) for directory access
- Write operations include automatic YAML validation
- File backups are created before overwriting
- Rate limiting prevents abuse (10 writes per minute per user)

## Additional Resources

- **HA Template Documentation**: https://www.home-assistant.io/docs/configuration/templating/
- **HA REST API**: https://developers.home-assistant.io/docs/api/rest/
- **Jinja2 Documentation**: https://jinja.palletsprojects.com/
- **Custom Integration Source**: `src/ha-integration/` in this repository
- **MCP Server Source**: `src/config-manager/` in this repository

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review steering files for specific workflows
3. Check HA logs for integration errors
4. Verify environment variables are set correctly
5. Test with official HA API tools first (templates, states, services)
