# Getting Started with Home Assistant Development Power

This guide walks you through setting up and using the Home Assistant Development Power for the first time.

## Step 1: Install the Power

1. Open Kiro
2. Go to the Powers panel
3. Search for "Home Assistant Development"
4. Click Install

The power will be installed to `~/.kiro/powers/installed/home-assistant-development/`

## Step 2: Create Long-Lived Access Token

1. **Open Home Assistant** in your browser
2. **Click your profile** (your name in the bottom left sidebar)
3. **Scroll down** to "Long-Lived Access Tokens" section
4. **Click "Create Token"**
5. **Enter a name**: "Kiro MCP Server" or similar
6. **Copy the token** immediately (you won't see it again!)
7. **Save it securely** - you'll need it for configuration

## Step 3: Configure the MCP Server

Choose one of two approaches:

### Option A: Environment Variables (Recommended)

This approach keeps your token out of configuration files and is more secure.

1. **Add environment variables to your shell configuration**:
   
   For macOS/Linux, edit `~/.zshrc` or `~/.bashrc`:
   ```bash
   export HA_URL="http://192.168.1.100:8123"
   export HA_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   ```

2. **Reload your shell configuration**:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

3. **Restart Kiro** to pick up the environment variables

4. **Verify the default mcp.json** uses variable expansion (it should by default):
   ```json
   {
     "env": {
       "HA_URL": "${HA_URL}",
       "HA_TOKEN": "${HA_TOKEN}"
     }
   }
   ```

**How it works:** Kiro expands `${VARIABLE_NAME}` syntax by reading environment variables from your shell. This keeps sensitive tokens out of configuration files.

### Option B: Direct Configuration

This approach stores credentials directly in the configuration file.

1. **Open the configuration file**:
   ```bash
   # macOS/Linux
   nano ~/.kiro/powers/installed/home-assistant-development/mcp.json
   
   # Or use your preferred editor
   code ~/.kiro/powers/installed/home-assistant-development/mcp.json
   ```

2. **Replace the variable references with actual values**:
   ```json
   {
     "mcpServers": {
       "ha-config-manager": {
         "command": "uvx",
         "args": ["--from", "ha-config-manager-mcp", "ha-config-manager"],
         "env": {
           "HA_URL": "http://192.168.1.100:8123",
           "HA_TOKEN": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
         },
         "disabled": false,
         "autoApprove": []
       }
     }
   }
   ```

3. **Save the file**

4. **In Kiro**, go to MCP Servers view and click "Reconnect" for ha-config-manager

### Configuration Values

- **HA_URL**: Your Home Assistant URL
  - Local: `http://192.168.1.100:8123`
  - Remote: `https://ha.example.com`
  - Include the port if not using standard HTTP/HTTPS ports
  
- **HA_TOKEN**: The long-lived access token you created in Step 2
  - Starts with `eyJ...` (JWT format)
  - Very long string (hundreds of characters)
  - Keep it secure!

### Verify Connection

After configuration, the MCP server should connect automatically. Check the MCP Servers view in Kiro:
- Status should show "Connected"
- Tools should be listed (14 total)
- No error messages in the logs

## Step 4: Install Custom Integration (Optional but Recommended)

The custom integration enables file and log access tools. Without it, you'll still have 11 working tools (templates, states, services, etc.).

### Installation Steps

1. **Locate the integration files**:
   ```
   src/ha-integration/custom_components/ha_config_manager/
   ```

2. **Copy to Home Assistant**:
   - If HA is local: Copy to `/config/custom_components/ha_config_manager/`
   - If HA is remote: Use file editor add-on or SFTP

3. **Add configuration** to `configuration.yaml`:
   ```yaml
   ha_config_manager:
     security:
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
   ```

4. **Restart Home Assistant**:
   - Settings → System → Restart
   - Or use Developer Tools → YAML → Restart

5. **Verify installation**:
   - Check Settings → System → Logs for any errors
   - Look for "Home Assistant Management Integration setup completed" message

## Step 5: Test the MCP Server

### Quick Test Script
Run the included test script:

```bash
cd /path/to/kiro-power-homeassistant
python test_real_ha_mcp.py
```

Expected output:
```
✅ Connection successful! Found XXX entities
✅ Official HA API endpoints working
✅ Template validation working
✅ Custom integration endpoints working (if installed)
```

### Manual Test
Try a simple tool call:

```bash
# Test get_states tool
python -c "
import asyncio
import os
import sys
sys.path.insert(0, 'src/config-manager/src')
from ha_config_manager.connection.api import HAAPIClient

async def test():
    client = HAAPIClient(os.getenv('HA_URL'), os.getenv('HA_TOKEN'))
    states = await client.get_states()
    print(f'Found {len(states)} entities')
    await client.close()

asyncio.run(test())
"
```

## Step 6: Install Power in Kiro

### Option A: Install from Local Directory (Development)

1. **Open Kiro**
2. **Open Command Palette** (Cmd/Ctrl + Shift + P)
3. **Type**: "Kiro: Configure Powers"
4. **Click "Install from Directory"**
5. **Select**: `/path/to/kiro-power-homeassistant/ha-development-power`
6. **Confirm installation**

### Option B: Install from Repository (Future)

Once published to a power registry:
1. Open Kiro Powers panel
2. Search for "Home Assistant Development"
3. Click Install

## Step 7: Verify Power Installation

1. **Check MCP Server Status**:
   - Open Kiro
   - Look for "ha-config-manager" in MCP Servers panel
   - Status should be "Connected" or "Running"

2. **Test a Tool**:
   - Ask Kiro: "List all my Home Assistant entities"
   - Or: "What's the current state of light.living_room?"
   - Or: "Test this template: {{ states('sensor.temperature') }}"

## Common Setup Issues

### Issue: "HA_URL not set"
**Solution**: Verify environment variables are set and Kiro was restarted after setting them.

### Issue: "Connection refused"
**Solution**: 
- Check HA URL is correct
- Verify HA is running
- Check firewall/network settings
- Try accessing HA URL in browser

### Issue: "Unauthorized" (401)
**Solution**:
- Verify token is correct (no extra spaces)
- Create a new long-lived access token
- Ensure token is from an admin user

### Issue: "Custom integration not found"
**Solution**:
- Verify files are in correct location
- Check HA logs for integration errors
- Restart HA after installation
- Verify configuration.yaml syntax

### Issue: "Module not found: ha_config_manager"
**Solution**:
- Check PYTHONPATH in mcp.json
- Verify Python dependencies installed
- Try: `pip install aiohttp pyyaml aiofiles`

## Next Steps

Now that you're set up, explore these workflows:

1. **Template Testing**: Read `steering/template-testing.md`
2. **Debugging**: Read `steering/debugging.md`
3. **File Management**: Read `steering/file-management.md`

## Quick Reference

### Environment Variables
```bash
HA_URL="http://192.168.1.100:8123"
HA_TOKEN="your_token_here"
```

### Test Command
```bash
python test_real_ha_mcp.py
```

### Integration Location
```
/config/custom_components/ha_config_manager/
```

### Configuration
```yaml
ha_config_manager:
  security:
    allowed_paths:
      - /config/configuration.yaml
      - /config/packages/*
```

## Getting Help

If you encounter issues:
1. Check the Troubleshooting section in POWER.md
2. Review HA logs: Settings → System → Logs
3. Test with `test_real_ha_mcp.py` script
4. Verify environment variables are set
5. Check MCP server logs in Kiro
