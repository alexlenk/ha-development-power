# Configuration File Management

Complete guide for working with Home Assistant configuration files using the MCP tools.

## Overview

The file management tools provide secure, controlled access to your Home Assistant configuration files. This enables:
- Reading configuration files programmatically
- Listing available files and directories
- Accessing logs for troubleshooting
- Managing configuration without SSH access

## Security Model

### Allowed Paths Configuration

File access is controlled by the `allowed_paths` configuration in your `configuration.yaml`:

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

**Key Points**:
- Only admin users can access files
- Files must be explicitly allowed
- Glob patterns (*) supported for directories
- Sensitive files automatically blocked (secrets.yaml, auth files)
- Paths are validated before access

### Automatically Blocked Files

These files are always blocked regardless of allowed_paths:
- `secrets.yaml` - Contains sensitive credentials
- `.storage/auth*` - Authentication data
- `.storage/onboarding` - Setup data
- `home-assistant.log` - Use get_logs tool instead
- Database files - Use HA's database tools

## Available File Tools

### 1. list_config_files

Lists configuration files in your HA instance.

**Parameters**:
- `directory` (optional): Filter by directory (e.g., "packages")

**Example Usage**:
```
List all configuration files
List files in the packages directory
```

**Returns**:
```json
[
  {
    "path": "configuration.yaml",
    "type": "configuration",
    "size": 2847,
    "last_modified": "2026-02-12T10:30:00Z"
  },
  {
    "path": "automations.yaml",
    "type": "automation",
    "size": 5234,
    "last_modified": "2026-02-11T15:45:00Z"
  }
]
```

### 2. read_config_file

Reads the content of a configuration file.

**Parameters**:
- `file_path` (required): Path to file (e.g., "configuration.yaml")

**Example Usage**:
```
Read configuration.yaml
Show me the contents of automations.yaml
Read packages/lighting.yaml
```

**Returns**: File content as text with proper YAML formatting

### 3. get_file_metadata

Gets metadata for a file without reading its full content. Useful for version checking and conflict detection.

**Parameters**:
- `file_path` (required): Path to file (e.g., "configuration.yaml")

**Example Usage**:
```
Get metadata for automations.yaml
Check when configuration.yaml was last modified
```

**Returns**:
```json
{
  "path": "automations.yaml",
  "size": 5234,
  "modified_at": "2026-02-12T10:30:00Z",
  "content_hash": "a3f5b8c9d2e1f4a7b6c5d8e9f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0",
  "exists": true,
  "accessible": true
}
```

### 4. batch_get_metadata

Gets metadata for multiple files in one request. Efficient for checking versions of related files.

**Parameters**:
- `file_paths` (required): Array of file paths

**Example Usage**:
```
Get metadata for automations.yaml, scripts.yaml, and configuration.yaml
Check versions of all package files
```

**Returns**: Array of metadata objects (same format as get_file_metadata)

### 5. write_config_file

Writes content to a configuration file on the HA instance. Includes validation and conflict detection.

**Parameters**:
- `file_path` (required): Path to file (e.g., "automations.yaml")
- `content` (required): File content to write
- `expected_hash` (optional): Expected current hash for conflict detection
- `validate_before_write` (optional): Validate YAML syntax (default: true)

**Example Usage**:
```
Upload automations.yaml with validation
Write packages/lighting.yaml with conflict checking
```

**Returns**: New file metadata after successful write

### 6. get_logs

Retrieves Home Assistant logs with filtering.

**Parameters**:
- `log_source` (required): "core", "supervisor", or "addon"
- `lines` (optional): Number of lines (default: 100)
- `level` (optional): Filter by level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- `search` (optional): Search term
- `offset` (optional): Pagination offset
- `limit` (optional): Max entries (default: 100)

**Example Usage**:
```
Show me the last 50 lines of core logs
Get errors from the last hour
Show me logs containing "automation"
```

## Workflow 1: Local Workspace Setup

---

**⚠️ IMPORTANT: Always follow all steps in this workflow**

**DO NOT skip steps - each step is required for proper version tracking and conflict prevention**

---

### Overview
The local workspace enables you to download files from your HA instance, edit them locally with full IDE support, and upload them back with validation and version checking.

### Workspace Structure
```
~/ha-dev-workspace/
├── .ha-workflow/
│   ├── state.json          # Current workflow state
│   ├── metadata.json       # File metadata cache
│   └── backups/            # Automatic backups
│       └── 2026-02-12/
│           └── automations.yaml
├── configuration.yaml
├── automations.yaml
├── scripts.yaml
├── scenes.yaml
└── packages/
    ├── lighting.yaml
    ├── security.yaml
    └── climate.yaml
```

### Step 1: Initialize Workspace
Ask Kiro:
```
Set up my local Home Assistant development workspace
```

Kiro will create the workspace structure in `~/ha-dev-workspace/`.

### Step 2: Download Files
Ask Kiro:
```
Download automations.yaml to my local workspace
```

Kiro will:
1. Get file metadata (hash, timestamp)
2. Download file content
3. Save to `~/ha-dev-workspace/automations.yaml`
4. Record metadata for version tracking

### Step 3: Edit Locally
Open files in your IDE:
- Full syntax highlighting
- Auto-completion
- Multi-cursor editing
- Find/replace
- Git integration

### Step 4: Upload Changes
Ask Kiro:
```
Upload automations.yaml with validation
```

Kiro will:
1. Check for version conflicts
2. Validate YAML syntax
3. Upload to HA instance
4. Verify upload succeeded

---

### ✅ Verify Workflow 1 Completion

After setting up your local workspace, verify:

**Workspace Structure Created:**
- [ ] `~/ha-dev-workspace/` directory exists
- [ ] `.ha-workflow/` subdirectory exists
- [ ] `state.json` file created
- [ ] `metadata.json` file created
- [ ] `backups/` directory exists

**Workspace Ready for Use:**
- [ ] Can save files to workspace
- [ ] Can track file metadata
- [ ] Can create backups

**Verification Commands:**
```bash
# Check workspace exists
ls -la ~/ha-dev-workspace/

# Verify workflow directory
ls -la ~/ha-dev-workspace/.ha-workflow/

# Check structure
tree ~/ha-dev-workspace/
```

---

## Workflow 2: Download Files with Metadata

---

**⚠️ IMPORTANT: Always follow all steps in this workflow**

**DO NOT skip steps - each step is required for proper version tracking and conflict prevention**

---

### Single File Download

**⚠️ DO NOT SKIP ANY STEPS - Follow this exact sequence:**

**Step 1: ALWAYS get_file_metadata FIRST**
```
Get metadata for automations.yaml
```

This shows:
- File size
- Last modified timestamp
- Content hash (for version tracking)
- Whether file exists and is accessible

**Step 2: THEN read_config_file**
```
Download automations.yaml to local workspace
```

**Step 3: THEN save locally to ~/ha-dev-workspace/**
Save the file content to:
- `~/ha-dev-workspace/automations.yaml`

**Step 4: THEN record metadata in .ha-workflow/metadata.json**
Record the following metadata:
- File path
- Content hash
- Last modified timestamp
- Download timestamp

**Verify Download Completion:**
Check that the file was saved correctly:
- File exists in `~/ha-dev-workspace/automations.yaml`
- Metadata recorded in `.ha-workflow/metadata.json`

### Batch File Download

**⚠️ DO NOT SKIP ANY STEPS - Follow this exact sequence:**

**Step 1: ALWAYS get metadata for ALL files FIRST**
```
Get metadata for automations.yaml, scripts.yaml, and configuration.yaml
```

**Step 2: THEN read_config_file for EACH file**
```
Download these files to local workspace:
- automations.yaml
- scripts.yaml
- configuration.yaml
```

**Step 3: THEN save ALL files locally to ~/ha-dev-workspace/**
Maintain proper folder structure for each file.

**Step 4: THEN record metadata for ALL files in .ha-workflow/metadata.json**
Record metadata for each downloaded file.

**Verify Structure:**
All files should maintain their folder structure:
```
~/ha-dev-workspace/
├── automations.yaml
├── scripts.yaml
└── configuration.yaml
```

### Package Directory Download

**⚠️ DO NOT SKIP ANY STEPS - Follow this exact sequence:**

**Step 1: ALWAYS list package files FIRST**
```
List files in packages directory
```

**Step 2: THEN get metadata for all packages**
```
Get metadata for all files in packages directory
```

**Step 3: THEN download all package files**
```
Download all package files to local workspace
```

**Step 4: THEN verify structure and metadata**
Ensure all files are saved with proper structure and metadata recorded.

**Verify Structure:**
```
~/ha-dev-workspace/packages/
├── lighting.yaml
├── security.yaml
└── climate.yaml
```

---

### ✅ Verify Workflow 2 Completion

After completing any download workflow, verify:

**Files Downloaded Successfully:**
- [ ] All target files exist in `~/ha-dev-workspace/`
- [ ] File content is complete and readable
- [ ] Folder structure matches HA instance

**Metadata Recorded:**
- [ ] `.ha-workflow/metadata.json` exists
- [ ] Metadata entry exists for each downloaded file
- [ ] Content hashes recorded correctly
- [ ] Download timestamps recorded

**Verification Commands:**
```bash
# Check file exists locally
ls -lh ~/ha-dev-workspace/automations.yaml

# Verify metadata recorded
cat ~/ha-dev-workspace/.ha-workflow/metadata.json | grep automations.yaml

# Compare with remote
Get metadata for automations.yaml
```

---

## Workflow 3: Upload Files with Validation

---

**⚠️ IMPORTANT: Always follow all steps in this workflow**

**DO NOT skip steps - each step is required for proper version tracking and conflict prevention**

---

### Basic Upload

**⚠️ DO NOT SKIP VALIDATION - Follow this exact sequence:**

**Step 1: ALWAYS validate YAML FIRST**
Before uploading, ensure YAML is valid:
```
Validate the YAML syntax in automations.yaml
```

**Step 2: THEN upload with validation enabled**
```
Upload automations.yaml with these options:
- Validate YAML syntax before upload
- Trigger configuration check after upload
```

**Step 3: THEN verify upload succeeded**
```
Read automations.yaml from HA instance
```

**Step 4: THEN compare with local file to confirm**
Compare with local file to confirm upload succeeded.

**Verify Upload Completion:**
- File content matches local version
- No validation errors reported
- Configuration check passed

### Upload with Conflict Detection

**⚠️ DO NOT SKIP CONFLICT CHECKING - Follow this exact sequence:**

**Step 1: ALWAYS check for changes FIRST**
```
Get metadata for automations.yaml
```

Compare the hash with your local metadata to detect if the file changed on the server.

**Step 2: THEN validate YAML syntax**
Ensure your local changes are valid before uploading.

**Step 3: THEN upload with expected_hash for conflict detection**
```
Upload automations.yaml with conflict checking:
- Expected hash: a3f5b8c9d2e1f4a7b6c5d8e9f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0
- Validate before write: true
```

If the hash doesn't match, Kiro will warn you about the conflict.

**Step 4: THEN verify upload succeeded**
Confirm the file was uploaded correctly.

**Handle Conflicts:**
If a conflict is detected, see `version-management.md` for resolution options.

### Batch Upload

**⚠️ DO NOT SKIP VALIDATION - Follow this exact sequence:**

**Step 1: ALWAYS validate ALL files FIRST**
```
Validate YAML syntax for:
- automations.yaml
- scripts.yaml
- configuration.yaml
```

**Step 2: THEN check for conflicts on ALL files**
Get metadata for all files to detect server-side changes.

**Step 3: THEN upload ALL files with validation**
```
Upload these files with validation:
- automations.yaml
- scripts.yaml
- configuration.yaml
```

**Step 4: THEN verify configuration is valid**
```
Check Home Assistant configuration
```

Ensures all uploads succeeded and configuration is valid.

**Verify Batch Upload Completion:**
- All files uploaded successfully
- No validation errors
- Configuration check passed
- No conflicts detected

---

### ✅ Verify Workflow 3 Completion

After completing any upload workflow, verify:

**Files Uploaded Successfully:**
- [ ] All target files exist on HA instance
- [ ] File content matches local versions
- [ ] No upload errors reported

**Validation Passed:**
- [ ] YAML syntax validation succeeded
- [ ] Home Assistant configuration check passed
- [ ] No validation warnings or errors

**Metadata Updated:**
- [ ] Local metadata updated with new hashes
- [ ] Upload timestamps recorded
- [ ] Conflict detection data refreshed

**Verification Commands:**
```bash
# Verify file exists and matches
Read [filename] from HA instance

# Check configuration is valid
Check Home Assistant configuration

# Verify metadata is current
Get metadata for [filename]
```

---

## Workflow 4: Version Checking

---

**⚠️ IMPORTANT: Always follow all steps in this workflow**

**DO NOT skip steps - each step is required for proper version tracking and conflict prevention**

---

### Check Single File Version

**Step 1: Get Local Metadata**
Check your local metadata cache:
```
Show me the metadata for my local automations.yaml
```

**Step 2: Get Remote Metadata**
```
Get metadata for automations.yaml from HA instance
```

**Step 3: Compare Versions**
Compare:
- **Hash**: If different, content has changed
- **Timestamp**: Shows when file was last modified
- **Size**: Quick indicator of changes

**Step 4: Decide Action**
- **Hashes match**: Safe to edit locally
- **Hashes differ**: File changed on server, check for conflicts

### Check Multiple File Versions

**Step 1: Get Remote Metadata**
```
Get metadata for automations.yaml, scripts.yaml, configuration.yaml
```

**Step 2: Compare with Local**
For each file, compare hash and timestamp with local metadata.

**Step 3: Identify Conflicts**
Files with different hashes have been modified on the server.

**Step 4: Resolve Conflicts**
See `version-management.md` for conflict resolution workflows.

### Automated Version Checking

**Before Starting Work**
```
Check if these files have changed on the server:
- automations.yaml
- scripts.yaml
```

**Before Uploading**
```
Check for conflicts before uploading automations.yaml
```

**After Uploading**
```
Verify automations.yaml was uploaded correctly
```

## Workflow 5: Batch Operations

### Batch Metadata Retrieval

**Use Case**: Check versions of all configuration files

```
Get metadata for all configuration files:
- configuration.yaml
- automations.yaml
- scripts.yaml
- scenes.yaml
```

**Benefits**:
- Single API call for multiple files
- Efficient version checking
- Quick conflict detection

### Batch Download

**Use Case**: Download entire configuration for backup

**Step 1: List All Files**
```
List all configuration files
```

**Step 2: Get Metadata**
```
Get metadata for all listed files
```

**Step 3: Download All**
```
Download all configuration files to local workspace
```

**Step 4: Verify**
Check that all files were downloaded and metadata recorded.

### Batch Upload

**Use Case**: Upload multiple modified files

**Step 1: Validate All**
```
Validate YAML syntax for all modified files
```

**Step 2: Check Versions**
```
Get metadata for all files I'm about to upload
```

**Step 3: Upload All**
```
Upload all modified files with validation
```

**Step 4: Verify Configuration**
```
Check Home Assistant configuration
```

## Workflow 6: Conflict Resolution Integration

### Detecting Conflicts

**Step 1: Get Current Metadata**
```
Get metadata for automations.yaml
```

**Step 2: Compare with Local**
If hashes differ, a conflict exists.

**Step 3: View Differences**
```
Show me the differences between my local automations.yaml and the server version
```

**Step 4: Choose Resolution**
See `version-management.md` for detailed conflict resolution workflows:
- Keep local version
- Keep remote version
- Manual merge

### Preventing Conflicts

**Best Practices**:
1. Always check metadata before editing
2. Download latest version before making changes
3. Upload changes promptly
4. Use version checking before upload
5. Coordinate with other users

## Workflow 7: Exploring Configuration Structure

### Step 1: List All Files
Ask Kiro:
```
List all my Home Assistant configuration files
```

### Step 2: Identify File Types
Review the returned list to understand your configuration structure:
- `configuration.yaml` - Main configuration
- `automations.yaml` - UI-managed automations
- `scripts.yaml` - UI-managed scripts
- `packages/*.yaml` - Organized configuration packages
- `.storage/*` - UI-managed entities and dashboards

### Step 3: Explore Packages
If you use packages:
```
List files in the packages directory
```

### Step 4: Check File Sizes
Large files may need optimization:
- `automations.yaml` > 50KB - Consider splitting into packages
- `configuration.yaml` > 20KB - Consider using includes or packages

## Workflow 8: Reading Configuration Files

### Reading Main Configuration
Ask Kiro:
```
Read configuration.yaml
```

**What to Look For**:
- Enabled integrations
- Include statements
- Package configuration
- Logger settings
- Recorder settings

### Reading Automations
Ask Kiro:
```
Read automations.yaml
```

**What to Look For**:
- Automation structure
- Trigger configurations
- Condition logic
- Action sequences
- Entity references

### Reading Package Files
Ask Kiro:
```
Read packages/lighting.yaml
```

**What to Look For**:
- Related automations grouped together
- Input helpers defined with automations
- Scripts used by automations
- Template sensors

### Reading Storage Files
Ask Kiro:
```
Read .storage/lovelace
```

**What to Look For**:
- Dashboard configuration
- Card layouts
- View organization
- Custom card configurations

## Workflow 9: Log Analysis

### Getting Recent Errors
Ask Kiro:
```
Show me errors from the last hour
```

**Use Cases**:
- Troubleshooting automation failures
- Identifying integration issues
- Finding configuration errors
- Debugging template problems

### Searching Logs
Ask Kiro:
```
Show me logs containing "automation.morning_routine"
```

**Use Cases**:
- Tracking specific automation execution
- Finding entity-related errors
- Debugging integration issues
- Monitoring service calls

### Filtering by Log Level
Ask Kiro:
```
Show me WARNING level logs from the last 24 hours
```

**Log Levels**:
- **DEBUG**: Detailed diagnostic information
- **INFO**: General informational messages
- **WARNING**: Warning messages (potential issues)
- **ERROR**: Error messages (something failed)
- **CRITICAL**: Critical errors (system issues)

### Pagination for Large Logs
Ask Kiro:
```
Show me the first 100 log entries
Show me the next 100 log entries (offset 100)
```

## Workflow 10: Configuration Review

### Pre-Restart Configuration Check
Before restarting HA, review your configuration:

**Step 1: Read Modified Files**
```
Read automations.yaml
Read scripts.yaml
```

**Step 2: Validate Configuration**
```
Check my Home Assistant configuration
```

**Step 3: Review Recent Changes**
Compare with previous version (if using version control).

### Post-Restart Verification
After restarting HA:

**Step 1: Check for Errors**
```
Show me errors from the last 5 minutes
```

**Step 2: Verify Integrations Loaded**
```
List all available services
```

**Step 3: Check Entity Availability**
```
List all entities
```

## Workflow 11: Automation Development

### Step 1: Read Existing Automations
```
Read automations.yaml
```

### Step 2: Identify Patterns
Look for common patterns in your automations:
- Trigger types used
- Condition structures
- Action sequences
- Template usage

### Step 3: Test Templates
Extract templates from automations and test:
```
Test this template: {{ states('sensor.temperature') | float > 25 }}
```

### Step 4: Verify Entity References
Check that entities exist:
```
What's the state of sensor.temperature?
```

### Step 5: Validate Before Saving
After making changes:
```
Check my Home Assistant configuration
```

## Workflow 12: Package Organization

### Understanding Package Structure
Packages group related configuration:

```yaml
# packages/lighting.yaml
input_boolean:
  lighting_automation:
    name: Enable Lighting Automation

automation:
  - alias: "Morning Lights"
    trigger:
      - platform: time
        at: "07:00:00"
    condition:
      - condition: state
        entity_id: input_boolean.lighting_automation
        state: 'on'
    action:
      - service: light.turn_on
        target:
          entity_id: light.bedroom

script:
  evening_lights:
    sequence:
      - service: light.turn_on
        target:
          entity_id: light.living_room
```

### Reading Package Files
Ask Kiro:
```
List files in packages directory
Read packages/lighting.yaml
Read packages/security.yaml
```

### Benefits of Packages
- Logical grouping of related configuration
- Easier to understand and maintain
- Better version control (smaller files)
- Can be enabled/disabled as units

## Workflow 13: Storage File Management

### Understanding Storage Files
Storage files contain UI-managed configuration:
- `.storage/lovelace*` - Dashboard configuration
- `.storage/automation` - UI-created automations
- `.storage/script` - UI-created scripts
- `.storage/input_*` - Input helpers
- `.storage/scene` - Scenes

### Reading Storage Files
Ask Kiro:
```
Read .storage/lovelace
Read .storage/automation
```

**Warning**: Storage files are JSON format, not YAML. They're managed by HA's UI and should generally not be edited manually.

### When to Access Storage Files
- Backing up dashboard configuration
- Migrating to YAML configuration
- Debugging UI issues
- Understanding entity structure

## Best Practices

### 1. Use Allowed Paths Wisely
Only allow access to files you need:
```yaml
ha_dev_tools:
  security:
    allowed_paths:
      # Core files
      - /config/configuration.yaml
      - /config/automations.yaml
      
      # Packages (use glob)
      - /config/packages/*
      
      # Specific storage files
      - /config/.storage/lovelace*
```

### 2. Regular Configuration Reviews
Schedule regular reviews:
- Weekly: Check for errors in logs
- Monthly: Review automation efficiency
- Quarterly: Audit configuration structure
- Yearly: Major cleanup and optimization

### 3. Version Control Integration
Use file access with version control:
1. Read configuration files
2. Commit to git repository
3. Track changes over time
4. Easy rollback if needed

### 4. Documentation
Document your configuration:
- Add comments to YAML files
- Maintain README in packages
- Document custom templates
- Track integration versions

### 5. Security Considerations
- Never expose secrets.yaml
- Use secrets for sensitive data
- Limit allowed_paths to necessary files
- Regular security audits
- Monitor access logs

## Common File Patterns

### Pattern 1: Main Configuration with Includes
```yaml
# configuration.yaml
homeassistant:
  name: Home
  
# Split configuration
automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

# Package configuration
homeassistant:
  packages: !include_dir_named packages
```

### Pattern 2: Package-Based Organization
```
/config/
├── configuration.yaml (minimal)
├── packages/
│   ├── lighting.yaml
│   ├── security.yaml
│   ├── climate.yaml
│   └── media.yaml
```

### Pattern 3: Split Configuration
```
/config/
├── configuration.yaml
├── automations/
│   ├── lighting.yaml
│   ├── security.yaml
│   └── climate.yaml
├── scripts/
│   ├── morning.yaml
│   └── evening.yaml
```

## Troubleshooting

### Error: "File not found"
**Cause**: File doesn't exist or path is incorrect

**Solution**:
1. List files to see available paths
2. Check spelling and case sensitivity
3. Verify file exists in HA

### Error: "Access denied" (403)
**Cause**: File not in allowed_paths

**Solution**:
1. Add file to allowed_paths in configuration.yaml
2. Restart Home Assistant
3. Verify you're using admin user token

### Error: "Unauthorized" (401)
**Cause**: Invalid or expired token

**Solution**:
1. Create new long-lived access token
2. Update HA_TOKEN environment variable
3. Restart MCP server

### Error: "Integration not loaded"
**Cause**: Custom integration not installed

**Solution**:
1. Install ha_dev_tools integration
2. Add configuration to configuration.yaml
3. Restart Home Assistant

### Large File Performance
**Issue**: Reading large files is slow

**Solution**:
- Use pagination for logs
- Split large configuration files
- Use packages for organization
- Consider file size limits

## Advanced Techniques

### Technique 1: Configuration Diffing
Compare configuration versions:
1. Read current configuration
2. Compare with previous version
3. Identify changes
4. Validate changes

### Technique 2: Automated Backups
Regular configuration backups:
1. List all configuration files
2. Read each file
3. Save to backup location
4. Timestamp backups

### Technique 3: Configuration Analysis
Analyze configuration for issues:
1. Read all configuration files
2. Extract entity references
3. Verify entities exist
4. Check for unused entities

### Technique 4: Template Extraction
Extract templates from configuration:
1. Read configuration files
2. Identify template usage
3. Test each template
4. Document template patterns

## Quick Reference

### List Files
```
List all configuration files
List files in packages directory
```

### Read Files
```
Read configuration.yaml
Read automations.yaml
Read packages/lighting.yaml
```

### Get Logs
```
Show me errors from the last hour
Show me logs containing "automation"
Get WARNING level logs
```

### Validate
```
Check my Home Assistant configuration
```

## Integration with Other Workflows

### With Template Testing
1. Read automation file
2. Extract templates
3. Test templates individually
4. Fix issues
5. Validate configuration

### With Debugging
1. Check logs for errors
2. Read relevant configuration
3. Identify issue
4. Test fix
5. Validate configuration

### With Version Control
1. Read configuration files
2. Commit to repository
3. Track changes
4. Easy rollback

## Next Steps

- Read `local-development.md` for workspace setup and development workflows
- Read `version-management.md` for conflict detection and resolution
- Read `workflow-patterns.md` for complete development patterns
- Read `template-testing.md` for template development
- Read `debugging.md` for troubleshooting
- Explore HA configuration documentation: https://www.home-assistant.io/docs/configuration/
