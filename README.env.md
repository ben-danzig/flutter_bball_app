# Environment Variables Setup

This project uses Flutter's `--dart-define-from-file` approach for managing environment variables.

## Local Development Setup

1. **Copy the config template:**
   ```bash
   cp config.prod.json.template config.dev.json
   ```

2. **Edit `config.dev.json`** with your actual development values:

   **Required keys:**
   ```json
   {
     "WEB_CLIENT_ID": "your_actual_dev_web_client_id_here"
   }
   ```

   **Optional keys (add as needed):**
   ```json
   {
     "WEB_CLIENT_ID": "your_actual_dev_web_client_id_here",
     "PICOVOICE_ACCESS_KEY": "your_picovoice_key_here"
   }
   ```

3. **Run the app** using VS Code launch configurations:
   - Select "Development" for mobile/desktop
   - Select "Development (Web)" for web development

   Or from command line:
   ```bash
   flutter run --dart-define-from-file=config.dev.json
   ```

## Production Deployment

Production config is automatically created from GitHub Secrets during CI/CD. The workflow creates `config.prod.json` with values from:
- `WEB_CLIENT_ID` secret (required)

**Note:** Additional secrets can be added as needed by updating the GitHub workflows.

## Adding New Environment Variables

### For Optional Keys (Development Only)
1. **Add to your local `config.dev.json`:**
   ```json
   {
     "WEB_CLIENT_ID": "existing_key",
     "NEW_OPTIONAL_KEY": "your_value_here"
   }
   ```

2. **Use in code with defaults:**
   ```dart
   const newKey = String.fromEnvironment('NEW_OPTIONAL_KEY', defaultValue: '');
   ```

### For Required Keys (Production)
1. **Add to `config.prod.json.template`** (shows other developers what's needed)
2. **Add to GitHub Secrets** 
3. **Update workflows** to include the new variable in the generated config
4. **Update your local `config.dev.json`**

## File Structure

- `config.dev.json` - Local development (gitignored)
- `config.prod.json` - Generated in CI/CD (gitignored) 
- `config.prod.json.template` - Template showing required structure (committed)

## Security Notes

- All `config.*.json` files (except templates) are gitignored
- Values are compiled into the app at build time using Flutter's built-in mechanism
- Production builds automatically use `--obfuscate` flag to make reverse engineering harder
- Debug info is separated (stored in CI artifacts) to enable crash analysis while keeping production build secure

## Build Commands

### PR Previews (Fast & Debuggable)
```bash
flutter build web --dart-define-from-file=config.prod.json
```

### Production Builds (Secure & Optimized)
```bash
flutter build web --release --obfuscate --split-debug-info=./debug_info --dart-define-from-file=config.prod.json
``` 