# 💡 AgileAI – Feature-Ideen & Erweiterungsvorschläge

> Diese Datei dokumentiert den Implementierungsstand aller Features sowie offene Ideen.  
> **Analysebasis:** Vollständige Durchsicht aller Dart-Dateien (`lib/`), `pubspec.yaml`
> und aller Dokumentationsdateien. Zuletzt aktualisiert: 2026-03-03.

---

## Aktueller Implementierungsstand

Die folgende Tabelle zeigt, was bereits vollständig, teilweise oder noch gar nicht umgesetzt ist.

### ✅ Vollständig implementiert (End-to-End nutzbar)

| Feature | Wo im Code |
|---|---|
| Chat mit KI-Scrum-Master | `ChatProvider`, `ChatScreen`, `AiService.sendMessage()` |
| 5 Scrum-Zeremonien mit Agenda & Timebox | `AppConfig.ceremonyDetails`, `CeremonySelector` |
| Meeting-Timer mit Timebox-Warnung | `MeetingTimerWidget`, importiert in `ChatScreen` |
| Sentiment-Analyse | `AiService.analyzeSentiment()`, Dialog in `ChatScreen` |
| Sprint-Goal-Generierung | `AiService.generateSprintGoal()`, Dialog in `ChatScreen` |
| Retrospektiven-Analyse | `AiService.analyzeRetrospective()`, Dialog in `ChatScreen` |
| Impediment-Erkennung | `AiService.detectImpediments()`, Dialog in `ChatScreen` |
| Sprint-Risiko-Analyse | `AiService.analyzeSprintRisk()`, Dialog in `ChatScreen` |
| Story Point Schätzung (KI) | `AiService.estimateStoryPoints()`, Dialog in `ChatScreen` |
| Acceptance Criteria Generator | `AiService.generateAcceptanceCriteria()`, Dialog in `ChatScreen` |
| INVEST-Validator | `AiService.validateInvest()`, Dialog in `ChatScreen` |
| Action Item Extraktion | `AiService.extractActionItems()`, `ActionItemTile`, Dialog in `ChatScreen` |
| Definition of Done Generator | `AiService.generateDefinitionOfDone()` |
| Scrum-Reifegrad-Bewertung (KI-Logik) | `AiService.evaluateScrumMaturity()` |
| Lokaler Chat-Verlauf | `StorageService` (SharedPreferences) |
| Chat-Suche | `_searchController` in `ChatScreen` |
| Backlog-Verwaltung (lokal) | `BacklogScreen`, `BacklogProvider`, `DatabaseService` (sqflite) |
| Team-Mitglieder-Modell | `TeamMember`, `TeamProvider`, `DatabaseService` |
| Sprint-Daten-Modell | `SprintData`, `DatabaseService.loadAllSprints()` |
| Analytics-Logik | `AnalyticsProvider` (Sentiment, Velocity, Health-Score) |
| Sentiment-Chart-Widget | `SentimentChartWidget` (fl_chart) |
| Sprachauswahl DE / EN | `SettingsProvider.setLanguage()`, `AppConfig.systemPrompt()` |
| Persona-Konfiguration | `AppConfig.personaStyles`, `SettingsProvider.setPersonaStyle()` |
| Multi-Modell-Auswahl | `AppConfig.availableModels`, `SettingsProvider.setAiModel()` |
| Onboarding (4 Seiten) | `OnboardingScreen` |
| Scrum-Wissensbasis (Daten) | `AppConfig.knowledgeBase` |
| Kontextgedächtnis-Methode | `AiService.buildCeremonyContext()` |
| Dark / Light Mode | `main.dart`, `ThemeMode.system` |
| Markdown-Rendering | `flutter_markdown` in pubspec |
| Teilen / Export (Basis) | `share_plus` in pubspec |
| Spracheingabe (Basis) | `speech_to_text` in pubspec |

---

### 🟡 Code existiert – aber nicht mit der App verbunden

Diese Features haben vollständigen Backend-Code, sind aber **nicht in `main.dart` registriert
und nicht navigierbar**. Die App startet direkt mit `ChatScreen`; alle anderen Provider und
Screens sind abgekoppelt.

| Feature | Was fehlt |
|---|---|
| **Navigation / Haupt-Shell** | `main_screen.dart` fehlt komplett – `OnboardingScreen` importiert diese Datei, die nicht existiert. Kein BottomNavigationBar / NavigationRail. |
| **SettingsProvider** | Nicht in `MultiProvider` in `main.dart` registriert. Sprache, Modell und Persona werden nicht persistent geladen. |
| **BacklogProvider** | Nicht registriert. `BacklogScreen` ist nicht erreichbar. |
| **TeamProvider** | Nicht registriert. Kein Team-Verwaltungs-Screen. |
| **AnalyticsProvider** | Nicht registriert. Charts und Health-Score werden nirgends angezeigt. |
| **SentimentChartWidget** | Widget existiert, wird aber in keinem Screen eingebunden. |
| **Onboarding-Flow** | `OnboardingScreen` existiert, wird aber nicht aus `main.dart` heraus gestartet (kein `onboardingComplete`-Check beim Start). |
| **Kontextgedächtnis** | `buildCeremonyContext()` in `AiService` ist implementiert, wird in `ChatProvider` aber nicht aufgerufen. |
| **DoD-Generator & Reifegrad** | KI-Methoden in `AiService` vorhanden, aber keine UI-Dialoge in `ChatScreen`. |

---

### 🔴 Noch nicht begonnen (neue Feature-Ideen)

Alles darunter ist weder Code noch UI vorhanden.

---

## Priorität-Legende

| Symbol | Bedeutung |
|--------|-----------|
| 🔴 | Hoher Mehrwert, gut in bestehende Architektur integrierbar |
| 🟡 | Mittlerer Aufwand, klarer thematischer Fit |
| 🔵 | Größerer Umfang / externe Abhängigkeiten |

---

## A. Dringende Verbindungsarbeiten (abgekoppelter Code)

Diese Punkte sind **kein neues Feature**, sondern das Fertigstellen von bereits geschriebenem Code.

### 🔴 A.1 Haupt-Navigation implementieren (`main_screen.dart`)
`OnboardingScreen` importiert `main_screen.dart`, die nicht existiert – das ist ein **Build-Fehler**.
Eine `MainScreen`-Klasse mit `BottomNavigationBar` oder `NavigationRail` muss erstellt werden,
die Chat, Backlog und Analytics vereint.  
**Aufwand:** 1–2h. Blockiert alle anderen UI-Features.

### 🔴 A.2 Alle Provider in `main.dart` registrieren
`SettingsProvider`, `BacklogProvider`, `TeamProvider` und `AnalyticsProvider` müssen in das
`MultiProvider`-Array in `main.dart` eingetragen werden, damit sie von Screens gelesen werden können.

### 🔴 A.3 Onboarding-Flow an App-Start koppeln
In `main.dart` beim Start `SettingsProvider.onboardingComplete` prüfen und bei `false` zuerst
`OnboardingScreen` anzeigen, ansonsten `MainScreen`.

### 🔴 A.4 Settings-Screen bauen
`SettingsProvider` ist fertig. Es fehlt ein UI-Screen mit:
- Sprachauswahl (DE/EN)
- KI-Modell-Auswahl (Dropdown aus `AppConfig.availableModels`)
- Persona-Stil-Auswahl
- Daten zurücksetzen

### 🔴 A.5 Team-Mitglieder-Screen bauen
`TeamProvider` + `TeamMember`-Modell sind fertig. Es fehlt ein Screen mit:
- Liste der Teammitglieder (Name, Rolle, Avatar-Farbe)
- Hinzufügen / Bearbeiten / Löschen
- Teilnehmerauswahl beim Starten einer Zeremonie

### 🔴 A.6 Analytics / Dashboard-Screen bauen
`AnalyticsProvider` und `SentimentChartWidget` sind fertig. Ein Screen mit:
- Sentiment-Liniendiagramm über Zeit
- Velocity-Chart (Story Points pro Sprint)
- Team-Health-Score als Gauge
- Action-Item-Abschlussquote

### 🟡 A.7 DoD-Generator & Reifegrad-UI verbinden
`AiService.generateDefinitionOfDone()` und `evaluateScrumMaturity()` existieren als KI-Methoden,
haben aber keine Dialoge im `ChatScreen`-Menü. Zwei neue `ListTile`-Einträge + Dialoge analog
zu den bestehenden.

### 🟡 A.8 Kontextgedächtnis aktivieren
`AiService.buildCeremonyContext()` baut bereits einen Kontext-String aus vergangenen Zeremonien.
In `ChatProvider.startCeremony()` die letzten 3 Retro-Zusammenfassungen laden und an
`facilitateCeremony()` übergeben.

---

## B. Meeting & Zeremonien

### 🟡 B.1 Meetings exportieren (PDF / Markdown)
`share_plus` ist bereits in `pubspec.yaml`. Fehlend: ein „Exportieren"-Button in der AppBar
des Chat-Screens, der die aktuelle Zeremonie als formatiertes Markdown serialisiert und teilt.  
Für PDF zusätzlich `printing` Package nötig.

### 🟡 B.2 Zeremonien-Protokoll-Screen
Eine eigene Ansicht aller vergangenen Zeremonien: Name, Datum, Dauer, KI-Zusammenfassung,
Action Items. Durchsuchbar und filterbar nach Typ oder Sprint.  
**Anknüpfungspunkt:** `StorageService.loadCeremonies()`.

### 🔵 B.3 Geführte Agenda (Schritt für Schritt)
Der KI-Moderator führt durch jeden Agenda-Punkt einzeln. Wenn ein Punkt abgehakt ist,
geht es automatisch zum nächsten. Agenda-Templates sind in `AppConfig.ceremonyDetails`
bereits hinterlegt.

---

## C. Sprint- & Backlog-Erweiterungen

### 🟡 C.1 Sprint zuweisen & Kapazität planen
Im Backlog-Screen können Items einem Sprint zugewiesen werden. Die Summe der Story Points
wird gegen eine einstellbare Team-Kapazität geprüft.  
**Anknüpfungspunkt:** `BacklogItem.sprintNumber` ist bereits vorhanden.

### 🟡 C.2 Velocity-Eingabe pro Sprint
Ein einfaches Formular zum manuellen Eintragen der abgeschlossenen Story Points pro Sprint.
Gespeichert in `SprintData`, visualisiert im Analytics-Screen.

### 🔵 C.3 Planning-Poker-Flow
Geführter Schätzungsworkflow: Die KI schlägt eine erste Schätzung vor, Teilnehmer können
widersprechen, die KI moderiert die Diskussion und schlägt einen Konsens vor.  
**Abhängig von:** A.5 (Team-Mitglieder).

---

## D. KI-Erweiterungen

### 🟡 D.1 Retro-Themen-Muster erkennen
Die KI analysiert mehrere gespeicherte Retrospektiven auf Wiederholungen:
„Dieses Thema taucht zum 3. Mal auf – es scheint ein strukturelles Problem zu sein."  
**Anknüpfungspunkt:** `AnalyticsProvider.retroSummaries` liefert bereits alle Retro-Texte.

### 🟡 D.2 Tages-Tipp / Scrum Best-Practice
`AiService.getScrumTip()` ist implementiert. Ein Widget in der AppBar oder als tägliche
Push-Notification zeigt einen kontextsensitiven Tipp an (z. B. passend zur aktuellen Sprint-Phase).

### 🔵 D.3 Multi-LLM-Backend-Unterstützung
Erweiterung von `AiService` um ein Interface `LlmBackend`, das verschiedene Provider
(Gemini, OpenAI GPT-4o, Ollama lokal) abstrahiert. Wählbar in den Einstellungen.  
**Notiz:** `SETUP_GUIDE.md` enthält bereits Code-Snippets für OpenAI und Ollama.

---

## E. UX & Produktivität

### 🟡 E.1 Spracheingabe (Speech-to-Text) verdrahten
`speech_to_text` ist bereits in `pubspec.yaml`. Ein Mikrofon-Icon neben dem Eingabefeld
startet die Spracherkennung und füllt das Textfeld automatisch.  
**Besonders nützlich** während laufender Zeremonien.

### 🟡 E.2 Erinnerungen / Benachrichtigungen
Push-Notification oder In-App-Banner, wenn z. B. das Daily seit 24h nicht stattgefunden hat
oder ein Sprint ausläuft (basierend auf `SprintData.endDate`).  
**Notwendige Abhängigkeiten:** `flutter_local_notifications`.

### 🟡 E.3 Scrum-Glossar-Screen
`AppConfig.knowledgeBase` enthält bereits ein vollständiges Scrum-Glossar mit Rollen,
Artefakten, INVEST-Kriterien und Zeremonien. Es fehlt nur ein durchsuchbarer UI-Screen dafür –
kein API-Call nötig, 100 % offline.

### 🔵 E.4 Jira / GitHub / Linear Integration
Backlog Items direkt aus dem jeweiligen PM-Tool importieren via REST API.  
**Anknüpfungspunkt:** `http` Package bereits vorhanden. OAuth-Flow nötig.

---

## F. Team & Kollaboration

### 🟡 F.1 Mehrere Teams / Projekte
Innerhalb der App zwischen verschiedenen Teams oder Projekten wechseln. Jedes Team hat
einen eigenen Chat-Verlauf, Backlog, Zeremonien und Sentiment-Daten.  
**Modellanpassung:** `AppSettings.currentTeamId` + Team-Profile in `DatabaseService`.

### 🔵 F.2 Cloud-Sync (Firebase)
Zeremonie-Protokolle und Action Items über Firebase Firestore synchronisieren.
Mehrere Geräte, ein Team.  
**Notwendige Abhängigkeiten:** `firebase_core`, `cloud_firestore`, `firebase_auth`.  
**Abhängig von:** F.1 (Mehrere Teams).

### 🔵 F.3 Echtzeit-Meeting-Ansicht
Mehrere Nutzer sehen KI-Antworten gleichzeitig während einer laufenden Zeremonie.  
**Abhängig von:** F.2 (Cloud-Sync).

---

## Empfohlene Umsetzungsreihenfolge

```
Phase 1 – Fehlende Verbindungen schließen (Pflicht, da teilweise Build-Fehler):
  A.1  main_screen.dart erstellen (Navigation)
  A.2  Alle Provider in main.dart registrieren
  A.3  Onboarding-Check beim App-Start
  A.4  Settings-Screen
  A.5  Team-Mitglieder-Screen
  A.6  Analytics-/Dashboard-Screen

Phase 2 – Sofortiger Mehrwert mit bestehendem Code:
  A.7  DoD-Generator & Reifegrad Dialoge
  A.8  Kontextgedächtnis aktivieren
  E.1  Spracheingabe verdrahten
  E.3  Scrum-Glossar-Screen
  B.1  Meetings exportieren (Markdown/Share)
  D.2  Tages-Tipp-Widget

Phase 3 – Neue Features:
  C.1  Sprint-Zuweisung im Backlog
  C.2  Velocity-Eingabe
  D.1  Retro-Muster erkennen
  B.2  Zeremonien-Protokoll-Screen
  E.2  Erinnerungen / Notifications

Phase 4 – Größere Vorhaben:
  C.3  Planning-Poker-Flow
  D.3  Multi-LLM-Backend
  B.3  Geführte Agenda
  F.1  Mehrere Teams/Projekte
  F.2  Cloud-Sync (Firebase)
```

---

*Zuletzt aktualisiert: 2026-03-03 | Basis: AgileAI v1.0.0*
