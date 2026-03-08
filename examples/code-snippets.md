# Code Snippets and Usage Examples

This document provides code snippets and usage examples for the Home Assistant Development Power.

## Table of Contents

1. [MCP Tool Usage Examples](#mcp-tool-usage-examples)
2. [Template Examples](#template-examples)
3. [Service Call Examples](#service-call-examples)
4. [File Management Examples](#file-management-examples)
5. [Debugging Examples](#debugging-examples)
6. [Workflow Examples](#workflow-examples)

## MCP Tool Usage Examples

### Get Entity State

**Simple state query:**
```
Get the state of sun.sun
```

**MCP Tool Call:**
```json
{
  "tool": "get_states",
  "arguments": {
    "entity_id": "sun.sun"
  }
}
```

**Response:**
```json
{
  "entity_id": "sun.sun",
  "state": "above_horizon",
  "attributes": {
    "next_dawn": "2026-03-09T06:30:00+00:00",
    "next_dusk": "2026-03-08T18:45:00+00:00",
    "elevation": 45.2
  },
  "last_changed": "2026-03-08T06:30:00+00:00"
}
```

### List All Entities

**Query:**
```
List all light entities
```

**MCP Tool Call:**
```json
{
  "tool": "get_states",
  "arguments": {}
}
```

Then filter for entities starting with "light."

### Render Template

**Simple template:**
```
Test this template: {{ states('sensor.temperature') }}
```

**MCP Tool Call:**
```json
{
  "tool": "render_template",
  "arguments": {
    "template": "{{ states('sensor.temperature') }}",
    "validate_entities": false
  }
}
```

**Response:**
```json
{
  "result": "22.5"
}
```

**Template with entity validation:**
```json
{
  "tool": "render_template",
  "arguments": {
    "template": "{{ states('sensor.temperature') | float + 5 }}",
    "validate_entities": true
  }
}
```

**Response with warnings:**
```json
{
  "result": "27.5",
  "warnings": [],
  "entities_found": ["sensor.temperature"]
}
```

### Validate Template

**Query:**
```
Validate this template: {{ states('sensor.temp') | float }}
```

**MCP Tool Call:**
```json
{
  "tool": "validate_template",
  "arguments": {
    "template": "{{ states('sensor.temp') | float }}",
    "validate_entities": true
  }
}
```

**Response:**
```json
{
  "valid": true,
  "errors": [],
  "warnings": ["Entity 'sensor.temp' not found"],
  "entities_referenced": ["sensor.temp"]
}
```

## Template Examples

### Basic State Access

```jinja2
{{ states('sensor.temperature') }}
```

### Numeric Calculations

```jinja2
{{ states('sensor.temperature') | float + 5 }}
```

### Conditional Logic

```jinja2
{% if states('sensor.temperature') | float > 25 %}
  Hot
{% else %}
  Cool
{% endif %}
```

### Entity Attributes

```jinja2
{{ state_attr('light.living_room', 'brightness') }}
```

### Time-Based Templates

```jinja2
{{ now().strftime('%H:%M') }}
```

### List Filtering

```jinja2
{{ states.light | selectattr('state', 'eq', 'on') | list | count }}
```

### Complex Template Example

```jinja2
{% set temp = states('sensor.temperature') | float %}
{% set humidity = states('sensor.humidity') | float %}
{% if temp > 25 and humidity > 60 %}
  Uncomfortable
{% elif temp > 25 %}
  Warm
{% elif humidity > 60 %}
  Humid
{% else %}
  Comfortable
{% endif %}
```

## Service Call Examples

### Turn On Light

**Query:**
```
Turn on light.living_room
```

**MCP Tool Call:**
```json
{
  "tool": "call_service",
  "arguments": {
    "domain": "light",
    "service": "turn_on",
    "service_data": {
      "entity_id": "light.living_room"
    }
  }
}
```

### Turn On Light with Brightness

**Query:**
```
Turn on light.bedroom with brightness 200
```

**MCP Tool Call:**
```json
{
  "tool": "call_service",
  "arguments": {
    "domain": "light",
    "service": "turn_on",
    "service_data": {
      "entity_id": "light.bedroom",
      "brightness": 200
    }
  }
}
```

### Turn On Light with Color

**MCP Tool Call:**
```json
{
  "tool": "call_service",
  "arguments": {
    "domain": "light",
    "service": "turn_on",
    "service_data": {
      "entity_id": "light.living_room",
      "brightness": 255,
      "rgb_color": [255, 0, 0]
    }
  }
}
```

### Set Climate Temperature

**MCP Tool Call:**
```json
{
  "tool": "call_service",
  "arguments": {
    "domain": "climate",
    "service": "set_temperature",
    "service_data": {
      "entity_id": "climate.living_room",
      "temperature": 22
    }
  }
}
```

### Trigger Automation

**MCP Tool Call:**
```json
{
  "tool": "call_service",
  "arguments": {
    "domain": "automation",
    "service": "trigger",
    "service_data": {
      "entity_id": "automation.morning_routine"
    }
  }
}
```

## File Management Examples

### List Configuration Files

**Query:**
```
List my Home Assistant configuration files
```

**MCP Tool Call:**
```json
{
  "tool": "list_config_files",
  "arguments": {}
}
```

**Response:**
```json
[
  {
    "path": "configuration.yaml",
    "type": "configuration",
    "size": 2048,
    "last_modified": "2026-03-08T10:30:00+00:00"
  },
  {
    "path": "automations.yaml",
    "type": "configuration",
    "size": 5120,
    "last_modified": "2026-03-07T15:20:00+00:00"
  }
]
```

### List Files in Directory

**Query:**
```
List files in my packages directory
```

**MCP Tool Call:**
```json
{
  "tool": "list_config_files",
  "arguments": {
    "directory": "packages"
  }
}
```

### Read Configuration File

**Query:**
```
Show me my automations.yaml
```

**MCP Tool Call:**
```json
{
  "tool": "read_config_file",
  "arguments": {
    "file_path": "automations.yaml"
  }
}
```

**Response:**
```yaml
- id: '1234567890'
  alias: Morning Routine
  trigger:
    - platform: time
      at: '07:00:00'
  action:
    - service: light.turn_on
      target:
        entity_id: light.bedroom
```

### Get File Metadata

**Query:**
```
Get metadata for configuration.yaml
```

**MCP Tool Call:**
```json
{
  "tool": "get_file_metadata",
  "arguments": {
    "file_path": "configuration.yaml"
  }
}
```

**Response:**
```json
{
  "path": "configuration.yaml",
  "size": 2048,
  "modified_at": "2026-03-08T10:30:00+00:00",
  "content_hash": "abc123def456",
  "exists": true,
  "accessible": true
}
```

### Write Configuration File

**MCP Tool Call:**
```json
{
  "tool": "write_config_file",
  "arguments": {
    "file_path": "automations.yaml",
    "content": "- id: '1234567890'\n  alias: Morning Routine\n  trigger:\n    - platform: time\n      at: '07:00:00'\n  action:\n    - service: light.turn_on\n      target:\n        entity_id: light.bedroom\n",
    "expected_hash": "abc123def456",
    "validate_before_write": true
  }
}
```

### Batch Get Metadata

**MCP Tool Call:**
```json
{
  "tool": "batch_get_metadata",
  "arguments": {
    "file_paths": [
      "configuration.yaml",
      "automations.yaml",
      "scripts.yaml"
    ]
  }
}
```

## Debugging Examples

### Get Recent Errors

**Query:**
```
Show me recent Home Assistant errors
```

**MCP Tool Call:**
```json
{
  "tool": "get_error_log",
  "arguments": {}
}
```

### Get Logs with Filter

**Query:**
```
Get logs with level ERROR
```

**MCP Tool Call:**
```json
{
  "tool": "get_logs",
  "arguments": {
    "log_source": "core",
    "level": "ERROR",
    "lines": 50
  }
}
```

### Search Logs

**MCP Tool Call:**
```json
{
  "tool": "get_logs",
  "arguments": {
    "log_source": "core",
    "search": "automation",
    "lines": 100
  }
}
```

### Get Entity History

**Query:**
```
Get history for light.living_room
```

**MCP Tool Call:**
```json
{
  "tool": "get_history",
  "arguments": {
    "entity_ids": ["light.living_room"],
    "start_time": "2026-03-08T00:00:00+00:00"
  }
}
```

### Get Logbook Entries

**MCP Tool Call:**
```json
{
  "tool": "get_logbook",
  "arguments": {
    "start_time": "2026-03-08T00:00:00+00:00",
    "entity_id": "automation.morning_routine"
  }
}
```

## Workflow Examples

### Workflow 1: Download and Edit File

**Step 1: Get metadata**
```json
{
  "tool": "get_file_metadata",
  "arguments": {
    "file_path": "automations.yaml"
  }
}
```

**Step 2: Read file**
```json
{
  "tool": "read_config_file",
  "arguments": {
    "file_path": "automations.yaml"
  }
}
```

**Step 3: Save locally**
Save content to `~/ha-dev-workspace/automations.yaml`

**Step 4: Edit in IDE**
Make changes using your preferred editor

**Step 5: Upload with validation**
```json
{
  "tool": "write_config_file",
  "arguments": {
    "file_path": "automations.yaml",
    "content": "<edited content>",
    "expected_hash": "<hash from step 1>",
    "validate_before_write": true
  }
}
```

### Workflow 2: Debug Template

**Step 1: Validate syntax**
```json
{
  "tool": "validate_template",
  "arguments": {
    "template": "{{ states('sensor.temp') | float }}",
    "validate_entities": true
  }
}
```

**Step 2: Check entity exists**
```json
{
  "tool": "get_states",
  "arguments": {
    "entity_id": "sensor.temp"
  }
}
```

**Step 3: Render template**
```json
{
  "tool": "render_template",
  "arguments": {
    "template": "{{ states('sensor.temp') | float }}",
    "validate_entities": true
  }
}
```

### Workflow 3: Investigate Automation Issue

**Step 1: Check automation state**
```json
{
  "tool": "get_states",
  "arguments": {
    "entity_id": "automation.morning_routine"
  }
}
```

**Step 2: Check logbook**
```json
{
  "tool": "get_logbook",
  "arguments": {
    "entity_id": "automation.morning_routine",
    "start_time": "2026-03-08T00:00:00+00:00"
  }
}
```

**Step 3: Check logs**
```json
{
  "tool": "get_logs",
  "arguments": {
    "log_source": "core",
    "search": "morning_routine",
    "level": "ERROR"
  }
}
```

**Step 4: Read automation file**
```json
{
  "tool": "read_config_file",
  "arguments": {
    "file_path": "automations.yaml"
  }
}
```

### Workflow 4: Validate Configuration

**Step 1: Read configuration**
```json
{
  "tool": "read_config_file",
  "arguments": {
    "file_path": "configuration.yaml"
  }
}
```

**Step 2: Make changes locally**
Edit the file in your IDE

**Step 3: Upload with validation**
```json
{
  "tool": "write_config_file",
  "arguments": {
    "file_path": "configuration.yaml",
    "content": "<edited content>",
    "validate_before_write": true
  }
}
```

**Step 4: Check configuration**
```json
{
  "tool": "check_config",
  "arguments": {}
}
```

## System Information Examples

### Get HA Configuration

**MCP Tool Call:**
```json
{
  "tool": "get_config",
  "arguments": {}
}
```

**Response:**
```json
{
  "version": "2026.3.0",
  "location_name": "Home",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "elevation": 0,
  "unit_system": "metric",
  "time_zone": "America/Los_Angeles",
  "components": ["automation", "light", "sensor", ...]
}
```

### List Available Services

**MCP Tool Call:**
```json
{
  "tool": "list_services",
  "arguments": {}
}
```

**Response:**
```json
{
  "light": {
    "turn_on": {
      "description": "Turn on one or more lights",
      "fields": {
        "entity_id": {"description": "Entity ID", "example": "light.living_room"},
        "brightness": {"description": "Brightness (0-255)", "example": 200}
      }
    },
    "turn_off": {...}
  },
  "automation": {...}
}
```

### List Event Types

**MCP Tool Call:**
```json
{
  "tool": "list_events",
  "arguments": {}
}
```

**Response:**
```json
[
  "state_changed",
  "service_called",
  "automation_triggered",
  "call_service",
  "component_loaded"
]
```

## Tips and Best Practices

### Template Testing
- Always use `validate_entities: true` when testing templates
- Test with actual entity IDs from your HA instance
- Check for undefined references in validation warnings

### File Management
- Always get metadata before editing to track versions
- Use `expected_hash` when uploading to prevent conflicts
- Enable validation when writing YAML files
- Keep local copies in a consistent workspace directory

### Service Calls
- Use `list_services` to discover available services
- Check service schemas for required parameters
- Test with non-critical entities first

### Debugging
- Start with `get_error_log` for recent errors
- Use `get_logs` with search to find specific issues
- Check `get_logbook` for state change history
- Combine multiple tools to correlate events

### Security
- Use environment variables for tokens
- Limit `allowed_paths` to necessary files
- Don't commit tokens to version control
- Use admin tokens only when required
