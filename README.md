# Financial Sentiment App — Setup Guide

A mobile-style app for tracking stocks, reading financial news metrics, and rating market sentiment. **No server required** — everything runs on your computer or phone.

This guide is written for people with little or no coding experience. Follow the steps in order.

---

## Quick summary

| Step | What you do | Time |
|------|-------------|------|
| 1 | Install Flutter (one-time) | ~15–30 min |
| 2 | Check that everything is installed | ~2 min |
| 3 | Run the app | ~2 min |

**No API keys needed** — the app uses sample data by default so you can try it immediately.

---

## What you need

- A computer running **Windows 10/11**, **macOS**, or **Linux**
- An internet connection (for the first-time Flutter install)
- About **3 GB** of free disk space

You do **not** need:
- A paid OpenAI or news API account (optional later)
- Prior programming experience

---

## Step 1: Install Flutter (one-time)

Flutter is the free toolkit this app is built with. You only install it once.

### Windows

1. **Download Flutter**
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Click **“Download Flutter SDK”** and unzip the folder (e.g. to `C:\flutter`).

2. **Add Flutter to your PATH**
   - Press the Windows key, type **“environment variables”**, and open **Edit the system environment variables**.
   - Click **Environment Variables…**
   - Under **User variables**, select **Path** → **Edit** → **New**
   - Add the path to Flutter’s `bin` folder, e.g. `C:\flutter\bin`
   - Click **OK** on every dialog.

3. **Enable Developer Mode** (required on Windows)
   - Press the Windows key, type **“Developer settings”**, and open it.
   - Turn **Developer Mode** **On**.
   - This lets Flutter build the app correctly.

4. **Install Git** (if you don’t have it)
   - Download from: https://git-scm.com/download/win
   - Run the installer and accept the defaults.

5. **Close and reopen** any open Terminal or Command Prompt windows.

### macOS

1. Go to: https://docs.flutter.dev/get-started/install/macos
2. Follow the **“Get started”** steps to download and unzip the Flutter SDK.
3. Add Flutter to your PATH as described on that page (usually editing `~/.zshrc`).

### Linux

1. Go to: https://docs.flutter.dev/get-started/install/linux
2. Follow the install steps for your distribution.

---

## Step 2: Check your installation

Open a terminal:

- **Windows:** Press `Win + R`, type `cmd`, press Enter  
  *(or search for “Command Prompt” or “Terminal”)*
- **macOS:** Press `Cmd + Space`, type `Terminal`, press Enter

### Easy way — run the check script

**Windows:** Double-click this file in File Explorer:

```
scripts\check_setup.bat
```

**Mac / Linux:** In Terminal, from the project folder:

```bash
bash scripts/check_setup.sh
```

The script will tell you if Flutter is missing and run a health check.

### Manual way

Type these two commands and press Enter after each:

```bash
flutter --version
```

You should see something like `Flutter 3.x.x`. If you get **“flutter is not recognized”**, go back to Step 1 and fix your PATH.

Then run:

```bash
flutter doctor
```

Yellow warnings are often OK. **Red errors** usually need fixing — the output will say what’s missing.

> **Easiest way to run the app:** If `flutter doctor` shows **Chrome** as available, you can run the app in your web browser. No phone emulator required.

---

## Step 3: Run the app

### Option A — Double-click (Windows, easiest)

1. Open this project folder in File Explorer.
2. Double-click:

   ```
   scripts\run_app.bat
   ```

3. Wait for the app to build (first time may take several minutes).
4. The app opens in **Google Chrome** when ready.

### Option B — Terminal commands (all platforms)

1. Open Terminal / Command Prompt.
2. Go to the project folder. Example on Windows:

   ```bash
   cd C:\Users\YourName\Projects\swagr-flutter
   ```

3. Install app dependencies (first time, or after updates):

   ```bash
   flutter pub get
   ```

4. Start the app:

   ```bash
   flutter run -d chrome
   ```

   **Other devices** (if set up):

   ```bash
   flutter run -d windows    # Windows desktop app
   flutter run               # Phone emulator, if installed
   ```

5. To stop the app, press **`q`** in the terminal window.

---

## Using the app

1. On first launch, the app loads a default watchlist (AAPL, MSFT, GOOGL, AMZN, NVDA) and fetches **sample news**.
2. Each card shows one financial metric extracted from a news article.
3. Drag the **slider** from Bearish (-1.0) to Bullish (+1.0) to rate the metric.
4. Tap **Save Rating** to see your **adjusted price target** range.
5. Use the **filter chips** at the top to focus on one stock.
6. Tap **Watchlist** (bottom-right) to add or remove tickers.
7. Tap the **refresh** icon to load more sample articles.

---

## Optional: Use real news and AI

By default the app uses **mock data** so anyone can run it without API keys.

To connect live services, run with API keys (replace the `...` with your real keys):

**Windows (Command Prompt):**

```bash
flutter run -d chrome --dart-define=USE_MOCK_DATA=false --dart-define=OPENAI_API_KEY=sk-... --dart-define=MARKETAUX_API_KEY=...
```

| Key | Where to get it |
|-----|-----------------|
| `OPENAI_API_KEY` | https://platform.openai.com/api-keys |
| `MARKETAUX_API_KEY` | https://www.marketaux.com/ |

---

## Troubleshooting

### “flutter is not recognized” / “command not found”

Flutter is not on your PATH. Repeat **Step 1** and restart your terminal.

### “Building with plugins requires symlink support” (Windows)

Turn on **Developer Mode**: Settings → Privacy & security → For developers → **Developer Mode** → On.  
Then run `scripts\check_setup.bat` again.

### “No supported devices connected”

List available devices:

```bash
flutter devices
```

Then pick one explicitly, e.g.:

```bash
flutter run -d chrome
```

### First build is very slow

Normal. Flutter downloads tools the first time. Later launches are faster.

### App window is blank or errors on refresh

1. Stop the app (`q` in the terminal).
2. Run:

   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

### Still stuck?

1. Run `flutter doctor -v` and read any **red** lines.
2. See Flutter’s official guide: https://docs.flutter.dev/get-started/install
3. Share the full error message when asking for help.

---

## Project scripts

| Script | Purpose |
|--------|---------|
| `scripts/check_setup.bat` | Windows — verify Flutter is installed |
| `scripts/check_setup.sh` | Mac/Linux — verify Flutter is installed |
| `scripts/run_app.bat` | Windows — install deps and launch in Chrome |
| `scripts/run_app.sh` | Mac/Linux — install deps and launch in Chrome |

---

## For developers

<details>
<summary>Architecture, algorithm, and project structure (click to expand)</summary>

### Architecture

```
App Launch → Sembast DB (watchlist, news cache, ratings)
     ↓
News API (Marketaux or mock) → OpenAI structured extraction
     ↓
Metric cards + sentiment slider (-1.0 to 1.0)
     ↓
Target calculator (delta × time decay) → adjusted price range
     ↓
Persist to Sembast → reactive UI (Riverpod)
```

### Algorithm

- `Delta = User_Rating - LLM_Baseline_Sentiment`
- `DecayedDelta = Delta × exp(-ln(2) × days_old / 7)`
- `Adjustment = DecayedDelta × 5%` applied to analyst high/low/median targets

### Key files

| Path | Purpose |
|------|---------|
| `lib/services/database_helper.dart` | Sembast singleton with 3 stores |
| `lib/services/openai_service.dart` | Structured output metric extraction |
| `lib/services/news_service.dart` | Marketaux / mock news |
| `lib/services/price_target_service.dart` | Consensus analyst targets (mock) |
| `lib/services/target_calculator.dart` | Sentiment delta + time decay |
| `lib/providers/app_providers.dart` | Riverpod state management |
| `lib/widgets/metric_card.dart` | Metric display + slider + targets |
| `lib/screens/` | Home and watchlist screens |

### Dependencies

- `sembast` + `path_provider` — local NoSQL storage
- `openai_dart` — OpenAI structured outputs
- `http` — REST news fetching
- `flutter_riverpod` — reactive state

### Tests

```bash
flutter test
```

</details>
