# Template Testing Workflows

Complete guide for developing and testing Home Assistant Jinja2 templates using the MCP tools.

## Why Test Templates?

Templates in Home Assistant can be complex and error-prone. Common issues:
- Undefined entity references
- Syntax errors in Jinja2
- Type mismatches (string vs number)
- Missing filters or functions
- Incorrect state access

Testing templates before deploying them saves time and prevents broken automations.

## Available Tools for Template Testing

1. **render_template** - Execute template and see result
2. **validate_template** - Check syntax without executing
3. **get_states** - Verify entities exist
4. **validate_entities** (via render_template) - Check entity references

## Workflow 1: Basic Template Testing

### Step 1: Write Your Template
```jinja2
{{ states('sensor.temperature') | float + 5 }}
```

### Step 2: Test with render_template
Ask Kiro:
```
Test this template: {{ states('sensor.temperature') | float + 5 }}
```

Kiro will use the `render_template` tool and show you the result.

### Step 3: Validate Entity References
Ask Kiro:
```
Test this template with entity validation: {{ states('sensor.temperature') | float + 5 }}
```

Kiro will use `render_template` with `validate_entities: true` and warn about missing entities.

## Workflow 2: Complex Template Development

### Step 1: Start Simple
Begin with the simplest version:
```jinja2
{{ states('sensor.temperature') }}
```

### Step 2: Add Complexity Gradually
```jinja2
{{ states('sensor.temperature') | float }}
```

Then:
```jinja2
{{ states('sensor.temperature') | float + 5 }}
```

Finally:
```jinja2
{% if states('sensor.temperature') | float > 20 %}
  Hot
{% else %}
  Cold
{% endif %}
```

### Step 3: Test Each Step
Test after each addition to catch errors early.

## Workflow 3: Debugging Template Errors

### Common Error: Undefined Entity

**Template:**
```jinja2
{{ states('sensor.nonexistent') }}
```

**Steps:**
1. Use `render_template` with `validate_entities: true`
2. Check warnings for missing entities
3. Use `get_states` to list available entities
4. Fix entity_id spelling

**Ask Kiro:**
```
List all sensor entities
```

### Common Error: Type Mismatch

**Template:**
```jinja2
{{ states('sensor.temperature') + 5 }}
```

**Problem:** String + number doesn't work

**Solution:** Convert to float first
```jinja2
{{ states('sensor.temperature') | float + 5 }}
```

### Common Error: Syntax Error

**Template:**
```jinja2
{{ states('sensor.temperature' }}
```

**Problem:** Missing closing parenthesis

**Steps:**
1. Use `validate_template` tool first
2. Check error message for line number
3. Fix syntax
4. Test again

## Workflow 4: Multi-Entity Templates

### Testing Templates with Multiple Entities

**Template:**
```jinja2
{% set temp = states('sensor.temperature') | float %}
{% set humidity = states('sensor.humidity') | float %}
{{ temp * humidity / 100 }}
```

**Steps:**
1. Verify all entities exist:
   ```
   Check if these entities exist: sensor.temperature, sensor.humidity
   ```

2. Test template with validation:
   ```
   Test this template with entity validation: [paste template]
   ```

3. Check individual entity states if needed:
   ```
   What's the state of sensor.temperature?
   What's the state of sensor.humidity?
   ```

## Workflow 5: Template for Automations

### Testing Automation Conditions

**Condition Template:**
```jinja2
{{ states('sensor.temperature') | float > 25 and 
   states('binary_sensor.window') == 'on' }}
```

**Steps:**
1. Test the template:
   ```
   Test this condition template: [paste template]
   ```

2. Verify it returns true/false:
   - Should return `True` or `False`
   - Not a string or number

3. Test edge cases:
   - What if sensor is unavailable?
   - What if sensor returns non-numeric value?

**Improved Template:**
```jinja2
{{ states('sensor.temperature') | float(0) > 25 and 
   states('binary_sensor.window') == 'on' }}
```

## Workflow 6: Template for Notifications

### Testing Notification Templates

**Template:**
```jinja2
Temperature is {{ states('sensor.temperature') }}°C
Humidity is {{ states('sensor.humidity') }}%
Status: {% if states('sensor.temperature') | float > 25 %}Hot{% else %}Normal{% endif %}
```

**Steps:**
1. Test the full template
2. Check formatting and spacing
3. Verify all entities are valid
4. Test with different entity states

**Ask Kiro:**
```
Test this notification template: [paste template]
```

## Best Practices

### 1. Always Validate Entities
Use `validate_entities: true` when testing templates that reference entities.

### 2. Use Default Values
Protect against unavailable entities:
```jinja2
{{ states('sensor.temperature') | float(20) }}
```

### 3. Test Edge Cases
- Entity unavailable
- Entity returns "unknown"
- Entity returns "unavailable"
- Numeric entity returns non-numeric value

### 4. Use Type Conversions
Always convert states to expected types:
- `| float` for numbers
- `| int` for integers
- `| string` for text

### 5. Check Return Types
Ensure templates return expected types:
- Conditions should return boolean
- Notifications should return string
- Calculations should return number

## Common Template Patterns

### Pattern 1: Safe Numeric Conversion
```jinja2
{{ states('sensor.temperature') | float(0) }}
```

### Pattern 2: Check Entity Availability
```jinja2
{% if states('sensor.temperature') not in ['unavailable', 'unknown'] %}
  {{ states('sensor.temperature') }}
{% else %}
  N/A
{% endif %}
```

### Pattern 3: Multiple Entity Check
```jinja2
{% set temp = states('sensor.temperature') | float(0) %}
{% set humidity = states('sensor.humidity') | float(0) %}
{% if temp > 0 and humidity > 0 %}
  {{ temp * humidity / 100 }}
{% else %}
  0
{% endif %}
```

### Pattern 4: Time-Based Logic
```jinja2
{% if now().hour >= 22 or now().hour < 6 %}
  Night
{% else %}
  Day
{% endif %}
```

## Troubleshooting

### Template Returns Unexpected Value

**Steps:**
1. Break template into parts
2. Test each part separately
3. Check entity states individually
4. Verify type conversions

### Template Works in HA but Not in MCP

**Possible Causes:**
- Different HA version
- Different entity states
- Timing differences

**Solution:**
- Test with current entity states
- Use `get_states` to verify entity values
- Check HA version compatibility

### Entity Validation Shows False Positives

**Cause:** Entity exists but is disabled or hidden

**Solution:**
- Use `get_states` to check entity
- Verify entity is enabled in HA
- Check entity_id spelling exactly

## Advanced Techniques

### Testing with Mock Data

If you want to test a template before entities exist:
1. Create a test entity in HA
2. Set its state manually
3. Test template with test entity
4. Replace with real entity later

### Batch Testing Multiple Templates

Test multiple templates in sequence:
1. List all templates to test
2. Test each one
3. Document results
4. Fix any errors
5. Retest

### Template Performance Testing

For complex templates:
1. Test with `render_template`
2. Note execution time
3. Simplify if too slow
4. Consider splitting into multiple templates

## Quick Reference

### Test Simple Template
```
Test this template: {{ states('sensor.temperature') }}
```

### Test with Entity Validation
```
Test this template with entity validation: {{ states('sensor.temperature') }}
```

### Validate Syntax Only
```
Validate this template syntax: {{ states('sensor.temperature') }}
```

### Check Entity Exists
```
Does entity sensor.temperature exist?
```

### List Available Entities
```
List all sensor entities
```

## Workflow 7: Local Template Development

### Overview
For complex templates or templates embedded in automations, you can download files locally, edit them in your IDE, test them, and upload them back.

### Step 1: Download Template File

**For templates in automations.yaml:**
```
Download automations.yaml to my local workspace
```

Kiro will:
1. Check file metadata for version tracking
2. Download the file to `~/ha-dev-workspace/automations.yaml`
3. Record metadata (hash, timestamp) for conflict detection

### Step 2: Edit Locally

Open the file in your IDE:
- Full syntax highlighting
- Auto-completion
- Multi-cursor editing
- Find/replace across file

Edit the template within the automation:
```yaml
- alias: "Temperature Alert"
  trigger:
    - platform: numeric_state
      entity_id: sensor.temperature
      above: 25
  action:
    - service: notify.mobile_app
      data:
        message: >
          {% set temp = states('sensor.temperature') | float(0) %}
          {% set humidity = states('sensor.humidity') | float(0) %}
          Temperature is {{ temp }}°C with {{ humidity }}% humidity.
          Heat index: {{ (temp * 1.8 + 32 + humidity * 0.5) | round(1) }}°F
```

### Step 3: Test Template with Real Entity Data

Extract just the template part and test it:
```
Test this template with entity validation:
{% set temp = states('sensor.temperature') | float(0) %}
{% set humidity = states('sensor.humidity') | float(0) %}
Temperature is {{ temp }}°C with {{ humidity }}% humidity.
Heat index: {{ (temp * 1.8 + 32 + humidity * 0.5) | round(1) }}°F
```

Kiro will:
- Validate all entity references (sensor.temperature, sensor.humidity)
- Execute template with current entity states
- Show the actual output you'll get

### Step 4: Verify Entity States

Check what data you're working with:
```
What are the current states of sensor.temperature and sensor.humidity?
```

This helps you understand if the template output makes sense.

### Step 5: Upload and Verify

After testing, upload the modified file:
```
Upload automations.yaml with validation
```

Kiro will:
1. Check for version conflicts (has file changed on HA since download?)
2. Validate YAML syntax
3. Upload the file
4. Trigger configuration check
5. Verify upload succeeded

### Step 6: Test in Context

After upload, test the automation:
```
Test the template in the "Temperature Alert" automation
```

Or trigger the automation manually to see the notification.

## Workflow 8: Template Upload and Verification

### Complete Upload Workflow

**Scenario:** You've edited a template locally and want to deploy it.

**Step 1: Pre-Upload Check**
```
Check if automations.yaml has changed on the server
```

Kiro will compare local and remote file hashes to detect conflicts.

**Step 2: Upload with Validation**
```
Upload automations.yaml with these options:
- Validate YAML syntax before upload
- Check for version conflicts
- Trigger config check after upload
```

**Step 3: Verify Configuration**
```
Check Home Assistant configuration
```

Ensures your changes didn't break anything.

**Step 4: Test Template Rendering**
```
Test the template from the uploaded automation
```

Verify the template works with real entity data.

**Step 5: Monitor for Errors**
```
Show recent Home Assistant logs
```

Check for any runtime errors after deployment.

## Workflow 9: Testing Templates with Real Entity Data

### Why Use Real Entity Data?

Testing with actual entity states ensures:
- Templates work with real-world values
- Edge cases are caught (unavailable, unknown, etc.)
- Output formatting is correct
- Entity references are valid

### Step 1: Identify Required Entities

List all entities your template uses:
```jinja2
{{ states('sensor.temperature') | float(0) }}
{{ states('sensor.humidity') | float(0) }}
{{ states('binary_sensor.window') }}
```

Entities: `sensor.temperature`, `sensor.humidity`, `binary_sensor.window`

### Step 2: Verify Entities Exist

```
Check if these entities exist:
- sensor.temperature
- sensor.humidity
- binary_sensor.window
```

Kiro will use `get_states` to verify each entity.

### Step 3: Check Current States

```
What are the current states of:
- sensor.temperature
- sensor.humidity
- binary_sensor.window
```

This shows you what data the template will work with.

### Step 4: Test Template with Real Data

```
Test this template with entity validation:
{% set temp = states('sensor.temperature') | float(0) %}
{% set humidity = states('sensor.humidity') | float(0) %}
{% set window = states('binary_sensor.window') %}
Temperature: {{ temp }}°C, Humidity: {{ humidity }}%, Window: {{ window }}
```

Kiro will:
- Validate all entity references
- Execute with current entity states
- Show actual output

### Step 5: Test Edge Cases

Manually test edge cases by checking entity states:
```
What happens if sensor.temperature is unavailable?
```

Then test template with default values:
```jinja2
{{ states('sensor.temperature') | float(20) }}  # Default to 20 if unavailable
```

## Integration with Workflow Patterns

### Pattern: Edit Automation with Template Testing

This combines file management, template testing, and upload workflows:

1. **Download** automation file
2. **Edit** template locally in IDE
3. **Test** template with real entity data
4. **Validate** entity references
5. **Upload** with validation
6. **Verify** configuration
7. **Test** in production

**Example:**
```
# Step 1: Download
Download automations.yaml

# Step 2: Edit locally (in your IDE)
# ... make changes ...

# Step 3: Test template
Test this template with entity validation: [paste template]

# Step 4: Check entities
Verify these entities exist: sensor.temperature, sensor.humidity

# Step 5: Upload
Upload automations.yaml with validation

# Step 6: Verify
Check Home Assistant configuration

# Step 7: Test
Trigger the automation to test the template
```

### Pattern: Create Package with Templates

When creating a new package file with templates:

1. **Create** file locally
2. **Write** templates
3. **Test** each template individually
4. **Validate** all entity references
5. **Upload** package
6. **Verify** configuration
7. **Restart** HA to load package

**Example:**
```
# Create local file: ~/ha-dev-workspace/packages/climate.yaml

# Test templates before upload
Test this template: {{ states('climate.living_room') }}

# Validate entities
Check if climate.living_room exists

# Upload package
Upload packages/climate.yaml with validation

# Verify
Check Home Assistant configuration

# Restart HA (manual step)
```

## Best Practices for Local Development

### 1. Always Download Before Editing
Ensures you have the latest version and can detect conflicts.

### 2. Test Templates Before Upload
Catch errors early with `render_template` and entity validation.

### 3. Use Version Checking
Check for conflicts before uploading to avoid overwriting changes.

### 4. Validate YAML Syntax
Always upload with validation enabled to catch syntax errors.

### 5. Verify After Upload
Read back the file or check configuration to confirm upload succeeded.

### 6. Keep Local Workspace Organized
Use the standard workspace structure:
```
~/ha-dev-workspace/
├── automations.yaml
├── scripts.yaml
├── packages/
│   └── climate.yaml
└── .ha-workflow/
    └── metadata.json
```

### 7. Test with Real Entity Data
Always test templates with current entity states, not mock data.

## Examples

### Example 1: Edit Automation Template

**Goal:** Update notification template in an automation

```
# Download file
Download automations.yaml to local workspace

# Edit in IDE (add template)
# ... edit file ...

# Test template
Test this template with entity validation:
Temperature is {{ states('sensor.temperature') | float(0) }}°C

# Check entity
What's the current state of sensor.temperature?

# Upload
Upload automations.yaml with validation

# Verify
Check Home Assistant configuration
```

### Example 2: Create Template Sensor

**Goal:** Create new template sensor in packages

```
# Create local file
# ~/ha-dev-workspace/packages/sensors.yaml

# Add template sensor
template:
  - sensor:
      - name: "Heat Index"
        state: >
          {% set temp = states('sensor.temperature') | float(0) %}
          {% set humidity = states('sensor.humidity') | float(0) %}
          {{ (temp * 1.8 + 32 + humidity * 0.5) | round(1) }}

# Test template
Test this template with entity validation:
{% set temp = states('sensor.temperature') | float(0) %}
{% set humidity = states('sensor.humidity') | float(0) %}
{{ (temp * 1.8 + 32 + humidity * 0.5) | round(1) }}

# Verify entities
Check if sensor.temperature and sensor.humidity exist

# Upload
Upload packages/sensors.yaml with validation

# Verify
Check Home Assistant configuration
```

### Example 3: Debug Template with Real Data

**Goal:** Fix broken template using real entity states

```
# Check what data we have
What's the current state of sensor.temperature?

# Test current template
Test this template: {{ states('sensor.temperature') + 5 }}

# Error: Can't add string and number

# Fix with type conversion
Test this template: {{ states('sensor.temperature') | float + 5 }}

# Success! Now upload the fix
Upload automations.yaml with validation
```

## Complete Example: Testing Template with Real Entity Data

This example shows a complete workflow for developing and testing a complex template using real entity states from your Home Assistant instance.

### Scenario

You're creating a notification template for a weather automation that needs to:
- Show current temperature and humidity
- Calculate feels-like temperature
- Provide a comfort assessment
- Handle unavailable sensors gracefully

### Step-by-Step Execution

#### Step 1: Identify Required Entities

**You list the entities you'll need:**
- `sensor.outdoor_temperature` - Current temperature
- `sensor.outdoor_humidity` - Current humidity
- `sensor.wind_speed` - Wind speed for feels-like calculation

**Checkpoint:** ✅ Entities identified

#### Step 2: Verify Entities Exist

**You ask Kiro:**
```
Check if these entities exist:
- sensor.outdoor_temperature
- sensor.outdoor_humidity
- sensor.wind_speed
```

**Kiro responds:**
```
✓ sensor.outdoor_temperature exists
✓ sensor.outdoor_humidity exists
✓ sensor.wind_speed exists

All entities are valid and accessible.
```

**Checkpoint:** ✅ All entities exist

#### Step 3: Check Current Entity States

**You ask Kiro:**
```
What are the current states of:
- sensor.outdoor_temperature
- sensor.outdoor_humidity
- sensor.wind_speed
```

**Kiro responds:**
```
sensor.outdoor_temperature: 18.5°C
  - unit_of_measurement: °C
  - device_class: temperature
  - last_updated: 2026-03-06 10:30:00

sensor.outdoor_humidity: 65%
  - unit_of_measurement: %
  - device_class: humidity
  - last_updated: 2026-03-06 10:30:00

sensor.wind_speed: 12 km/h
  - unit_of_measurement: km/h
  - last_updated: 2026-03-06 10:29:00
```

**You note:** Good data to work with - all sensors reporting valid values.

**Checkpoint:** ✅ Entity states retrieved

#### Step 4: Write Initial Template

**You start with a simple version:**
```jinja2
Current temperature: {{ states('sensor.outdoor_temperature') }}°C
Humidity: {{ states('sensor.outdoor_humidity') }}%
```

**Checkpoint:** ✅ Basic template written

#### Step 5: Test Initial Template

**You ask Kiro:**
```
Test this template with entity validation:
Current temperature: {{ states('sensor.outdoor_temperature') }}°C
Humidity: {{ states('sensor.outdoor_humidity') }}%
```

**Kiro responds:**
```
✓ Template syntax valid
✓ Entity sensor.outdoor_temperature exists
✓ Entity sensor.outdoor_humidity exists
✓ Template result:
Current temperature: 18.5°C
Humidity: 65%
```

**Checkpoint:** ✅ Basic template works

#### Step 6: Add Feels-Like Calculation

**You expand the template:**
```jinja2
{% set temp = states('sensor.outdoor_temperature') | float(0) %}
{% set humidity = states('sensor.outdoor_humidity') | float(0) %}
{% set wind = states('sensor.wind_speed') | float(0) %}

Current temperature: {{ temp }}°C
Humidity: {{ humidity }}%
Wind speed: {{ wind }} km/h

{% if temp > 0 and humidity > 0 %}
  {% set feels_like = temp - ((wind / 10) * 2) %}
  Feels like: {{ feels_like | round(1) }}°C
{% else %}
  Feels like: N/A
{% endif %}
```

**Checkpoint:** ✅ Calculation added

#### Step 7: Test Calculation Template

**You ask Kiro:**
```
Test this template with entity validation:
{% set temp = states('sensor.outdoor_temperature') | float(0) %}
{% set humidity = states('sensor.outdoor_humidity') | float(0) %}
{% set wind = states('sensor.wind_speed') | float(0) %}

Current temperature: {{ temp }}°C
Humidity: {{ humidity }}%
Wind speed: {{ wind }} km/h

{% if temp > 0 and humidity > 0 %}
  {% set feels_like = temp - ((wind / 10) * 2) %}
  Feels like: {{ feels_like | round(1) }}°C
{% else %}
  Feels like: N/A
{% endif %}
```

**Kiro responds:**
```
✓ Template syntax valid
✓ All entities exist and validated
✓ Current values: temp=18.5°C, humidity=65%, wind=12 km/h
✓ Template result:
Current temperature: 18.5°C
Humidity: 65%
Wind speed: 12 km/h
Feels like: 16.1°C
```

**You verify the math:** 18.5 - ((12/10) * 2) = 18.5 - 2.4 = 16.1 ✓

**Checkpoint:** ✅ Calculation works correctly

#### Step 8: Add Comfort Assessment

**You add comfort logic:**
```jinja2
{% set temp = states('sensor.outdoor_temperature') | float(0) %}
{% set humidity = states('sensor.outdoor_humidity') | float(0) %}
{% set wind = states('sensor.wind_speed') | float(0) %}

Current temperature: {{ temp }}°C
Humidity: {{ humidity }}%
Wind speed: {{ wind }} km/h

{% if temp > 0 and humidity > 0 %}
  {% set feels_like = temp - ((wind / 10) * 2) %}
  Feels like: {{ feels_like | round(1) }}°C
  
  {% if feels_like < 10 %}
    Comfort: Cold - dress warmly!
  {% elif feels_like < 20 %}
    Comfort: Cool - light jacket recommended
  {% elif feels_like < 25 %}
    Comfort: Pleasant - perfect weather!
  {% else %}
    Comfort: Warm - stay hydrated
  {% endif %}
{% else %}
  Feels like: N/A
  Comfort: Unable to assess
{% endif %}
```

**Checkpoint:** ✅ Comfort assessment added

#### Step 9: Test Complete Template

**You ask Kiro:**
```
Test this complete template with entity validation:
{% set temp = states('sensor.outdoor_temperature') | float(0) %}
{% set humidity = states('sensor.outdoor_humidity') | float(0) %}
{% set wind = states('sensor.wind_speed') | float(0) %}

Current temperature: {{ temp }}°C
Humidity: {{ humidity }}%
Wind speed: {{ wind }} km/h

{% if temp > 0 and humidity > 0 %}
  {% set feels_like = temp - ((wind / 10) * 2) %}
  Feels like: {{ feels_like | round(1) }}°C
  
  {% if feels_like < 10 %}
    Comfort: Cold - dress warmly!
  {% elif feels_like < 20 %}
    Comfort: Cool - light jacket recommended
  {% elif feels_like < 25 %}
    Comfort: Pleasant - perfect weather!
  {% else %}
    Comfort: Warm - stay hydrated
  {% endif %}
{% else %}
  Feels like: N/A
  Comfort: Unable to assess
{% endif %}
```

**Kiro responds:**
```
✓ Template syntax valid
✓ All entities exist and validated
✓ Current values: temp=18.5°C, humidity=65%, wind=12 km/h
✓ Template result:
Current temperature: 18.5°C
Humidity: 65%
Wind speed: 12 km/h
Feels like: 16.1°C
Comfort: Cool - light jacket recommended
```

**Checkpoint:** ✅ Complete template works

#### Step 10: Test Edge Case - Unavailable Sensor

**You ask Kiro:**
```
What happens if sensor.outdoor_temperature becomes unavailable?
```

**Kiro responds:**
```
When a sensor is unavailable, states() returns the string 'unavailable'.
Your template uses | float(0) which converts 'unavailable' to 0.

With temp=0, your condition "if temp > 0" will be False, so it will show:
  Feels like: N/A
  Comfort: Unable to assess

This is good error handling!
```

**Checkpoint:** ✅ Edge case handled

#### Step 11: Test Edge Case - High Wind

**You simulate high wind conditions:**
```
If wind speed was 30 km/h instead of 12, what would the template show?
```

**You mentally calculate:** 18.5 - ((30/10) * 2) = 18.5 - 6 = 12.5°C

**You test:**
```
Test this template assuming sensor.wind_speed is 30:
{% set temp = 18.5 %}
{% set humidity = 65 %}
{% set wind = 30 %}
{% set feels_like = temp - ((wind / 10) * 2) %}
Feels like: {{ feels_like | round(1) }}°C
{% if feels_like < 10 %}
  Comfort: Cold - dress warmly!
{% elif feels_like < 20 %}
  Comfort: Cool - light jacket recommended
{% endif %}
```

**Kiro responds:**
```
✓ Template result:
Feels like: 12.5°C
Comfort: Cool - light jacket recommended
```

**Checkpoint:** ✅ High wind scenario works

#### Step 12: Integrate into Automation

**You create the automation file locally:**
```bash
code ~/ha-dev-workspace/automations.yaml
```

**You add:**
```yaml
- id: morning_weather_notification
  alias: "Morning Weather Notification"
  description: "Send weather update every morning"
  trigger:
    - platform: time
      at: "07:00:00"
  condition:
    - condition: template
      value_template: >
        {{ states('sensor.outdoor_temperature') not in ['unavailable', 'unknown'] }}
  action:
    - service: notify.mobile_app
      data:
        title: "Good Morning! ☀️"
        message: >
          {% set temp = states('sensor.outdoor_temperature') | float(0) %}
          {% set humidity = states('sensor.outdoor_humidity') | float(0) %}
          {% set wind = states('sensor.wind_speed') | float(0) %}
          
          Current temperature: {{ temp }}°C
          Humidity: {{ humidity }}%
          Wind speed: {{ wind }} km/h
          
          {% if temp > 0 and humidity > 0 %}
            {% set feels_like = temp - ((wind / 10) * 2) %}
            Feels like: {{ feels_like | round(1) }}°C
            
            {% if feels_like < 10 %}
              Comfort: Cold - dress warmly!
            {% elif feels_like < 20 %}
              Comfort: Cool - light jacket recommended
            {% elif feels_like < 25 %}
              Comfort: Pleasant - perfect weather!
            {% else %}
              Comfort: Warm - stay hydrated
            {% endif %}
          {% else %}
            Feels like: N/A
            Comfort: Unable to assess
          {% endif %}
```

**Checkpoint:** ✅ Template integrated into automation

#### Step 13: Validate Automation YAML

**You ask Kiro:**
```
Validate the YAML syntax in ~/ha-dev-workspace/automations.yaml
```

**Kiro responds:**
```
✓ YAML syntax is valid
✓ No indentation errors
✓ All quotes balanced
✓ Template formatting correct
✓ Ready for upload
```

**Checkpoint:** ✅ YAML validated

#### Step 14: Upload Automation

**You ask Kiro:**
```
Upload ~/ha-dev-workspace/automations.yaml with validation
```

**Kiro responds:**
```
Uploading automations.yaml...
✓ YAML syntax validated
✓ File uploaded successfully
✓ Configuration check triggered
✓ Configuration is valid
✓ Automation loaded: morning_weather_notification
```

**Checkpoint:** ✅ Upload successful

#### Step 15: Test Automation

**You ask Kiro:**
```
Trigger automation.morning_weather_notification to test it
```

**Kiro responds:**
```
✓ Automation triggered
✓ Condition evaluated: True (sensor available)
✓ Notification sent

Notification content:
---
Title: Good Morning! ☀️
Message:
Current temperature: 18.5°C
Humidity: 65%
Wind speed: 12 km/h
Feels like: 16.1°C
Comfort: Cool - light jacket recommended
---
```

**You check your phone:** Notification received! ✓

**Checkpoint:** ✅ Automation works in production

### Summary

**Total Time:** ~30 minutes

**Template Development:**
- ✅ Started with simple template
- ✅ Added complexity incrementally
- ✅ Tested each step with real entity data
- ✅ Validated all entity references
- ✅ Tested edge cases (unavailable sensors, high wind)
- ✅ Integrated into automation
- ✅ Deployed and tested in production

**Entity Data Used:**
- `sensor.outdoor_temperature`: 18.5°C
- `sensor.outdoor_humidity`: 65%
- `sensor.wind_speed`: 12 km/h

**Template Features:**
- ✅ Type-safe conversions with defaults
- ✅ Feels-like temperature calculation
- ✅ Comfort assessment logic
- ✅ Error handling for unavailable sensors
- ✅ Clean, readable output

**Testing Performed:**
- ✅ Syntax validation
- ✅ Entity validation
- ✅ Rendering with current states
- ✅ Edge case testing (unavailable sensor)
- ✅ Edge case testing (high wind)
- ✅ Production testing (triggered automation)

**Files Modified:**
- `automations.yaml` (added morning_weather_notification)

**Next Steps:**
- Monitor notification accuracy over several days
- Adjust feels-like formula if needed
- Consider adding precipitation data
- Add more comfort categories
- Test during different weather conditions

**Key Learnings:**
- Always test with real entity data, not mock values
- Build templates incrementally and test each step
- Use default values to handle unavailable sensors
- Verify calculations manually before deploying
- Test edge cases before production use
- Real entity states reveal issues mock data doesn't

## Next Steps

- Read `local-development.md` for workspace setup and file management
- Read `version-management.md` for conflict resolution
- Read `workflow-patterns.md` for complete development workflows
- Read `debugging.md` for automation troubleshooting
- Read `file-management.md` for configuration file access
- Explore HA template documentation: https://www.home-assistant.io/docs/configuration/templating/
