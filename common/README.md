# Common Configuration

Single source of truth for applications across all platforms.

## apps.json Structure

```json
{
  "categories": {
    "browsers": {
      "apps": {
        "chrome": {
          "macos": "google-chrome",
          "windows": "Google.Chrome",
          "wsl_ubuntu": "google-chrome-stable"
        }
      }
    }
  }
}
```

Categories: `cli_tools`, `development`, `languages`, `browsers`, `productivity`, `media`, `communication`, `cloud_sync`, `terminal`

Platforms: `macos`, `windows`, `wsl_ubuntu` (future: `arch_linux`, `fedora`, etc.)## How Bootstrap Scripts Use This

- **Windows**: Uses PowerShell's built-in `ConvertFrom-Json` to parse the configuration
- **macOS**: Uses `jq` (auto-installed if needed) to parse and generate Brewfile
- **WSL Ubuntu**: Uses `jq` to extract WSL Ubuntu-specific packages for `apt`
- **All**: Have fallback mechanisms if the common config is unavailable

## Adding Applications

1. Edit `apps.json` with platform-specific package names
2. Bootstrap scripts automatically use new config on next run
3. Set platform to `null` if app not available on that platform
