# PocketMac

**Access your MacBook's local files and full desktop from your iPhone, iPad, Android/Pixel, or another Mac over cellular data or remote Wi-Fi — while your Mac stays safely plugged into power at home with its lid closed.**

PocketMac keeps your Mac's normal lid-close sleep behavior **100% untouched by default**, and gives you reversible on-demand shell commands (`pocket-on` / `pocket-off`) for when you travel.

---

## How It Works

1. **Reversible Vacation Mode (`pocketmac.zsh`)** — Toggles `pmset -a disablesleep` + `caffeinate -s` only when you explicitly run `pocket-on`, and restores normal sleep immediately with `pocket-off`.
2. **Tailscale (Private Encrypted Mesh VPN)** — Connects your devices over an end-to-end encrypted WireGuard tunnel with zero router port forwarding and no public internet exposure.
3. **Built-in macOS Sharing (SMB + Screen Sharing/VNC)** — Uses native macOS services for both fast file browsing/downloads and full remote desktop control.

---

## Quick Setup (5 Minutes)

### 1. Install the Shell Commands

Clone the repo and run the installer:

```zsh
git clone https://github.com/kalikiranl/PocketMac.git
cd PocketMac
chmod +x install.sh
./install.sh
source ~/.zshrc
```

This installs four commands into your shell (`~/.pocketmac.zsh`, sourced from `~/.zshrc`):

| Command | Description |
| --- | --- |
| `pocket-on` | Enables stay-awake mode (`sudo pmset -a disablesleep 1` + detached `caffeinate -s`) so your Mac stays online with the lid closed while plugged in. |
| `pocket-off` | Stops `caffeinate` and immediately restores normal lid-close sleep (`sudo pmset -a disablesleep 0`). |
| `pocket-status` | Checks `pmset -g \| grep SleepDisabled` and prints whether Vacation Mode is **ON** or **OFF**. |
| `pocket-info` | Displays your Mac's current username, Tailscale IP, MagicDNS hostname, SMB/VNC addresses, and Vacation Mode status. |

Enable Wake for Network Access (optional, recommended):

```zsh
sudo pmset -a womp 1
```

### 2. Install & Connect Tailscale

Install the standalone macOS app via Homebrew and sign in:

```zsh
brew install --cask tailscale-app
open -a Tailscale
```

Sign in with your Tailscale account (Google, Apple, GitHub, etc.), approve the macOS VPN/Network Extension prompt, and run:

```zsh
pocket-info
```

Note your Mac's private Tailscale IP (`100.x.y.z`) and MagicDNS hostname (`<mac-name>.<tailnet>.ts.net`).

> **Tip (Key Expiry):** By default, Tailscale node keys expire every 180 days. For long trips, open your [Tailscale Admin Console](https://login.tailscale.com/admin/machines), click **`•••`** next to your Mac, and select **Disable key expiry**.

### 3. Enable Built-in macOS Sharing

#### File Sharing (SMB — Browse & Download Local Files)
1. Open **System Settings → General → Sharing**.
2. Toggle **File Sharing** **ON**.
3. Click **`(i)`** → confirm your shared folders and user account permissions.
4. Click **Options…** → verify **Share files and folders using SMB** is checked, and check your user account under **Windows File Sharing**.

#### Screen Sharing (VNC — Optional Full Desktop Control)
1. Open **System Settings → General → Sharing**.
2. Toggle **Screen Sharing** **ON**.
3. Click **`(i)` → Computer Settings…**:
   - Check **"VNC viewers may control screen with password"**.
   - Set an **8-character VNC password** *(required for standard mobile VNC clients like RealVNC Viewer; all traffic remains end-to-end encrypted by Tailscale)*.

---

## Vacation Checklists

### Before Leaving Home
- [ ] **Plug your MacBook into AC power.**
- [ ] Run `pocket-on` in Terminal and confirm it prints `PocketMac Vacation Mode ON`.
- [ ] **Close the lid.**
- [ ] Turn Wi-Fi **OFF** on your phone/iPad and do a quick cellular test before leaving.

### When Returning Home
- [ ] Run `pocket-off` in Terminal.
- [ ] Verify normal sleep is restored with `pocket-status` (should report **OFF**).

> **Safety Warning:** Never put your MacBook into a bag or sleeve while `pocket-on` is active (`SleepDisabled=1`), as it will stay awake with the lid shut and could overheat. Always run `pocket-off` first.

---

## Connecting From Your Devices

First, install **Tailscale** on your phone, iPad, or secondary computer, sign in with the **same account**, and toggle Tailscale **ON**.

### iPhone & iPad

- **Files (Built-in Apple Files App):**
  1. Open **Files** → **Browse** → tap **`•••`** (top right) → **Connect to Server**.
  2. Enter `smb://<tailscale-ip>` (or `smb://<magicdns-hostname>`) → **Connect**.
  3. Choose **Registered User**, enter your macOS username and Mac login password → **Next**.
  4. Your Mac stays pinned under **Shared** in the Files sidebar for one-tap access.
- **Full Desktop Control (RealVNC Viewer):**
  1. Install **RealVNC Viewer** *(free on App Store)*.
  2. Add a connection to `<tailscale-ip>` (port `5900`).
  3. In connection settings, set **Encryption** to **Let VNC Server choose** (or **Prefer off** — Tailscale already encrypts the tunnel).
  4. Connect and enter your **VNC password**.
  *(iPad Pro/Air with keyboard + trackpad makes this feel like a full remote Mac! Paid apps like **Jump Desktop** or **Screens 5** also support native macOS Screen Sharing auth.)*

### Google Pixel / Android

- **Files:** Use an SMB-capable file manager (**Solid Explorer**, **CX File Explorer**, or **Material Files**) → add an SMB connection to `<tailscale-ip>`, port `445`, with your macOS username and login password.
- **Full Desktop Control:** Install **RealVNC Viewer** from Google Play → connect to `<tailscale-ip>` with **Encryption** set to **Let VNC Server choose** / **Prefer off** and your **VNC password**.

### Another Mac

- **Files:** Finder → `Cmd + K` → `smb://<tailscale-ip>`
- **Full Desktop:** Finder → `Cmd + K` → `vnc://<tailscale-ip>`

---

## Keeping Personal Notes Local

Save your personal Tailscale IP, MagicDNS hostname, and device list in a local `MY_SETUP.md` file inside this folder — `.gitignore` is pre-configured to exclude `MY_SETUP.md` and `*.local.md` so personal info is never committed to Git.

---

## Troubleshooting

| Issue | Fix |
| --- | --- |
| **Can't reach Mac from phone/iPad** | Verify Tailscale is toggled **ON** on your phone/iPad and your Mac shows a green **Online** indicator in the Tailscale app. |
| **RealVNC says "incompatible protocol version" or "server not running"** | Set RealVNC's **Encryption** to **Let VNC Server choose** (or **Prefer off**), and verify **VNC viewers may control screen with password** is enabled under **System Settings → General → Sharing → Screen Sharing → `(i)` → Computer Settings…**. |
| **Files app rejects SMB login** | Select **Registered User** (not Guest), enter your lowercase macOS username + Mac login password (not the VNC password), and check **Windows File Sharing** under **File Sharing → `(i)` → Options…**. |
| **Unsure if lid-close sleep is restored** | Run `pocket-status` in Terminal — it should print `OFF (SleepDisabled=0)`. |

---

## License

MIT — see [LICENSE](LICENSE).
