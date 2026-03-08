# Local Development Workflow

Complete guide for developing Home Assistant configurations locally with full IDE support, version checking, and seamless synchronization.

## Overview

The local development workflow enables you to:
- Download configuration files to your local machine
- Edit with full IDE support (syntax highlighting, autocomplete, linting)
- Test changes before deploying
- Track file versions and detect conflicts
- Upload validated changes back to your HA instance
- Maintain a clean, organized workspace

This workflow eliminates the friction of editing directly on the HA instance while ensuring you never lose work or overwrite newer changes.

## Workspace Structure

### Recommended Setup

Create a dedicated workspace directory for your HA development:

```
~/ha-dev-workspace/
├── .ha-workflow/              # Workflow metadata (managed automatically)
│   ├── state.json            # Current workflow state
│   ├── metadata.json         # File metadata cache
│   └── backups/              # Automatic backups before uploads
│       └── 2026-02-12/
│           └── configuration.yaml
├── configuration.yaml         # Main configuration
├── automations.yaml          # Automations
├── scripts.yaml              # Scripts
├── scenes.yaml               # Scenes
└── packages/                 # Package-based configuration
    ├── lighting.yaml
    ├── security.yaml
    └── climate.yaml
```

### The .ha-workflow Directory

This hidden directory stores workflow metadata and is managed automatically:

**state.json**: Tracks your current workflow
```json
{
  "workflow_id": "edit-automation-2026-02-12",
  "workflow_type": "automation",
  "current_step": 3,
  "files": [
    {
      "local_path": "automations.yaml",
      "remote_path": "automations.yaml",
      "downloaded_at": "2026-02-12T10:30:00Z",
      "remote_hash": "a1b2c3...",
      "status": "modified"
    }
  ],
  "started_at": "2026-02-12T10:30:00Z",
  "status": "in_progress"
}
```

**metadata.json**: Caches file metadata for quick version checks
```json
{
  "automations.yaml": {
    "path": "automations.yaml",
    "size": 5234,
    "modified_at": "2026-02-12T10:30:00Z",
    "content_hash": "a1b2c3d4e5f6...",
    "last_checked": "2026-02-12T10:35:00Z"
  }
}
```

**backups/**: Automatic backups organized by date
- Created before every upload
- Kept for 30 days
- Organized by date for easy recovery

## Getting Started: Your First Download

### Step 1: Create Your Workspace

```bash
# Create the workspace directory
mkdir -p ~/ha-dev-workspace
cd ~/ha-dev-workspace
```

### Step 2: Download a Configuration File

Ask Kiro:
```
Download my automations.yaml file to ~/ha-dev-workspace/
```

Kiro will:
1. Read the file from your HA instance
2. Save it to your local workspace
3. Record metadata (hash, timestamp, size)
4. Create the .ha-workflow directory if needed

### Step 3: Verify the Download

Check that the file was created:
```bash
ls -la ~/ha-dev-workspace/
cat ~/ha-dev-workspace/automations.yaml
```

You should see:
- The automations.yaml file
- The .ha-workflow directory
- Metadata files inside .ha-workflow

### Step 4: Open in Your IDE

```bash
# VS Code
code ~/ha-dev-workspace/

# Or your preferred editor
```

Now you have full IDE support:
- Syntax highlighting for YAML
- Autocomplete for HA entities
- Linting for YAML errors
- Git integration
- Multi-file search

## Maintaining Folder Structure

### Why Folder Structure Matters

Your local workspace should mirror your HA instance structure exactly:

**HA Instance**:
```
/config/
├── configuration.yaml
├── automations.yaml
└── packages/
    ├── lighting.yaml
    └── security.yaml
```

**Local Workspace**:
```
~/ha-dev-workspace/
├── configuration.yaml
├── automations.yaml
└── packages/
    ├── lighting.yaml
    └── security.yaml
```

This ensures:
- Easy navigation between local and remote
- Correct relative paths in includes
- Consistent organization
- Simple synchronization

### Downloading Package Files

When downloading files from subdirectories, maintain the structure:

Ask Kiro:
```
Download packages/lighting.yaml to ~/ha-dev-workspace/packages/
```

Kiro will:
1. Create the packages/ directory if needed
2. Download the file to the correct location
3. Record the full path in metadata

### Batch Downloads

Download multiple related files at once:

Ask Kiro:
```
Download these files to ~/ha-dev-workspace/:
- configuration.yaml
- automations.yaml
- scripts.yaml
- packages/lighting.yaml
- packages/security.yaml
```

Kiro will:
1. Create necessary directories
2. Download all files
3. Maintain folder structure
4. Record metadata for each file

## Metadata Tracking

### What Metadata is Tracked

For every downloaded file, the system tracks:

- **path**: Relative path from /config
- **size**: File size in bytes
- **modified_at**: Last modification timestamp on HA instance
- **content_hash**: SHA-256 hash of file content
- **downloaded_at**: When you downloaded the file locally

### Why Metadata Matters

Metadata enables:
- **Version checking**: Detect if remote file changed
- **Conflict detection**: Prevent overwriting newer changes
- **Change tracking**: Know what you've modified
- **Backup management**: Identify what needs backing up

### Viewing Metadata

Ask Kiro:
```
Show me metadata for automations.yaml
```

Response:
```json
{
  "path": "automations.yaml",
  "size": 5234,
  "modified_at": "2026-02-12T10:30:00Z",
  "content_hash": "a1b2c3d4e5f6789...",
  "exists": true,
  "accessible": true
}
```

### Checking Multiple Files

Ask Kiro:
```
Show me metadata for these files:
- automations.yaml
- scripts.yaml
- packages/lighting.yaml
```

This batch request is efficient and returns metadata for all files at once.

## Version Checking Workflow

### Before You Start Editing

Always check if the remote file has changed:

Ask Kiro:
```
Check if automations.yaml has been modified on the HA instance since I downloaded it
```

Kiro will:
1. Get current remote metadata
2. Compare with your local metadata
3. Report if versions match or conflict

### Understanding Version Status

**Status: Clean**
```
✅ File is up to date
Local hash: a1b2c3...
Remote hash: a1b2c3...
Safe to edit locally
```

**Status: Remote Newer**
```
⚠️ Remote file has been modified
Local modified: 2026-02-12 10:30:00
Remote modified: 2026-02-12 11:45:00
Recommendation: Download latest version before editing
```

**Status: Conflict**
```
❌ Both local and remote have been modified
Local hash: a1b2c3...
Remote hash: d4e5f6...
Recommendation: Review changes and resolve conflict
```

### Automatic Version Checking

When you ask to upload a file, Kiro automatically checks versions:

Ask Kiro:
```
Upload my modified automations.yaml to the HA instance
```

Kiro will:
1. Check remote version
2. Detect conflicts if any
3. Warn you before uploading
4. Offer resolution options

## IDE Integration Tips

### VS Code Setup

#### Recommended Extensions

1. **YAML** by Red Hat
   - Syntax highlighting
   - Schema validation
   - Autocomplete

2. **Home Assistant Config Helper**
   - HA-specific autocomplete
   - Entity validation
   - Service completion

3. **GitLens** (if using version control)
   - Track changes
   - View file history
   - Compare versions

#### Workspace Settings

Create `.vscode/settings.json` in your workspace:

```json
{
  "files.associations": {
    "*.yaml": "home-assistant"
  },
  "yaml.schemas": {
    "https://raw.githubusercontent.com/home-assistant/core/dev/homeassistant/helpers/config_validation.py": "*.yaml"
  },
  "files.exclude": {
    ".ha-workflow": true
  },
  "search.exclude": {
    ".ha-workflow": true
  }
}
```

This configuration:
- Associates YAML files with HA schema
- Hides .ha-workflow from file explorer
- Excludes .ha-workflow from search

#### Tasks Configuration

Create `.vscode/tasks.json` for quick actions:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Check HA Configuration",
      "type": "shell",
      "command": "echo 'Ask Kiro: Check my Home Assistant configuration'",
      "problemMatcher": []
    },
    {
      "label": "Test Template",
      "type": "shell",
      "command": "echo 'Ask Kiro: Test this template: ${selectedText}'",
      "problemMatcher": []
    }
  ]
}
```

### Other IDEs

#### PyCharm / IntelliJ IDEA

1. Install YAML plugin
2. Configure file associations for *.yaml
3. Add .ha-workflow to ignored files
4. Use built-in version control integration

#### Sublime Text

1. Install YAML syntax package
2. Install Home Assistant package (if available)
3. Configure build system for validation
4. Add .ha-workflow to folder exclude patterns

#### Vim / Neovim

1. Install vim-yaml plugin
2. Install ALE for linting
3. Configure yaml-language-server
4. Add .ha-workflow to wildignore

## Complete Development Workflow

### Workflow: Edit an Automation

**Step 1: Check Current State**
```
List my automations
Show me metadata for automations.yaml
```

**Step 2: Download File**
```
Download automations.yaml to ~/ha-dev-workspace/
```

**Step 3: Edit Locally**
- Open in your IDE
- Make changes
- Save file

**Step 4: Test Templates**
```
Test this template from my automation:
{{ states('sensor.temperature') | float > 25 }}
```

**Step 5: Validate Syntax**
```
Validate the YAML syntax in ~/ha-dev-workspace/automations.yaml
```

**Step 6: Check for Conflicts**
```
Check if automations.yaml has been modified remotely
```

**Step 7: Upload Changes**
```
Upload ~/ha-dev-workspace/automations.yaml to my HA instance
```

**Step 8: Verify Configuration**
```
Check my Home Assistant configuration
```

**Step 9: Confirm Upload**
```
Read automations.yaml from HA instance and verify my changes
```

### Workflow: Create a New Package

**Step 1: Create Local File**
```bash
mkdir -p ~/ha-dev-workspace/packages
touch ~/ha-dev-workspace/packages/new_feature.yaml
```

**Step 2: Edit in IDE**
Add your configuration:
```yaml
# packages/new_feature.yaml
input_boolean:
  new_feature_enabled:
    name: Enable New Feature

automation:
  - alias: "New Feature Automation"
    trigger:
      - platform: state
        entity_id: input_boolean.new_feature_enabled
        to: 'on'
    action:
      - service: notify.mobile_app
        data:
          message: "New feature activated!"
```

**Step 3: Test Templates**
```
Test this template: {{ states('input_boolean.new_feature_enabled') }}
```

**Step 4: Validate Entities**
```
Check if these entities exist:
- input_boolean.new_feature_enabled
- notify.mobile_app
```

**Step 5: Upload Package**
```
Upload ~/ha-dev-workspace/packages/new_feature.yaml to packages/new_feature.yaml on HA instance
```

**Step 6: Verify Configuration**
```
Check my Home Assistant configuration
```

**Step 7: Restart HA**
```
Restart Home Assistant to load the new package
```

### Workflow: Batch Update Multiple Files

**Step 1: Download All Files**
```
Download these files to ~/ha-dev-workspace/:
- automations.yaml
- scripts.yaml
- packages/lighting.yaml
```

**Step 2: Edit Multiple Files**
- Make changes across files
- Ensure consistency
- Test cross-file references

**Step 3: Test All Templates**
```
Test all templates in my workspace files
```

**Step 4: Check All Versions**
```
Check if any of these files have been modified remotely:
- automations.yaml
- scripts.yaml
- packages/lighting.yaml
```

**Step 5: Upload All Files**
```
Upload these files to HA instance:
- ~/ha-dev-workspace/automations.yaml
- ~/ha-dev-workspace/scripts.yaml
- ~/ha-dev-workspace/packages/lighting.yaml
```

**Step 6: Verify Configuration**
```
Check my Home Assistant configuration
```

## Best Practices

### 1. Always Check Versions First

Before editing, check if the remote file has changed:
```
Show me metadata for automations.yaml
```

This prevents conflicts and lost work.

### 2. Test Before Uploading

Always test your changes locally:
- Validate YAML syntax
- Test templates with current entity states
- Verify entity references exist
- Check configuration validity

### 3. Use Descriptive Workflow Names

When starting a workflow, use clear names:
- "edit-morning-automation"
- "create-lighting-package"
- "update-climate-config"

This helps track what you're working on.

### 4. Commit to Version Control

Use git to track changes:
```bash
cd ~/ha-dev-workspace
git init
git add .
git commit -m "Initial commit"
```

After each change:
```bash
git add automations.yaml
git commit -m "Add morning routine automation"
```

### 5. Regular Backups

The system creates automatic backups, but also:
- Commit to git regularly
- Push to remote repository
- Keep local backups of critical files

### 6. Clean Up Old Workflows

Periodically clean up completed workflows:
```bash
# Remove old backups (older than 30 days)
find ~/ha-dev-workspace/.ha-workflow/backups -mtime +30 -delete
```

### 7. Organize with Packages

Use package-based organization for better structure:
```
packages/
├── lighting.yaml      # All lighting-related config
├── security.yaml      # All security-related config
├── climate.yaml       # All climate-related config
└── media.yaml         # All media-related config
```

Each package contains related:
- Input helpers
- Automations
- Scripts
- Template sensors

### 8. Document Your Configuration

Add comments to your YAML files:
```yaml
# Morning Routine Automation
# Triggers at 7:00 AM on weekdays
# Turns on lights, adjusts thermostat, starts coffee maker
automation:
  - alias: "Morning Routine"
    description: "Automated morning routine for weekdays"
    # ... rest of automation
```

### 9. Use Consistent Naming

Follow naming conventions:
- **Entities**: `domain.location_function` (e.g., `light.bedroom_main`)
- **Automations**: Descriptive names (e.g., "Morning Routine")
- **Scripts**: Action-based names (e.g., "Evening Lights")
- **Files**: Lowercase with underscores (e.g., `morning_routine.yaml`)

### 10. Test with Real Data

Always test templates with current entity states:
```
Test this template with current states:
{{ states('sensor.temperature') | float > 25 }}
```

This ensures templates work with real data, not just syntax.

## Troubleshooting

### Issue: File Not Found Locally

**Symptom**: Can't find downloaded file

**Solution**:
1. Check you're in the correct directory
2. Verify the download completed successfully
3. Check .ha-workflow/state.json for file location
4. Re-download if necessary

### Issue: Metadata Out of Sync

**Symptom**: Version check shows conflict but files are identical

**Solution**:
1. Delete .ha-workflow/metadata.json
2. Re-download the file
3. Metadata will be refreshed

### Issue: Upload Fails with Conflict

**Symptom**: Upload rejected due to version conflict

**Solution**:
1. Download current remote version
2. Compare with your local version
3. Merge changes manually
4. Upload merged version

See `version-management.md` for detailed conflict resolution.

### Issue: IDE Not Recognizing YAML

**Symptom**: No syntax highlighting or autocomplete

**Solution**:
1. Install YAML extension for your IDE
2. Configure file associations for *.yaml
3. Restart IDE
4. Check extension settings

### Issue: Workspace Too Large

**Symptom**: .ha-workflow directory growing too large

**Solution**:
```bash
# Clean old backups
find ~/ha-dev-workspace/.ha-workflow/backups -mtime +7 -delete

# Remove completed workflow states
rm ~/ha-dev-workspace/.ha-workflow/state.json
```

### Issue: Permission Denied

**Symptom**: Can't create files in workspace

**Solution**:
```bash
# Check permissions
ls -la ~/ha-dev-workspace/

# Fix permissions
chmod -R u+w ~/ha-dev-workspace/
```

## Advanced Techniques

### Technique 1: Multi-Instance Development

Manage multiple HA instances:

```
~/ha-dev-workspace/
├── production/
│   ├── .ha-workflow/
│   └── configuration.yaml
└── testing/
    ├── .ha-workflow/
    └── configuration.yaml
```

Switch between instances by changing HA_URL environment variable.

### Technique 2: Automated Sync Script

Create a sync script for regular updates:

```bash
#!/bin/bash
# sync-ha-config.sh

cd ~/ha-dev-workspace

# Download all files
echo "Downloading configuration files..."
# Ask Kiro to download all files

# Commit changes
git add .
git commit -m "Sync from HA instance $(date)"
git push

echo "Sync complete!"
```

### Technique 3: Pre-Upload Validation

Create a validation script:

```bash
#!/bin/bash
# validate-config.sh

cd ~/ha-dev-workspace

# Check YAML syntax
for file in *.yaml; do
  echo "Validating $file..."
  # Ask Kiro to validate each file
done

# Test all templates
echo "Testing templates..."
# Ask Kiro to test all templates

echo "Validation complete!"
```

### Technique 4: Workspace Templates

Create templates for common configurations:

```
~/ha-dev-workspace/templates/
├── automation-template.yaml
├── script-template.yaml
└── package-template.yaml
```

Copy and customize when creating new configurations.

## Integration with Other Workflows

### With Template Testing

1. Download file with templates
2. Extract templates
3. Test each template individually
4. Fix issues
5. Upload corrected file

See `template-testing.md` for details.

### With Debugging

1. Check logs for errors
2. Download relevant configuration
3. Identify issue
4. Fix locally
5. Test fix
6. Upload corrected file

See `debugging.md` for details.

### With Version Control

1. Initialize git repository
2. Download files to workspace
3. Commit initial state
4. Make changes
5. Commit changes
6. Upload to HA instance
7. Tag release

### With CI/CD

1. Push changes to git
2. CI runs validation tests
3. CI checks configuration
4. CI deploys to HA instance
5. CD monitors for errors

## Quick Reference

### Download Files
```
Download automations.yaml to ~/ha-dev-workspace/
Download packages/lighting.yaml to ~/ha-dev-workspace/packages/
```

### Check Metadata
```
Show me metadata for automations.yaml
Check if automations.yaml has been modified remotely
```

### Upload Files
```
Upload ~/ha-dev-workspace/automations.yaml to HA instance
Upload ~/ha-dev-workspace/packages/lighting.yaml to packages/lighting.yaml
```

### Batch Operations
```
Download these files: automations.yaml, scripts.yaml, scenes.yaml
Show me metadata for: automations.yaml, scripts.yaml, scenes.yaml
Upload these files: automations.yaml, scripts.yaml, scenes.yaml
```

### Validation
```
Validate YAML syntax in ~/ha-dev-workspace/automations.yaml
Check my Home Assistant configuration
Test this template: {{ states('sensor.temperature') }}
```

## Next Steps

- Read `version-management.md` for conflict resolution
- Read `workflow-patterns.md` for complete workflow examples
- Read `template-testing.md` for template development
- Explore IDE extensions for better productivity

## Summary

The local development workflow provides:
- ✅ Full IDE support for editing
- ✅ Version checking to prevent conflicts
- ✅ Metadata tracking for all files
- ✅ Automatic backups before uploads
- ✅ Seamless synchronization with HA instance
- ✅ Organized workspace structure
- ✅ Integration with version control

This workflow eliminates the friction of remote editing while ensuring you never lose work or overwrite newer changes. Happy developing!
