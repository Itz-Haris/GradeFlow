# GradeFlow — Student Academic Performance Tracker

> **Tagline:** *Your Marks, Your Progress.*  
> **Course:** Digital Literacy and Application (DL&A) — Unit 6, Activity 6  
> **Department:** Robotics and Automation  
> **Platform:** Android Mobile Application (Flutter & Dart)  
> **Data Source:** Google Sheets via Google Apps Script JSON API  

---

## 1. Project Overview

**GradeFlow** is a modern, student-centric academic records tracking and analytics mobile application built for Android using Flutter, Dart, and Material Design 3. The system links seamlessly with a cloud-hosted Google Spreadsheet through a Google Apps Script Web App JSON API, allowing faculty and students in the Department of Robotics and Automation to visualize academic performance trajectories from secondary board examinations (10th and 12th) through University Semester 1 and Semester 2 assessments.

### Key Highlights
- **100% Dynamic Statistical Computations:** Class averages, cohort highest/lowest scores, and performance distribution bands are calculated dynamically from active records without hardcoded values.
- **Robust Fault Tolerance:** Missing, withheld, or diploma entrant records (e.g. lateral entry students without 12th board marks) are safely mapped to `null` and displayed as `"N/A"`, completely excluded from mathematical divisors.
- **Interactive Academic Comparison:** Head-to-head student comparison table highlighting higher assessment scores in emerald green.
- **Cohort Analytics & Distribution:** Configurable academic performance brackets (0–39 Remedial, 40–59 Pass, 60–79 First Class, 80–100 Distinction) across any chosen assessment metric.
- **Built-in Demo Mode:** Allows offline college viva evaluations and laboratory demonstrations using realistic, fictional student data with a persistent "DEMO DATA" indicator banner.
- **Zero Paid Dependencies:** Uses free Google Workspace cloud infrastructure and standard Flutter packages.

---

## 2. Technology Stack & Architecture

| Component | Technology | Version / Specification |
| :--- | :--- | :--- |
| **Mobile Framework** | Flutter SDK | `>=3.0.0 <4.0.0` |
| **Language** | Dart | Modern Sound Null Safety |
| **UI Design System** | Material Design 3 | `useMaterial3: true` |
| **State Management** | Provider | `ChangeNotifierProvider` |
| **Networking** | HTTP Package | `http: ^1.2.0` (15s timeout, SSL/TLS) |
| **Local Cache & Prefs** | Shared Preferences | `shared_preferences: ^2.2.2` |
| **Visual Analytics** | Pure Flutter Canvas / Charts | Custom-painted responsive bar charts |
| **Backend API** | Google Apps Script | `doGet(e)` Web App returning MIME type `application/json` |
| **Cloud Database** | Google Sheets | 7-column structured academic ledger |

---

## 3. Visual Identity & Color Palette

GradeFlow implements a high-contrast, modern engineering aesthetic:

- **Primary:** Deep Navy Blue (`#0F172A`)
- **Secondary:** Electric Blue (`#2563EB`)
- **Accent:** Cyan (`#06B6D4`)
- **Background:** Light Blue-Grey (`#F1F5F9`)
- **Cards & Surfaces:** Pure White (`#FFFFFF`) with 20px rounded radii and soft elevation shadows
- **Positive Indicators:** Emerald Green (`#10B981`)
- **Warning Indicators:** Amber Orange (`#F59E0B`)
- **Critical / Remedial:** Crimson (`#EF4444`)

---

## 4. Project Directory Structure

```text
gradeflow/
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/AndroidManifest.xml   <-- Internet permission enabled
│   ├── build.gradle
│   └── settings.gradle
├── google_apps_script/
│   ├── Code.gs                            <-- Google Apps Script doGet() API
│   └── sample_students.csv                <-- Importable template for Google Sheets
├── lib/
│   ├── main.dart                          <-- Application entry & theme initialization
│   ├── models/
│   │   └── student.dart                   <-- Null-safe model with math helpers
│   ├── services/
│   │   └── student_service.dart           <-- API client, demo mode, and stats engine
│   ├── screens/
│   │   ├── splash_screen.dart             <-- Animated cap & chart brand logo
│   │   ├── home_screen.dart               <-- Dashboard, bottom nav & quick actions
│   │   ├── students_screen.dart           <-- Searchable & sortable directory
│   │   ├── student_details_screen.dart    <-- Individual breakdown & delta progress
│   │   ├── analytics_screen.dart          <-- Cohort metrics & distribution charts
│   │   ├── compare_screen.dart            <-- Two-student head-to-head comparison
│   │   └── settings_screen.dart           <-- API configuration & practical info
│   ├── widgets/
│   │   ├── student_card.dart              <-- List item card with initials & progress
│   │   ├── statistics_card.dart           <-- Dynamic dashboard KPI card
│   │   ├── marks_progress_card.dart       <-- Assessment progress indicator
│   │   └── performance_chart.dart         <-- Responsive bar & distribution charts
│   └── utils/
│       └── app_theme.dart                 <-- Color tokens, radii & theme config
├── pubspec.yaml
└── README.md
```

---

## 5. Google Sheets Integration Guide

### Spreadsheet Column Layout
Your Google Sheet **must** use the following exact column headers in Row 1:

| Sr No | Roll No | Student Name | 10th | 12th | Sem 1 | Sem 2 |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | RA-2026-001 | Aarav Sharma | 92.5 | 88.0 | 85.5 | 91.0 |
| 2 | RA-2026-002 | Diya Patel | 95.0 | 94.5 | 92.0 | 96.0 |
| 3 | RA-2026-005 | Kabir Mehta | 81.0 | N/A | 76.0 | 82.5 |

*(Tip: You can upload `google_apps_script/sample_students.csv` directly via **File → Import → Upload**)*.

### 7-Step Google Apps Script Deployment

1. **Create the Google Sheet:** Create a new sheet at [sheets.google.com](https://sheets.google.com) and populate Row 1 with the headers above.
2. **Open Apps Script Editor:** Click **Extensions** in the top menu bar → select **Apps Script**.
3. **Paste the Web App Code:** Delete any placeholder code in `Code.gs` and paste the entire contents of [`gradeflow/google_apps_script/Code.gs`](google_apps_script/Code.gs).
4. **Configure Spreadsheet ID & Sheet Name:**
   - If the script is bound inside the sheet, leave `SPREADSHEET_ID = ""` (or set it to your sheet ID extracted from the browser URL: `https://docs.google.com/spreadsheets/d/<SPREADSHEET_ID>/edit`).
   - Set `SHEET_NAME = "Sheet1"` (matching your worksheet tab name).
   - Press **Ctrl + S** (or Cmd + S) to save.
5. **Deploy the Script as a Web App:**
   - Click the blue **Deploy** button (top right) → **New deployment**.
   - Click the gear icon next to *Select type* → choose **Web app**.
   - In Description, type: `GradeFlow API v1`.
6. **Configure Access Permissions (Important):**
   - **Execute as:** `Me (your email address)`
   - **Who has access:** `Anyone` *(This allows the mobile app HTTP client to read records without requiring Google OAuth login)*.
   - Click **Deploy** and authorize access when prompted.
7. **Copy Deployment URL:**
   - Copy the generated Web App URL (e.g. `https://script.google.com/macros/s/AKfycb.../exec`).
   - Open **GradeFlow** → navigate to **Settings** → tap **Google Sheets Integration** → paste the URL.

---

## 6. Configuring Flutter API Service

In [`lib/services/student_service.dart`](lib/services/student_service.dart), the placeholder is defined at line 14:

```dart
/// PLACEHOLDER REQUIRED BY SPECIFICATION:
/// Replace this string with your deployed Google Apps Script Web App URL.
const String googleSheetsApiUrl = 'PASTE_YOUR_APPS_SCRIPT_WEB_APP_URL_HERE';
```

> **Note:** You do **not** even need to rebuild the app to update the URL! GradeFlow includes an in-app URL configuration dialog under **Settings → Google Sheets Integration** which saves the live URL directly to device storage via `SharedPreferences`.

---

## 7. Android Build & Execution Instructions

### Prerequisites
1. **Flutter SDK:** Version 3.10.0 or higher ([flutter.dev](https://flutter.dev)).
2. **Android Studio:** With Android SDK (API level 34) and command-line tools installed.
3. **Java Development Kit (JDK):** JDK 17 (bundled with Android Studio).

### Setup & Run Commands

```powershell
# 1. Navigate into the GradeFlow project root
cd gradeflow

# 2. Verify Flutter environment health
flutter doctor

# 3. Download and install all Dart dependencies
flutter pub get

# 4. Run the app on a connected Android phone or Emulator
flutter run

# 5. Build optimized, standalone Release APK
flutter build apk --release
```

### Where to Find the Generated Release APK
Once compilation completes, the standalone Android APK will be located at:
```text
gradeflow/build/app/outputs/flutter-apk/app-release.apk
```
You can transfer this APK directly via USB or Google Drive to any Android phone (Android 5.0 Lollipop / API 21 or higher) and install it.

### Required Android Permission
GradeFlow requires internet access to synchronize with Google Sheets. This is configured in [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

---

## 8. Privacy & Security Notice

- **Direct HTTPS Communication:** GradeFlow sends standard HTTPS GET requests directly to the user-provided Google Apps Script Web App. No student data passes through third-party telemetry, ads, or tracking servers.
- **Web App Access Model:** Because Google Apps Script Web Apps configured with *Who has access: Anyone* are publicly queryable by anyone possessing the URL, **never host confidential or personally identifiable real-world student data on an unprotected endpoint**.
- **Demonstration Protocol:** For all classroom assignments, viva voce, and college demonstrations, use fictional test records (such as those provided in `google_apps_script/sample_students.csv`).
- **No Credentials Required:** GradeFlow does not ask for or store Google passwords, OAuth tokens, or device account credentials.

---

## 9. Comprehensive Testing Checklist

| Test Scenario | Action / Steps | Expected Result | Pass/Fail |
| :--- | :--- | :--- | :---: |
| **1. Splash Screen** | Launch application | Animated cap/chart logo scales in; transitions to Dashboard after ~2s | Pass |
| **2. Demo Mode** | Open fresh install without API | "DEMO DATA" banner visible; 10 sample student records loaded | Pass |
| **3. Live Sheets Sync** | Enter Apps Script URL in Settings & tap Save | Fetches live rows from Google Sheets; sync time updates | Pass |
| **4. Statistics Accuracy** | Compare Sheet averages with Cards | Total students, 10th avg, 12th avg, Sem 1 avg, Sem 2 avg match exactly | Pass |
| **5. Null Handling** | Inspect student Kabir Mehta (missing 12th) | 12th shows "N/A"; Average strictly calculated using 3 available marks | Pass |
| **6. Search by Name** | Type "Diya" in search bar | Instantly filters to Diya Patel; case-insensitive | Pass |
| **7. Search by Roll No** | Type "007" in search bar | Instantly filters to Vikramaditya Roy (RA-2026-007) | Pass |
| **8. Sorting** | Change sort to "Semester 2: High to Low" | Student with 96.0 appears top of list; descending order verified | Pass |
| **9. Student Details** | Tap any student card | Opens dedicated breakdown, showing all 4 assessments + progress bars | Pass |
| **10. Semester Delta** | View student details | Improvement banner shows accurate + or - delta between Sem 1 and Sem 2 | Pass |
| **11. Comparison Mode** | Select Student A & B in Compare Screen | Side-by-side table displays; higher scores highlighted in emerald green | Pass |
| **12. Network Failure** | Disconnect Wi-Fi and pull to refresh | Network error banner appears; previous dataset remains visible; retry button | Pass |
| **13. Max Marks Config** | Change max marks from 100 to 50 | All progress percentages and chart bounds scale dynamically | Pass |

---

## 10. Practical Assignment Credits

- **Student / Author:** Haris
- **Academic Year:** 2026
- **Subject:** Digital Literacy and Application (DL&A)
- **Unit / Activity:** Unit 6, Activity 6
- **Department:** Robotics and Automation
- **Institution:** Engineering College Practical Examination
