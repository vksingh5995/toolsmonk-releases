# ToolsMonk Desktop — Releases

A native desktop shell around the live **toolsmonk.com** site. It is fully
self-contained in this `desktop/` folder and does **not** touch the web app or
the PWA — the web/Next.js build is unaffected.

It loads the deployed site (like the Slack / Notion / Spotify desktop apps), so
all server features (AI chat, auth, payments) work, and the existing PWA service
worker runs inside the window too (so offline caching applies here as well).

Auto-update artifacts (Windows installer + `latest.yml` update feed) for the ToolsMonk desktop app.
Managed by electron-builder / electron-updater. Source code lives in the private ToolsMonk repo.

You can also checkout at [ToolsMonk](https://toolsmonk.com)

## The app's own screens

The app opens on **`/desktop`**. A persistent rail down the left lists Home and
every category; the work pane leads with **Continue** and **Pinned**, then the
operator's "Most popular" band, then the whole catalogue grouped by category.
**`/desktop/category/<slug>`** is the drill-down (All / Popular / Trending
filters). They are light and dense, and they match this shell's title bar
rather than the website.

⚠️ **The rail and the palette live in the route LAYOUT**, so they survive every
navigation. Only the work pane scrolls, never the window. That is what makes a
route change read as an application switching views.

### ⚠️ The title bar owns the ONE search, and the palette's input is always in the DOM

⚠️ **Do not add a search box to a screen inside the app.** An early version of the
redesign had three at once on a category screen: this title bar's button, a
"Search" item in the rail, and a "Filter N tools" box in the toolbar. Two of them
opened the same palette. `tests/desktop-shell.test.mjs` now fails on any `<input`
in a desktop screen.

Ctrl+K opens the palette, and so does the title bar's search button, and so does
Ctrl+L. All three end up focusing one input, and **focusing it is what opens the
palette** — which is precisely how the search button in an ALREADY INSTALLED
shell still works: `FOCUS_SEARCH_JS` runs a focus selector, and there is
something for it to find.

So when the palette is closed its input is **clipped, never `display: none` or
`visibility: hidden`**. Both of those make an element unfocusable and would break
the search button on every machine that has not taken an update, silently.
`tests/desktop-shell.test.mjs` pins it, along with the rule that exactly one
element in the tree may carry `data-tm-desktop-search`.

### Tool pages inside the app

`src/app/desktop-app.css` (imported by the web app's root layout) restyles the
255 tool pages for this window: the OS font, the app ground, and no website
chrome — no star rating, no share or favourite buttons, no cookie banner.

⚠️ Every rule there is keyed on `html[data-tm-route]`, which **this preload
already sets before first paint**. So it is inert on the website, it applies
without a flash, and it reaches users on a WEB DEPLOY rather than needing a
release. It hides `data-tm-web-chrome`, an attribute on our own elements, rather
than matching Tailwind classes the way `DESKTOP_CSS` below still has to.

⚠️ Hiding the consent banner means analytics consent is never given inside the
app, so analytics do not run there. That is deliberate and privacy-safe; it also
means desktop visits do not appear on the analytics screens.

⚠️ **Those screens live in the WEB app (`src/app/desktop/`), not in this folder.**
That is deliberate. The catalogue is 255 tools and the "Most popular" band is
configured from the admin panel (`/admin/tools` → **Desktop app home**, stored in
`app.site_setting["desktop-tools"]`); putting either inside the installer would
mean a second copy of the catalogue that drifts, no way to reach the database, and
a signed release for every change. This shell only points at the route, so
redesigning a screen is a web deploy.

### The rail

One fixed width (76px), icon over label, on every screen. It does not expand or
collapse: that control changed the width of the whole work pane, and removing it took
the stored state, the pre-paint attribute and a whole module with it.

⚠️ **It renders on TOOL PAGES too**, which is the point. `/desktop/*` has its own
layout, so the app's navigation used to disappear the moment somebody opened a tool.
`components/Layout.tsx` mounts it through `DesktopRailMount` for every other route.

⚠️ **That mount renders `null` outside this shell** — not `display: none`. It sits in
the website's shared layout, so hiding it with CSS would put ten links to `noindex`
`/desktop/*` routes on every indexed page of the site.

⚠️ **Its CSS lives in `src/app/desktop-app.css`, not `src/app/desktop/desktop.css`.**
The second file is loaded by the `/desktop/*` layout only, so a rail rule there is a
rail that renders unpainted on a tool page. The `--tmd-*` tokens moved with it, and
were moved rather than copied.

### Navigation

⚠️ **The title bar carries HISTORY only** (back, forward, reload). **The rail owns
LOCATIONS**, including Home. Do not add a Home button back to the chrome: the
rail's Home row is the only thing that marks the home view as current
(`aria-current`), so the two were never interchangeable, and two Home controls on
one screen is what prompted removing the chrome one.

The app menu still has a Home item, which calls `navHome` directly.
`tests/desktop-shell.test.mjs` fails if a Home button returns to the bar, if the
rail loses its `aria-current`, or if the `nav:home` bridge comes back with no
caller.

### Loading

⚠️ **Do not reintroduce a shimmer.** The placeholders are flat and still on
`--tmd-skel`, and `.tmd-loading` (a 2px indeterminate line at the top of the work
pane) is the only thing that moves. A sweeping gradient over a field of blocks is
the website's idiom and is what made the app's loading state read as a page
loading. `tests/desktop-shell.test.mjs` fails on its return.

⚠️ The blocks are not removed: they reserve the box the real content lands in.

⚠️ Website skeletons rendered inside the app adopt the same treatment, by
redefining the two tokens `theme.css` builds its sheen from. The website keeps its
shimmer, which is correct there.

⚠️ These route skeletons are nearly unreachable in production: every route is
prerendered and the launcher prefetches its links, so the boundary is usually
bypassed. In `pnpm run dev` they fire constantly, because a first hit compiles the
route.

### Appearance: System, Light, Dark

An **Appearance** control sits in the foot of the rail, with the collapse control
under it, and turns over the title bar, the rail, the work pane and the tool pages
together. It cycles System -> Light -> Dark, and **System is the default**.

⚠️ **THREE PREFERENCES, TWO THEMES.** The preference is what was chosen and is what
is persisted; the theme is what is on screen. Under `system` the theme moves on its
own, at sunset, so they are two attributes: `data-tm-theme` (resolved, what the CSS
keys on) and `data-tm-theme-pref` (the choice, what the control renders).
`nativeTheme.shouldUseDarkColors` resolves it, and `nativeTheme.on("updated")` is
what keeps it resolved — remove that listener and `system` is inert after launch.

⚠️ **`theme.json` migrates, it does not reset.** An older `{ "theme": "dark" }` is
read as the preference `dark`, because that was an explicit choice. A fresh profile
writes nothing until somebody chooses.

⚠️ **THE MAIN PROCESS OWNS THE THEME, NOT THE PAGE.** It persists the choice to
`theme.json` in userData and paints three surfaces with it before any content
exists: the window background, the embedded view background and this title bar.
The site preload reads it with `sendSync("theme:get")` at document-start, which is
what makes the switch and every navigation flash-free.

⚠️ **It sets `data-tm-theme`, never the `dark` class.** next-themes owns that
class in the web app and re-applies it on OS theme changes, so a class set here
would be stripped later with nothing reporting it. It is also what keeps the
WEBSITE light: nothing out there ever sets the attribute.

⚠️ **The palette here and in `src/app/desktop/desktop.css` are the same values,
in BOTH themes.** `shell.html` is the source:

| | light | dark |
|---|---|---|
| ground | `#edf1f7` | `#0b0f1a` |
| bar | `#ffffff` / `#f1f4f9` | `#111a2e` / `#0d1424` |
| text / muted | `#0f172a` / `#55607a` | `#e8edf7` / `#9aa6bf` |
| accent | `#0A66C2` (brand1) | `#378FE9` (brand2) |

⚠️ The accent FLIPS with the theme and that is not decoration: the deeper blue
has no weight on a pale bar and the lighter one disappears into a dark one. A
single accent fails at one end.

Change one without the other and a seam appears where the title bar meets the
content.

⚠⚠ **THE GROUND IS NOT WHITE ON PURPOSE.** The tool card is white; a white ground
would dissolve it into the page. A light neutral pane carrying white document
sheets is how Word, Acrobat and Figma draw a light application.

⚠️ **The ground is written in FIVE places and two of them paint before any content
exists**: this file (title bar and loader stage), `desktop.css`,
`src/app/desktop-app.css`, `main.js` `setBackgroundColor` (the embedded view) and
`main.js` `backgroundColor` (the window itself). Miss either of the last two and
every launch flashes the old colour for a few frames.
`tests/desktop-shell.test.mjs` pins all five.

### Releasing

⚠️⚠️ **ONE MACHINE CANNOT BUILD ALL THREE PLATFORMS, AND TWO OF THOSE LIMITS ARE THE
TOOLING'S, NOT A PREFERENCE.** Measured on Windows:

| platform | what happens | why |
|---|---|---|
| Windows | build exits 1 | `forceCodeSigning: true` with no certificate. Working as designed |
| macOS | refused outright | `app-builder-lib/out/packager.js` throws "Build for macOS is supported only on macOS" |
| Linux | `ENOENT` on `mksquashfs` | electron-builder resolves the **darwin** AppImage binary on a Windows host; `.deb` fails too |

So releases go through **`.github/workflows/desktop-release.yml`**, a three-OS matrix.
Run it from the Actions tab: leave `publish` off for a build-only dry run that uploads
the installers as artifacts, and turn it on to publish a DRAFT release.

⚠️ **The bytecode is compiled per platform and must be.** `protect.js` produces V8
bytecode, and V8 only accepts bytecode from a V8 booted on the same read-only heap
snapshot: a `main.jsc` built on Windows is rejected at launch on macOS or Linux. Each
`dist:*` script runs `protect` itself, so this is correct by construction. On the
headless Linux runner that compile needs `xvfb-run`, because bytenode spawns Electron
in GUI mode.

⚠️ Secrets the workflow expects: `RELEASES_TOKEN` (a PAT with `contents: write` on the
**releases** repo — `GITHUB_TOKEN` is scoped to this repo and cannot publish there),
`AZURE_*` for Windows signing, and `MAC_CSC_LINK` / `MAC_CSC_KEY_PASSWORD` plus the
`APPLE_API_*` trio for macOS.

### Where the app is published

Seven channels, and only two of them are ours to push to directly. The full record, with
identities, package ids, manifest paths, what is blocked on whom, and the traps each one
cost, is **`docs/DESKTOP-APP-LISTINGS.md`**.

| Channel | Identity there | Whose move (2026-09-05) |
|---|---|---|
| GitHub Releases | `vksingh5995/toolsmonk-releases` | ours |
| SourceForge | project `toolsmonk` | ours; releases mirror themselves |
| winget | `ToolsMonk.ToolsMonk` | Microsoft moderator, all checks passed |
| Chocolatey | package `toolsmonk` | Chocolatey moderation |
| Microsoft Store | Store ID `9P1W5M4JBZDM` | blocked on Microsoft account verification |
| AlternativeTo | app `ToolsMonk` | their review queue |

⚠️ **`winget install ToolsMonk` answering "No package found matching input criteria" is
the expected state until that PR merges.** It is not a defect.

⚠️ **A release published here reaches SourceForge on its own**, through a GitHub webhook,
and that folder's README is generated from the **release notes**. An empty release body is
therefore an empty page on a second site.

⚠️ **Chocolatey cannot take a new version while the previous one is in moderation.** The
push returns a bare 403 that looks like a bad API key and is not.

### Platforms

Windows (nsis + portable), macOS (dmg + zip, arm64 and x64) and Linux (AppImage +
deb). Build with `pnpm run dist`, `dist:mac`, `dist:linux` — each names its platform,
because bare `electron-builder` builds for whatever the build machine happens to be.

⚠️ **macOS and Linux artifacts must be built on their own platforms.** Signing and
notarization call Apple tooling that does not exist elsewhere.

⚠️⚠️ **The macOS `zip` target is not optional.** Squirrel.Mac updates from it, and
without it `latest-mac.yml` is never produced, so auto-update fails at runtime with
nothing in the build to explain why.

⚠️ **`forceCodeSigning` does not reach macOS** (only `winPackager` reads it), but a
real run showed the platform stops anyway, from a different path: `⨯ skipped macOS
application code signing ... 0 valid identities found`. An earlier note here claimed an
unsigned dmg would build quietly; it does not.

⚠️ What no build step asserts is NOTARIZATION, so check a signed build by hand:

```
codesign -dv --verbose=4 "dist/mac/ToolsMonk.app"
spctl -a -vvv -t install "dist/mac/ToolsMonk.app"
xcrun stapler validate "dist/ToolsMonk-<version>.dmg"
```

⚠️ Notarization is not a config flag: electron-builder runs it when it finds
`APPLE_API_KEY` + `APPLE_API_KEY_ID` + `APPLE_API_ISSUER` (preferred), or the
`APPLE_ID` / `APPLE_APP_SPECIFIC_PASSWORD` / `APPLE_TEAM_ID` trio, in the environment.

⚠️ **Linux `.deb` cannot auto-update** — it would need a package repository. AppImage
can.

### The ⋯ menu

⚠️ **No fact lives in it.** `About ToolsMonk` opens `/desktop/about`, a web route
that derives its figures from the catalogue; it used to be a dialog reading "252+
tools" when the catalogue was 255. A number typed into `main.js` can only be
corrected by shipping a new installer. Privacy Policy and Terms open the live pages
for the same reason.

⚠️⚠️ **The accelerators printed here are LABELS.** `Menu.setApplicationMenu(null)`
means the popup registers nothing; the bindings are in `before-input-event`. "Quit
ToolsMonk  Ctrl+Q" was printed for a key nothing listened for. Add a shortcut in BOTH
places, or the menu prints a promise the app does not keep.

⚠️ **Donate opens in the app, and so does the payment.** An earlier note here said
the payment step leaves for the system browser. That was wrong: `IN_APP_HOST_PATTERNS`
lists `*.paypal.com`, `*.razorpay.com` and `accounts.google.com` as in-app, so those
popups are child windows of the app. Only hosts OUTSIDE that list are handed to the
browser. Neither gateway has been driven to completion, because that means making a
real payment.

⚠️ There is no Toggle Developer Tools item. It was `isDev`-gated so it never shipped,
and Ctrl+Shift+I still works under the same gate.

### Type

**Segoe UI Variable**, in three optical sizes — Small for captions, Text for running
UI, Display for anything large. That is the face Windows 11 and the Microsoft Store
render in, and using the wrong optical size is worse than using none.

⚠️ No webfont, ever. Shipping one is the cheapest "this is a website" tell there is,
and the site's own Inter is what the app had to stop looking like.

⚠️ **This file needs its own copy of the stack** — the title bar is a separate
WebContents and cannot read a token from the site's stylesheet — and it also needs
`button, input, select, textarea { font-family: inherit }`. Form controls do not
inherit a font, and this bar is almost entirely buttons: before that rule, 11 of them
including the Search button rendered in **Arial**.

⚠️ To check whether a font is installed, measure canvas text width against a
monospace baseline. `document.fonts.check()` does not answer the question — it returns
`true` for fonts that are not there.

⚠️ **`body` here must also set `color: var(--fg)`.** Without it, text that does not
name its own colour falls to the UA default, pure black. The app name did: 18.53:1 on
the light bar by luck, **1.1:1** on the dark one. Fix it on `body`, never on the one
element, or the next control added to this bar inherits the same trap.

### Search

One search, and it covers TOOLS only — no pages, no blog posts. The placeholder says
so: "Search tools".

⚠️ The website's own palette ("Search tools, blogs, categories...") is mounted on tool
pages, and is kept out of reach by two things at once: this preload hides
`nav.sticky.top-0`, the only control that opens it, and `main.js` takes Ctrl+K before
the page sees it. Remove either and the app grows a second search that returns blog
posts.

### Ctrl+K

The search button prints a `Ctrl K` cap, and `main.js` binds the shortcut to the
same `focusSearch` the button calls — including navigating home first from a screen
that has no palette. The bar is on screen everywhere, so a shortcut that only worked
on the launcher screens would print a hint that is a lie on every tool page.

⚠️ It cannot be verified by driving the app over CDP: injected keys never reach
`before-input-event`. Ctrl+L, bound to the same function and shipped much earlier,
is equally inert under injection, which is how that was established rather than
mistaken for a broken binding. Press it by hand.

⚠️ **`preload.js`'s `DESKTOP_CSS` is a JS template literal: never put a backtick
inside it**, not even in a CSS comment. It closes the literal, and a broken preload
injects no CSS *and* never exposes `window.toolsmonkDesktop`, so the web app stops
recognising the desktop and starts showing PWA install prompts. Run
`node --check desktop/preload.js` after editing it.

## Run

```bash
cd desktop
pnpm install         # downloads Electron on first use

pnpm start           # opens the production site (https://toolsmonk.com)
pnpm run dev         # opens http://localhost:3000 (run the web app's `pnpm run dev` first)
```

You can override the URL: `TOOLSMONK_APP_URL=https://staging.toolsmonk.com pnpm start`.

## Build a Windows installer

```bash
cd desktop
pnpm run dist        # -> dist/ToolsMonk-Setup-<version>.exe  (installer)
                     #    dist/ToolsMonk-<version>-portable.exe (no-install)
                     #    dist/latest.yml + *.blockmap (auto-update metadata)
pnpm run pack        # quick unpacked build (dist/win-unpacked/) for testing
```

## Auto-update

Auto-update is wired up via `electron-updater` and works with **unsigned** builds
(`win.verifyUpdateCodeSignature: false` in `electron-builder.yml`). It runs only
in the **installed (Setup) build** — not in dev or the portable `.exe`.

How it behaves: a few seconds after launch the app quietly checks the update
feed; if a newer version exists it downloads in the background and then offers
**Restart now / Later** (and installs on next quit). There's also a manual
**Help → Check for Updates…** menu item.

### Publishing an update

Releases are published to the **public** repo
[`vksingh5995/toolsmonk-releases`](https://github.com/vksingh5995/toolsmonk-releases)
(configured under `publish:` in `electron-builder.yml`). The private source repo
is never touched — only the installer + update feed go to the public repo.

> ⚠️ A git commit/push does **nothing** by itself — you must build and publish a
> GitHub Release for installed apps to update. (Bumping the version in
> `package.json` alone is not enough.)

**Recommended (reliable) flow — build, then publish with `gh`:**

1. Bump `version` in `package.json`.
2. Authenticate once with write access to the releases repo: `gh auth login`
   (or `gh auth switch` to the right account).
3. Build the installer (no publish):
   ```bash
   cd desktop
   pnpm run dist
   ```
4. Create ONE release and upload all three assets:
   ```bash
   gh release create v<version> -R vksingh5995/toolsmonk-releases \
     --title "ToolsMonk <version>" --notes "What changed…" \
     dist/ToolsMonk-Setup-<version>.exe \
     dist/latest.yml \
     dist/ToolsMonk-Setup-<version>.exe.blockmap
   ```
5. Installed apps pick it up automatically a few seconds after the next launch
   (or via **Help → Check for Updates…**).

Verify it went live (should print your new version):
```bash
curl -sL https://github.com/vksingh5995/toolsmonk-releases/releases/latest/download/latest.yml
```

Notes:
- **Why not `pnpm run release`?** `electron-builder --publish always` runs the
  GitHub publisher once **per artifact concurrently**, which can race and create
  **duplicate releases** / drop the large `.exe`. The `pnpm run dist` + single
  `gh release create` flow above avoids that entirely. (`pnpm run release` is kept
  only for CI setups that serialize publishing.)
- The releases repo must be **public** and have **at least one commit** — GitHub
  rejects a release on an empty repo (422 "Repository is empty").
- `GH_TOKEN` / `gh` auth is used only at publish time; it is **never** shipped in
  the app.

## App icon

`build/icon.png` (512×512) is converted to a Windows `.ico` automatically by
electron-builder. For the crispest result, replace it with a **1024×1024 PNG**
(or drop in a multi-size `build/icon.ico`).

## Code signing (remove the install warning)

On a fresh machine, an **unsigned** installer makes Windows show SmartScreen
("Windows protected your PC") and a UAC **"Publisher: Unknown"** line. Removing
this requires a real **code-signing certificate** — it cannot be bundled in the
repo and must be bought from a CA against your organization's identity.

⚠️ **That is true of the installer we distribute ourselves, and only of it.** There
is a fourth route that costs no certificate at all: publishing through the
**Microsoft Store**, which signs the package itself during ingestion. It does not
replace the download on the site, so both paths are worth having — see
`electron-builder.appx.yml` and `pnpm run dist:appx`.

**Which route removes the warning *immediately*:**

| Type | Removes UAC "Unknown Publisher" | Removes SmartScreen warning | Notes |
|---|---|---|---|
| **EV** | ✅ instantly | ✅ **instantly** (reputation granted) | Key on USB token / cloud HSM |
| **Azure Trusted Signing** | ✅ instantly | ✅ **instantly** | Cloud, no token, ~$10/mo, CI-friendly |
| **OV (standard)** | ✅ instantly | ⚠️ **not** at first — SmartScreen keeps warning until the binary earns download reputation (can take weeks / many installs) | Key on token / HSM |
| **Microsoft Store** | ✅ n/a — there is no installer to elevate | ✅ **instantly** (a Store install is trusted) | Microsoft signs it, free. One-time account fee; needs the Partner Center identity values |

> Since June 2023 the CA/Browser Forum requires **all** code-signing keys (OV *and*
> EV) to live on hardware (USB token) or a cloud HSM — a plain exportable `.pfx`
> is only possible for legacy certs. For automated/CI builds, **Azure Trusted
> Signing** or a cloud-HSM service (DigiCert KeyLocker, SSL.com eSigner) is the
> practical path.

### Using an EV certificate (chosen route)

**1. Buy an EV Code Signing certificate** from a CA — e.g. **SSL.com**, **Sectigo**,
**DigiCert**, or **GlobalSign** (~$250–600/yr). If you want to keep the automated
publish flow, pick a CA that offers **cloud signing** (SSL.com eSigner, DigiCert
KeyLocker).

**2. Complete organization identity verification** (business registration /
D-U-N-S, phone or notary). Usually a few days to ~2 weeks. You then receive the
key on a **USB token** (SafeNet eToken) or a **cloud HSM**.

**3a. Sign locally with a USB token** — install the token drivers (e.g. *SafeNet
Authentication Client*), plug it in, then:

```powershell
# find the thumbprint
Get-ChildItem Cert:\CurrentUser\My | Format-List Subject, Thumbprint
```

Uncomment in `electron-builder.yml` (`win` section) and set it:

```yaml
certificateSha1: "<thumbprint>"
```

```bash
pnpm run dist       # enter the token PIN when prompted -> signed installer
```

**3b. Sign in CI / automated `pnpm run release`** — a physical token can't be used
headlessly, so use a **cloud-HSM EV cert** (SSL.com eSigner, DigiCert KeyLocker,
GlobalSign). Uncomment `sign: "./sign.js"` in `electron-builder.yml` and add a
`sign.js` that calls the provider's signing CLI (provider supplies the exact
command + the env-var credentials).

> ⚠️ With a **physical USB token**, the current headless `pnpm run release` flow
> **cannot sign** — either run the build on a machine with the token attached, or
> use a cloud-HSM EV cert (3b).

**Verify a build is signed:**

```bash
# PowerShell
Get-AuthenticodeSignature .\dist\ToolsMonk-Setup-<version>.exe | Format-List
# or: right-click the .exe → Properties → Digital Signatures
```

Once releases are signed with a consistent publisher, you may set
`win.verifyUpdateCodeSignature: true` for extra auto-update integrity.

## Notes

- Security: `contextIsolation` on, `nodeIntegration` off, `sandbox` on; the
  preload exposes only a tiny read-only `window.toolsmonkDesktop` flag.
- External links (non-ToolsMonk) open in the system browser; auth/payment
  redirects (Google, Razorpay and PayPal) stay in-app. Supabase is no longer part
  of the runtime architecture.
- Window size/position is remembered between launches.
- `HOME_URL` is `/desktop`. The title bar's search button and `Ctrl+L` focus that
  screen's search box; `Ctrl+F` is find-in-page, which is a different thing.
- Auto-update is set up (see above) and works on unsigned builds.
- **Unsigned by default:** a fresh install shows the SmartScreen / "Unknown
  Publisher" warning until a code-signing certificate is configured — see
  **Code signing** above. Auto-update is unaffected.
