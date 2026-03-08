# Debugging Home Assistant Automations and Scripts

Complete guide for troubleshooting Home Assistant automations, scripts, and templates using the MCP tools.

## Overview

Debugging HA automations can be challenging because:
- Automations run in the background
- Errors may not be immediately visible
- State changes happen asynchronously
- Template errors can be cryptic

This guide shows you how to use the MCP tools to efficiently debug issues.

## Available Debugging Tools

1. **get_logs** - View HA logs with filtering
2. **get_error_log** - Get all errors from current session
3. **get_logbook** - See state changes and events
4. **get_history** - Historical state data
5. **get_states** - Current entity states
6. **render_template** - Test templates interactively
7. **validate_template** - Check template syntax
8. **check_config** - Validate configuration

## Workflow 1: Automation Not Triggering

### Symptoms
- Automation exists but never runs
- Expected trigger conditions met but nothing happens

### Debugging Steps

**Step 1: Verify Automation is Enabled**
Ask Kiro:
```
Check if automation.morning_routine is enabled
```

**Step 2: Check Recent Logbook Entries**
Ask Kiro:
```
Show me logbook entries for automation.morning_routine from the last 24 hours
```

**Step 3: Verify Trigger Conditions**
Ask Kiro:
```
What's the current state of binary_sensor.workday?
```

**Step 4: Test Trigger Template (if using template trigger)**
If your automation uses a template trigger:
```
Test this template: {{ states('sensor.temperature') | float > 25 }}
```

**Step 5: Check for Errors**
Ask Kiro:
```
Show me errors from the last hour related to automations
```

### Common Causes
- Automation disabled in UI
- Trigger condition never actually met
- Entity ID misspelled in trigger
- Time zone issues with time triggers
- Condition block preventing execution

## Workflow 2: Automation Triggers But Action Fails

### Symptoms
- Automation shows in logbook as triggered
- Expected action doesn't happen
- No obvious error messages

### Debugging Steps

**Step 1: Check Logbook for Action Execution**
Ask Kiro:
```
Show me logbook entries for light.living_room from the last hour
```

**Step 2: Verify Target Entity Exists**
Ask Kiro:
```
What's the state of light.living_room?
```

**Step 3: Check Service Call Syntax**
Ask Kiro:
```
List services for the light domain
```

Verify your service call matches the schema.

**Step 4: Look for Action Errors**
Ask Kiro:
```
Show me errors containing "light.living_room"
```

**Step 5: Test Service Call Manually**
Ask Kiro:
```
Turn on light.living_room with brightness 200
```

### Common Causes
- Entity ID doesn't exist or is misspelled
- Service parameters incorrect
- Entity unavailable or offline
- Permissions issue (rare)
- Integration not loaded

## Workflow 3: Template Error in Automation

### Symptoms
- Automation fails with template error
- Error log shows "TemplateError"
- Automation worked before, now broken

### Debugging Steps

**Step 1: Get the Error Message**
Ask Kiro:
```
Show me template errors from the last hour
```

**Step 2: Extract the Template**
Identify the problematic template from your automation.

**Step 3: Test Template Syntax**
Ask Kiro:
```
Validate this template: {{ states('sensor.temperature') | float > 25 }}
```

**Step 4: Test Template Execution**
Ask Kiro:
```
Test this template: {{ states('sensor.temperature') | float > 25 }}
```

**Step 5: Verify Entity References**
Ask Kiro:
```
Test this template with entity validation: {{ states('sensor.temperature') | float > 25 }}
```

**Step 6: Check Entity States**
If entities are missing:
```
List all sensor entities
```

### Common Template Errors

**Error: "UndefinedError: 'None' has no attribute"**
```jinja2
# Problem
{{ states.sensor.temperature.state | float }}

# Solution - use states() function
{{ states('sensor.temperature') | float(0) }}
```

**Error: "TypeError: unsupported operand type(s)"**
```jinja2
# Problem - string + number
{{ states('sensor.temperature') + 5 }}

# Solution - convert to float first
{{ states('sensor.temperature') | float + 5 }}
```

**Error: "TemplateError: Must provide a device or entity ID"**
```jinja2
# Problem - missing entity_id
{{ device_attr('device_id', 'name') }}

# Solution - verify device exists
{{ device_attr('abc123', 'name') if device_id('abc123') else 'Unknown' }}
```

## Workflow 4: Script Execution Issues

### Symptoms
- Script doesn't complete
- Script stops partway through
- Script takes too long

### Debugging Steps

**Step 1: Check Script State**
Ask Kiro:
```
What's the state of script.morning_routine?
```

**Step 2: Review Logbook for Script Execution**
Ask Kiro:
```
Show me logbook entries for script.morning_routine from the last hour
```

**Step 3: Check for Timeout Issues**
Look for "timeout" in logs:
```
Show me logs containing "timeout" and "script"
```

**Step 4: Verify Each Action**
Test each action in the script individually:
```
Turn on light.bedroom
Wait 5 seconds
Turn on light.living_room
```

**Step 5: Check for Blocking Actions**
Look for actions that might block:
- `wait_template` without timeout
- `wait_for_trigger` without timeout
- Long delays

### Common Script Issues
- Missing timeout on wait actions
- Service call to unavailable entity blocks execution
- Condition in script prevents continuation
- Script mode conflicts (single vs parallel)

## Workflow 5: Condition Not Working as Expected

### Symptoms
- Automation triggers but action doesn't run
- Condition should be true but isn't
- Inconsistent behavior

### Debugging Steps

**Step 1: Extract Condition Template**
Identify the condition from your automation.

**Step 2: Test Condition**
Ask Kiro:
```
Test this condition: {{ states('sensor.temperature') | float > 25 and is_state('binary_sensor.home', 'on') }}
```

**Step 3: Check Each Part Separately**
Break down complex conditions:
```
Test: {{ states('sensor.temperature') | float > 25 }}
Test: {{ is_state('binary_sensor.home', 'on') }}
```

**Step 4: Verify Entity States**
```
What's the state of sensor.temperature?
What's the state of binary_sensor.home?
```

**Step 5: Check for Edge Cases**
Test with actual current values:
```
Test: {{ 23.5 > 25 }}  # If sensor.temperature is 23.5
```

### Common Condition Issues
- Numeric comparison with string values
- Entity state is "unavailable" or "unknown"
- Time zone issues with time conditions
- Incorrect boolean logic (and vs or)

## Workflow 6: Integration Not Loading

### Symptoms
- Entities missing after restart
- Integration shows as "failed to load"
- Services unavailable

### Debugging Steps

**Step 1: Check Error Log**
Ask Kiro:
```
Show me errors from the last restart
```

**Step 2: Validate Configuration**
Ask Kiro:
```
Check my Home Assistant configuration
```

**Step 3: Check Integration Status**
Ask Kiro:
```
List all available services
```

Look for missing service domains.

**Step 4: Review Integration Logs**
Ask Kiro:
```
Show me logs for the last hour filtered by ERROR level
```

**Step 5: Check Dependencies**
Look for missing dependency errors in logs.

### Common Integration Issues
- Configuration syntax error
- Missing required configuration keys
- API credentials invalid
- Network connectivity issues
- Incompatible HA version

## Workflow 7: Performance Issues

### Symptoms
- HA slow to respond
- Automations delayed
- UI sluggish

### Debugging Steps

**Step 1: Check System Load**
Ask Kiro:
```
Show me system information
```

**Step 2: Look for Error Patterns**
Ask Kiro:
```
Show me all errors from the last hour
```

**Step 3: Check for Excessive Logging**
Ask Kiro:
```
Show me logs with DEBUG level
```

**Step 4: Identify Problematic Automations**
Look for automations that trigger frequently:
```
Show me logbook entries from the last hour
```

**Step 5: Check Template Complexity**
Test complex templates for performance:
```
Test this template: {{ states | selectattr('state', 'eq', 'on') | list | count }}
```

### Common Performance Issues
- Template sensors updating too frequently
- Automations with very short delays
- Excessive logging enabled
- Too many entities
- Database size issues

## Best Practices for Debugging

### 1. Start with Recent Logs
Always check logs first:
```
Show me errors from the last hour
```

### 2. Isolate the Problem
Test components individually:
- Test templates separately
- Test service calls manually
- Check entity states

### 3. Use Logbook for Timeline
Understand the sequence of events:
```
Show me logbook entries for the last 30 minutes
```

### 4. Validate Before Deploying
Always validate changes:
```
Check my Home Assistant configuration
```

### 5. Test Templates Interactively
Don't wait for automation to trigger:
```
Test this template: {{ your_template_here }}
```

### 6. Check Entity Availability
Verify entities exist and are available:
```
What's the state of sensor.temperature?
```

### 7. Use Entity Validation
Catch missing entities early:
```
Test this template with entity validation: {{ states('sensor.missing') }}
```

## Common Error Messages and Solutions

### "Entity not found: sensor.temperature"
**Solution**: Check entity ID spelling, verify entity exists
```
List all sensor entities
```

### "Template variable error: 'None' has no attribute 'state'"
**Solution**: Use states() function instead of states.entity.state
```jinja2
# Wrong
{{ states.sensor.temperature.state }}

# Right
{{ states('sensor.temperature') }}
```

### "Service not found: light.turn_on"
**Solution**: Check integration is loaded, verify service domain
```
List services for the light domain
```

### "Timeout waiting for trigger"
**Solution**: Add timeout to wait_for_trigger
```yaml
# Add timeout
wait_for_trigger:
  - platform: state
    entity_id: binary_sensor.motion
    to: 'on'
timeout: '00:05:00'  # 5 minute timeout
```

### "Invalid config for [automation]"
**Solution**: Validate configuration syntax
```
Check my Home Assistant configuration
```

## Advanced Debugging Techniques

### Technique 1: Binary Search for Errors
If automation is complex, disable half the actions and test:
1. Disable second half of actions
2. Test automation
3. If works, problem is in second half
4. If fails, problem is in first half
5. Repeat until found

### Technique 2: Add Notification Actions
Insert notifications to track execution:
```yaml
action:
  - service: notify.mobile_app
    data:
      message: "Step 1 complete"
  - service: light.turn_on
    target:
      entity_id: light.bedroom
  - service: notify.mobile_app
    data:
      message: "Step 2 complete"
```

### Technique 3: Use Script Mode for Debugging
Change script mode to see execution behavior:
```yaml
script:
  my_script:
    mode: queued  # or parallel, restart
    sequence:
      # actions
```

### Technique 4: Enable Debug Logging
Temporarily enable debug logging for specific components:
```yaml
logger:
  default: info
  logs:
    homeassistant.components.automation: debug
    homeassistant.components.script: debug
```

## Quick Reference

### Check for Errors
```
Show me errors from the last hour
```

### Test Template
```
Test this template: {{ your_template }}
```

### Check Entity State
```
What's the state of entity_id?
```

### View Recent Events
```
Show me logbook entries from the last hour
```

### Validate Configuration
```
Check my Home Assistant configuration
```

### Test Service Call
```
Turn on light.living_room
```

### List Available Services
```
List all services
```

## Next Steps

- Read `template-testing.md` for detailed template debugging
- Read `file-management.md` for configuration file access
- Explore HA documentation: https://www.home-assistant.io/docs/automation/troubleshooting/
