# Privacy Policy — TinyTunes

**Effective date:** 6 August 2026  
**Last updated:** 8 August 2026  
**Language:** English (authoritative for international disclosure). A German version is provided in [`privacy-policy.de.md`](privacy-policy.de.md).  
**Live HTML:** https://blumenlaube.at/apps/tinytunes/privacy-policy.html

**Controller:** Mario Angerer · privacy@blumenlaube.at

---

## 1. Who we are (controller)

**TinyTunes** (“the App”) is a mobile audio player for Android (and planned for iOS).

**Controller** (responsible for personal data processed *in connection with the App* as described here):

| Field | Value |
| --- | --- |
| Legal name | Mario Angerer |
| Contact email | [privacy@blumenlaube.at](mailto:privacy@blumenlaube.at) |
| App package (Android) | `at.blumenlaube.tinytunes` |

If you have questions about this policy or your personal data, contact us at the email above.

---

## 2. Scope

This policy explains how TinyTunes processes personal data when you install and use the App.

TinyTunes is designed as a **local-first** app: your music library index, play queue, settings, and (optional) cloud cache live **on your device**. The App does **not** operate its own backend server that receives your library or listening history.

Third parties you choose to connect (notably **Google** for Drive and **Microsoft** for personal OneDrive) process data under **their own** terms and privacy policies when you sign in or access cloud files. Section 6 summarizes those relationships.

---

## 3. What data we process

### 3.1 Data stored only on your device

Depending on how you use the App, the following may be stored in the App’s private storage on your device (for example via the local database and preferences):

| Category | Examples | Purpose |
| --- | --- | --- |
| Library / catalog | Folder roots you add, file/display names, opaque locators (local content URIs, `gdrive:<fileId>`, or OneDrive drive/item locators), optional audio tags (title, artist, album) | Index music and show it in the queue |
| Queue / playback state | Ordered playlist entries, now-playing related state | Play and navigate your queue |
| Settings | Theme preference, cloud cache size limit | Remember your choices |
| Session messages | Short in-app status/error messages | Show recent feedback in the message center |
| Cloud cache (optional) | Downloaded audio files and cache index metadata (size, last access) | Play cloud tracks offline-capable after download |

The App may read **audio metadata and embedded artwork** from files you open (local or cached) to display titles and related information. That metadata stays on the device unless you separately share it outside the App.

### 3.2 Google account data (only if you sign in)

If you use **Sign in with Google** for Drive:

- The App receives your Google **account email** (and may receive a **display name**) via Google Sign-In and can show the email in Settings.
- The App obtains **OAuth access tokens** scoped to **read-only** Google Drive access (`https://www.googleapis.com/auth/drive.readonly`) so it can list folders/files you browse and download audio you choose to play.
- The App does **not** receive or store your Google password.

### 3.3 Microsoft account data (only if you sign in to OneDrive)

If you use **Sign in with Microsoft** for personal OneDrive:

- The App receives your Microsoft account **email** (and may receive a **display name**) and can show the email in Settings.
- The App obtains **OAuth access tokens** scoped to **read-only** Microsoft Graph file access (`Files.Read`, plus identity / offline scopes needed for sign-in and silent refresh) so it can list folders/files in your own OneDrive and download audio you choose to play.
- The App does **not** receive or store your Microsoft password.
- Work/school / organizational OneDrive tenants are **out of scope** for the current product; the App is configured for **personal Microsoft accounts** only.

### 3.4 Data we do not collect (current App)

As of the effective date, TinyTunes does **not**:

- Run its own analytics, advertising, or marketing trackers
- Sell personal data
- Operate a TinyTunes cloud account or sync your catalog to a TinyTunes server
- Upload, modify, rename, or delete files on Google Drive or OneDrive (cloud access is **read-only**)
- Require an account with us to play **local** device music

If that changes in a future version, this policy will be updated.

---

## 4. Purposes and legal bases (GDPR)

We process personal data only as needed to provide the App you choose to use:

| Purpose | Typical data | Legal basis (GDPR) |
| --- | --- | --- |
| Provide local playback, catalog, and queue | On-device library and queue data | Art. 6(1)(b) — performance of the contract / service you request by using the App |
| Remember settings (theme, cache budget) | Preferences on device | Art. 6(1)(b); where required locally, Art. 6(1)(f) legitimate interest in a functioning UI — overridden by your control of settings and uninstall |
| Optional Google Drive library (sign-in, list, download-to-cache, play) | Google email/name display, tokens, Drive file metadata and file bytes you trigger for playback | Art. 6(1)(a) — **consent**, given when you sign in and grant Drive access (and withdrawable by signing out / revoking access in Google Account settings) |
| Optional personal OneDrive library (sign-in, list, download-to-cache, play) | Microsoft email/name display, tokens, OneDrive file metadata and file bytes you trigger for playback | Art. 6(1)(a) — **consent**, given when you sign in and grant Files.Read (and withdrawable by signing out / revoking access in your Microsoft account) |
| Answer privacy requests you send us | Whatever you include in email | Art. 6(1)(c) legal obligation and/or Art. 6(1)(f) / (b) as applicable |

You can refuse Google and/or Microsoft sign-in and still use local folders. Each cloud provider’s features simply will not be available until you consent to that provider.

---

## 5. How long we keep data

| Data | Retention |
| --- | --- |
| On-device catalog, queue, settings, messages, cloud cache | Until you delete it in the App (for example Forget folder, Clear cloud cache, Sign out for that provider’s cache wipe) or uninstall the App / clear App storage |
| Google tokens / session | Until you sign out in the App or revoke access in your Google Account; Sign out also wipes that provider’s local cloud **cache** |
| Microsoft tokens / session | Until you sign out in the App or revoke access in your Microsoft account; Sign out also wipes that provider’s local cloud **cache** |
| Emails you send to our contact email | Only as long as needed to handle your request and meet legal record-keeping duties |

We do not run a TinyTunes server-side archive of your library.

---

## 6. Recipients and processors (Google / Microsoft)

### 6.1 No TinyTunes cloud recipients

We do not transmit your library or listening history to a TinyTunes-operated server.

### 6.2 Google

If you enable Google Drive features, **Google Ireland Limited** and/or other Google entities process your Google Account and Drive data as described in Google’s documentation and policies, including:

- [Google Privacy Policy](https://policies.google.com/privacy)
- [Google APIs Terms of Service](https://developers.google.com/terms)
- Google Drive / Sign-In product terms applicable to your account

TinyTunes uses Google Sign-In and the Google Drive API solely to:

1. Authenticate you  
2. List Drive folders/files (audio and folders relevant to browsing)  
3. Download selected audio into the App’s **local** cache for playback  

TinyTunes does **not** use Drive data for advertising and does not grant the App write access to your Drive.

Google may process data in locations outside the EEA under Google’s own transfer mechanisms (for example Standard Contractual Clauses). See Google’s privacy documentation for details.

### 6.3 Microsoft

If you enable personal OneDrive features, **Microsoft** entities process your Microsoft account and OneDrive data as described in Microsoft’s documentation and policies, including:

- [Microsoft Privacy Statement](https://privacy.microsoft.com/privacystatement)
- Microsoft identity platform / Microsoft Graph terms applicable to your account

TinyTunes uses Microsoft sign-in (MSAL) and Microsoft Graph solely to:

1. Authenticate you with a **personal** Microsoft account  
2. List folders/files in your own OneDrive (audio and folders relevant to browsing)  
3. Download selected audio into the App’s **local** cache for playback  

TinyTunes does **not** use OneDrive data for advertising and does not grant the App write access to your OneDrive.

Microsoft may process data in locations outside the EEA under Microsoft’s own transfer mechanisms. See Microsoft’s privacy documentation for details.

### 6.4 Device / OS vendors

Your device manufacturer and OS (for example Google Android / Play Services) may process data under their own policies when you install the App, use system folder pickers, or use platform sign-in components.

---

## 7. International transfers

On-device data stays on your device unless you choose a feature that contacts Google (Sign-In / Drive) or Microsoft (sign-in / Graph / OneDrive). Those transfers are governed by Google’s or Microsoft’s terms and transfer tools. We do not operate additional TinyTunes international transfers of your library.

---

## 8. Security

We aim to limit data exposure by design:

- Local-first storage for catalog and queue  
- Read-only cloud scopes (`drive.readonly` / `Files.Read`)  
- No TinyTunes backend holding your music index  
- No client secrets shipped in the mobile APK  

No method of electronic storage is perfectly secure. Protect your device with a screen lock and keep the OS updated. Anyone with unlock access to your device may access App data stored on it.

---

## 9. Your rights (EEA / UK and similar)

Where the GDPR (or UK GDPR) applies, you have the right to:

- **Access** your personal data  
- **Rectification** of inaccurate data  
- **Erasure** (“right to be forgotten”) where applicable  
- **Restriction** of processing  
- **Data portability** where applicable  
- **Object** to processing based on legitimate interests  
- **Withdraw consent** at any time (for Google Drive / OneDrive features) without affecting the lawfulness of processing before withdrawal  

**Practical exercise in the App:**

- Remove local library data: Forget folder / clear queue as offered in the UI  
- Remove cloud cache: Clear cloud cache or Sign out for that provider  
- Disconnect Google: Sign out in Settings; optionally revoke TinyTunes in your [Google Account third-party connections](https://myaccount.google.com/permissions)  
- Disconnect Microsoft: Sign out in Settings; optionally revoke TinyTunes in your Microsoft account privacy / app permissions  

For requests that need our help (for example confirmation what we hold as controller), email [privacy@blumenlaube.at](mailto:privacy@blumenlaube.at). We will respond within the statutory period (generally one month).

You also have the right to lodge a complaint with a supervisory authority, in particular in your EU/EEA member state of residence. In Austria, for example, that is the **Österreichische Datenschutzbehörde** ([dsb.gv.at](https://www.dsb.gv.at/)).

---

## 10. Children

The App is not directed at children. We do not knowingly offer Google Drive or OneDrive sign-in aimed at users under the digital consent age applicable in their country (often 16 in the EU, sometimes lower). If you believe a child provided personal data via the App contrary to this policy, contact us and we will help delete on-device guidance and revoke access as appropriate.

---

## 11. No automated decision-making

TinyTunes does not use your personal data for automated decision-making or profiling that produces legal or similarly significant effects (GDPR Art. 22).

---

## 12. Changes to this policy

We may update this policy when the App’s features or legal requirements change. The “Last updated” date at the top will change accordingly. Material changes affecting cloud OAuth use should be reflected before you rely on a new scope or new sharing of data.

The current version lives in the TinyTunes repository under `docs/legal/` and, once published, at the public HTTPS URL used on Google and Microsoft OAuth consent screens.

---

## 13. Hosted URL (for OAuth / store listings)

Google and Microsoft consent / branding flows need a **publicly accessible HTTPS** privacy policy URL. Hosting only inside the git repo is not enough.

Recommended: publish this file (or an HTML export) via GitHub Pages, your own domain, or another stable HTTPS host, then put that URL in:

1. Google Cloud Console → OAuth consent screen → Privacy policy  
2. Microsoft Entra app registration branding → Privacy statement URL  
3. Play Console / store listing (when applicable)  
4. In-app Settings link (see [`README.md`](README.md) in this folder)

**Publish note (Phase 0):** the in-repo drafts now describe optional personal OneDrive. Update the live HTML at blumenlaube.at to match before relying on that URL for Microsoft consent branding.

---

*This document is provided to describe TinyTunes’ intended data practices. It is not legal advice. Have it reviewed for your jurisdiction if needed.*
