# OneDrive / Microsoft OAuth — public-use effort

## Summary

Configuring Microsoft identity + Graph for a **public Android (optionally iOS) client** that only needs **read-only OneDrive** is mechanically similar to Google Drive OAuth: one Entra app registration, Android package name + signing **signature hash** (Google’s SHA-1 analogue), and delegated scopes. There is **no** Google-style “sensitive scope verification / brand review” gate before arbitrary **personal Microsoft account (MSA)** users can consent to `Files.Read`. Consumer MSA users can grant scopes for themselves; `Files.Read` does not require admin consent by default.

**Verdict vs Google (TinyTunes-style official GitHub APK for any end user):** for **personal OneDrive (outlook.com / live.com)** public use, Microsoft is **slightly easier** overall — no Testing→Production publishing status, no sensitive-scope review queue, no separate Web `serverClientId`, and no separate “enable Drive API” product switch. Pain that **remains similar**: package + signing-hash binding (debug vs release), forks bringing their own client IDs, and consent UX friction (“Unverified” until publisher verification). Supporting **work/school OneDrive in other tenants** without **publisher verification** is a distinct, harder problem (risk-based step-up → admin approval) and is **harder than** Google’s unverified-app warning for consumer Drive if org accounts matter.

**TinyTunes decision (post Phase 1 device spike):** do **not** request
`offline_access` explicitly for personal MSA — the token endpoint may decline
it and `msal_auth` fails the whole acquire. Request `Files.Read` + `User.Read` +
`openid` / `profile` only. MSAL still caches tokens for silent renew after a
successful grant. Locked in ADR 0003 / `OneDriveOAuthConfig.graphScopes`.

---

## Setup checklist (maintainer)

### 1. Prerequisites

- An Azure / Microsoft Entra tenant (free Azure account is enough to start). ([Register an app](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app))
- Role at least **Application Developer** (or higher) in that tenant. ([Same](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app))

### 2. App registration (public mobile client)

1. **Entra ID → App registrations → New registration.**
2. **Supported account types** (pick based on audience):
   - **Personal accounts only** → `PersonalMicrosoftAccount` / consumers endpoint.
   - **Any Entra tenant + personal Microsoft accounts** → `AzureADandPersonalMicrosoftAccount` / `common` (widest; covers outlook.com **and** work/school). ([Register](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app), [modify supported accounts](https://learn.microsoft.com/en-us/entra/identity-platform/howto-modify-supported-accounts), [supported-accounts validation](https://learn.microsoft.com/en-us/entra/identity-platform/supported-accounts-validation))
3. Record **Application (client) ID**.
4. Treat the app as a **public client** (mobile/desktop): **do not** create client secrets/certificates for the mobile app. Public clients cannot safely hold secrets. ([Public vs confidential](https://learn.microsoft.com/en-us/entra/identity-platform/msal-client-applications))
5. Optionally enable **Allow public client flows** if using flows that require it (e.g. some native/device flows); Android/iOS auth-code + redirect URI is the normal mobile path. ([Mobile app configuration](https://learn.microsoft.com/en-us/entra/identity-platform/scenario-mobile-app-configuration))

### 3. Platform redirect URIs

| Platform | What to register | Redirect URI shape |
| --- | --- | --- |
| **Android** | Package name + **Signature hash** (base64 of SHA-1 of signing cert) | `msauth://<PACKAGE_NAME>/<URL_ENCODED_SIGNATURE_HASH>` |
| **iOS / macOS** | Bundle ID | Generated; typically `msauth.<BUNDLE_ID>://auth` |

Sources: [Add redirect URI](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-redirect-uri), [MSAL Android](https://learn.microsoft.com/en-us/entra/msal/android/), [Mobile app configuration](https://learn.microsoft.com/en-us/entra/identity-platform/scenario-mobile-app-configuration).

**Yes — package name + signing hash is required for Android**, analogous to Google’s package name + SHA-1 OAuth client. Debug and release (or Play App Signing) certs produce **different** hashes; Microsoft docs recommend **adding another Android platform / redirect URI** rather than overwriting the debug one. ([Play signing hash troubleshooting](https://learn.microsoft.com/en-us/troubleshoot/entra/entra-id/app-integration/android-app-authentication-fails-after-published-to-google-play-store))

Also wire the Android **intent filter** / MSAL config so the hash encoding matches (manifest: base64; MSAL `redirect_uri`: URL-encoded base64). ([MSAL Android FAQ](https://learn.microsoft.com/en-us/entra/msal/android/frequently-asked-questions))

### 4. API permissions / scopes (read-only OneDrive)

Add **Microsoft Graph → Delegated**:

| Scope | Role for TinyTunes |
| --- | --- |
| `Files.Read` | **Minimum** for list/download of the signed-in user’s own files (e.g. `GET /me/drive/...`). Admin consent required: **No**. Available for personal MSA. |
| `Files.Read.All` | Broader “all files the user can access” (shared / org). **Not required** for own-drive read-only. Admin consent required: **No** (delegated). |
| `openid` / `profile` / `User.Read` | Typical sign-in / identity (often included automatically). |
| `offline_access` | Refresh tokens for native apps (critical for background/silent renew). |

Sources: [OneDrive permissions reference](https://learn.microsoft.com/en-us/onedrive/developer/rest-api/concepts/permissions_reference?view=odsp-graph-online), [Graph permissions reference — Files.Read](https://learn.microsoft.com/en-us/graph/permissions-reference), [Consent types / offline_access](https://learn.microsoft.com/en-us/entra/identity-platform/consent-types-developer).

**Personal vs work/school for scopes:** `Files.Read` / `Files.Read.All` (delegated) are valid for both. For personal accounts, docs note `Files.Read` also covers files shared with the user. ([OneDrive permissions remarks](https://learn.microsoft.com/en-us/onedrive/developer/rest-api/concepts/permissions_reference?view=odsp-graph-online))

**Admin consent for personal MSA:** Not required for these delegated Files scopes. Consumer MSA users **can always grant scopes for themselves**. Organizational users may be blocked by **tenant consent policy**. ([Delegated access primer](https://learn.microsoft.com/en-us/entra/identity-platform/delegated-access-primer))

There is **no** separate “enable OneDrive API” product toggle like GCP’s Drive API enablement; you request Graph permissions on the app registration.

### 5. Auth flow (runtime)

- Use **authorization code + PKCE** for mobile/desktop public clients; **never** redeem codes with a client secret. ([Auth code flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow))
- Prefer MSAL (or equivalent) token cache + silent acquire; refresh is handled via refresh tokens when `offline_access` was granted. ([Acquire/cache tokens](https://learn.microsoft.com/en-us/entra/msal/msal-acquire-cache-tokens))

### 6. Branding / trust (recommended for public multi-tenant)

- Add **privacy statement** and **terms of service** URLs on the app. Missing links show an **alert** on the multi-tenant consent UI (may discourage consent; not documented as a hard block). ([ToS / privacy](https://learn.microsoft.com/en-us/entra/identity-platform/howto-add-terms-of-service-privacy-statement))
- Optional: **Publisher verification** (blue verified badge) — see below.

### 7. Distribution without stores

OAuth binding is **client ID + redirect URI (package/bundle + signature hash)**, not store listing. Sideloaded / GitHub APKs work if the APK is signed with a certificate whose signature hash is registered. No Microsoft Store or Play Store requirement appears in identity-platform mobile registration docs. (Play App Signing only matters if you *do* use Play and Microsoft’s signing hash must match the cert that actually signs the installed APK.) ([Android redirect URI](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-redirect-uri), [Play signing note](https://learn.microsoft.com/en-us/troubleshoot/entra/entra-id/app-integration/android-app-authentication-fails-after-published-to-google-play-store))

---

## Comparison to Google Drive OAuth (TinyTunes)

| Step / pain | Google Drive (`drive.readonly`) | Microsoft Graph OneDrive (`Files.Read`) |
| --- | --- | --- |
| Cloud project | GCP project | Entra app registration in a tenant |
| Enable API product | Enable **Google Drive API** | Add Graph **delegated** permission (no separate OneDrive “product enable”) |
| Consent / audience mode | OAuth consent screen **External**; **Testing** vs **In production** | Supported account types (`Personal…` / `AzureADandPersonal…`); **no** Testing-mode user cap in docs |
| Android client binding | Package name + **SHA-1** (often separate debug/release OAuth clients) | Package name + **signature hash** (add multiple Android platform entries) |
| Extra client IDs | Web client as `serverClientId` for `google_sign_in` 7.x | Typically **one** public client ID; no Web-secret pattern for mobile |
| Client secrets | Not for Android public client; Web client exists for ID token audience | **None** for public mobile client |
| Minimum scope | `drive.readonly` (sensitive) | `Files.Read` (+ `offline_access` for refresh) |
| Public end-user gate | Sensitive scope **verification** + often brand verification; “unverified app” until review | **No** Files.Read “scope verification” review for MSA; consent shows **“Unverified”** until **publisher verification** |
| Org / work accounts | Workspace admin policies may block | Risk-based step-up / tenant consent can force **admin approval** for unverified multi-tenant apps |
| Privacy / ToS | Required for verification / production consent screen | Strongly recommended for multi-tenant; missing → consent **alert** |
| Forks | Own GCP OAuth clients | Own Entra app registration + hashes |
| Sideload / GitHub APK | OK if SHA matches registered client | OK if signature hash matches registered redirect URI |

---

## Public verification & consent friction

### Is there a Google “sensitive scope verification” equivalent?

**Not for `Files.Read` as a scope-review program.** Microsoft’s public trust program for multi-tenant OAuth apps is **publisher verification** (verify the *publisher organization* via Microsoft AI Cloud Partner Program / former MPN, associate Partner ID, set publisher domain). It is **not** a permission-by-permission content review like Google’s sensitive scopes. ([Publisher verification overview](https://learn.microsoft.com/en-us/entra/identity-platform/publisher-verification-overview), [Mark app verified](https://learn.microsoft.com/en-us/entra/identity-platform/mark-app-as-publisher-verified))

Without verification, the consent UI shows **“Unverified”** instead of a publisher name. ([Consent experience](https://learn.microsoft.com/en-us/entra/identity-platform/application-consent-experience))

### What happens for unverified apps requesting `Files.Read`?

**Personal Microsoft accounts (MSA):**

- Users can grant delegated scopes for themselves. ([Delegated access primer](https://learn.microsoft.com/en-us/entra/identity-platform/delegated-access-primer))
- They still see the normal consent prompt, including **Unverified** if not publisher-verified. ([Consent experience](https://learn.microsoft.com/en-us/entra/identity-platform/application-consent-experience))
- Missing privacy/ToS links add a consent **alert** for multi-tenant apps. ([ToS / privacy](https://learn.microsoft.com/en-us/entra/identity-platform/howto-add-terms-of-service-privacy-statement))

**Work/school accounts in *other* Entra tenants (multi-tenant):**

- Since Nov 2020, with **risk-based step-up consent** (default), users often **cannot** consent to newly registered **unverified** multitenant apps that request permissions beyond basic sign-in/profile; the request is treated as risky and stepped up to **admin consent**. Applies to apps registered after **2020-11-08** requesting consent outside the home tenant. ([Publisher verification note](https://learn.microsoft.com/en-us/entra/identity-platform/publisher-verification-overview), [Risk-based step-up consent](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-risk-based-step-up-consent))
- Tenant admins can further restrict user consent. ([Consent types](https://learn.microsoft.com/en-us/entra/identity-platform/consent-types-developer))

**Uncertainty:** Official docs describe step-up primarily in the **organizational tenant / multitenant** framing. They do **not** state that MSA consumers are blocked by the same step-up policy. Combined with “consumers can always grant scopes for themselves,” the practical public path for **personal OneDrive** appears open without publisher verification — but expect **Unverified** UX. Treat any claim that MSA is *hard-blocked* without verification as **unverified against primary docs**.

### Publisher verification cost / timeline / requirements

- Microsoft documents **no charge** for publisher verification itself; partners who already meet prerequisites can complete in **minutes**. ([Publisher verification overview](https://learn.microsoft.com/en-us/entra/identity-platform/publisher-verification-overview))
- Hard requirements include: verified **Partner Program** account (PGA), app registered with a **work/school** account (**MSA-registered apps cannot be publisher verified**), publisher domain (not `*.onmicrosoft.com`), domain alignment with Partner Center verification email, MFA, admin roles in Entra + Partner Center. ([Same](https://learn.microsoft.com/en-us/entra/identity-platform/publisher-verification-overview))
- Partner Program / business identity setup can dominate calendar time for indie / personal projects — **uncertainty:** Partner Center verification duration is outside identity-platform docs; expect organization/legal friction, not a Graph scope review queue.

### Privacy policy

- Multi-tenant / Microsoft-account apps **should** provide ToS + privacy URLs; without them the consent UI shows an alert. Not framed as Google’s “verification blocker,” but still required for a polished public consent experience. ([ToS / privacy](https://learn.microsoft.com/en-us/entra/identity-platform/howto-add-terms-of-service-privacy-statement))

---

## Testing vs production

| Google | Microsoft |
| --- | --- |
| Consent screen **Testing**: only listed test users (cap), then **In production** | **No documented equivalent** of a Testing publishing status with a user whitelist/cap |
| Unverified sensitive scopes warn / limit until review | MSA: consent works for any personal account once account types allow it; org tenants: consent policy / step-up |

Going from “only the developer” to “any MSA user with the APK”:

1. Register with **Personal Microsoft accounts** or **Entra + personal**.
2. Add Android (and optionally iOS) redirect URIs for the **release** signing hash used by the distributed APK.
3. Request `Files.Read` (+ `offline_access`) at runtime / in API permissions.
4. Ship APK — any matching Microsoft account can attempt sign-in; MSA users consent themselves.

Restricting to “test users only” is **not** a first-class identity-platform publishing mode; you’d approximate with single-tenant + invite guests, or simply not distributing the client ID — **not** the same as Google Testing mode.

---

## Ongoing hassle

| Topic | Expectation |
| --- | --- |
| **Token refresh** | Public client + `offline_access`; MSAL (or equivalent) caches refresh tokens and renews silently. No client secret rotation. ([Auth code](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow), [MSAL acquire](https://learn.microsoft.com/en-us/entra/msal/msal-acquire-cache-tokens)) |
| **Client secrets** | Should be **none** for the mobile public client. ([Public clients](https://learn.microsoft.com/en-us/entra/identity-platform/msal-client-applications)) |
| **Signing key / cert rotation** | New signature hash → new Android redirect URI (keep old hashes if old builds still circulate). Same class of ops as Google SHA-1 updates. ([Play signing guide](https://learn.microsoft.com/en-us/troubleshoot/entra/entra-id/app-integration/android-app-authentication-fails-after-published-to-google-play-store)) |
| **Debug vs release** | Multiple Android platform entries / redirect URIs. |
| **iOS** | Bundle ID platform entry; less hash churn than Android unless App ID / team changes. |
| **Forks** | Each fork needs its own app registration (client ID) and its own package/signing hashes if package name differs. |
| **Publisher verification maintenance** | Domain / Partner ID association if you pursue the badge. |

---

## Gotchas

1. **Android signature hash = Google SHA-1 pain class.** Debug ≠ release ≠ Play App Signing. Wrong hash → auth redirect fails. GitHub APK maintainers control the upload key; still must register that key’s hash.
2. **Personal MSA vs work/school are different consent worlds.** MSA public use of `Files.Read` is comparatively open. Org tenants often block unverified multi-tenant apps via **risk-based step-up** unless an admin consents or you complete **publisher verification**.
3. **Publisher verification is organizational, not a Files API review** — and **impossible** for apps registered only under a personal Microsoft account. Indie maintainers targeting only MSA may skip it and live with **“Unverified”**; targeting enterprise OneDrive without verification will frustrate non-admin users.
4. **No Google Testing mode.** Misconfiguration ships to whoever installs the APK and can reach the login endpoint — use account-type settings and least privilege carefully.
5. **No `serverClientId` / Web client dance** (simpler than current Google Sign-In 7.x setup) — but Flutter/MSAL wiring and Android intent filters are still non-trivial engineering (out of scope here; identity *config* effort is what’s compared).
6. **Privacy/ToS missing → consent alert** for multi-tenant apps; add GitHub Pages (or similar) URLs early.
7. **`Files.Read` vs `Files.Read.All`:** prefer `Files.Read` for own-drive list/download; `.All` is for broader “everything the user can access” and is unnecessary for a simple personal library sync.
8. **Account-type choice locks validation rules** (e.g. stricter identifier URI limits when personal accounts are included). ([Supported accounts validation](https://learn.microsoft.com/en-us/entra/identity-platform/supported-accounts-validation))

---

## Bottom-line verdict

For TinyTunes’ stated goal — **official sideloaded APK, any end user signs into personal OneDrive read-only** — Microsoft OAuth is **slightly easier than Google Drive’s public path**: similar Android package/hash setup, but **no sensitive-scope verification wait**, **no Testing→Production gate**, and **no extra Web client ID**. Biggest residual costs are **signature-hash hygiene**, **consent “Unverified” / privacy URLs**, and **forks’ own registrations**. If the product must also work smoothly for **arbitrary work/school OneDrive without tenant-admin help**, budget **publisher verification (Partner Program + domain + Entra work registration)** — that path can become **harder than Google’s consumer Drive verification** for a solo maintainer.

---

## Sources

1. https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app  
2. https://learn.microsoft.com/en-us/entra/identity-platform/howto-modify-supported-accounts  
3. https://learn.microsoft.com/en-us/entra/identity-platform/supported-accounts-validation  
4. https://learn.microsoft.com/en-us/entra/identity-platform/msal-client-applications  
5. https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-redirect-uri  
6. https://learn.microsoft.com/en-us/entra/identity-platform/scenario-mobile-app-configuration  
7. https://learn.microsoft.com/en-us/entra/msal/android/  
8. https://learn.microsoft.com/en-us/entra/msal/android/frequently-asked-questions  
9. https://learn.microsoft.com/en-us/entra/msal/android/msal-configuration  
10. https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow  
11. https://learn.microsoft.com/en-us/entra/msal/msal-acquire-cache-tokens  
12. https://learn.microsoft.com/en-us/onedrive/developer/rest-api/concepts/permissions_reference?view=odsp-graph-online  
13. https://learn.microsoft.com/en-us/graph/permissions-reference  
14. https://learn.microsoft.com/en-us/graph/permissions-overview  
15. https://learn.microsoft.com/en-us/entra/identity-platform/delegated-access-primer  
16. https://learn.microsoft.com/en-us/entra/identity-platform/consent-types-developer  
17. https://learn.microsoft.com/en-us/entra/identity-platform/application-consent-experience  
18. https://learn.microsoft.com/en-us/entra/identity-platform/publisher-verification-overview  
19. https://learn.microsoft.com/en-us/entra/identity-platform/mark-app-as-publisher-verified  
20. https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-risk-based-step-up-consent  
21. https://learn.microsoft.com/en-us/entra/identity-platform/howto-add-terms-of-service-privacy-statement  
22. https://learn.microsoft.com/en-us/troubleshoot/entra/entra-id/app-integration/android-app-authentication-fails-after-published-to-google-play-store  

---
*Research date: 2026-08-08. Primary sources: Microsoft Learn / identity platform / Graph / OneDrive docs only.*
