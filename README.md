# ToolsMonk Desktop: Releases

This repository publishes the **ToolsMonk desktop app for Windows**: the installer, its
auto-update feed and the release notes for every version. The app's source code is
private; nothing but published builds and their packaging lives here.

**Latest version: [1.1.23](https://github.com/vksingh5995/toolsmonk-releases/releases/latest)**
(2 October 2026). Status on this page was last checked on 2 October 2026.

## What the app is

ToolsMonk Desktop puts all 255 [ToolsMonk](https://toolsmonk.com) tools in one window:
PDF, image, video, text, developer, SEO, business, student and health tools, plus
calculators and converters. It is a native window around the live toolsmonk.com site,
the same way the Slack and Notion desktop apps work, so every tool and every fix
arrives the moment the website is updated, without a new download.

What the desktop app adds on top of the website:

- **Its own home screen.** A sidebar with Home and every category, a "Continue"
  row of the tools you used last, your pinned tools, the most popular tools, and the
  whole catalogue by category. The sidebar stays on screen inside every tool.
- **One search for every tool.** Press **Ctrl+K** (or Ctrl+L), or use the search box
  in the title bar.
- **Open your files straight from Windows.** Double-click a file (once ToolsMonk is
  the default app for it), use **Open with**, or choose **Open File… (Ctrl+O)** in the
  ⋯ menu. Files open in the app's own viewer, and **Edit** hands them to the matching
  tool:

  | You open | It opens in | Edit goes to |
  |---|---|---|
  | `.pdf` | PDF viewer (thumbnails, zoom, rotate, print, passwords) | PDF Editor |
  | `.png .jpg .jpeg .webp .gif .bmp .avif .svg` | Image viewer (zoom, pan, rotate, next and previous in the folder) | Photo Editor |
  | `.mp4 .webm .mov .m4v .mp3 .wav .ogg .m4a` | Video and audio player | Video Editor |
  | `.txt .log .md .json .xml .sql .css .csv .tsv .yaml .yml .ini` | Text editor that keeps the file's encoding and line endings | (it is the editor) |
  | `.html .htm` | Web page viewer with a safe preview (scripts and network off until you allow them) and a code view | |
  | `.docx .xlsx .xls .xlsm .pptx .ppsx .tif .tiff .heic .heif` | The matching converter, or the Photo Editor | |

  Viewing a file never uploads it. Only pressing **Edit** sends it to a tool.
  Each file family gets its own icon in Explorer. ToolsMonk never makes itself the
  default app for anything; you choose that in Windows, or with
  **Set Default Apps…** in the ⋯ menu.
- **System, Light or Dark** appearance, from the control at the foot of the sidebar.
- **Your account in the title bar**, and a **Your Data and Privacy** page in the ⋯
  menu explaining how to see, download, correct or delete your data.
- **Optional usage statistics.** Off until you choose Allow, and you can switch them
  off again on the About screen, which also deletes what was collected. Website
  analytics do not run inside the app.

## Download

| Where | How | Version |
|---|---|---|
| **This page** | [ToolsMonk-Setup-1.1.23.exe](https://github.com/vksingh5995/toolsmonk-releases/releases/latest) under Assets | 1.1.23 |
| **toolsmonk.com** | [toolsmonk.com/download/windows](https://toolsmonk.com/download/windows) always gives the latest installer from this page | 1.1.23 |
| **Microsoft Store** | [ToolsMonk on the Microsoft Store](https://apps.microsoft.com/detail/9P1W5M4JBZDM) (signed by Microsoft, updates through the Store) | updated by the Store |
| **Chocolatey** | `choco install toolsmonk` | 1.1.22 approved; 1.1.23 in moderation |
| **winget** | `winget install ToolsMonk.ToolsMonk` | 1.1.18 listed; 1.1.23 [waiting for review](https://github.com/microsoft/winget-pkgs/pull/445530) |

**Requirements:** Windows 10 or 11, 64-bit, and an internet connection (the tools load
from toolsmonk.com). macOS and Linux builds are not published yet.

The installer installs for your user account only, so it does not need administrator
rights, and it can be removed from **Settings > Apps** like any other app.

## Every release contains three files

| File | What it is |
|---|---|
| `ToolsMonk-Setup-<version>.exe` | The Windows installer, about 107 MB |
| `ToolsMonk-Setup-<version>.exe.blockmap` | Lets the app download only the changed parts of an update |
| `latest.yml` | The update feed installed apps read; it carries the installer's size and SHA-512 hash |

## Code signing and the Windows warning

From **1.1.23** the installer, the app and the uninstaller are digitally signed by
**ToolsMonk Labs LLP**, with a DigiCert timestamp. Earlier versions were not signed.

The certificate is self-signed, not issued by a public certificate authority, so
Windows does not trust it automatically yet. That means **Windows SmartScreen may still
show "Windows protected your PC"** when you run the installer, and the publisher may
still be shown as not verified. Choose **More info**, then **Run anyway**. The
Microsoft Store version does not show this warning, because Microsoft signs it.

To check a download, compare it against `latest.yml`, or in PowerShell:

```powershell
Get-AuthenticodeSignature .\ToolsMonk-Setup-1.1.23.exe | Format-List Status, SignerCertificate
```

The signer should read `CN=ToolsMonk Labs LLP, O=ToolsMonk Labs LLP, C=IN`.

## Updates

The installed app checks this page a few seconds after it starts. When a new version
exists it downloads in the background and an update icon appears in the title bar;
clicking it restarts the app and installs the update. Nothing installs without that
click. You can also check by hand with **Check for Updates…** in the ⋯ menu.

The portable build and the Microsoft Store version do not use this feed (the Store
updates itself).

If an update ever reports that it could not be installed, download the latest
installer from this page and run it over your current installation. Your settings and
sign-in are kept.

## Version history

Full notes for each version are on the [Releases](https://github.com/vksingh5995/toolsmonk-releases/releases) page.

| Version | Date | Highlights |
|---|---|---|
| 1.1.23 | 2026-10-02 | The installer is digitally signed |
| 1.1.22 | 2026-09-30 | "Your Data and Privacy" in the menu; ToolsMonk pages always open inside the app; signing out leaves account screens |
| 1.1.21 | 2026-09-29 | My Account in the title bar; clearer title bar; updated browser engine |
| 1.1.20 | 2026-09-25 | Two-tone ToolsMonk name in the title bar; updated browser engine |
| 1.1.19 | 2026-09-21 | Every file type gets its own icon in Explorer |
| 1.1.18 | 2026-09-18 | PDFs, pictures, video, text and web pages open in a built-in viewer; optional usage statistics |
| 1.1.17 | 2026-09-16 | Website-only screens no longer open inside the app; current licence in the installer |
| 1.1.16 | 2026-09-15 | Maintenance release; updated browser engine |
| 1.1.15 | 2026-09-13 | Open a file straight into the tool that handles it |
| 1.1.14 | 2026-09-09 | Updates need your click before they install; licence agreement added; Electron 44 |
| 1.1.12 | 2026-09-05 | Donations open in your browser; smaller fixes |
| 1.1.11 | 2026-09-04 | New sidebar that stays with you on every screen, including inside a tool |
| 1.1.10 | 2026-09-03 | Installer publisher details |
| 1.1.9 | 2026-09-03 | Electron 44, with two major versions of Chromium security fixes |
| 1.1.4 to 1.1.8 | 2026-07 | Early desktop releases |
| 1.0.0 to 1.0.9 | 2026-06 | First releases: custom title bar, tool search, light and dark mode |

## Privacy and licence

- The app is free. Its licence agreement is at
  [toolsmonk.com/desktop-license](https://toolsmonk.com/desktop-license).
- [Privacy Policy](https://toolsmonk.com/privacy-policy) and
  [Terms of Service](https://toolsmonk.com/terms-of-service).
- Most tools process your files inside the app on your PC. The few that use a server
  are listed at
  [toolsmonk.com/where-your-files-are-processed](https://toolsmonk.com/where-your-files-are-processed).

## Help

- Use **Report a Problem** in the ⋯ menu, or [toolsmonk.com/contact](https://toolsmonk.com/contact).
- User guide: [toolsmonk.com/docs/desktop](https://toolsmonk.com/docs/desktop).

---

<sub>For maintainers: releases are built from the private
`vksingh5995/Toolsmonk-Desktop-App` repository, whose README covers building, signing
and publishing. Publishing a release here runs the **Publish downstream** workflow,
which pushes the Chocolatey package (`choco/toolsmonk/`, secret `CHOCO_API_KEY`) and
opens the winget update pull request (secret `WINGET_TOKEN`).</sub>
