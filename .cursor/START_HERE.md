# START HERE — Cursor / AI Agent Entry Point

> **Read this file first.** Every time you start a new task on this
> project, read this file top-to-bottom, then read every file in
> `.cursor/rules/` before writing a single line of code.

Bright Fortune is a **forked deployment** of the Relay Flow template
(`gray_part_flow_android`). It ships a real Flame tower-defense game
as the white part plus the isolated relay module (`lib/relay`) that
implements the gray flow: attribution → backend verdict → either the
native game or a full-screen WebView.

The forge has already run on this project — `forge.lock` at the repo
root is the audit trail of the mutation that was applied, and the
matching entry lives in `..\portfolio.json`. Any change to a
fingerprint-sensitive value goes through
`dart run tool/forge/mint.dart`, never by hand.

---

## 1. Read these documents in order

1. `.cursor/START_HERE.md` — this file (index + high-level flow).
2. `.cursor/rules/relay_forge.md` — the forge process, recipe
   schema, codec registry, mutation targets.
3. `.cursor/rules/portfolio_registry.md` — anti-collision policy;
   what MUST be unique per project vs what MAY repeat.
4. `.cursor/rules/gray_user_agent.mdc` — encoded-fragment UA
   contract; what to grep to prove no plaintext ships.
5. `.cursor/rules/webview_safe_area_injection.mdc` — safe rules
   for the JS enhancers loaded by `WebScripts.installAll`.
6. `.cursor/rules/gray_part_pitfalls.md` — battle-tested fixes
   for known Android quirks (file_picker, VPN offline, keyboard
   drift, 16 KB pages, etc.).
7. `FINAL_CHECKLIST.md` (repo root) — the pre-ship sweep.

Where a rule file describes the template's own layout (`lib/app/`,
`lib/app_assets.dart`, `MenuScreen`, the Skyward Towers placeholder),
map it onto this project using §2 below. The *policies* in those files
apply verbatim; only the paths differ.

---

## 2. Where the code lives

The relay flow is one isolated Dart tree. Nothing under `lib/screens`,
`lib/game`, `lib/widgets`, `lib/services`, `lib/data` or `lib/models`
knows about verdicts, attribution, push, or the WebView shell.

```
lib/
├── main.dart                       bootstrap wiring only
├── boot/
│   └── boot_screen.dart            loading art + progress; the ONLY
│                                   startup surface, routes on Landing
├── app/
│   └── relay_buttons.dart          buttons for the shell surfaces
├── relay/                          ← all gray logic
│   ├── relay_coordinator.dart      single decide() entry point
│   ├── codec/veil_codec.dart       string codec (forge-generated)
│   ├── config/
│   │   ├── relay_config.dart       identity + timing constants
│   │   ├── legal_urls.dart         public privacy/support URLs
│   │   └── veiled_bytes.dart       encoded byte arrays
│   ├── core/landing.dart           sealed Landing + RouteMemory + Verdict
│   ├── wire/
│   │   ├── pulse_probe.dart        connectivity + DNS reachability
│   │   ├── device_signature.dart   User-Agent assembly from fragments
│   │   ├── relay_agent.dart        http.Client carrying the forged UA
│   │   ├── beacon_keystore.dart    SharedPreferences + secure storage
│   │   ├── attribution_pulse.dart  AppsFlyer wrapper + organic rescue
│   │   ├── verdict_call.dart       POST verdict + cache the URL
│   │   ├── alert_channel.dart      Firebase Messaging + local notifications
│   │   ├── inline_beacon.dart      cold-boot push URL reader
│   │   └── web_scripts.dart        JS enhancer bundle assembler
│   └── stage/
│       ├── portal_stage.dart       WebView host (no page classification)
│       ├── permission_stage.dart   push opt-in promo
│       └── offline_stage.dart      no-connection screen
├── core/                           white-part palette / fonts /
│                                   asset registry / orientation
├── screens/                        white-part UI (menu / game / HUD)
├── game/                           white-part Flame game
├── data/, models/, services/       white-part content + persistence
└── widgets/                        white-part UI atoms
```

**Never** put gray-flow logic outside `lib/relay/`. **Never** import
anything from `lib/relay/` into the white-part directories — the game
surface must stay forensically clean. `lib/boot/` is the one place
allowed to see both, because it is the bootstrap layer.

Asset paths for every surface (including the boot / offline /
push-invite artwork) live in `lib/core/assets.dart`. The addon folder
`assets/Bright_Fortune_additional_assets/` is fingerprinted — see
`.cursor/rules/custom_screens.md`.

---

## 3. How the boot pipeline works (30-second version)

```
main.dart
  → Firebase + AppCheck (failures never block startup)
  → all orientations + immersive chrome (status AND navigation bar
    hidden on every surface, re-asserted on each resume)
  → prime UA + keystore
  → construct pipeline (probe / pulse / verdict / alerts / coordinator)
  → runApp(BrightFortuneApp)

BrightFortuneApp → BootScreen (loading art + progress bar)
  → coordinator.decide(onProgress: ...)      owns progress 0 .. 0.6
  → switch on the returned Landing:
       GameLanding()        → warm sprites/audio/progress (0.6 .. 1.0),
                              lock landscape + immersive, MainMenuScreen
       PortalLanding(url)   → PermissionStage or PortalStage (WebView)
       OfflineLanding()     → OfflineStage (retry rebuilds BootScreen)
```

`RelayCoordinator.decide` is the ONLY place gray/native routing is
decided. It reads the push launch intent first (`InlineBeacon`), then
branches on the persisted `RouteMemory` and the current state
(adapter → DNS probe → verdict / cache). All timing constants come
from `RelayConfig`.

The game art warm-up runs **only** on the native branch — a portal
install must not pay for ~70 sprite decodes. The progress bar is
monotonic and reaches 1.0 on the frame the next route is pushed —
except on `OfflineLanding`, which is pushed the moment the probe
fails so "no connection" never arrives after a full bar.

Read `lib/relay/relay_coordinator.dart` when you need to understand
or extend the decision. Do NOT scatter routing logic across screens.

---

## 4. The forge

`tool/forge/mint.dart` takes `tool/forge/recipe.json` (gitignored —
it holds plaintext secrets), encodes every secret with the selected
codec family, verifies round-trips, refuses if the recipe collides
with `..\portfolio.json`, and rewrites ten files across `lib/`,
`android/`, and `pubspec.yaml`.

This project's applied mutation:

| field | value |
|---|---|
| codec family | `fnv_lcg` (stream length 45) |
| storage key prefix | `q4v_` |
| notification channel | `lantern_alerts` |
| upload MethodChannel | `lantern/chooser` |
| Chrome UA version | `149.0.7614.128` |
| DNS probe hosts | `wikipedia.org`, `microsoft.com` |
| JS enhancers | `safeArea`, `keyboard`, `viewportTint`, `keyboardBridge` (no `autoplay`) |

The enhancer bodies live in `tool/forge/jsvariants/` and are encoded
into `veiled_bytes.dart` by the forge — never edit the generated
arrays, and never inline JS into `web_scripts.dart`.

Re-running the forge:

```powershell
dart run tool/forge/mint.dart --dry-run     # shows planned writes
dart run tool/forge/mint.dart               # applies + updates portfolio
flutter analyze                             # must pass
```

The recipe schema, mutation contract, and codec registry are in
`.cursor/rules/relay_forge.md`.

---

## 5. Things that must NEVER be in the binary

If any of these grep hits are non-zero on a release build, the
project is not shippable. Every one of them ships zero today:

```powershell
# UA scaffolding fragments  ← every one must be encoded
rg -n 'Mozilla/5\.0|Linux; Android|AppleWebKit|Mobile Safari|like Gecko|Chrome/' lib

# Credentials + endpoint ← all three live encoded in veiled_bytes.dart
rg -n 'L64QUBb5yCKzqrv5cSy6JS|557368285355|config\.php' lib

# App identity in the UA ← this project ships no appid/appname suffix
rg -n 'appid/|appname/' lib

# Page-classification vocabulary ← the client must never classify
rg -n 'deposit|cashier' lib -i

# Legacy naming (means an old file survived the migration)
rg -n 'TowerFacade|AppMode|ShellMode|FlowRouter|WebStage|Clarity' lib

# White part must not import the relay tree
rg -n "relay/" lib/screens lib/game lib/widgets lib/services lib/data lib/models
```

Full grep list lives in `FINAL_CHECKLIST.md`.

---

## 6. Invariants — do not break these

1. `RelayCoordinator.decide` is the only place that emits a
   `Landing`. Add new destinations by extending the sealed class
   in `lib/relay/core/landing.dart` — do NOT bypass with ad-hoc
   `Navigator.pushReplacement`.
2. Every string that plaintext-clusters (URLs, keys, UA fragments,
   JS bodies) lives as an encoded byte array in `veiled_bytes.dart`.
   Add new secrets by appending to `veiled_bytes.dart` AND to the
   forge encoder — never inline a raw literal in the module.
3. The client never classifies the pages it loads. If page-level
   logic is required, it lives server-side.
4. The WebView carries the same UA as the HTTP client. Both come
   from `DeviceSignature.userAgent`.
5. `push_token` and `firebase_project_id` fields are omitted from
   the verdict body when Firebase failed to initialise — never
   sent as `""` or `null`.
6. Storage key prefix, notification channel id and MethodChannel
   name are forge-rotated; hand-edits are forbidden.
7. Numeric constants (timeouts, retries, snoozes) all live in
   `RelayConfig` — every one has a range in `relay_forge.md`.
8. Debug logs are `assert`-wrapped so `--release` strips them. No
   `print(...)`, no `debugPrint(...)` outside `assert(() { ... })`.
9. `BootScreen` is the only screen that supports portrait. The game
   locks landscape through `enterGameChrome()`; the shell surfaces
   stay in both orientations. No surface shows system bars —
   `enterImmersive()` in `lib/core/orientation_helper.dart` is the
   single place that configures chrome.
10. A push URL is never persisted. It is read from the launch intent
    once per launch, de-duplicated by message id (Android replays the
    launch intent when the task is restored), and every other launch
    resolves its destination from the config response or the cache.
11. Launcher icon layers are generated: `dart run tool/gen_icon.dart`
    then `dart run flutter_launcher_icons`. The notification icon
    (`res/drawable/ic_notification.xml`) is a separate flame
    silhouette and must stay distinct from it.

---

## 7. Windows / PowerShell notes

Use PowerShell syntax for shell one-liners, and `dart run tool/...`
for anything doing 64-bit integer arithmetic (PowerShell overflows at
32 bits and corrupts byte streams — the reason `tool/forge/` is Dart).

This project is Android-first. Check with the operator before editing
`ios/`; iOS has no Firebase configuration and no store id today
(`RelayConfig.storeNumericId` is empty, so `storeId` falls back to the
application id).
