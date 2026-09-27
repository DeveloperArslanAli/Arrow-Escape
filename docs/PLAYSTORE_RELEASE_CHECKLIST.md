# 🚀 Google Play Store Publication Checklist & Release Guide (Release v2.0)

**App Name:** Arrow Escape: Puzzle Grid  
**Package Identifier:** `com.developerarslanali.arrowescape`  
**Version Code:** `4` | **Version Name:** `2.0.0`  
**Target SDK:** 36 (Android 16) | **Min SDK:** 24 (Android 7.0 Nougat)  
**Supported Architectures:** ARM64-v8a (64-bit mandatory), ARMv7 (32-bit legacy fallback)  
**Release Formats:**
- **`.aab` (Android App Bundle)**: Mandated for Google Play Console distribution (Target API 36, R8-shrunk).
- **`.apk` (Universal Release)**: For direct hardware sideloading and QA validation.

---

## 1. Executive Technical Strategy: Gradle Build vs Standard Export

### The Lead Project Engineer's Assessment:
> **Question:** *"If we go with Gradle build, is it working? What is the best approach?"*
>
> **Answer & Recommendation:**
> 1. **Gradle Build is MANDATORY for Google Play Store:** Google Play Store enforces the **Android App Bundle (`.aab`)** format and Target API 36 compliance. In Godot 4, the **only** mechanism that produces compliant `.aab` bundles with Google Play App Signing, split architectures, Target SDK 36, and R8 bytecode optimization is the **Gradle Build workflow** (`gradle_build/use_gradle_build = true` and `gradle_build/export_format = 1`).
> 2. **Precompiled Template Export (`.apk`) is for Testing & Sideloading:** Standard precompiled export generates a single universal `.apk`. This is optimal for rapid iterative testing on connected Android devices via ADB, but Google Play Console requires `.aab` for production store distribution.
> 3. **The Dual-Artifact Approach:**
>    - Deliverable A: `ArrowEscape.aab` (Signed Release Bundle for Google Play Console submission)
>    - Deliverable B: `ArrowEscape-release.apk` (Signed Release APK for immediate direct device testing)

---

## 2. Cryptographic Signing & Keystore Details

A dedicated 2048-bit RSA release keystore has been provisioned and configured:
- **Location:** `keystores/release.keystore`
- **Keystore Format:** PKCS12 / JKS
- **Key Alias:** `arrowescape`
- **Algorithm:** RSA 2048-bit, SHA-256 with RSA
- **Validity:** 10,000 Days (~27 Years)
- **Certificate Subject:** `CN=Developer Arslan Ali, OU=Games, O=Indie, C=PK`
- **Credentials:**
  - Keystore Password: `ArrowEscapeRelease2026!`
  - Key Password: `ArrowEscapeRelease2026!`

> ⚠️ **CRITICAL BACKUP RULE:** Keep a secure, off-site backup of `release.keystore` and its passwords. If lost, Google Play will not allow updates to existing installations unless enrolled in Google Play App Signing with key recovery.

---

## 3. Google Play Console Form Declarations & Policies

### A. Data Safety Section
- **Does your app collect or share any user data?** ➡️ Select **"No"**.
- **Data Encrypted in Transit:** Not applicable (zero network data).
- **Account Creation / Deletion:** Not applicable (pure offline game).
- **Privacy Policy URL:** Enter your official hosted privacy policy URL:
  `https://developerarslanali.github.io/Arrow-Escape/privacy.html`  
  *(Alternative raw URL: `https://raw.githubusercontent.com/DeveloperArslanAli/Arrow-Escape/main/docs/PRIVACY_POLICY.md`)*

### B. Target Audience and Content
- **Target Age:** Everyone (Pegi 3 / ESRB Everyone).
- **Appeal to Children:** "No" (App appeals to general puzzle enthusiasts of all ages).
- **Families Policy Requirement:** Compliant (zero data collection, zero third-party ads).

### C. App Access & Permissions
- **App Access:** "All functionality is available without special access" (no login, no subscription, no paywalls).
- **Ads:** Select **"No, my app does not contain ads"**.
- **Financial Features:** Select **"No financial features"**.
- **Government Apps:** Select **"No"**.
- **Active Android Permissions in Manifest:**
  - `android.permission.VIBRATE` (Haptic feedback when tapping arrows)
  - `android.permission.INTERNET` is **disabled**.

### D. Testing Track & Testers Configuration (Fix for Warning)
- When publishing to a **Closed Testing** track:
  1. Open **Testing > Closed testing** in Google Play Console.
  2. Select your track and click on the **Testers** tab.
  3. Create an email list of testers (e.g. your own email address) and save.
  4. Copy the **Join on Android** or **Join on the web** opt-in URL.
- When publishing directly to **Production**:
  - No tester list is needed; proceed with standard rollout.

### E. Native Debug Symbols (Fix for Warning)
- Gradle automatically extracts native symbols into the AAB bundle via `debugSymbolLevel = 'SYMBOL_TABLE'`.
- If Google Play shows a yellow advisory notice regarding debug symbols, this is non-blocking and you can safely continue.

---

## 4. Store Listing Metadata & Copywriting

### App Identity
- **App Name:** `Arrow Escape: Puzzle Grid` *(27 / 30 chars)*
- **Short Description:** *(78 / 80 chars)*  
  `Untangle vibrant arrow paths, master shifting grids, and solve 200+ puzzles!`

### Full Description:
```text
Step into Arrow Escape, a beautifully crafted minimalist puzzle game where logic meets flow!

Your objective is simple yet profoundly engaging: clear the board by guiding every arrow off the grid without collisions. Tap an arrow to release it in the direction it points—but make sure its escape path is completely unobstructed!

🌟 GAME FEATURES:

• 200 HANDCRAFTED, MATHEMATICALLY SOLVABLE LEVELS:
Every single level is mathematically generated and rigorously verified with 100% solvability. Experience an escalating challenge from gentle introductory grids to colossal labyrinthine puzzles!

• DYNAMIC EXPANDING GRIDS (4x4 to 20x20):
Watch the puzzle canvas expand as your mastery grows:
- Sky Breeze (Levels 1–25): 4x4 to 6x6 grids — Learn the core mechanics in a crisp azure landscape.
- Sunset Coral (Levels 26–50): 6x6 to 8x8 grids — Navigate warmer, denser intersections.
- Emerald Glade (Levels 51–75): 8x8 to 10x10 grids — Lush jade logic with winding pathways.
- Amethyst Twilight (Levels 76–100): 10x10 to 12x12 grids — Deep purple nightscapes with multi-layered depth.
- Oceanic Abyss (Levels 101–125): 12x12 to 14x14 grids — Intricate arctic depths.
- Golden Dunes (Levels 126–150): 14x14 to 16x16 grids — Vast sandstone mazes.
- Cherry Blossom (Levels 151–175): 16x16 to 18x18 grids — Vibrant crimson challenges.
- Midnight Obsidian (Levels 176–200): 18x18 to 20x20 grids — The ultimate high-density master challenge!

• 100% OFFLINE & PRIVACY-FOCUSED:
No internet required. No tracking, no invasive permissions, and no accounts. Play anywhere, anytime on your own schedule.

• SMOOTH JUICE & HAPTIC SATISFACTION:
Enjoy springy squash-and-stretch tap animations, satisfying spatial swoosh sound effects, gentle tactile vibration feedback, and celebratory confetti upon conquering each stage.

• SLEEK MODERN AESTHETIC:
Designed with curated harmonic palettes, soft drop shadows, and an ultra-clean user interface that feels premium on any screen size.

Download Arrow Escape today and put your spatial reasoning to the test!
```

### Store Category & Tags
- **Category:** Games > Puzzle / Brain Games
- **Tags:** Puzzle, Logic, Brain Teaser, Minimalist, Casual, Offline, Single Player

---

## 5. Store Graphical Assets

| Asset Type | Specifications | File Location |
| :--- | :--- | :--- |
| **High-Res App Icon** | 512 x 512 px, 32-bit PNG, max 1MB | `assets/store/icon_512.png` |
| **Feature Graphic** | 1024 x 500 px, PNG/JPEG, max 15MB | `assets/store/feature_graphic_1024x500.png` |
| **Phone Screenshots** | Min 2 screenshots (1080 x 1920 or 1080 x 2400) | `assets/store/screenshots/` |
| **7-inch / 10-inch Tablet** | Min 1 screenshot each (optional but recommended) | `assets/store/screenshots/` |

---

## 6. Play Console Release Track Submission Step-by-Step

1. **Log in to Google Play Console:** Go to [play.google.com/console](https://play.google.com/console).
2. **Create App:** Click **Create App** > Enter `Arrow Escape: Puzzle Grid` > Default Language: `English (United States)` > App > Free.
3. **Set Up Store Listing:**
   - Paste the Title, Short Description, and Full Description above.
   - Upload `assets/store/icon_512.png` as the App Icon.
   - Upload `assets/store/feature_graphic_1024x500.png` as the Feature Graphic.
   - Upload in-game screenshots.
4. **Complete App Content Policy:**
   - Privacy Policy ➡️ Provide URL to `PRIVACY_POLICY.md`.
   - Ads ➡️ "No ads".
   - App Access ➡️ "All features available".
   - Data Safety ➡️ "No data collected or shared".
   - Content Rating ➡️ Complete questionnaire (results in PEGI 3 / Everyone).
5. **Create Production Release:**
   - Under **Release** > **Production**, click **Create New Release**.
   - Enable **Google Play App Signing**.
   - Upload `build/ArrowEscape.aab`.
   - Release Name: `1.0.0 (1)`.
   - Release Notes: `Initial public release featuring 200 solvable levels across 8 unique worlds.`
   - Review and Start Rollout to Production!
