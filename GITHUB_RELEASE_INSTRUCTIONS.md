# GitHub Release Instructions for ha-development-power v1.0.0

## Status

- ✅ Version 1.0.0 tagged
- ✅ Tag pushed to GitHub
- ⏳ GitHub release creation (requires manual step)
- ⏳ Kiro Powers registry submission (if applicable)

## Creating the GitHub Release

### Step 1: Navigate to GitHub Releases

1. Go to https://github.com/alexlenk/ha-development-power/releases
2. Click "Draft a new release"

### Step 2: Configure the Release

**Tag**: Select `v1.0.0` from the dropdown (already pushed)

**Release Title**: `HA Development Power v1.0.0 - Initial Release`

**Description**: Copy the content from `RELEASE_NOTES_v1.0.0.md`

**Options**:
- ✅ Set as the latest release
- ✅ Create a discussion for this release (optional)
- ❌ Do NOT mark as pre-release

### Step 3: Publish the Release

Click "Publish release"

## Submitting to Kiro Powers Registry

### Check Registry Requirements

1. Visit the Kiro Powers registry documentation
2. Verify submission requirements
3. Check if manual submission is needed or if GitHub releases are auto-discovered

### Typical Registry Requirements

Most power registries require:

- ✅ Valid `POWER.md` file (already present)
- ✅ Valid `mcp.json` file (already present)
- ✅ GitHub repository with releases (done)
- ✅ README.md with installation instructions (already present)
- ✅ LICENSE file (already present)
- ✅ Semantic versioning (v1.0.0)

### Manual Submission (if required)

If the Kiro Powers registry requires manual submission:

1. Go to the Kiro Powers registry submission page
2. Provide the repository URL: `https://github.com/alexlenk/ha-development-power`
3. Specify the release tag: `v1.0.0`
4. Add description and keywords
5. Submit for review

### Auto-Discovery (if supported)

If the registry auto-discovers GitHub releases:

1. Ensure the repository is public
2. Verify POWER.md is in the root directory
3. Wait for the registry to index the release (may take a few hours)
4. Search for "Home Assistant Development" in Kiro Powers UI

## Verification Checklist

After creating the release:

- [ ] Release appears at https://github.com/alexlenk/ha-development-power/releases
- [ ] Tag v1.0.0 is visible in the tags list
- [ ] Release notes are properly formatted
- [ ] POWER.md is valid and complete
- [ ] mcp.json references correct MCP server package
- [ ] Power can be installed via Kiro Powers UI
- [ ] MCP server auto-installs when power is activated
- [ ] All 17 tools are available after activation
- [ ] Steering guides load correctly

## Testing the Power Installation

### Method 1: Via Kiro Powers UI

1. Open Kiro IDE
2. Go to Powers panel
3. Search for "Home Assistant Development" or "ha-development-power"
4. Click "Install"
5. Verify installation completes without errors
6. Activate the power
7. Test a simple command: "List my Home Assistant configuration files"

### Method 2: Manual Installation Test

```bash
# Clone to Kiro powers directory
mkdir -p ~/.kiro/powers/
cd ~/.kiro/powers/
git clone https://github.com/alexlenk/ha-development-power.git

# Restart Kiro IDE
# Activate power from Powers panel
```

### Method 3: Verify MCP Server Auto-Configuration

After installing the power:

1. Check Kiro's MCP settings
2. Verify `ha-dev-tools` server is configured
3. Verify uvx command is correct: `uvx --from ha-dev-tools-mcp ha-dev-tools-mcp`
4. Test MCP server connection

## Troubleshooting

### Issue: Power doesn't appear in Kiro Powers UI

**Solution**:
- Ensure repository is public
- Verify POWER.md exists and is valid
- Check that release is published (not draft)
- Wait a few hours for registry indexing
- Try manual installation method

### Issue: MCP server fails to install

**Solution**:
- Verify uvx is installed: `uvx --version`
- Check Python version: `python3 --version` (should be 3.12+)
- Verify PyPI package exists: https://pypi.org/project/ha-dev-tools-mcp/
- Check Kiro logs for error messages
- Try manual MCP server installation: `pip install ha-dev-tools-mcp`

### Issue: Tools not available after activation

**Solution**:
- Check MCP server status in Kiro
- Verify HA Dev Tools integration is installed in Home Assistant
- Check Home Assistant connection settings
- Review Kiro logs for MCP server errors
- Restart Kiro IDE

### Issue: Connection to Home Assistant fails

**Solution**:
- Verify Home Assistant URL is correct
- Check long-lived access token is valid
- Ensure HA Dev Tools integration is installed and configured
- Test HA API manually: `curl http://your-ha:8123/api/`
- Check firewall/network settings

## Next Steps After Release

1. **Announce the release**:
   - Kiro community forums
   - Home Assistant community
   - Reddit r/homeassistant
   - Discord servers

2. **Update documentation**:
   - Add installation badge to README
   - Update screenshots if needed
   - Add user testimonials

3. **Monitor feedback**:
   - Watch GitHub issues
   - Respond to questions
   - Collect feature requests

4. **Plan future releases**:
   - Track enhancement requests
   - Plan new features
   - Schedule regular updates

## Version Compatibility Matrix

Document the compatibility between components:

| Component | Version | Required |
|-----------|---------|----------|
| ha-development-power | 1.0.0 | - |
| ha-dev-tools-mcp | 1.0.0 | Yes |
| ha-dev-tools (HA integration) | 1.0.0 | Yes |
| Home Assistant | 2024.1.0+ | Yes |
| Python | 3.12+ | Yes |
| Kiro IDE | Latest | Yes |

## Release Artifacts

This release includes:

- Source code (zip and tar.gz)
- POWER.md - Power documentation
- mcp.json - MCP server configuration
- steering/ - 7 steering guides
- examples/ - Code snippets and patterns
- README.md - Installation guide
- LICENSE - MIT license

All artifacts are automatically included in the GitHub release.
