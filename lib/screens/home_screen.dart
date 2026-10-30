import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_service.dart';
import '../utils/app_theme.dart';
import '../widgets/statistics_card.dart';
import '../widgets/performance_chart.dart';
import 'students_screen.dart';
import 'analytics_screen.dart';
import 'compare_screen.dart';
import 'settings_screen.dart';

/// Main container screen featuring Bottom Navigation and the Home Dashboard tab.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _searchTriggeredFromHome = false;

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
      _searchTriggeredFromHome = false;
    });
  }

  void _navigateToStudents({bool focusSearch = false}) {
    setState(() {
      _currentIndex = 1;
      _searchTriggeredFromHome = focusSearch;
    });
  }

  void _navigateToAnalytics() {
    setState(() {
      _currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = AppTheme.getSurface(context);
    final borderColor = AppTheme.getBorder(context);

    final List<Widget> pages = [
      _DashboardView(
        onViewAllStudents: () => _navigateToStudents(focusSearch: false),
        onSearchStudents: () => _navigateToStudents(focusSearch: true),
        onViewAnalytics: _navigateToAnalytics,
      ),
      StudentsScreen(autoFocusSearch: _searchTriggeredFromHome),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
          boxShadow: AppTheme.getSoftShadow(context),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            backgroundColor: surfaceColor,
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: _onBottomNavTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Students',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights_outlined),
                activeIcon: Icon(Icons.insights_rounded),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Home Dashboard view containing header, dynamic statistics cards,
/// academic performance chart, and quick actions.
class _DashboardView extends StatelessWidget {
  final VoidCallback onViewAllStudents;
  final VoidCallback onSearchStudents;
  final VoidCallback onViewAnalytics;

  const _DashboardView({
    required this.onViewAllStudents,
    required this.onSearchStudents,
    required this.onViewAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final studentService = Provider.of<StudentService>(context);
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final bgColor = AppTheme.getBackground(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => studentService.fetchStudents(forceRefresh: true),
          color: AppTheme.secondaryElectric,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header with GradeFlow Logo, Title, Theme Toggle, and Refresh
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        // Mini Logo
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppTheme.electricCyanGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.secondaryElectric.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GradeFlow',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Track your academic journey.',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Actions: Theme Mode Toggle & Refresh Button
                    Row(
                      children: [
                        // Instant Theme Toggle (Sun/Moon)
                        IconButton(
                          tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                          icon: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                            color: isDark ? const Color(0xFFFBBF24) : textPrimary,
                            size: 22,
                          ),
                          onPressed: () {
                            studentService.toggleTheme();
                          },
                        ),
                        // Refresh Button
                        IconButton(
                          tooltip: 'Refresh Records from Google Sheets',
                          icon: studentService.isRefreshing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryElectric),
                                  ),
                                )
                              : Icon(Icons.refresh_rounded, color: textPrimary),
                          onPressed: () {
                            studentService.fetchStudents(forceRefresh: true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Welcome Card with Gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: isDark ? AppTheme.darkPrimaryGradient : AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    boxShadow: AppTheme.getSoftShadow(context),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome to GradeFlow',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Student Academic Records Management System for DL&A Unit 6.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFCBD5E1),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Demo mode tag or live sync indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: studentService.isDemoMode
                                    ? AppTheme.warningOrange.withOpacity(0.25)
                                    : AppTheme.positiveGreen.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: studentService.isDemoMode
                                      ? AppTheme.warningOrange
                                      : AppTheme.positiveGreen,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                studentService.isDemoMode ? 'DEMO DATA MODE' : 'LIVE SHEETS SYNCED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: studentService.isDemoMode
                                      ? const Color(0xFFFDE68A)
                                      : const Color(0xFFA7F3D0),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          color: AppTheme.accentCyanLight,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                // Error Notice if API failed
                if (studentService.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.criticalRedBgDark : AppTheme.criticalRedBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.criticalRed.withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.criticalRed, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data Synchronization Notice',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.criticalRed,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                studentService.errorMessage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF7F1D1D),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => studentService.fetchStudents(forceRefresh: true),
                                    child: const Text(
                                      'Retry Sync',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.criticalRed,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                    onTap: () => studentService.toggleDemoMode(true),
                                    child: const Text(
                                      'Switch to Demo Data',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondaryElectric,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Statistics Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Academic Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'Max Marks: ${studentService.maxMarks.toInt()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dynamic Statistics Cards Grid (5 key metrics)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double cardWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        // Card 1: Total Students (full width)
                        SizedBox(
                          width: constraints.maxWidth,
                          child: StatisticsCard(
                            title: 'Total Enrolled Students',
                            value: '${studentService.totalStudents}',
                            subtitle: '${studentService.studentsWithRecordsCount} with active assessment scores',
                            icon: Icons.groups_rounded,
                            accentColor: AppTheme.secondaryElectric,
                            onTap: onViewAllStudents,
                          ),
                        ),
                        // Card 2: Average 10th Marks
                        SizedBox(
                          width: cardWidth,
                          child: StatisticsCard(
                            title: 'Avg. 10th Marks',
                            value: studentService.avg10th != null
                                ? '${studentService.avg10th!.toStringAsFixed(1)}%'
                                : 'N/A',
                            subtitle: 'Secondary board',
                            icon: Icons.school_outlined,
                            accentColor: const Color(0xFF3B82F6),
                          ),
                        ),
                        // Card 3: Average 12th Marks
                        SizedBox(
                          width: cardWidth,
                          child: StatisticsCard(
                            title: 'Avg. 12th Marks',
                            value: studentService.avg12th != null
                                ? '${studentService.avg12th!.toStringAsFixed(1)}%'
                                : 'N/A',
                            subtitle: 'Higher secondary / Dip.',
                            icon: Icons.history_edu_outlined,
                            accentColor: const Color(0xFF6366F1),
                          ),
                        ),
                        // Card 4: Average Semester 1 Marks
                        SizedBox(
                          width: cardWidth,
                          child: StatisticsCard(
                            title: 'Avg. Semester 1',
                            value: studentService.avgSem1 != null
                                ? '${studentService.avgSem1!.toStringAsFixed(1)}%'
                                : 'N/A',
                            subtitle: 'Autumn term results',
                            icon: Icons.assignment_outlined,
                            accentColor: AppTheme.secondaryElectric,
                          ),
                        ),
                        // Card 5: Average Semester 2 Marks
                        SizedBox(
                          width: cardWidth,
                          child: StatisticsCard(
                            title: 'Avg. Semester 2',
                            value: studentService.avgSem2 != null
                                ? '${studentService.avgSem2!.toStringAsFixed(1)}%'
                                : 'N/A',
                            subtitle: 'Spring term results',
                            icon: Icons.fact_check_outlined,
                            accentColor: AppTheme.accentCyan,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Academic Performance Chart
                AcademicPerformanceChart(
                  avg10th: studentService.avg10th,
                  avg12th: studentService.avg12th,
                  avgSem1: studentService.avgSem1,
                  avgSem2: studentService.avgSem2,
                  maxMarks: studentService.maxMarks,
                ),

                const SizedBox(height: 24),

                // Quick Actions Section
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        label: 'All Students',
                        icon: Icons.format_list_bulleted_rounded,
                        color: AppTheme.secondaryElectric,
                        onTap: onViewAllStudents,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionButton(
                        label: 'Search Student',
                        icon: Icons.search_rounded,
                        color: AppTheme.accentCyan,
                        onTap: onSearchStudents,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        label: 'Academic Analytics',
                        icon: Icons.insights_rounded,
                        color: const Color(0xFF6366F1),
                        onTap: onViewAnalytics,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionButton(
                        label: 'Compare Students',
                        icon: Icons.compare_arrows_rounded,
                        color: AppTheme.positiveGreen,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CompareScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = AppTheme.getSurface(context);
    final borderColor = AppTheme.getBorder(context);
    final textPrimary = AppTheme.getTextPrimary(context);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.getSoftShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
