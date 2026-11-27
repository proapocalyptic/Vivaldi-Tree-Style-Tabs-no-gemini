# Release Notes (v2.3.9-nogemini)

The no-Gemini fork of [R0STEFAN/Vivaldi-Tree-Style-Tabs](https://github.com/R0STEFAN/Vivaldi-Tree-Style-Tabs) now tracks upstream **v2.3.9**. It remains source-only: build it yourself with `npm run build`.

## 🚀 What's Fixed in v2.3.9 (upstream)

* **Detach Tabs to New Window**: Detach tabs into new windows via the native Vivaldi API and fix multi-tab fallback creation.
* **Web Panel Tabs**: Hide Vivaldi web panel tabs (`panelId`) from the tab tree and preserve them during new-window cleanup.
* **Popup & Window Isolation**: Skip mounting in popup/DevTools windows and filter tab events by `windowId`.

## 🗑️ Removed in this fork

* **Gemini AI Tab Grouping**: Removed the Gemini API client, the header AI button, the "AI Tab Grouping" settings block and the toast notifications that only it used. The mod makes no calls to any AI service and never asks for an API key.
* **Stored settings cleanup**: Saved `geminiApiKey`, `geminiModel` and `geminiFolderLanguage` are deleted from browser storage the first time the mod loads, so an old key does not linger in your profile.

## 🔄 Changed in this fork

* **Windows updater**: `svb-updater.exe` checks this fork's releases instead of upstream's.
* **Linux installer**: `install-linux.sh` targets Debian/Ubuntu. It installs an APT post-invoke hook (`/etc/apt/apt.conf.d/99vivaldi-patch`) in place of the pacman hook, and symlinks the build output so `npm run build` is picked up without reinstalling.
* **Tab title font size**: The fork's Settings selector for tab title font size is retained.

Everything else (tree persistence, workspace handling, side panel coexistence and the other upstream v2.3.x fixes) is unchanged.

---

## 📦 Automated Tests
* Full test suite passing with **144 automated unit and integration tests**.
