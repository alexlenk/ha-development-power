# Version Management and Conflict Resolution

Complete guide for checking file versions, detecting conflicts, and resolving version mismatches when developing Home Assistant configurations.

## Overview

Version management prevents you from accidentally overwriting newer changes when working with configuration files. The system tracks file metadata including modification timestamps and content hashes to detect when files have changed on your HA instance since you downloaded them.

This guide covers:
- Understanding file metadata and version tracking
- Checking for version conflicts before uploading
- Viewing differences between local and remote versions
- Resolving conflicts with multiple strategies
- Best practices for avoiding conflicts

## Why Version Management Matters

### The Problem

Without version management, you can lose work:

1. **Day 1, 10:00 AM**: You download `automations.yaml` to edit locally
2. **Day 1, 2:00 PM**: Someone else (or you on another device) modifies `automations.yaml` on the HA instance
3. **Day 1, 4:00 PM**: You upload your local changes, overwriting the 2:00 PM changes
4. **Result**: The 2:00 PM changes are lost forever

### The Solution

Version management detects this scenario:

1. **Day 1, 10:00 AM**: You download `automations.yaml` (hash: `a1b2c3...`)
2. **Day 1, 2:00 PM**: File modified on HA instance (hash: `d4e5f6...`)
3. **Day 1, 4:00 PM**: You attempt to upload
4. **System detects**: Local hash `a1b2c3` ≠ Remote hash `d4e5f6`
5. **System warns**: "Conflict detected! Remote file has been modified."
6. **You choose**: View diff, merge changes, or keep one version

## Understanding File Metadata

### What is File Metadata?

Metadata is information *about* a file, not the file content itself:

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

### Metadata Fields Explained

**path**: Relative path from `/config`
- Example: `automations.yaml`, `packages/lighting.yaml`
- Used to identify the file

**size**: File size in bytes
- Example: `5234` (about 5 KB)
- Quick indicator of file changes

**modified_at**: Last modification timestamp (ISO 8601 format)
- Example: `2026-02-12T10:30:00Z`
- Precise to the second
- UTC timezone

**content_hash**: SHA-256 hash of file content
- Example: `a1b2c3d4e5f6789abcdef...` (64 characters)
- Unique fingerprint of file content
- Changes if even one character changes
- Most reliable way to detect changes

**exists**: Whether the file exists
- `true` or `false`
- Useful for detecting deleted files

**accessible**: Whether you have permission to access the file
- `true` or `false`
- Respects `allowed_paths` configuration

### Why Hash is Most Important

The content hash is the definitive way to detect changes:

**Scenario 1: File Modified**
```
Original hash: a1b2c3d4e5f6...
Modified hash: d4e5f6a7b8c9...
Result: Hashes differ → File changed
```

**Scenario 2: File Unchanged**
```
Original hash: a1b2c3d4e5f6...
Current hash:  a1b2c3d4e5f6...
Result: Hashes match → File unchanged
```

**Scenario 3: Timestamp Changed but Content Same**
```
Original: modified_at: 2026-02-12T10:30:00Z, hash: a1b2c3...
Current:  modified_at: 2026-02-12T11:00:00Z, hash: a1b2c3...
Result: Hash matches → File effectively unchanged (maybe just touched)
```

## Checking File Versions

### Getting File Metadata

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
  "content_hash": "a1b2c3d4e5f6789abcdef0123456789abcdef0123456789abcdef0123456789",
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

### When to Check Versions

**Before Starting Work**
```
Show me metadata for automations.yaml
```
Check if the file has been modified since you last worked on it.

**Before Uploading Changes**
```
Check if automations.yaml has been modified on the HA instance since I downloaded it
```
Kiro will compare your local metadata with current remote metadata.

**After Interruptions**
If you took a break or worked on something else:
```
Has automations.yaml changed remotely?
```

**Before Major Changes**
Before making significant edits:
```
Show me current metadata for automations.yaml
```
Record the current state before you begin.

## Detecting Version Conflicts

### Automatic Conflict Detection

When you ask to upload a file, Kiro automatically checks for conflicts:

Ask Kiro:
```
Upload ~/ha-dev-workspace/automations.yaml to my HA instance
```

Kiro will:
1. Read your local file
2. Get current remote metadata
3. Compare with metadata from when you downloaded
4. Detect if hashes differ
5. Warn you if conflict exists

### Conflict Detection Logic

```
IF local_hash ≠ remote_hash THEN
  Conflict detected
  
  IF local_modified_at < remote_modified_at THEN
    Remote is newer
  ELSE IF local_modified_at > remote_modified_at THEN
    Local is newer
  ELSE
    Both modified at same time (rare)
  END IF
END IF
```

### Types of Conflicts

**Type 1: Remote Newer**
```
⚠️ Remote file has been modified since download

Local version:
  Downloaded: 2026-02-12 10:30:00
  Hash: a1b2c3...

Remote version:
  Modified: 2026-02-12 11:45:00
  Hash: d4e5f6...

Recommendation: Download latest version and merge your changes
```

**Type 2: Both Modified**
```
❌ Both local and remote versions have been modified

Local version:
  Modified: 2026-02-12 12:00:00
  Hash: a1b2c3...

Remote version:
  Modified: 2026-02-12 11:45:00
  Hash: d4e5f6...

Recommendation: Review both versions and merge manually
```

**Type 3: Local Deleted, Remote Modified**
```
⚠️ File deleted locally but modified remotely

Local: File not found
Remote: Modified 2026-02-12 11:45:00

Recommendation: Decide if deletion was intentional
```

## Viewing Differences

### Requesting a Diff

When a conflict is detected, ask to see the differences:

Ask Kiro:
```
Show me the differences between my local automations.yaml and the remote version
```

### Understanding Diff Format

Diffs use unified diff format:

```diff
File: automations.yaml
Local version (modified 2026-02-12 10:30:00)
Remote version (modified 2026-02-12 11:45:00)

--- Local
+++ Remote
@@ -15,7 +15,7 @@
   trigger:
     - platform: time
-      at: "07:00:00"
+      at: "07:30:00"
   action:
     - service: light.turn_on
       target:
-        entity_id: light.bedroom
+        entity_id: light.bedroom_main
```

### Reading the Diff

**Header Section**:
- `--- Local`: Your local version
- `+++ Remote`: Remote version on HA instance
- `@@ -15,7 +15,7 @@`: Line numbers (starts at line 15, 7 lines shown)

**Change Markers**:
- Lines starting with `-`: Removed in remote (present in local)
- Lines starting with `+`: Added in remote (not in local)
- Lines with no marker: Unchanged (context)

**Example Interpretation**:
```diff
-      at: "07:00:00"
+      at: "07:30:00"
```
Means: Local has `07:00:00`, remote has `07:30:00`

### Viewing Full Files

If the diff is confusing, view both files completely:

Ask Kiro:
```
Show me my local automations.yaml
Show me the remote automations.yaml
```

Then compare them side-by-side in your IDE.

## Conflict Resolution Strategies

### Strategy 1: Keep Local Version

**When to Use**:
- Your local changes are more important
- Remote changes were mistakes
- You want to overwrite remote with your version

**How to Do It**:

Ask Kiro:
```
Upload my local automations.yaml and overwrite the remote version
```

Or more explicitly:
```
I want to keep my local version of automations.yaml. Upload it and overwrite the remote file.
```

**What Happens**:
1. System creates backup of remote version
2. Your local file is uploaded
3. Remote file is overwritten
4. New metadata is recorded

**Warning**: Remote changes will be lost. Make sure this is what you want!

### Strategy 2: Keep Remote Version

**When to Use**:
- Remote changes are more important
- You want to discard your local changes
- You want to start fresh with remote version

**How to Do It**:

Ask Kiro:
```
Download the latest automations.yaml and overwrite my local version
```

Or:
```
I want to keep the remote version. Download it and replace my local file.
```

**What Happens**:
1. System creates backup of your local version
2. Remote file is downloaded
3. Your local file is overwritten
4. New metadata is recorded

**Warning**: Your local changes will be lost. Make sure this is what you want!

### Strategy 3: Manual Merge

**When to Use**:
- Both versions have important changes
- You need to combine changes from both
- Changes are in different parts of the file

**How to Do It**:

**Step 1: View the Diff**
```
Show me the differences between local and remote automations.yaml
```

**Step 2: Download Remote Version to Compare**
```
Download automations.yaml to ~/ha-dev-workspace/automations.yaml.remote
```

**Step 3: Open Both Files in Your IDE**
```bash
# VS Code
code --diff ~/ha-dev-workspace/automations.yaml ~/ha-dev-workspace/automations.yaml.remote

# Or use your IDE's diff tool
```

**Step 4: Merge Changes Manually**
- Review each difference
- Decide which changes to keep
- Edit your local file to include both sets of changes
- Save the merged version

**Step 5: Validate the Merged File**
```
Validate YAML syntax in ~/ha-dev-workspace/automations.yaml
Check my Home Assistant configuration
```

**Step 6: Upload Merged Version**
```
Upload ~/ha-dev-workspace/automations.yaml to my HA instance
```

**Step 7: Clean Up**
```bash
rm ~/ha-dev-workspace/automations.yaml.remote
```

### Strategy 4: Abort and Investigate

**When to Use**:
- You're not sure which version is correct
- You need to consult with others
- You want to investigate what changed and why

**How to Do It**:

Ask Kiro:
```
Don't upload anything yet. Let me investigate the changes first.
```

**Then**:
1. Review both versions carefully
2. Check logs to see what changed
3. Consult with team members if applicable
4. Decide on a strategy
5. Come back and resolve the conflict

## Conflict Resolution Workflows

### Workflow 1: Simple Time-Based Conflict

**Scenario**: You edited locally, someone else edited remotely, changes don't overlap.

**Step 1: Detect Conflict**
```
Upload ~/ha-dev-workspace/automations.yaml
```

Response:
```
⚠️ Conflict detected! Remote file modified at 11:45:00, your local version is from 10:30:00.
```

**Step 2: View Diff**
```
Show me the differences
```

**Step 3: Analyze Changes**
- Your changes: Added new automation at line 50
- Remote changes: Modified existing automation at line 20
- Conclusion: Changes don't overlap, can merge

**Step 4: Manual Merge**
```
Download remote version to automations.yaml.remote
```

Edit local file to include both changes.

**Step 5: Upload Merged Version**
```
Upload ~/ha-dev-workspace/automations.yaml
```

### Example: Non-Overlapping Changes

**Local Changes** (added new automation):
```yaml
- id: morning_routine
  alias: "Morning Routine"
  trigger:
    - platform: time
      at: "07:00:00"
  action:
    - service: light.turn_on
      target:
        entity_id: light.bedroom
```

**Remote Changes** (modified existing automation):
```yaml
- id: evening_routine
  alias: "Evening Routine"
  trigger:
    - platform: time
      at: "21:30:00"  # Changed from 21:00:00
  action:
    - service: light.turn_off
      target:
        entity_id: light.living_room
```

**Merged Result** (includes both):
```yaml
- id: evening_routine
  alias: "Evening Routine"
  trigger:
    - platform: time
      at: "21:30:00"  # Remote change
  action:
    - service: light.turn_off
      target:
        entity_id: light.living_room

- id: morning_routine
  alias: "Morning Routine"
  trigger:
    - platform: time
      at: "07:00:00"  # Local addition
  action:
    - service: light.turn_on
      target:
        entity_id: light.bedroom
```

### Workflow 2: Overlapping Changes

**Scenario**: Both versions modified the same automation.

**Step 1: Detect Conflict**
```
Upload ~/ha-dev-workspace/automations.yaml
```

**Step 2: View Diff**
```
Show me the differences
```

Diff shows:
```diff
-      at: "07:00:00"    # Your change
+      at: "07:30:00"    # Remote change
```

**Step 3: Decide Which is Correct**
- Check why each change was made
- Determine which time is correct
- Or choose a third option (e.g., "07:15:00")

**Step 4: Edit Local File**
Choose the correct value and save.

**Step 5: Upload**
```
Upload ~/ha-dev-workspace/automations.yaml
```

### Workflow 3: Remote Deletion

**Scenario**: You modified locally, file was deleted remotely.

**Step 1: Detect Conflict**
```
Upload ~/ha-dev-workspace/automations.yaml
```

Response:
```
⚠️ File doesn't exist on remote. It may have been deleted or moved.
```

**Step 2: Investigate**
```
List all configuration files
```

Check if file was moved or renamed.

**Step 3: Decide**
- If deletion was intentional: Don't upload
- If deletion was mistake: Upload to restore
- If file was moved: Upload to new location

**Step 4: Take Action**
```
Upload ~/ha-dev-workspace/automations.yaml to automations.yaml
```

Or:
```
Upload ~/ha-dev-workspace/automations.yaml to automations_backup.yaml
```

### Workflow 4: Multiple File Conflicts

**Scenario**: You modified several files, multiple conflicts detected.

**Step 1: Check All Files**
```
Show me metadata for:
- automations.yaml
- scripts.yaml
- packages/lighting.yaml
```

**Step 2: Prioritize**
Resolve conflicts in order of importance:
1. Critical files first (configuration.yaml)
2. Files with simple conflicts
3. Files with complex conflicts

**Step 3: Resolve Each File**
Use appropriate strategy for each:
- Keep local for some
- Keep remote for others
- Merge for complex ones

**Step 4: Validate All Changes**
```
Check my Home Assistant configuration
```

**Step 5: Upload All Resolved Files**
```
Upload all resolved files to HA instance
```

## Best Practices for Avoiding Conflicts

### 1. Check Versions Before Starting

Always check if files have changed before you start editing:

```
Show me metadata for automations.yaml
```

If it changed, download the latest version first.

### 2. Work in Short Sessions

The longer you work on a file locally, the more likely someone else will modify it remotely.

**Good**: Download → Edit for 30 minutes → Upload
**Risky**: Download → Edit for 3 days → Upload

### 3. Communicate with Team

If multiple people manage your HA instance:
- Announce when you're working on a file
- Use a shared calendar or chat
- Coordinate major changes

### 4. Use Version Control

Commit your changes to git:
```bash
cd ~/ha-dev-workspace
git add automations.yaml
git commit -m "Add morning routine automation"
```

This gives you a safety net and history.

### 5. Check Before Uploading

Always check for conflicts before uploading:

```
Check if automations.yaml has been modified remotely
```

Don't skip this step!

### 6. Upload Frequently

Upload your changes frequently to reduce conflict window:
- After each logical change
- After testing
- Before taking a break

### 7. Use Descriptive Commits

If using version control, write clear commit messages:
```bash
git commit -m "Change morning routine time from 7:00 to 7:30"
```

This helps understand what changed and why.

### 8. Backup Before Major Changes

Before making major changes:
```bash
cp ~/ha-dev-workspace/automations.yaml ~/ha-dev-workspace/automations.yaml.backup
```

### 9. Test Before Uploading

Always test your changes:
```
Validate YAML syntax
Test templates
Check configuration
```

This reduces the chance of uploading broken configuration.

### 10. Document Your Changes

Add comments to your YAML:
```yaml
# Changed from 07:00 to 07:30 on 2026-02-12 to allow more sleep time
- platform: time
  at: "07:30:00"
```

## Advanced Conflict Resolution

### Three-Way Merge

For complex conflicts, use three-way merge:

**Three Versions**:
1. **Base**: Original version when you downloaded
2. **Local**: Your modified version
3. **Remote**: Current remote version

**Process**:
1. Identify what changed in local vs base
2. Identify what changed in remote vs base
3. Merge both sets of changes
4. Resolve any overlapping changes

**Tools**:
- VS Code: Built-in three-way merge
- Git: `git merge-file`
- Meld: Visual diff and merge tool
- KDiff3: Three-way merge tool

### Automated Merge Tools

Use merge tools for complex conflicts:

```bash
# Using git merge-file
git merge-file \
  ~/ha-dev-workspace/automations.yaml \
  ~/ha-dev-workspace/automations.yaml.base \
  ~/ha-dev-workspace/automations.yaml.remote
```

### Conflict Markers

Merge tools add conflict markers:

```yaml
<<<<<<< LOCAL
  at: "07:00:00"
=======
  at: "07:30:00"
>>>>>>> REMOTE
```

**Resolve by**:
1. Choose one version
2. Or write a new version
3. Remove conflict markers
4. Save file

### Partial File Merges

For large files, merge sections independently:

1. Split file into logical sections
2. Merge each section separately
3. Combine merged sections
4. Validate complete file

## Troubleshooting

### Issue: Conflict Detected but Files Look Identical

**Cause**: Whitespace or line ending differences

**Solution**:
1. Check for trailing spaces
2. Check line endings (LF vs CRLF)
3. Normalize whitespace
4. Re-upload

### Issue: Hash Keeps Changing

**Cause**: File being modified by HA or another process

**Solution**:
1. Check if automations are being edited in UI
2. Disable UI editing temporarily
3. Check for automation that modifies files
4. Upload during quiet period

### Issue: Can't See Differences

**Cause**: Diff is too large or complex

**Solution**:
1. Download both versions
2. Use IDE's diff tool
3. Compare section by section
4. Use external diff tool (Meld, Beyond Compare)

### Issue: Merge Created Invalid YAML

**Cause**: Manual merge introduced syntax errors

**Solution**:
```
Validate YAML syntax in ~/ha-dev-workspace/automations.yaml
```

Fix errors and validate again.

### Issue: Lost Track of Which Version is Which

**Cause**: Multiple downloads and edits

**Solution**:
1. Check file timestamps
2. Check .ha-workflow/metadata.json
3. Download fresh copy
4. Start over with clear versions

### Issue: Uploaded Wrong Version

**Cause**: Uploaded local instead of merged

**Solution**:
1. Check .ha-workflow/backups/
2. Restore from backup
3. Re-do merge
4. Upload correct version

## Quick Reference

### Check Version
```
Show me metadata for automations.yaml
Check if automations.yaml has been modified remotely
```

### View Differences
```
Show me the differences between local and remote automations.yaml
```

### Keep Local
```
Upload my local automations.yaml and overwrite remote
```

### Keep Remote
```
Download latest automations.yaml and overwrite my local version
```

### Manual Merge
```
Download automations.yaml to automations.yaml.remote
# Edit to merge changes
Upload merged automations.yaml
```

### Abort
```
Don't upload anything. Let me investigate first.
```

## Integration with Other Workflows

### With Local Development
1. Download files to workspace
2. Check versions before editing
3. Edit locally
4. Check versions before uploading
5. Resolve conflicts if any
6. Upload changes

See `local-development.md` for details.

### With Template Testing
1. Download file with templates
2. Edit templates locally
3. Test templates
4. Check for conflicts
5. Upload if no conflicts

See `template-testing.md` for details.

### With Version Control
1. Commit before downloading
2. Download and merge
3. Commit merged version
4. Upload to HA instance
5. Tag release

## Complete Example: Handling Version Conflicts

This example shows a complete conflict resolution workflow from detection through merge.

### Scenario

You downloaded `automations.yaml` yesterday to add a new automation. Overnight, someone else modified an existing automation in the same file. Now you're trying to upload your changes and a conflict is detected.

### Step-by-Step Execution

#### Step 1: Attempt Upload

**You ask Kiro:**
```
Upload ~/ha-dev-workspace/automations.yaml to my Home Assistant instance
```

**Kiro responds:**
```
⚠️ Version Conflict Detected!

The remote file has been modified since you downloaded it.

Local version:
  Downloaded: 2026-03-05 10:00:00
  Hash: a1b2c3d4e5f6789...
  Size: 12,654 bytes

Remote version:
  Modified: 2026-03-06 02:30:00
  Hash: d4e5f6a7b8c9012...
  Size: 12,891 bytes

The file was modified 16 hours after you downloaded it.

Options:
1. View differences between versions
2. Keep your local version (overwrites remote)
3. Keep remote version (discards your changes)
4. Download remote and merge manually
5. Abort and investigate

What would you like to do?
```

**Checkpoint:** ⚠️ Conflict detected

#### Step 2: View Differences

**You ask Kiro:**
```
Show me the differences between my local and remote versions
```

**Kiro responds:**
```diff
File: automations.yaml
Local version (downloaded 2026-03-05 10:00:00)
Remote version (modified 2026-03-06 02:30:00)

--- Local
+++ Remote
@@ -45,11 +45,11 @@
 - id: evening_routine
   alias: "Evening Routine"
   description: "Turn off lights in the evening"
   trigger:
     - platform: time
-      at: "22:00:00"
+      at: "22:30:00"
   action:
     - service: light.turn_off
       target:
-        entity_id: light.living_room
+        area_id: living_room
     - service: notify.mobile_app
       data:
         message: "Good night! Lights turned off."

@@ -120,6 +120,18 @@
   action:
     - service: light.turn_on
       target:
         entity_id: light.kitchen

+# Your new automation (only in local)
+- id: temperature_alert
+  alias: "Temperature Alert"
+  description: "Alert when temperature is too high"
+  trigger:
+    - platform: numeric_state
+      entity_id: sensor.temperature
+      above: 28
+  action:
+    - service: notify.mobile_app
+      data:
+        message: "Temperature is high: {{ states('sensor.temperature') }}°C"
```

**Analysis:**
- **Remote changes** (lines 45-56): Evening routine time changed from 22:00 to 22:30, and target changed from entity_id to area_id
- **Local changes** (lines 120-135): New temperature alert automation added
- **Conflict type**: Non-overlapping changes - can be merged

**Checkpoint:** ✅ Differences identified

#### Step 3: Decide on Strategy

**You analyze:**
- Remote changes: Important update to evening routine (better to use area_id)
- Local changes: New automation that doesn't conflict
- **Decision**: Manual merge to keep both changes

**You tell Kiro:**
```
I want to merge both versions. Download the remote version so I can merge manually.
```

**Checkpoint:** ✅ Strategy chosen: Manual merge

#### Step 4: Download Remote Version

**Kiro responds:**
```
Downloading remote version...
✓ Downloaded to ~/ha-dev-workspace/automations.yaml.remote
✓ Size: 12,891 bytes
✓ Hash: d4e5f6a7b8c9012...

You now have:
- automations.yaml (your local version with new automation)
- automations.yaml.remote (current remote version with evening routine changes)
```

**Checkpoint:** ✅ Remote version downloaded

#### Step 5: Compare Versions in IDE

**You open both files:**
```bash
code --diff ~/ha-dev-workspace/automations.yaml ~/ha-dev-workspace/automations.yaml.remote
```

**You see side-by-side:**

**Left (Local):**
```yaml
- id: evening_routine
  alias: "Evening Routine"
  trigger:
    - platform: time
      at: "22:00:00"  # Old time
  action:
    - service: light.turn_off
      target:
        entity_id: light.living_room  # Old target

# ... other automations ...

- id: temperature_alert  # Your new automation
  alias: "Temperature Alert"
  # ...
```

**Right (Remote):**
```yaml
- id: evening_routine
  alias: "Evening Routine"
  trigger:
    - platform: time
      at: "22:30:00"  # Updated time
  action:
    - service: light.turn_off
      target:
        area_id: living_room  # Updated target

# ... other automations ...
# (no temperature_alert)
```

**Checkpoint:** ✅ Visual comparison complete

#### Step 6: Merge Changes Manually

**You edit `automations.yaml` to include both changes:**

1. **Update evening routine** (from remote):
```yaml
- id: evening_routine
  alias: "Evening Routine"
  description: "Turn off lights in the evening"
  trigger:
    - platform: time
      at: "22:30:00"  # ← Took from remote
  action:
    - service: light.turn_off
      target:
        area_id: living_room  # ← Took from remote
    - service: notify.mobile_app
      data:
        message: "Good night! Lights turned off."
```

2. **Keep your new automation** (from local):
```yaml
- id: temperature_alert
  alias: "Temperature Alert"
  description: "Alert when temperature is too high"
  trigger:
    - platform: numeric_state
      entity_id: sensor.temperature
      above: 28
  action:
    - service: notify.mobile_app
      data:
        message: "Temperature is high: {{ states('sensor.temperature') }}°C"
```

**Checkpoint:** ✅ Changes merged

#### Step 7: Validate Merged File

**You ask Kiro:**
```
Validate the YAML syntax in ~/ha-dev-workspace/automations.yaml
```

**Kiro responds:**
```
✓ YAML syntax is valid
✓ No indentation errors
✓ All quotes balanced
✓ File structure is correct
```

**You test the template:**
```
Test this template with entity validation:
Temperature is high: {{ states('sensor.temperature') }}°C
```

**Kiro responds:**
```
✓ Template syntax valid
✓ Entity sensor.temperature exists
✓ Template result: Temperature is high: 23.5°C
```

**Checkpoint:** ✅ Merged file validated

#### Step 8: Upload Merged Version

**You ask Kiro:**
```
Upload ~/ha-dev-workspace/automations.yaml to my Home Assistant instance
```

**Kiro responds:**
```
Uploading automations.yaml...
✓ YAML syntax validated
✓ File uploaded successfully
✓ New hash: e7f8g9h0i1j2345...
✓ Size: 13,124 bytes
✓ Configuration check triggered
```

**Checkpoint:** ✅ Upload successful

#### Step 9: Verify Configuration

**Kiro automatically checks:**
```
Checking Home Assistant configuration...
✓ Configuration is valid
✓ All automations loaded successfully
✓ 2 automations modified:
  - evening_routine (updated)
  - temperature_alert (new)
✓ No errors detected
```

**Checkpoint:** ✅ Configuration valid

#### Step 10: Verify Both Changes Applied

**You ask Kiro:**
```
Read automations.yaml and show me:
1. The evening_routine automation
2. The temperature_alert automation
```

**Kiro responds:**
```yaml
# 1. Evening Routine (with remote changes)
- id: evening_routine
  alias: "Evening Routine"
  description: "Turn off lights in the evening"
  trigger:
    - platform: time
      at: "22:30:00"  ✓ Remote change applied
  action:
    - service: light.turn_off
      target:
        area_id: living_room  ✓ Remote change applied
    - service: notify.mobile_app
      data:
        message: "Good night! Lights turned off."

# 2. Temperature Alert (your new automation)
- id: temperature_alert
  alias: "Temperature Alert"
  description: "Alert when temperature is too high"
  trigger:
    - platform: numeric_state
      entity_id: sensor.temperature
      above: 28
  action:
    - service: notify.mobile_app
      data:
        message: "Temperature is high: {{ states('sensor.temperature') }}°C"
  ✓ Local change applied
```

**Checkpoint:** ✅ Both changes verified

#### Step 11: Clean Up

**You remove the temporary file:**
```bash
rm ~/ha-dev-workspace/automations.yaml.remote
```

**You update your local metadata:**
```
Get metadata for automations.yaml
```

**Kiro responds:**
```json
{
  "path": "automations.yaml",
  "size": 13124,
  "modified_at": "2026-03-06T10:45:00Z",
  "content_hash": "e7f8g9h0i1j2345...",
  "exists": true,
  "accessible": true
}
```

**You note the new hash for future reference.**

**Checkpoint:** ✅ Cleanup complete

### Summary

**Total Time:** ~20 minutes

**Conflict Resolution:**
- ✅ Conflict detected automatically
- ✅ Differences viewed and analyzed
- ✅ Manual merge strategy chosen
- ✅ Remote version downloaded
- ✅ Changes merged successfully
- ✅ Merged file validated
- ✅ Upload successful
- ✅ Both changes verified

**Changes Merged:**
- ✅ Remote: Evening routine time (22:00 → 22:30)
- ✅ Remote: Evening routine target (entity_id → area_id)
- ✅ Local: New temperature alert automation

**Files Modified:**
- `automations.yaml` (12.7 KB → 13.1 KB)

**Lessons Learned:**
- Always check for conflicts before uploading
- View diffs to understand what changed
- Non-overlapping changes are easy to merge
- Validate merged files before uploading
- Keep track of new hash after resolution

**Next Steps:**
- Monitor both automations
- Test evening routine at 22:30
- Test temperature alert when temp exceeds 28°C
- Consider adding more conditions to temperature alert

## Summary

Version management prevents lost work by:
- ✅ Tracking file metadata (hash, timestamp, size)
- ✅ Detecting when files change remotely
- ✅ Warning before overwriting newer changes
- ✅ Providing diff views to see changes
- ✅ Offering multiple resolution strategies
- ✅ Creating automatic backups
- ✅ Integrating with local development workflow

**Key Takeaways**:
1. Always check versions before uploading
2. Use content hash as definitive change indicator
3. View diffs to understand what changed
4. Choose appropriate resolution strategy
5. Test merged files before uploading
6. Communicate with team to avoid conflicts
7. Use version control for additional safety

With proper version management, you can work confidently knowing you'll never accidentally lose important changes!
