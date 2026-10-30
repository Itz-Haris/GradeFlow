import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/student_service.dart';
import '../utils/app_theme.dart';

/// Settings screen for API configuration, Theme selection, Demo Mode toggle,
/// max marks settings, Google Sheets integration guide, and college practical metadata.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showApiUrlDialog(BuildContext context, StudentService service) {
    final controller = TextEditingController(
      text: service.activeApiUrl == googleSheetsApiUrl ? '' : service.activeApiUrl,
    );
    final surfaceColor = AppTheme.getSurface(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Configure Google Apps Script API',
            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste your deployed Google Apps Script Web App URL below:',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 2,
                style: TextStyle(color: textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'https://script.google.com/macros/s/.../exec',
                  hintStyle: TextStyle(fontSize: 12, color: textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.paste, size: 20, color: textSecondary),
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        controller.text = data!.text!.trim();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final url = controller.text.trim();
                service.updateApiUrl(url);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('API URL updated. Synchronizing records...'),
                    backgroundColor: AppTheme.secondaryElectric,
                  ),
                );
              },
              child: const Text('Save & Sync'),
            ),
          ],
        );
      },
    );
  }

  void _showMaxMarksDialog(BuildContext context, StudentService service) {
    final controller = TextEditingController(text: service.maxMarks.toInt().toString());
    final surfaceColor = AppTheme.getSurface(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Configure Maximum Marks',
            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the benchmark total marks or GPA scale (e.g. 100, 75, 50, or 10):',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Maximum Marks / Scale',
                  hintText: '100',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text.trim());
                if (val != null && val > 0) {
                  service.setMaxMarks(val);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showSetupGuideModal(BuildContext context) {
    final surfaceColor = AppTheme.getSurface(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.getBorder(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Google Sheets Integration Guide',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Follow these 7 steps to connect your own Google Sheet to GradeFlow:',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 16),

                  _GuideStep(
                    stepNumber: 1,
                    title: 'Create Google Sheet',
                    desc: 'Create a new Google Sheet named "GradeFlow Student Records". In Row 1, add these exact column headers:\n\nSr No | Roll No | Student Name | 10th | 12th | Sem 1 | Sem 2',
                  ),
                  _GuideStep(
                    stepNumber: 2,
                    title: 'Open Apps Script Editor',
                    desc: 'Click on Extensions in the top menu bar, then select Apps Script.',
                  ),
                  _GuideStep(
                    stepNumber: 3,
                    title: 'Paste Web App Code',
                    desc: 'Clear any existing code in Code.gs and paste the Google Apps Script code provided in the project folder (google_apps_script/Code.gs).',
                  ),
                  _GuideStep(
                    stepNumber: 4,
                    title: 'Configure Spreadsheet ID & Sheet Name',
                    desc: 'Set SPREADSHEET_ID to your Google Sheet ID (from the sheet URL) and SHEET_NAME to "Sheet1" (or your sheet tab name).',
                  ),
                  _GuideStep(
                    stepNumber: 5,
                    title: 'Deploy as Web App',
                    desc: 'Click Deploy (top right) → New deployment. Click the gear icon next to "Select type" and choose "Web app".',
                  ),
                  _GuideStep(
                    stepNumber: 6,
                    title: 'Configure Permissions (Critical)',
                    desc: 'Set Execute as: "Me"\nSet Who has access: "Anyone" (allows the mobile app to fetch records without OAuth tokens). Click Deploy.',
                  ),
                  _GuideStep(
                    stepNumber: 7,
                    title: 'Copy & Paste Web App URL',
                    desc: 'Copy the generated Web App URL (ending in /exec). Go to GradeFlow Settings → "Configure API Endpoint" and paste the URL.',
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Understood'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentService = Provider.of<StudentService>(context);
    final surfaceColor = AppTheme.getSurface(context);
    final borderColor = AppTheme.getBorder(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final isConfigured = studentService.activeApiUrl != googleSheetsApiUrl &&
        studentService.activeApiUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      appBar: AppBar(
        title: const Text('Settings & Info'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Appearance & Themes (Dark / Light)
            _SettingsSectionTitle(title: 'Appearance & Theme'),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: borderColor),
                boxShadow: AppTheme.getSoftShadow(context),
              ),
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text('Light Mode', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                    subtitle: Text('Classic clean white & navy palette', style: TextStyle(fontSize: 12, color: textSecondary)),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.light_mode_outlined, color: Color(0xFFF59E0B)),
                    ),
                    value: ThemeMode.light,
                    groupValue: studentService.themeMode,
                    activeColor: AppTheme.secondaryElectric,
                    onChanged: (val) {
                      if (val != null) studentService.setThemeMode(val);
                    },
                  ),
                  Divider(height: 1, color: borderColor),
                  RadioListTile<ThemeMode>(
                    title: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                    subtitle: Text('Obsidian navy & electric blue palette', style: TextStyle(fontSize: 12, color: textSecondary)),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryElectric.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.dark_mode_outlined, color: AppTheme.secondaryElectric),
                    ),
                    value: ThemeMode.dark,
                    groupValue: studentService.themeMode,
                    activeColor: AppTheme.secondaryElectric,
                    onChanged: (val) {
                      if (val != null) studentService.setThemeMode(val);
                    },
                  ),
                  Divider(height: 1, color: borderColor),
                  RadioListTile<ThemeMode>(
                    title: Text('System Default', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                    subtitle: Text('Follows phone system appearance settings', style: TextStyle(fontSize: 12, color: textSecondary)),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.brightness_auto_outlined, color: AppTheme.accentCyan),
                    ),
                    value: ThemeMode.system,
                    groupValue: studentService.themeMode,
                    activeColor: AppTheme.secondaryElectric,
                    onChanged: (val) {
                      if (val != null) studentService.setThemeMode(val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: Academic Practical Information
            _SettingsSectionTitle(title: 'Practical Information'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: borderColor),
                boxShadow: AppTheme.getSoftShadow(context),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Application', value: 'GradeFlow'),
                  _InfoRow(label: 'Tagline', value: 'Your Marks, Your Progress.'),
                  _InfoRow(label: 'Subject', value: 'Digital Literacy & Application'),
                  _InfoRow(label: 'Unit / Activity', value: 'Unit 6 — Activity 6'),
                  _InfoRow(label: 'Department', value: 'Robotics and Automation'),
                  _InfoRow(label: 'Version', value: '1.0.0 (Release Build)'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 3: Data Source & API Status
            _SettingsSectionTitle(title: 'Google Sheets Integration'),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: borderColor),
                boxShadow: AppTheme.getSoftShadow(context),
              ),
              child: Column(
                children: [
                  // Status Tile
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (studentService.isDemoMode
                                ? AppTheme.warningOrange
                                : (isConfigured ? AppTheme.positiveGreen : AppTheme.neutralGrey))
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        studentService.isDemoMode
                            ? Icons.science_outlined
                            : (isConfigured ? Icons.cloud_done : Icons.cloud_off),
                        color: studentService.isDemoMode
                            ? AppTheme.warningOrange
                            : (isConfigured ? AppTheme.positiveGreen : AppTheme.neutralGrey),
                      ),
                    ),
                    title: Text(
                      studentService.isDemoMode
                          ? 'Demo Mode Active'
                          : (isConfigured ? 'Live Sheets API Connected' : 'API Unconfigured'),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary),
                    ),
                    subtitle: Text(
                      studentService.isDemoMode
                          ? 'Displaying 10 sample student records'
                          : (isConfigured
                              ? 'Endpoint configured. Tap to modify.'
                              : 'Tap to configure Apps Script Web App URL'),
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right, color: textSecondary),
                    onTap: () => _showApiUrlDialog(context, studentService),
                  ),

                  Divider(height: 1, color: borderColor),

                  // Demo Mode Toggle Switch
                  SwitchListTile(
                    title: Text(
                      'Demo Mode',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                    ),
                    subtitle: Text(
                      'Use offline mock dataset for college viva demonstration',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    activeColor: AppTheme.secondaryElectric,
                    value: studentService.isDemoMode,
                    onChanged: (val) {
                      studentService.toggleDemoMode(val);
                    },
                  ),

                  Divider(height: 1, color: borderColor),

                  // Step-by-Step Setup Guide
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryElectric.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book_outlined, color: AppTheme.secondaryElectric),
                    ),
                    title: Text(
                      'Connection Instructions',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary),
                    ),
                    subtitle: Text(
                      'Step-by-step tutorial to create Apps Script Web App',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right, color: textSecondary),
                    onTap: () => _showSetupGuideModal(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 4: Academic Preferences (Max Marks / Scale)
            _SettingsSectionTitle(title: 'Academic Preferences'),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: borderColor),
                boxShadow: AppTheme.getSoftShadow(context),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryElectric.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune, color: AppTheme.secondaryElectric),
                ),
                title: Text(
                  'Maximum Assessment Marks / Scale',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary),
                ),
                subtitle: Text(
                  'Currently set to ${studentService.maxMarks.toInt()} (change to 10 for CGPA/GPA)',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
                trailing: Text(
                  '${studentService.maxMarks.toInt()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryElectric,
                  ),
                ),
                onTap: () => _showMaxMarksDialog(context, studentService),
              ),
            ),

            const SizedBox(height: 20),

            // Section 5: Privacy & Security
            _SettingsSectionTitle(title: 'Privacy & Security Notice'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: borderColor),
                boxShadow: AppTheme.getSoftShadow(context),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: AppTheme.secondaryElectric, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'GradeFlow communicates directly with your Google Sheets endpoint via HTTPS. '
                      'No student data is routed through third-party analytics or external trackers. '
                      'Always use fictitious data for public viva demonstrations.',
                      style: TextStyle(fontSize: 12, color: textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;

  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.neutralGrey,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String desc;

  const _GuideStep({
    required this.stepNumber,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppTheme.secondaryElectric,
            child: Text(
              '$stepNumber',
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
