# Microsoft brand assets (TinyTunes)

Official marks for OneDrive account UI and the library source picker.
Do **not** redraw, recolor, stretch, tint, or regenerate these assets.

## Inventory

| File | Use | Source |
| --- | --- | --- |
| [`assets/branding/onedrive_icon.png`](../../assets/branding/onedrive_icon.png) | OneDrive product mark (picker / Settings tile) | Microsoft Fabric / Office CDN brand-icons (`onedrive_96x1.png`) |
| [`assets/branding/microsoft_symbol.png`](../../assets/branding/microsoft_symbol.png) | Microsoft 2×2 symbol for composed “Sign in with Microsoft” (localized label) | [Sign in with Microsoft branding guidelines](https://learn.microsoft.com/en-us/entra/identity-platform/howto-add-branding-in-apps) (`ms-symbollockup_mssymbol_19.png`) |
| [`assets/branding/microsoft_symbol.svg`](../../assets/branding/microsoft_symbol.svg) | Same symbol, vector source | Same Learn doc (`ms-symbollockup_mssymbol_19.svg`) |
| [`assets/branding/ms_signin_light.png`](../../assets/branding/ms_signin_light.png) | English pre-rendered light “Sign in with Microsoft” button (reference / fallback) | Same Learn doc |
| [`assets/branding/ms_signin_dark.png`](../../assets/branding/ms_signin_dark.png) | English pre-rendered dark button (reference / fallback) | Same Learn doc |

## Usage rules

- Prefer **composed** CTA: Microsoft symbol + localized “Sign in with Microsoft”
  text (mirrors `SignInWithGoogleButton`), so DE/EN l10n stay accurate.
- Keep official colors; no Material tint overlays on the marks.
- OneDrive product icon is for **in-app identity** (source picker / Settings),
  not marketing decoration.
- Do not use Azure / Active Directory wording in end-user UI.

## License / trademark notes

- Sign-in button artwork and Microsoft logo usage follow Microsoft identity
  platform branding guidelines (linked above).
- OneDrive product icon is a Microsoft trademark asset obtained from the
  Office Fabric brand-icons CDN for representing the OneDrive provider in-app.
- TinyTunes does not claim ownership of these marks.

## Re-download commands

```powershell
$learn = "https://learn.microsoft.com/en-us/entra/identity-platform/media/howto-add-branding-in-apps"
Invoke-WebRequest "$learn/ms-symbollockup_mssymbol_19.png" -OutFile assets/branding/microsoft_symbol.png
Invoke-WebRequest "$learn/ms-symbollockup_mssymbol_19.svg" -OutFile assets/branding/microsoft_symbol.svg
Invoke-WebRequest "$learn/ms-symbollockup_signin_light.png" -OutFile assets/branding/ms_signin_light.png
Invoke-WebRequest "$learn/ms-symbollockup_signin_dark.png" -OutFile assets/branding/ms_signin_dark.png

$cdn = "https://res.cdn.office.net/files/fabric-cdn-prod_20240129.001/assets/brand-icons/product/png"
Invoke-WebRequest "$cdn/onedrive_96x1.png" -OutFile assets/branding/onedrive_icon.png
```

Widgets: `lib/shared/widgets/microsoft_sign_in_button.dart`,
`microsoft_brand_assets.dart`, and OneDrive marks in the source picker / Settings.
