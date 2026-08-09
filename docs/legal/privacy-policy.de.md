# Datenschutzerklärung — TinyTunes

> **Entwurf / Vorlage (kein lebendes Rechtsdokument).**  
> Diese Datei liegt im Git-Repository mit **Platzhaltern**, damit Forks nicht die
> Identität eines anderen Anbieters als Verantwortlichen übernehmen. Ersetzen Sie
> jedes `[PLATZHALTER]`, bevor Sie eine echte Erklärung veröffentlichen (eigene Domain,
> GitHub Pages, Store, OAuth-Zustimmung).  
> Die veröffentlichte HTML-Fassung der offiziellen TinyTunes-Builds ist von diesem Entwurf getrennt.

**Status:** Entwurf / Vorlage  
**Gültig ab:** `[GÜLTIG-AB-DATUM]`  
**Zuletzt aktualisiert:** `[AKTUALISIERT-AM]`  

Die englische Fassung [`privacy-policy.md`](privacy-policy.md) ist die verbindliche Vorlage für internationale Angaben (z. B. Google-/Microsoft-OAuth). Diese deutsche Fassung dient der Verständlichkeit für Nutzerinnen und Nutzer im deutschsprachigen Raum.  
**Öffentliche HTTPS-URL (nach Veröffentlichung):** `[ÖFFENTLICHE-DATENSCHUTZ-URL]`

**Verantwortlicher:** `[NAME DES VERANTWORTLICHEN]` · `[DATENSCHUTZ-KONTAKT-E-MAIL]`

---

## 1. Verantwortlicher

**TinyTunes** („die App“) ist ein mobiler Audio-Player (Android; iOS geplant).

| Feld | Wert |
| --- | --- |
| Name / Firma | `[NAME DES VERANTWORTLICHEN]` |
| E-Mail | `[DATENSCHUTZ-KONTAKT-E-MAIL]` |
| Android-Paketname | `[ANDROID-APPLICATION-ID]` |

---

## 2. Gegenstand

Diese Erklärung beschreibt die Verarbeitung personenbezogener Daten bei Nutzung der App.

TinyTunes ist **lokal ausgerichtet**: Katalog, Warteschlange, Einstellungen und optionaler Cloud-Cache liegen **auf Ihrem Gerät**. Es gibt **keinen** TinyTunes-Server, der Ihre Bibliothek oder Hörhistorie empfängt.

Bei optionaler Anmeldung bei **Google** (Drive) oder **Microsoft** (persönliches OneDrive) gelten zusätzlich deren Bedingungen und Datenschutzhinweise (siehe Abschnitt 6).

---

## 3. Welche Daten werden verarbeitet?

### 3.1 Nur auf dem Gerät

| Kategorie | Beispiele | Zweck |
| --- | --- | --- |
| Bibliothek / Katalog | Ordnerwurzeln, Dateinamen, Locators (`gdrive:…` / OneDrive), optionale Tags (Titel, Interpret, Album) | Indexierung und Anzeige |
| Warteschlange / Wiedergabe | Reihenfolge, aktueller Titel | Steuerung der Wiedergabe |
| Einstellungen | Theme, Cache-Limit | Speichern Ihrer Wahl |
| Sitzungsnachrichten | Kurze Status-/Fehlermeldungen | Nachrichtenübersicht |
| Cloud-Cache (optional) | Heruntergeladene Audiodateien und Cache-Metadaten | Wiedergabe von Cloud-Titeln |

### 3.2 Google-Konto (nur bei Anmeldung)

- E-Mail-Adresse (und ggf. Anzeigename) über Google Sign-In; Anzeige in den Einstellungen möglich  
- OAuth-Zugriffstoken mit Umfang **nur Lesen** für Google Drive (`drive.readonly`)  
- **Kein** Speichern Ihres Google-Passworts in der App  

### 3.3 Microsoft-Konto (nur bei OneDrive-Anmeldung)

- E-Mail-Adresse (und ggf. Anzeigename); Anzeige in den Einstellungen möglich  
- OAuth-Zugriffstoken mit Umfang **nur Lesen** für Microsoft Graph / OneDrive (`Files.Read`, zuzüglich Identitäts-/Offline-Scopes für Anmeldung und stille Erneuerung)  
- **Kein** Speichern Ihres Microsoft-Passworts in der App  
- Nur **persönliche** Microsoft-Konten; Firmen-/Schul-Tenants sind derzeit nicht vorgesehen  

### 3.4 Was wir derzeit nicht tun

Keine eigenen Analytics-/Werbe-Tracker; kein Verkauf von Daten; kein TinyTunes-Cloud-Konto; **kein** Schreiben/Löschen/Umbenennen auf Google Drive oder OneDrive; lokale Musik ohne Cloud-Konto nutzbar.

---

## 4. Zwecke und Rechtsgrundlagen (DSGVO)

| Zweck | Rechtsgrundlage |
| --- | --- |
| Lokale Wiedergabe, Katalog, Warteschlange | Art. 6 Abs. 1 lit. b DSGVO |
| Einstellungen | Art. 6 Abs. 1 lit. b bzw. lit. f DSGVO |
| Optionales Google Drive (Anmeldung, Listen, Download in lokalen Cache, Abspielen) | Art. 6 Abs. 1 lit. a DSGVO (**Einwilligung**); widerrufbar durch Abmelden / Widerruf in den Google-Kontoeinstellungen |
| Optionales persönliches OneDrive (Anmeldung, Listen, Download in lokalen Cache, Abspielen) | Art. 6 Abs. 1 lit. a DSGVO (**Einwilligung**); widerrufbar durch Abmelden / Widerruf in den Microsoft-Kontoeinstellungen |
| Beantwortung Ihrer Datenschutzanfragen | Art. 6 Abs. 1 lit. c und/oder lit. b/f DSGVO |

---

## 5. Speicherdauer

Gerätedaten: bis Sie sie in der App löschen (z. B. Ordner vergessen, Cloud-Cache leeren, Abmelden) oder die App / App-Daten deinstallieren bzw. löschen.  
Google-/Microsoft-Sitzung: bis Abmelden oder Widerruf beim jeweiligen Anbieter (Abmelden löscht den Cache dieses Anbieters).  
E-Mails an uns: nur so lange wie zur Bearbeitung und gesetzlichen Pflichten nötig.

---

## 6. Empfänger — Google und Microsoft

### 6.1 Google

Bei Nutzung der Drive-Funktionen verarbeitet Google Konten- und Drive-Daten gemäß [Google-Datenschutzerklärung](https://policies.google.com/privacy) und den API-/Produktbedingungen.

TinyTunes nutzt Google Sign-In und die Drive-API nur zum Anmelden, Auflisten und **Lesen/Herunterladen** ausgewählter Audiodateien in den **lokalen** Cache. Kein Schreibzugriff auf Drive durch die App.

### 6.2 Microsoft

Bei Nutzung von persönlichem OneDrive verarbeitet Microsoft Konten- und OneDrive-Daten gemäß [Microsoft-Datenschutzrichtlinie](https://privacy.microsoft.com/privacystatement) und den Identity-/Graph-Bedingungen.

TinyTunes nutzt Microsoft-Anmeldung (MSAL) und Microsoft Graph nur zum Anmelden, Auflisten und **Lesen/Herunterladen** ausgewählter Audiodateien in den **lokalen** Cache. Kein Schreibzugriff auf OneDrive durch die App.

Übermittlungen in Drittländer können bei Google bzw. Microsoft nach deren Mechanismen (z. B. Standardvertragsklauseln) erfolgen.

---

## 7. Ihre Rechte

Soweit die DSGVO gilt: Auskunft, Berichtigung, Löschung, Einschränkung, Datenübertragbarkeit, Widerspruch, Widerruf der Einwilligung.

In der App u. a.: Ordner vergessen, Cloud-Cache leeren, Abmelden; zusätzlich Zugriff bei Google widerrufen: [myaccount.google.com/permissions](https://myaccount.google.com/permissions); bei Microsoft über die Konto-/App-Berechtigungen widerrufen.

Anfragen an `[DATENSCHUTZ-KONTAKT-E-MAIL]`. Beschwerderecht bei einer Aufsichtsbehörde im Wohnsitzmitgliedstaat. Beispiel Österreich: [Datenschutzbehörde](https://www.dsb.gv.at/) — anpassen an `[NAME DES VERANTWORTLICHEN]` / Ihre Nutzerinnen und Nutzer.

---

## 8. Kinder, automatisierte Entscheidungen, Änderungen

Die App richtet sich nicht an Kinder. Keine automatisierten Entscheidungen mit Rechtswirkung im Sinne von Art. 22 DSGVO. Änderungen werden durch Aktualisierung des Datums und der veröffentlichten Fassung kenntlich gemacht.

**Forks:** keine fremde Privacy-URL und keine fremde Verantwortlichen-Identität wiederverwenden. Eigene OAuth-Clients, eigene gehostete Erklärung, eigene Kontaktdaten.

**Hinweis:** Die Live-HTML-Fassung muss dem befüllten Entwurf entsprechen, bevor OAuth-Zustimmungsseiten auf die Privacy-URL verweisen.

---

*Vorlage, keine Rechtsberatung. Befüllte Fassung bei Bedarf für Ihre Jurisdiktion rechtlich prüfen lassen.*
