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
          "linux": "google-chrome-stable"
        }
      }
    }
  }
}
```

Categories: `cli_tools`, `development`, `languages`, `browsers`, `productivity`, `media`, `communication`, `cloud_sync`, `terminal`

## How Bootstrap Scripts Use This

- **Windows**: PowerShell reads JSON directly with `ConvertFrom-Json`
- **macOS**: Bash uses `jq` (auto-installed) to generate Brewfile
- **Both**: Fall back gracefully if config unavailable

## Adding Applications

1. Edit `apps.json` with platform-specific package names
2. Bootstrap scripts automatically use new config on next run
3. Set platform to `null` if app not available on that platform
