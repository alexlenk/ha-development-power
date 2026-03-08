# Home Assistant Development Workflow Patterns

Complete guide to efficient development workflows using the Home Assistant Development Power. This guide provides prescriptive, step-by-step patterns for common development tasks.

## Overview

This guide documents proven workflow patterns that combine local development, version checking, testing, and deployment. Each pattern is designed to minimize errors, prevent conflicts, and ensure reliable deployments.

**Key Principles**:
- Work locally with full IDE support
- Check versions before making changes
- Test thoroughly before deploying
- Verify deployments succeed
- Handle conflicts gracefully

## When to Use Each Workflow

### Decision Tree

```
What are you working on?
│
├─ Editing existing automation/script
│  └─ Use: Edit Automation Workflow
│
├─ Testing a Jinja2 template
│  └─ Use: Test Template Workflow
│
├─ Creating new package
│  └─ Use: Create Package Workflow
│
├─ Modifying configuration.yaml
│  └─ Use: Edit Configuration Workflow
│
└─ Debugging automation issue
   └─ Use: Debugging Workflow (see debugging.md)
```

### Quick Selection Guide

| Task | Workflow | Complexity | Time |
|------|----------|------------|------|
| Edit automation | Edit Automation | Medium | 10-15 min |
| Test template | Test Template | Low | 2-5 min |
| Create package | Create Package | High | 20-30 min |
| Edit config | Edit Configuration | Medium | 10-15 min |
| Debug issue | Debugging | Variable | 5-60 min |

## Workflow 1: Edit Automation

**Use When**: Modifying existing automations in `automations.yaml` or package files

**Prerequisites**:
- Custom integration installed
- File in allowed_paths
- Admin access token configured

### Step-by-Step Guide

#### Step 1: Identify the File

Ask Kiro:
```
List all configuration files
```

Or if you know it's in a package:
```
List files in the packages directory
```

**Checkpoint**: Confirm you've identified the correct file containing your automation.

#### Step 2: Check for Remote Changes

Ask Kiro:
```
Get metadata for automations.yaml
```

Or for a package:
```
Get metadata for packages/lighting.yaml
```

**What to Check**:
- `modified_at` timestamp - When was it last changed?
- `content_hash` - Unique identifier for current version

**Checkpoint**: If the file was recently modified by someone else, consider coordinating before proceeding.

#### Step 3: Download File to Local Workspace

Ask Kiro:
```
Read automations.yaml and save it to ~/ha-dev-workspace/automations.yaml
```

Or:
```
Download packages/lighting.yaml to my local workspace
```

**What Happens**:
- File content is retrieved from HA instance
- Saved to local workspace with same folder structure
- Metadata recorded for version tracking

**Checkpoint**: Verify the file was saved correctly and you can open it in your IDE.

#### Step 4: Edit Locally

Open the file in your preferred IDE:
```bash
code ~/ha-dev-workspace/automations.yaml
# or
vim ~/ha-dev-workspace/automations.yaml
```

**Best Practices**:
- Use YAML syntax highlighting
- Enable YAML validation in your IDE
- Keep formatting consistent
- Add comments for complex logic
- Test templates as you write them

**Checkpoint**: Save your changes and verify YAML syntax is valid.

#### Step 5: Test Templates

If your automation contains templates, test them before uploading:

Ask Kiro:
```
Test this template with entity validation:
{{ states('sensor.temperature') | float > 25 }}
```

For condition templates:
```
Test this condition template:
{{ states('sensor.temperature') | float > 25 and 
   states('binary_sensor.window') == 'on' }}
```

**What to Test**:
- All condition templates
- All action templates (in service data)
- All trigger templates (if using template triggers)

**Checkpoint**: All templates should render without errors and return expected values.

#### Step 6: Validate YAML Syntax

Before uploading, validate the YAML:

Ask Kiro:
```
Validate the YAML syntax in ~/ha-dev-workspace/automations.yaml
```

**Common Issues**:
- Indentation errors (use spaces, not tabs)
- Missing colons
- Unquoted special characters
- Incorrect list formatting

**Checkpoint**: YAML validation should pass with no errors.

#### Step 7: Check for Conflicts

Before uploading, check if the remote file changed:

Ask Kiro:
```
Get metadata for automations.yaml and compare with my local version
```

**Conflict Scenarios**:
- **No conflict**: Hashes match, safe to upload
- **Remote newer**: Someone else modified it, need to merge
- **Local only**: You have changes, remote unchanged

**If Conflict Detected**: See "Handling Version Conflicts" section below.

**Checkpoint**: Confirm no conflicts or resolve them before proceeding.

#### Step 8: Upload Changes

Ask Kiro:
```
Upload ~/ha-dev-workspace/automations.yaml to my Home Assistant instance
```

Or with conflict protection:
```
Upload ~/ha-dev-workspace/automations.yaml with expected hash [hash from step 2]
```

**What Happens**:
- File is validated before upload
- If expected_hash provided, checked for conflicts
- File written to HA instance
- Configuration check triggered automatically

**Checkpoint**: Upload should succeed with no errors.

#### Step 9: Verify Configuration

Ask Kiro:
```
Check my Home Assistant configuration
```

**Expected Result**: Configuration check should pass.

**If Errors**:
1. Review error messages
2. Fix issues locally
3. Re-upload
4. Check configuration again

**Checkpoint**: Configuration check passes successfully.

#### Step 10: Verify Upload

Read back the file to confirm changes:

Ask Kiro:
```
Read automations.yaml
```

**What to Verify**:
- Your changes are present
- No unexpected modifications
- Formatting preserved
- Comments preserved

**Checkpoint**: File content matches your local version.

#### Step 11: Test Automation (Optional)

If possible, trigger the automation to test:

Ask Kiro:
```
Trigger automation.morning_routine
```

Or manually trigger through HA UI.

**Checkpoint**: Automation executes successfully.

### Summary Checklist

- [ ] Identified correct file
- [ ] Checked for remote changes
- [ ] Downloaded to local workspace
- [ ] Edited with IDE
- [ ] Tested all templates
- [ ] Validated YAML syntax
- [ ] Checked for conflicts
- [ ] Uploaded changes
- [ ] Verified configuration
- [ ] Confirmed upload successful
- [ ] Tested automation (optional)

## Workflow 2: Test Template

**Use When**: Developing or debugging Jinja2 templates

**Prerequisites**:
- HA instance accessible
- Entities referenced in template exist

### Step-by-Step Guide

#### Step 1: Write Template

Start with your template:
```jinja2
{{ states('sensor.temperature') | float > 25 }}
```

#### Step 2: Validate Syntax

Ask Kiro:
```
Validate this template syntax:
{{ states('sensor.temperature') | float > 25 }}
```

**What to Check**:
- No syntax errors
- Proper Jinja2 formatting
- Balanced brackets and quotes

**Checkpoint**: Template syntax is valid.

#### Step 3: Validate Entity References

Ask Kiro:
```
Test this template with entity validation:
{{ states('sensor.temperature') | float > 25 }}
```

**What to Check**:
- All entities exist
- No typos in entity_ids
- Entities are accessible

**If Entities Missing**:
```
List all sensor entities
```

Find the correct entity_id and update your template.

**Checkpoint**: All entity references are valid.

#### Step 4: Render with Current States

Ask Kiro:
```
Render this template:
{{ states('sensor.temperature') | float > 25 }}
```

**What to Check**:
- Template executes without errors
- Returns expected type (boolean, string, number)
- Result makes sense with current entity states

**Checkpoint**: Template renders successfully and returns expected result.

#### Step 5: Test Edge Cases

Test with different scenarios:

**Unavailable Entity**:
```jinja2
{{ states('sensor.temperature') | float(0) > 25 }}
```

**Unknown State**:
```jinja2
{% if states('sensor.temperature') not in ['unavailable', 'unknown'] %}
  {{ states('sensor.temperature') | float > 25 }}
{% else %}
  false
{% endif %}
```

**Checkpoint**: Template handles edge cases gracefully.

### Summary Checklist

- [ ] Template written
- [ ] Syntax validated
- [ ] Entity references validated
- [ ] Rendered with current states
- [ ] Edge cases tested
- [ ] Ready to use in automation

## Workflow 3: Create Package

**Use When**: Creating a new package file with related automations, scripts, and helpers

**Prerequisites**:
- Custom integration installed
- Packages enabled in configuration.yaml
- packages/* in allowed_paths

### Step-by-Step Guide

#### Step 1: Plan Package Structure

Decide what to include:
- Input helpers (input_boolean, input_number, etc.)
- Automations
- Scripts
- Template sensors
- Groups

**Example Structure**:
```yaml
# packages/lighting.yaml
input_boolean:
  lighting_automation:
    name: Enable Lighting Automation

automation:
  - alias: "Morning Lights"
    # ...

script:
  evening_lights:
    # ...

sensor:
  - platform: template
    sensors:
      # ...
```

**Checkpoint**: Package structure planned and documented.

#### Step 2: Create Local File

Create the file locally:
```bash
mkdir -p ~/ha-dev-workspace/packages
touch ~/ha-dev-workspace/packages/lighting.yaml
```

Open in your IDE:
```bash
code ~/ha-dev-workspace/packages/lighting.yaml
```

**Checkpoint**: Local file created and opened in IDE.

#### Step 3: Define Package Content

Write your package configuration:

```yaml
# packages/lighting.yaml

# Enable/disable automation
input_boolean:
  lighting_automation:
    name: Enable Lighting Automation
    icon: mdi:lightbulb-auto

# Morning routine
automation:
  - alias: "Morning Lights"
    description: "Turn on lights in the morning"
    trigger:
      - platform: time
        at: "07:00:00"
    condition:
      - condition: state
        entity_id: input_boolean.lighting_automation
        state: 'on'
      - condition: template
        value_template: "{{ states('sensor.temperature') | float > 15 }}"
    action:
      - service: light.turn_on
        target:
          entity_id: light.bedroom
        data:
          brightness_pct: 50

# Evening routine script
script:
  evening_lights:
    alias: "Evening Lights"
    sequence:
      - service: light.turn_on
        target:
          entity_id: light.living_room
        data:
          brightness_pct: 75
      - delay:
          seconds: 2
      - service: light.turn_on
        target:
          entity_id: light.kitchen
        data:
          brightness_pct: 60
```

**Checkpoint**: Package content written with proper YAML formatting.

#### Step 4: Test All Templates

Extract and test each template:

Ask Kiro:
```
Test this template with entity validation:
{{ states('sensor.temperature') | float > 15 }}
```

**Test Each**:
- Condition templates
- Action templates
- Trigger templates (if any)

**Checkpoint**: All templates validated and tested.

#### Step 5: Validate Entity References

Check that all entities exist:

Ask Kiro:
```
Does entity light.bedroom exist?
Does entity light.living_room exist?
Does entity light.kitchen exist?
Does entity sensor.temperature exist?
```

**If Entities Don't Exist**:
- Create them in HA first
- Or update package to use existing entities
- Or document that they need to be created

**Checkpoint**: All entity references are valid or documented.

#### Step 6: Validate YAML Syntax

Ask Kiro:
```
Validate the YAML syntax in ~/ha-dev-workspace/packages/lighting.yaml
```

**Checkpoint**: YAML syntax is valid.

#### Step 7: Upload Package

Ask Kiro:
```
Upload ~/ha-dev-workspace/packages/lighting.yaml to my Home Assistant instance
```

**What Happens**:
- File validated before upload
- Written to packages directory
- Configuration check triggered

**Checkpoint**: Upload succeeds with no errors.

#### Step 8: Verify Configuration

Ask Kiro:
```
Check my Home Assistant configuration
```

**Expected Result**: Configuration check passes.

**Common Issues**:
- Entity references to non-existent entities
- Duplicate entity_ids
- Invalid service calls
- Template syntax errors

**Checkpoint**: Configuration check passes.

#### Step 9: Restart Home Assistant

Packages require a restart to load:

**Via UI**:
- Settings → System → Restart

**Via Service Call**:
Ask Kiro:
```
Call service homeassistant.restart
```

**Checkpoint**: HA restarts successfully.

#### Step 10: Verify Package Loaded

After restart, verify entities exist:

Ask Kiro:
```
Does entity input_boolean.lighting_automation exist?
List all automations containing "Morning Lights"
```

**Checkpoint**: Package entities and automations are loaded.

#### Step 11: Test Functionality

Test the package:

**Enable Automation**:
```
Turn on input_boolean.lighting_automation
```

**Trigger Automation** (if possible):
```
Trigger automation.morning_lights
```

**Run Script**:
```
Call script.evening_lights
```

**Checkpoint**: Package functionality works as expected.

### Summary Checklist

- [ ] Package structure planned
- [ ] Local file created
- [ ] Package content written
- [ ] All templates tested
- [ ] Entity references validated
- [ ] YAML syntax validated
- [ ] Package uploaded
- [ ] Configuration verified
- [ ] HA restarted
- [ ] Package loaded successfully
- [ ] Functionality tested

## Workflow 4: Edit Configuration

**Use When**: Modifying `configuration.yaml` or other core configuration files

**Prerequisites**:
- Custom integration installed
- configuration.yaml in allowed_paths
- Admin access token configured

### Step-by-Step Guide

#### Step 1: Backup Current Configuration

Before making changes, create a backup:

Ask Kiro:
```
Read configuration.yaml and save to ~/ha-dev-workspace/backups/configuration.yaml.backup
```

**Checkpoint**: Backup created successfully.

#### Step 2: Check for Remote Changes

Ask Kiro:
```
Get metadata for configuration.yaml
```

**Record**:
- Current hash
- Last modified timestamp

**Checkpoint**: Metadata recorded for conflict detection.

#### Step 3: Download Configuration

Ask Kiro:
```
Read configuration.yaml and save to ~/ha-dev-workspace/configuration.yaml
```

**Checkpoint**: File downloaded to local workspace.

#### Step 4: Edit Locally

Open in your IDE:
```bash
code ~/ha-dev-workspace/configuration.yaml
```

**Common Changes**:
- Adding integrations
- Modifying logger settings
- Updating recorder configuration
- Adding includes or packages
- Changing homeassistant settings

**Best Practices**:
- Keep changes minimal
- Add comments explaining changes
- Follow HA configuration style
- Use secrets for sensitive data

**Checkpoint**: Changes made and saved locally.

#### Step 5: Validate YAML Syntax

Ask Kiro:
```
Validate the YAML syntax in ~/ha-dev-workspace/configuration.yaml
```

**Checkpoint**: YAML syntax is valid.

#### Step 6: Check for Conflicts

Ask Kiro:
```
Get metadata for configuration.yaml and compare with my local version
```

**If Conflict**: See "Handling Version Conflicts" section.

**Checkpoint**: No conflicts detected.

#### Step 7: Upload Configuration

Ask Kiro:
```
Upload ~/ha-dev-workspace/configuration.yaml to my Home Assistant instance
```

**Checkpoint**: Upload succeeds.

#### Step 8: Check Configuration

Ask Kiro:
```
Check my Home Assistant configuration
```

**Expected Result**: Configuration check passes.

**If Errors**:
1. Review error messages carefully
2. Fix issues locally
3. Re-upload
4. Check again

**Checkpoint**: Configuration check passes.

#### Step 9: Restart Home Assistant

Configuration changes typically require restart:

Ask Kiro:
```
Call service homeassistant.restart
```

**Checkpoint**: HA restarts successfully.

#### Step 10: Verify Changes

After restart, verify your changes took effect:

**Check Logs**:
```
Show me errors from the last 5 minutes
```

**Verify Integrations**:
```
List all available services
```

**Check Entities**:
```
List all entities
```

**Checkpoint**: Changes applied successfully, no errors.

### Summary Checklist

- [ ] Backup created
- [ ] Remote changes checked
- [ ] Configuration downloaded
- [ ] Changes made locally
- [ ] YAML syntax validated
- [ ] Conflicts checked
- [ ] Configuration uploaded
- [ ] Configuration check passed
- [ ] HA restarted
- [ ] Changes verified

## Handling Version Conflicts

### What is a Version Conflict?

A version conflict occurs when:
1. You download a file
2. Someone else (or another process) modifies it on the HA instance
3. You try to upload your changes

### Detecting Conflicts

**Before Upload**:
Ask Kiro:
```
Get metadata for automations.yaml
```

Compare the `content_hash` with the hash from when you downloaded the file.

**During Upload**:
Use expected_hash parameter:
```
Upload ~/ha-dev-workspace/automations.yaml with expected hash [original_hash]
```

If hashes don't match, upload will fail with conflict error.

### Resolution Strategies

#### Strategy 1: Keep Local Changes

**When to Use**: You're confident your changes are correct and should overwrite remote changes.

**Steps**:
1. Review your local changes
2. Upload without expected_hash check:
   ```
   Upload ~/ha-dev-workspace/automations.yaml (force)
   ```
3. Verify upload succeeded

**Risk**: Remote changes will be lost.

#### Strategy 2: Keep Remote Changes

**When to Use**: Remote changes are more important than your local changes.

**Steps**:
1. Discard local changes
2. Download fresh copy:
   ```
   Read automations.yaml and save to ~/ha-dev-workspace/automations.yaml
   ```
3. Start editing again

**Risk**: Your local changes will be lost.

#### Strategy 3: Manual Merge

**When to Use**: Both local and remote changes are important.

**Steps**:

1. **Download remote version**:
   ```
   Read automations.yaml and save to ~/ha-dev-workspace/automations.yaml.remote
   ```

2. **Compare versions**:
   ```bash
   diff ~/ha-dev-workspace/automations.yaml ~/ha-dev-workspace/automations.yaml.remote
   ```
   
   Or use a visual diff tool:
   ```bash
   code --diff ~/ha-dev-workspace/automations.yaml ~/ha-dev-workspace/automations.yaml.remote
   ```

3. **Identify conflicts**:
   - Lines changed in both versions
   - Additions in both versions
   - Deletions vs modifications

4. **Merge manually**:
   - Open both files
   - Create merged version
   - Include changes from both versions
   - Resolve any logical conflicts

5. **Test merged version**:
   - Validate YAML syntax
   - Test all templates
   - Check entity references

6. **Upload merged version**:
   ```
   Upload ~/ha-dev-workspace/automations.yaml
   ```

7. **Verify**:
   ```
   Check my Home Assistant configuration
   Read automations.yaml
   ```

#### Strategy 4: Abort and Coordinate

**When to Use**: Conflicts are complex or you need to coordinate with others.

**Steps**:
1. Don't upload
2. Contact other person/team
3. Coordinate changes
4. Decide on approach together
5. Proceed with agreed strategy

### Preventing Conflicts

**Best Practices**:
1. **Check before starting**: Always get metadata before downloading
2. **Work quickly**: Minimize time between download and upload
3. **Communicate**: Let others know you're working on a file
4. **Use version control**: Commit changes to git for tracking
5. **Small changes**: Make focused, small changes rather than large rewrites
6. **Check before upload**: Always check metadata before uploading

## Working Locally vs. Directly on Instance

### When to Work Locally

**Advantages**:
- Full IDE support (syntax highlighting, autocomplete)
- Version control integration
- Offline editing
- Better diff tools
- Safer (test before deploying)

**Use For**:
- Complex automations
- Large configuration changes
- Package development
- Template development
- Multi-file changes

### When to Work Directly on Instance

**Advantages**:
- Faster for small changes
- No download/upload cycle
- Immediate testing
- No conflict risk

**Use For**:
- Quick fixes
- Single-line changes
- Testing ideas
- Emergency fixes
- UI-managed entities

### Hybrid Approach

**Best Practice**: Combine both approaches

1. **Quick iteration**: Work directly on instance
2. **Refinement**: Download to local, refine with IDE
3. **Testing**: Test locally
4. **Deployment**: Upload and verify

## Checkpoints and Verification

### Why Checkpoints Matter

Checkpoints ensure:
- Errors caught early
- Changes validated before proceeding
- Rollback points if needed
- Confidence in deployment

### Key Checkpoints

1. **After Download**: Verify file saved correctly
2. **After Edit**: Validate YAML syntax
3. **After Template Changes**: Test all templates
4. **Before Upload**: Check for conflicts
5. **After Upload**: Verify configuration
6. **After Restart**: Check for errors

### Verification Steps

**YAML Validation**:
```
Validate YAML syntax in [file]
```

**Template Testing**:
```
Test this template: [template]
```

**Entity Validation**:
```
Does entity [entity_id] exist?
```

**Configuration Check**:
```
Check my Home Assistant configuration
```

**Log Review**:
```
Show me errors from the last 5 minutes
```

## Best Practices Summary

### Before Starting
- [ ] Check for remote changes
- [ ] Create backup
- [ ] Plan your changes
- [ ] Identify all affected files

### During Development
- [ ] Work in local workspace
- [ ] Use IDE with YAML support
- [ ] Test templates as you write
- [ ] Validate syntax frequently
- [ ] Keep changes focused

### Before Deployment
- [ ] Validate all YAML
- [ ] Test all templates
- [ ] Check entity references
- [ ] Check for conflicts
- [ ] Review changes one more time

### During Deployment
- [ ] Upload with conflict protection
- [ ] Verify configuration check passes
- [ ] Read back uploaded file
- [ ] Check logs for errors

### After Deployment
- [ ] Restart if needed
- [ ] Verify changes applied
- [ ] Test functionality
- [ ] Monitor for issues
- [ ] Document changes

## Troubleshooting Common Issues

### Issue: Upload Fails with Conflict Error

**Cause**: File was modified remotely since download

**Solution**: Use conflict resolution workflow (see above)

### Issue: Configuration Check Fails

**Cause**: Syntax error or invalid configuration

**Solution**:
1. Review error message carefully
2. Fix issue locally
3. Validate YAML syntax
4. Re-upload
5. Check configuration again

### Issue: Template Test Fails

**Cause**: Entity doesn't exist or template syntax error

**Solution**:
1. Validate template syntax first
2. Check entity exists
3. Test with simpler template
4. Build up complexity gradually

### Issue: Changes Don't Appear After Upload

**Cause**: Restart required or caching

**Solution**:
1. Restart Home Assistant
2. Clear browser cache
3. Verify file was actually uploaded
4. Check logs for loading errors

### Issue: File Not in Allowed Paths

**Cause**: Security configuration blocks access

**Solution**:
1. Add file to allowed_paths in configuration.yaml
2. Restart Home Assistant
3. Verify configuration loaded

## Quick Reference

### Edit Automation
```
1. List files
2. Get metadata
3. Download file
4. Edit locally
5. Test templates
6. Validate YAML
7. Check conflicts
8. Upload
9. Verify config
10. Verify upload
```

### Test Template
```
1. Write template
2. Validate syntax
3. Validate entities
4. Render template
5. Test edge cases
```

### Create Package
```
1. Plan structure
2. Create local file
3. Write content
4. Test templates
5. Validate entities
6. Validate YAML
7. Upload
8. Verify config
9. Restart HA
10. Verify loaded
11. Test functionality
```

### Edit Configuration
```
1. Backup
2. Check metadata
3. Download
4. Edit locally
5. Validate YAML
6. Check conflicts
7. Upload
8. Check config
9. Restart HA
10. Verify changes
```

## Complete Example: Create New Package

This example shows creating a new package file from scratch with automations, scripts, and helpers.

### Scenario

You want to create a new "Climate Control" package that includes:
- Input boolean to enable/disable automation
- Automation to adjust thermostat based on temperature
- Script to set comfort mode
- Template sensor for heat index

### Step-by-Step Execution

#### Step 1: Plan Package Structure

**You decide on:**
```yaml
# packages/climate_control.yaml

input_boolean:
  climate_automation:
    name: "Enable Climate Automation"

automation:
  - alias: "Auto Adjust Thermostat"
    # Adjust based on temperature

script:
  comfort_mode:
    # Set comfortable temperature

sensor:
  - platform: template
    sensors:
      heat_index:
        # Calculate heat index
```

**Checkpoint:** ✅ Structure planned

#### Step 2: Create Local File

**You create the file:**
```bash
mkdir -p ~/ha-dev-workspace/packages
touch ~/ha-dev-workspace/packages/climate_control.yaml
code ~/ha-dev-workspace/packages/climate_control.yaml
```

**Checkpoint:** ✅ File created

#### Step 3: Write Package Content

**You write:**
```yaml
# Climate Control Package
# Manages thermostat automation and comfort settings

# Enable/disable automation
input_boolean:
  climate_automation:
    name: "Enable Climate Automation"
    icon: mdi:thermostat-auto

# Auto-adjust thermostat based on temperature
automation:
  - id: auto_adjust_thermostat
    alias: "Auto Adjust Thermostat"
    description: "Adjust thermostat when temperature is too high or low"
    trigger:
      - platform: numeric_state
        entity_id: sensor.indoor_temperature
        above: 24
        for:
          minutes: 5
      - platform: numeric_state
        entity_id: sensor.indoor_temperature
        below: 20
        for:
          minutes: 5
    condition:
      - condition: state
        entity_id: input_boolean.climate_automation
        state: 'on'
      - condition: template
        value_template: "{{ states('climate.thermostat') not in ['unavailable', 'unknown'] }}"
    action:
      - choose:
          - conditions:
              - condition: numeric_state
                entity_id: sensor.indoor_temperature
                above: 24
            sequence:
              - service: climate.set_temperature
                target:
                  entity_id: climate.thermostat
                data:
                  temperature: 22
              - service: notify.mobile_app
                data:
                  message: "Temperature high ({{ states('sensor.indoor_temperature') }}°C). Cooling to 22°C."
          - conditions:
              - condition: numeric_state
                entity_id: sensor.indoor_temperature
                below: 20
            sequence:
              - service: climate.set_temperature
                target:
                  entity_id: climate.thermostat
                data:
                  temperature: 21
              - service: notify.mobile_app
                data:
                  message: "Temperature low ({{ states('sensor.indoor_temperature') }}°C). Heating to 21°C."

# Comfort mode script
script:
  comfort_mode:
    alias: "Set Comfort Mode"
    description: "Set thermostat to comfortable temperature"
    sequence:
      - service: climate.set_temperature
        target:
          entity_id: climate.thermostat
        data:
          temperature: 21
      - service: climate.set_hvac_mode
        target:
          entity_id: climate.thermostat
        data:
          hvac_mode: "auto"
      - service: notify.mobile_app
        data:
          message: "Comfort mode activated. Temperature set to 21°C."

# Heat index sensor
sensor:
  - platform: template
    sensors:
      heat_index:
        friendly_name: "Heat Index"
        unit_of_measurement: "°C"
        value_template: >
          {% set temp = states('sensor.indoor_temperature') | float(0) %}
          {% set humidity = states('sensor.indoor_humidity') | float(0) %}
          {% if temp > 0 and humidity > 0 %}
            {{ ((temp * 1.8 + 32) + (humidity * 0.5) - 32) / 1.8 | round(1) }}
          {% else %}
            {{ temp }}
          {% endif %}
```

**Checkpoint:** ✅ Package content written

#### Step 4: Test All Templates

**You test the condition template:**
```
Test this template with entity validation:
{{ states('climate.thermostat') not in ['unavailable', 'unknown'] }}
```

**Kiro responds:**
```
✓ Template syntax valid
✓ Entity climate.thermostat exists
✓ Current state: heat
✓ Template result: True
```

**You test the notification templates:**
```
Test this template with entity validation:
Temperature high ({{ states('sensor.indoor_temperature') }}°C). Cooling to 22°C.
```

**Kiro responds:**
```
✓ Template syntax valid
✓ Entity sensor.indoor_temperature exists
✓ Template result: Temperature high (23.5°C). Cooling to 22°C.
```

**You test the heat index template:**
```
Test this template with entity validation:
{% set temp = states('sensor.indoor_temperature') | float(0) %}
{% set humidity = states('sensor.indoor_humidity') | float(0) %}
{% if temp > 0 and humidity > 0 %}
  {{ ((temp * 1.8 + 32) + (humidity * 0.5) - 32) / 1.8 | round(1) }}
{% else %}
  {{ temp }}
{% endif %}
```

**Kiro responds:**
```
✓ Template syntax valid
✓ Entity sensor.indoor_temperature exists
✓ Entity sensor.indoor_humidity exists
✓ Current values: temp=23.5°C, humidity=55%
✓ Template result: 24.8
```

**Checkpoint:** ✅ All templates tested

#### Step 5: Validate Entity References

**You ask Kiro:**
```
Check if these entities exist:
- sensor.indoor_temperature
- sensor.indoor_humidity
- climate.thermostat
```

**Kiro responds:**
```
✓ sensor.indoor_temperature exists (current: 23.5°C)
✓ sensor.indoor_humidity exists (current: 55%)
✓ climate.thermostat exists (current: heat, 21°C)

All entities are valid and accessible.
```

**Checkpoint:** ✅ All entities validated

#### Step 6: Validate YAML Syntax

**You ask Kiro:**
```
Validate the YAML syntax in ~/ha-dev-workspace/packages/climate_control.yaml
```

**Kiro responds:**
```
✓ YAML syntax is valid
✓ No indentation errors
✓ All quotes balanced
✓ File structure is correct
✓ Ready for upload
```

**Checkpoint:** ✅ YAML validated

#### Step 7: Upload Package

**You ask Kiro:**
```
Upload ~/ha-dev-workspace/packages/climate_control.yaml to my Home Assistant instance
```

**Kiro responds:**
```
Uploading packages/climate_control.yaml...
✓ YAML syntax validated
✓ File uploaded successfully (4.2 KB)
✓ New file created at packages/climate_control.yaml
✓ Configuration check triggered
```

**Checkpoint:** ✅ Upload successful

#### Step 8: Verify Configuration

**Kiro automatically checks:**
```
Checking Home Assistant configuration...
✓ Configuration is valid
✓ Package loaded successfully
✓ 1 new automation found
✓ 1 new script found
✓ 1 new input_boolean found
✓ 1 new sensor found
✓ No errors detected
```

**Checkpoint:** ✅ Configuration valid

#### Step 9: Restart Home Assistant

**You restart HA:**
```
Restart Home Assistant to load the new package
```

**Kiro responds:**
```
⚠️ Note: Packages require a Home Assistant restart to load.
Please restart HA manually through:
- Settings → System → Restart
- Or Developer Tools → YAML → Restart

I'll wait for you to confirm the restart is complete.
```

**You restart through the UI and confirm:**
```
HA has restarted
```

**Checkpoint:** ✅ HA restarted

#### Step 10: Verify Package Loaded

**You ask Kiro:**
```
Check if these entities exist:
- input_boolean.climate_automation
- automation.auto_adjust_thermostat
- script.comfort_mode
- sensor.heat_index
```

**Kiro responds:**
```
✓ input_boolean.climate_automation exists (state: off)
✓ automation.auto_adjust_thermostat exists (state: on)
✓ script.comfort_mode exists
✓ sensor.heat_index exists (state: 24.8°C)

All package entities loaded successfully!
```

**Checkpoint:** ✅ Package loaded

#### Step 11: Test Functionality

**You enable the automation:**
```
Turn on input_boolean.climate_automation
```

**Kiro responds:**
```
✓ input_boolean.climate_automation turned on
✓ Climate automation is now active
```

**You test the script:**
```
Call script.comfort_mode
```

**Kiro responds:**
```
✓ Script executed successfully
✓ Thermostat set to 21°C
✓ HVAC mode set to auto
✓ Notification sent
```

**You check the sensor:**
```
What's the state of sensor.heat_index?
```

**Kiro responds:**
```
sensor.heat_index: 24.8°C
Attributes:
  - friendly_name: Heat Index
  - unit_of_measurement: °C
  - Based on: temp=23.5°C, humidity=55%
```

**Checkpoint:** ✅ All functionality working

### Summary

**Total Time:** ~25 minutes

**Package Created:**
- ✅ 1 input boolean (climate_automation)
- ✅ 1 automation (auto_adjust_thermostat)
- ✅ 1 script (comfort_mode)
- ✅ 1 template sensor (heat_index)

**Verification:**
- ✅ All templates tested with real data
- ✅ All entities validated
- ✅ YAML syntax validated
- ✅ Configuration check passed
- ✅ Package loaded after restart
- ✅ All functionality tested

**Files Created:**
- `packages/climate_control.yaml` (4.2 KB)

**Next Steps:**
- Monitor automation behavior over next few days
- Adjust temperature thresholds if needed
- Add more conditions (e.g., time of day, occupancy)
- Consider adding away mode

## Complete Example: Edit Automation Workflow

This example shows a complete workflow from start to finish, including version checking, template testing, and upload verification.

### Scenario

You want to modify the "Morning Routine" automation to:
- Change the trigger time from 7:00 AM to 7:30 AM
- Add a condition to check if temperature is above 15°C
- Update the notification message to include current temperature

### Step-by-Step Execution

#### Step 1: Identify the File

**You ask Kiro:**
```
List all configuration files
```

**Kiro responds:**
```
Found 15 configuration files:
- configuration.yaml (5.2 KB)
- automations.yaml (12.4 KB)  ← Your automation is here
- scripts.yaml (3.1 KB)
- scenes.yaml (1.8 KB)
- packages/lighting.yaml (4.5 KB)
...
```

**Checkpoint:** ✅ Confirmed automations.yaml contains the automation

#### Step 2: Check for Remote Changes

**You ask Kiro:**
```
Get metadata for automations.yaml
```

**Kiro responds:**
```json
{
  "path": "automations.yaml",
  "size": 12654,
  "modified_at": "2026-03-05T08:15:00Z",
  "content_hash": "a1b2c3d4e5f6789abcdef0123456789abcdef0123456789abcdef0123456789",
  "exists": true,
  "accessible": true
}
```

**You note:** Last modified yesterday at 8:15 AM. Hash: `a1b2c3...`

**Checkpoint:** ✅ Metadata recorded for conflict detection

#### Step 3: Download File

**You ask Kiro:**
```
Read automations.yaml and save it to ~/ha-dev-workspace/automations.yaml
```

**Kiro responds:**
```
✓ Downloaded automations.yaml (12.6 KB)
✓ Saved to ~/ha-dev-workspace/automations.yaml
✓ Metadata recorded for version tracking
```

**Checkpoint:** ✅ File downloaded successfully

#### Step 4: Edit Locally

**You open the file:**
```bash
code ~/ha-dev-workspace/automations.yaml
```

**Original automation:**
```yaml
- id: morning_routine
  alias: "Morning Routine"
  description: "Turn on lights and send notification"
  trigger:
    - platform: time
      at: "07:00:00"
  action:
    - service: light.turn_on
      target:
        entity_id: light.bedroom
      data:
        brightness_pct: 50
    - service: notify.mobile_app
      data:
        message: "Good morning! Time to wake up."
```

**You modify it to:**
```yaml
- id: morning_routine
  alias: "Morning Routine"
  description: "Turn on lights and send notification"
  trigger:
    - platform: time
      at: "07:30:00"  # Changed from 07:00:00
  condition:
    - condition: template
      value_template: "{{ states('sensor.temperature') | float > 15 }}"  # New condition
  action:
    - service: light.turn_on
      target:
        entity_id: light.bedroom
      data:
        brightness_pct: 50
    - service: notify.mobile_app
      data:
        message: >  # Updated message
          Good morning! Time to wake up.
          Current temperature: {{ states('sensor.temperature') }}°C
```

**Checkpoint:** ✅ Changes made and saved

#### Step 5: Test Templates

**You ask Kiro to test the condition template:**
```
Test this template with entity validation:
{{ states('sensor.temperature') | float > 15 }}
```

**Kiro responds:**
```
✓ Template syntax valid
✓ Entity sensor.temperature exists
✓ Current state: 18.5
✓ Template result: True

The condition will evaluate to True with current temperature.
```

**You ask Kiro to test the notification template:**
```
Test this template with entity validation:
Good morning! Time to wake up.
Current temperature: {{ states('sensor.temperature') }}°C
```

**Kiro responds:**
```
✓ Template syntax valid
✓ Entity sensor.temperature exists
✓ Template result:
Good morning! Time to wake up.
Current temperature: 18.5°C
```

**Checkpoint:** ✅ All templates tested and working

#### Step 6: Validate YAML Syntax

**You ask Kiro:**
```
Validate the YAML syntax in ~/ha-dev-workspace/automations.yaml
```

**Kiro responds:**
```
✓ YAML syntax is valid
✓ No indentation errors
✓ All quotes balanced
✓ File is ready for upload
```

**Checkpoint:** ✅ YAML validation passed

#### Step 7: Check for Conflicts

**You ask Kiro:**
```
Get metadata for automations.yaml and compare with my local version
```

**Kiro responds:**
```
Checking for conflicts...

Local version (downloaded):
  Hash: a1b2c3d4e5f6789...
  Downloaded: 2026-03-06T09:00:00Z

Remote version (current):
  Hash: a1b2c3d4e5f6789...
  Modified: 2026-03-05T08:15:00Z

✓ No conflicts detected
✓ Hashes match - safe to upload
```

**Checkpoint:** ✅ No conflicts, safe to proceed

#### Step 8: Upload Changes

**You ask Kiro:**
```
Upload ~/ha-dev-workspace/automations.yaml to my Home Assistant instance with expected hash a1b2c3d4e5f6789...
```

**Kiro responds:**
```
Uploading automations.yaml...
✓ YAML syntax validated
✓ Expected hash matches current file
✓ File uploaded successfully
✓ New hash: d4e5f6a7b8c9012...
✓ Configuration check triggered
```

**Checkpoint:** ✅ Upload successful

#### Step 9: Verify Configuration

**Kiro automatically checks configuration:**
```
Checking Home Assistant configuration...
✓ Configuration is valid
✓ All automations loaded successfully
✓ No errors detected
```

**Checkpoint:** ✅ Configuration check passed

#### Step 10: Verify Upload

**You ask Kiro:**
```
Read automations.yaml and show me the morning_routine automation
```

**Kiro responds:**
```yaml
- id: morning_routine
  alias: "Morning Routine"
  description: "Turn on lights and send notification"
  trigger:
    - platform: time
      at: "07:30:00"  ✓ Updated
  condition:
    - condition: template
      value_template: "{{ states('sensor.temperature') | float > 15 }}"  ✓ Added
  action:
    - service: light.turn_on
      target:
        entity_id: light.bedroom
      data:
        brightness_pct: 50
    - service: notify.mobile_app
      data:
        message: >
          Good morning! Time to wake up.
          Current temperature: {{ states('sensor.temperature') }}°C  ✓ Updated
```

**Checkpoint:** ✅ All changes present and correct

#### Step 11: Test Automation (Optional)

**You ask Kiro:**
```
Trigger automation.morning_routine to test it
```

**Kiro responds:**
```
✓ Automation triggered
✓ Condition evaluated: True (temperature is 18.5°C)
✓ Light turned on
✓ Notification sent: "Good morning! Time to wake up. Current temperature: 18.5°C"
```

**Checkpoint:** ✅ Automation works as expected

### Summary

**Total Time:** ~15 minutes

**Changes Made:**
- ✅ Trigger time changed from 7:00 to 7:30
- ✅ Temperature condition added
- ✅ Notification message updated with current temperature

**Verification:**
- ✅ Templates tested with real entity data
- ✅ YAML syntax validated
- ✅ No version conflicts
- ✅ Configuration check passed
- ✅ Upload verified
- ✅ Automation tested successfully

**Files Modified:**
- `automations.yaml` (12.6 KB → 12.8 KB)

**Next Steps:**
- Monitor automation execution over next few days
- Adjust temperature threshold if needed
- Consider adding more conditions (e.g., day of week)

## Next Steps

- Read `local-development.md` for workspace setup
- Read `version-management.md` for conflict resolution details
- Read `template-testing.md` for advanced template techniques
- Read `debugging.md` for troubleshooting workflows
- Read `file-management.md` for file access patterns

## Additional Resources

- [Home Assistant Configuration](https://www.home-assistant.io/docs/configuration/)
- [Automation Documentation](https://www.home-assistant.io/docs/automation/)
- [Template Documentation](https://www.home-assistant.io/docs/configuration/templating/)
- [Package Documentation](https://www.home-assistant.io/docs/configuration/packages/)
