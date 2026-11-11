# Release Notes (v2.3.8-nogemini)

First release of the no-Gemini fork of [R0STEFAN/Vivaldi-Tree-Style-Tabs](https://github.com/R0STEFAN/Vivaldi-Tree-Style-Tabs). It is upstream **v2.3.8** with the Gemini AI integration removed.

## 🗑️ Removed

* **Gemini AI Tab Grouping**: Removed the Gemini API client, the header AI button, the "AI Tab Grouping" settings block and the toast notifications that only it used. The mod makes no calls to any AI service and never asks for an API key.
* **Stored settings cleanup**: Saved `geminiApiKey`, `geminiModel` and `geminiFolderLanguage` are deleted from browser storage the first time the mod loads, so an old key does not linger in your profile.

## 🔄 Changed

* **Windows updater**: `svb-updater.exe` now checks this fork's releases instead of upstream's.
* **Linux installer**: `install-linux.sh` targets Debian/Ubuntu. It installs an APT post-invoke hook (`/etc/apt/apt.conf.d/99vivaldi-patch`) in place of the pacman hook, and symlinks the build output so `npm run build` is picked up without reinstalling.

Everything else (tree persistence, workspace handling, side panel coexistence and the other upstream v2.3.x fixes) is unchanged.

---

## 📦 Automated Tests
* Full test suite passing with **123 automated unit and integration tests**.
