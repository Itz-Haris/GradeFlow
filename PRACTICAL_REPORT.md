# LABORATORY PRACTICAL REPORT

**Department of Robotics and Automation**  
**Course:** Digital Literacy and Application (DL&A)  
**Academic Level:** First-Year Engineering Practical Assignment  
**Unit:** 6 — Cloud Integration & Mobile Application Development  
**Activity:** 6 — Academic Records Management System  

---

## 1. Project Title
**GradeFlow — Student Academic Performance Tracker and Analytics Mobile Application**  
*Tagline: Your Marks, Your Progress.*

---

## 2. Introduction
In contemporary educational ecosystems, monitoring academic progression across foundational secondary schooling and undergraduate semesters is vital for early intervention, performance forecasting, and personalized mentoring. The Department of Robotics and Automation requires a lightweight, cost-effective, and robust mobile tool that enables faculty advisors and students to access standardized records stored on cloud spreadsheets.

**GradeFlow** addresses this need by combining the omnipresence of Google Sheets with a cross-platform Flutter client on Android. By utilizing Google Apps Script as a serverless JSON REST interface, GradeFlow provides real-time access to student performance data without requiring paid server hosting or complex relational databases.

---

## 3. Aim
To design, develop, deploy, and test a modern Android mobile application named **GradeFlow** using the Flutter framework and Dart language to track, analyze, and compare student academic performance records stored dynamically in Google Sheets.

---

## 4. Objectives
1. Implement a structured cloud spreadsheet ledger tracking:
   - Serial Number (`Sr No`)
   - Roll Number (`Roll No`)
   - Student Full Name (`Student Name`)
   - 10th Standard Board Examination Marks (`10th`)
   - 12th Standard / Diploma Entrance Examination Marks (`12th`)
   - Semester 1 University Examination Marks (`Sem 1`)
   - Semester 2 University Examination Marks (`Sem 2`)
2. Create a serverless Google Apps Script Web App responding to HTTP `GET` requests with well-formed JSON objects.
3. Architect a Flutter mobile client following Material Design 3 guidelines featuring a branded splash screen, dynamic statistical cards, performance comparison charts, and multi-criteria student directories.
4. Implement fault-tolerant data parsing that represents absent or unrecorded assessments strictly as `null` (`"N/A"`), ensuring class averages and metrics exclude missing values from the divisor.
5. Provide side-by-side student comparison capabilities with automated visual highlighting of higher scores.
6. Support offline laboratory evaluation through an isolated, clearly flagged Demo Data Mode.

---

## 5. Hardware and Software Requirements

### A. Hardware Requirements
| Parameter | Development Machine | Target Mobile Device (Android) |
| :--- | :--- | :--- |
| **Processor** | Intel Core i3 / AMD Ryzen 3 (or higher) | ARMv7 / ARM64 Quad-Core 1.5 GHz+ |
| **RAM** | 8 GB minimum (16 GB recommended) | 2 GB minimum (3 GB+ recommended) |
| **Storage** | 10 GB free hard drive / SSD space | 50 MB available internal storage |
| **Connectivity** | Active broadband Internet connection | Wi-Fi or 4G/5G Cellular data |

### B. Software Requirements
| Tool / Component | Specification | Purpose |
| :--- | :--- | :--- |
| **Operating System** | Windows 10/11 64-bit | Development host |
| **Framework** | Flutter SDK (v3.10+) | Cross-platform UI toolkit |
| **Language** | Dart SDK (v3.0+) | Client application logic |
| **IDE** | VS Code / Android Studio | Code development & debugging |
| **Mobile OS** | Android 5.0 (API 21) to Android 14+ | Target deployment runtime |
| **Cloud Platform** | Google Workspace (Sheets + Apps Script) | Backend database & API endpoint |
| **Version Control** | Git | Source code revision management |

---

## 6. Development Procedure

The project development was executed systematically across seven engineering phases:

### Phase 1: Database Design (Google Sheets)
1. Created a dedicated Google Spreadsheet titled `GradeFlow Student Records`.
2. Structured Row 1 with fixed schema headers:
   `Sr No | Roll No | Student Name | 10th | 12th | Sem 1 | Sem 2`.
3. Populated the sheet with 10 representative records reflecting diverse academic scenarios (distinction scorers, lateral entry diploma students without 12th marks, and medical leave cases without Semester 2 scores).

### Phase 2: Serverless API Development (Google Apps Script)
1. Opened the Apps Script editor via **Extensions → Apps Script**.
2. Developed the `doGet(e)` handler in JavaScript:
   - Acquired spreadsheet data range using `sheet.getDataRange().getValues()`.
   - Mapped column headers in Row 0 as dictionary keys.
   - Iterated data rows, discarding blank entries and cleaning string numbers into floating-point numbers.
   - Explicitly mapped `"N/A"`, empty cells, and dashes to `null`.
   - Serialized the array into JSON with MIME type `ContentService.MimeType.JSON`.
3. Deployed the script as a Web App with access permissions configured to **"Execute as: Me"** and **"Who has access: Anyone"**.

### Phase 3: Flutter Client Architecture & State Management
1. Initialized the Flutter project using `flutter create gradeflow`.
2. Created a clean layered architecture:
   - `models/`: Immutable `Student` data class with custom JSON parsing and mathematical helper methods (`averageMark`, `highestMark`, `lowestMark`, `availableMarks`).
   - `services/`: `StudentService` extending `ChangeNotifier` to orchestrate HTTP requests, timeout handling, persistent cache, and dynamic statistics calculations.
   - `widgets/`: Reusable, atomic UI components (`StudentCard`, `StatisticsCard`, `MarksProgressCard`, `PerformanceChart`).
   - `screens/`: Dedicated feature views (`SplashScreen`, `HomeScreen`, `StudentsScreen`, `StudentDetailsScreen`, `AnalyticsScreen`, `CompareScreen`, `SettingsScreen`).
   - `utils/`: `AppTheme` configuring deep navy blue, electric blue, cyan, white cards, and 20px rounded radii.

### Phase 4: Dynamic Statistics Engine & Analytics Charting
1. Programmed dynamic statistical getters in `StudentService`:
   - Filtered each assessment column using `.where((m) => m != null)` to discard absent records.
   - Computed true arithmetic means without skewing denominators.
2. Built responsive custom chart widgets:
   - Four-bar cohort assessment comparison chart (10th vs 12th vs Sem 1 vs Sem 2).
   - Horizontal distribution bar chart bucketing students into 0–39, 40–59, 60–79, and 80–100 ranges across any selected assessment metric.

### Phase 5: Student Directory & Search / Sort Implementation
1. Implemented real-time, case-insensitive search by student name or roll number.
2. Designed modal sorting supporting 12 sort configurations (A-Z, Z-A, Roll No, Highest/Lowest Average, Assessment Scores).

### Phase 6: Student Comparison Module
1. Engineered a side-by-side comparison interface with student selectors.
2. Implemented comparison evaluation functions that dynamically highlight whichever student achieved a higher score in each academic category.

### Phase 7: Android Platform Configuration & Build
1. Added network permission `<uses-permission android:name="android.permission.INTERNET"/>` in `AndroidManifest.xml`.
2. Executed `flutter pub get` and compiled the release APK via `flutter build apk --release`.

---

## 7. Salient Features

1. **Branded Animated Splash Screen:** Custom logo blending a graduation mortarboard cap with upward progress bars.
2. **Dynamic Dashboard KPIs:**
   - Total Students
   - Average 10th Board Marks
   - Average 12th Board Marks
   - Average Semester 1 Marks
   - Average Semester 2 Marks
3. **Semester Trajectory Tracking:** Automatically calculates individual improvements (+/- delta) between Semester 1 and Semester 2.
4. **Student Comparison Engine:** Instant head-to-head analysis highlighting winning marks in emerald green.
5. **Robust Fault Tolerance:** Zero crashes on missing marks; clean `"N/A"` placeholders.
6. **Isolated Demo Mode:** Allows viva presentations offline without requiring internet access.
7. **Dynamic API Configuration:** In-app settings dialog to update the Apps Script Web App URL without modifying source code.

---

## 8. Testing Procedure & Verification

| Test Case | Scenario / Input | Expected Output | Actual Output | Status |
| :---: | :--- | :--- | :--- | :---: |
| **TC-01** | App initialization | Splash screen animates for 2s, redirects to Home | Splash renders smoothly, navigates to Home | **PASSED** |
| **TC-02** | Fetching Google Sheets records | HTTP GET returns JSON array of students | Service parses rows into `Student` objects | **PASSED** |
| **TC-03** | Missing mark calculation (Kabir Mehta - lateral entry) | 12th mark is `null`; Avg = `(81.0 + 76.0 + 82.5) / 3` | Displays 12th as `"N/A"`, average correctly computes to `79.8%` | **PASSED** |
| **TC-04** | Name Search filter (`"Sneha"`) | Filters list to only students named Sneha | Single card for "Sneha Kulkarni" displayed | **PASSED** |
| **TC-05** | Roll No Search (`"004"`) | Filters list to Roll No RA-2026-004 | Card for "Ananya Iyer" displayed | **PASSED** |
| **TC-06** | Sorting by Sem 1 (High to Low) | Top scorer in Sem 1 listed first | Diya Patel (92.0) appears at top | **PASSED** |
| **TC-07** | Head-to-head comparison | Select Aarav (85.5 Sem 1) & Diya (92.0 Sem 1) | Diya's Sem 1 highlighted in green | **PASSED** |
| **TC-08** | Network Disconnection | Turn off Wi-Fi/Mobile data and pull to refresh | Network error banner shown; cached data preserved | **PASSED** |
| **TC-09** | Benchmark scale change | Set Max Marks = 50 in Settings | Progress bars scale relative to 50 | **PASSED** |

---

## 9. Result
The GradeFlow mobile application was successfully implemented, compiled, and executed on Android. All specified features—including Google Sheets integration, dynamic mathematical averages, Material Design 3 UI, student directory search and sorting, cohort analytics charts, and side-by-side student comparison—operate with complete reliability, zero mathematical skewing on missing marks, and no external paid dependencies.

---

## 10. Conclusion
The **GradeFlow** project demonstrates the practical application of modern digital literacy tools and cross-platform mobile frameworks in solving real-world educational data management challenges. By integrating Google Sheets with Flutter through a serverless Google Apps Script JSON API, the system delivers an enterprise-grade academic tracker at zero operating cost. The application successfully fulfills all requirements of **Digital Literacy and Application, Unit 6, Activity 6** for the Department of Robotics and Automation.
