# TreeTabsVivaldi (no-Gemini fork)

![Vivaldi Tree Style Tabs Screenshot](screenshot/vivaldi_aIzu7wJKEg.jpg)

A fork of [R0STEFAN/Vivaldi-Tree-Style-Tabs](https://github.com/R0STEFAN/Vivaldi-Tree-Style-Tabs), a Sidebery-inspired vertical tree tab panel for Vivaldi. It is not a browser extension: it is a `custom.js` UI modification loaded into Vivaldi's `window.html`.

This fork tracks upstream **v2.3.8** and differs in two ways: the Gemini AI integration is removed, and the Linux install targets Debian-based systems.

**This fork is source-only: it publishes no prebuilt releases.** Build it yourself with `npm run build` (see [Installation](#installation)).

## What's different in this fork

### Gemini AI tab grouping removed

Upstream added Google Gemini tab grouping in v2.3.0. This fork removes it entirely, so the mod never makes a network call to an AI service and never asks for an API key.

- Removed the Gemini API client, the `aiGroupTabs` store action, the header AI button and the "AI Tab Grouping" settings block.
- Removed the toast notification system, which only the AI feature used.
- Saved `geminiApiKey`, `geminiModel` and `geminiFolderLanguage` settings are deleted from storage the first time the mod loads, so an old key does not linger in your browser profile.
- Everything else from upstream v2.3.8 (tree persistence, workspace fixes, side panel coexistence and so on) is unchanged.

The upstream v2.3.0 notes in `CHANGELOG.md` are kept for history; see the `Unreleased` entry for the removal.

### Debian/Ubuntu install instead of Arch

Upstream's Linux installer set up a pacman hook. This fork replaces it with an APT hook. See [Linux (Debian/Ubuntu-based)](#linux-debianubuntu-based) below.

- `install-linux.sh` symlinks `custom.js` and `svb-folder.html` from `dist/` into `~/.local/share/vivaldi-patch/`, so `npm run build` is picked up without reinstalling.
- It installs `/etc/apt/apt.conf.d/99vivaldi-patch`, which re-applies the patch after every apt/dpkg run.

### Not changed, but worth knowing

- The Windows auto-updater (`updater/`) now checks **this fork's** GitHub releases (`proapocalyptic/Vivaldi-Tree-Style-Tabs-no-gemini`) instead of upstream's, so it never pulls in Gemini. Because this fork publishes no releases, a self-compiled updater has nothing to download and will report an error when checking for updates. Its Vivaldi-update watching still works, since it patches using the `custom.js` embedded when you built it. Do not use upstream's prebuilt `svb-updater.exe`: it installs the Gemini version.
- The macOS and Windows scripts are inherited from upstream and are untested here.

## What It Does (inherited from upstream)

- Adds a vertical tab panel with a Sidebery-like visual style.
- Supports hierarchical tree tabs with nested parent/child relations.
- Persists tree structure and collapsed/expanded state across browser restarts.
- Synchronizes with native Vivaldi workspaces.
- Keeps the native tab order aligned with the custom tree order.
- Supports pinned tabs, tab renaming, tab colors, mute/unmute, duplicate, close actions, and custom context menus.
- Supports multi-select and drag-and-drop between tree levels.
- Supports moving tabs or whole trees to another workspace or a new window.
- Supports saving a tree as a Vivaldi bookmarks folder and restoring it later.
- Supports Vivaldi native tiling from the custom multi-selection.
- Supports a pinned/auto-hide panel mode and resizable panel width.
- Hides itself during fullscreen video/browser fullscreen.

## Project Structure

```text
vivaldi-mod/
  src/              Source modules
  build/            Custom bundler
  dist/custom.js    Built Vivaldi mod bundle
  package.json      Build scripts
```

The source code is modular, but the final output is a single file:

```text
dist/custom.js
```

## Installation

### Windows

> **Fork note:** there are no prebuilt `svb-updater.exe` or `mod.zip` downloads for this fork. Build from source, then use the patcher below, or compile the updater yourself.

**Patch with the batch script (simplest):**
1. Run `npm install` and `npm run build`.
2. Double-click `patch-windows.bat` (or run it from CMD/PowerShell). It detects your Vivaldi path, copies `custom.js`, and injects the script.
3. *Note: you will need to run it again after every browser update.*

**Compile the auto-updater yourself (optional, needs Go 1.21+):**
The updater sits in your system tray, detects Vivaldi updates, and re-applies the mod from the `custom.js` embedded in it. The files are embedded at build time, so copy them in first:
```cmd
npm run build
copy dist\custom.js updater\
copy dist\svb-folder.html updater\
cd updater
go mod tidy
go build -ldflags "-H=windowsgui" -o svb-updater.exe .
```
Rebuild the updater after each mod rebuild to refresh the embedded files.

**Uninstallation (Windows)**
To cleanly remove the mod from Vivaldi:
- Double-click `uninstall-windows.bat` (or `unpatch-windows.bat`), or run `npm run uninstall:windows`.
- The script automatically locates your Vivaldi installation (including user or system-wide installs and Snapshot), restores `window.html` by safely removing the injected `<script>` tag, and deletes `custom.js` and `svb-folder.html`.
- If you have Vivaldi installed in a custom directory:
  ```cmd
  uninstall-windows.bat "D:\CustomPath\Vivaldi\Application"
  ```

### Linux (Debian/Ubuntu-based)

The project includes an installer that links the mod into your home directory, patches Vivaldi, and sets up an APT hook to keep it patched across updates.

1. **Build the project** (or download the pre-built files):
   ```bash
   npm run build
   ```
2. **Run the installer:**
   ```bash
   bash install-linux.sh
   ```
   *What it does:*
   - Symlinks `custom.js` and `svb-folder.html` from `dist/` into `~/.local/share/vivaldi-patch/`, so a later `npm run build` is picked up without reinstalling.
   - Creates a patching script that injects the mod into Vivaldi's `window.html`.
   - Installs an **APT hook** (`/etc/apt/apt.conf.d/99vivaldi-patch`, via `sudo`) that re-applies the patch after every apt/dpkg run. The patch is idempotent, so it only changes files when Vivaldi has overwritten them.
   - Applies the patch immediately.

Because the hook runs as root and executes a script from your home directory, only install it on a machine where you trust everything that can write to that directory. To remove it, delete `/etc/apt/apt.conf.d/99vivaldi-patch`. Without the hook, re-apply manually after Vivaldi updates with `sudo ~/.local/share/vivaldi-patch/patch.sh`.

To patch straight from the repository without installing anything to your home directory, you can use:
```bash
sudo bash patch-linux.sh
```

### macOS

The repo includes `install-macos.sh` and `uninstall-macos.sh`, plus matching npm scripts.

1. **Install:**
   ```bash
   npm run install:macos
   ```
   *What it does:*
   - Runs `npm run build` to produce a fresh `dist/custom.js`.
   - Resolves the Vivaldi resources dir (default `/Applications/Vivaldi.app/Contents/Frameworks/Vivaldi Framework.framework/Versions/Current/Resources/vivaldi`).
   - Backs up `window.html` to `window.html.bak` (only the first time, so the pristine original is preserved across re-installs).
   - Copies `dist/custom.js` into the resources dir.
   - Injects `<script src="custom.js"></script>` before `</body>` in `window.html`.
   - Auto-detects whether `sudo` is needed based on file ownership and only escalates if necessary.

2. **Uninstall:**
   ```bash
   npm run uninstall:macos
   ```
   Restores `window.html` from `window.html.bak` if present, otherwise surgically removes the injected `<script>` line, then deletes `custom.js`.

3. **Custom Vivaldi paths** (e.g. Vivaldi Snapshot):
   ```bash
   bash install-macos.sh /Applications/Vivaldi Snapshot.app
   bash uninstall-macos.sh /Applications/Vivaldi Snapshot.app
   ```

*Notes:*
- After every Vivaldi auto-update the resources directory is replaced, wiping the mod. Re-run `npm run install:macos` to reapply.
- Modifying files inside `Vivaldi.app` invalidates the code signature. macOS may show a Gatekeeper warning on first launch after install; dismiss it once and Vivaldi continues to work normally.
- Pass `-y` / `--yes` to skip the "Vivaldi is currently running" prompt.

### Manual Installation (All platforms)

If you prefer to manually inject the mod without scripts:
1. Close Vivaldi.
2. Locate Vivaldi's browser UI resources directory (`window.html`).
3. Back up `window.html` to `window.html.bak`.
4. Copy the built bundle `dist/custom.js` into the resources folder.
5. Add `<script src="custom.js"></script>` to `window.html` right before `</body>`.
6. Start Vivaldi. (Repeat after every browser update).

## Developer Setup

Install dependencies:

```bash
cd vivaldi-mod
npm install
```

Build once:

```bash
npm run build
```

Watch source files and rebuild automatically:

```bash
npm run watch
```

The build command writes:

```text
vivaldi-mod/dist/custom.js
```

## Developer Copy Workflow

For local development on Linux stable Vivaldi:

```bash
cd vivaldi-mod
npm run build

VIVALDI_DIR="/opt/vivaldi/resources/vivaldi"
sudo cp dist/custom.js "$VIVALDI_DIR/custom.js"
```

If `window.html` does not already include the mod script, add it once:

```bash
VIVALDI_DIR="/opt/vivaldi/resources/vivaldi"
grep -q 'custom.js' "$VIVALDI_DIR/window.html" || \
  sudo sed -i 's#</body>#  <script src="custom.js"></script>\n</body>#' "$VIVALDI_DIR/window.html"
```

Then restart Vivaldi.

For Vivaldi Snapshot, change the path:

```bash
VIVALDI_DIR="/opt/vivaldi-snapshot/resources/vivaldi"
```

## Recommended Vivaldi Settings

The mod is designed to replace the native tab strip visually. You can keep the native tab strip enabled while testing, but for normal use it is recommended to hide or move the native tab bar through Vivaldi settings.

Native Vivaldi workspaces remain supported and are used by the custom panel.

## Important Notes

- This mod relies on Vivaldi-specific browser APIs and some internal runtime behavior.
- A Vivaldi update can break parts of the integration, especially workspace, tiling, or window-moving features.
- Always keep a backup of the original `window.html`.
- This project is intended for users who are comfortable modifying Vivaldi's application files.

## Build Output

The repository should commit source files and may optionally include the latest `dist/custom.js` build for direct installation.

To regenerate the bundle:

```bash
npm run build
```

