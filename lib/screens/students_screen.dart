import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../utils/app_theme.dart';
import '../widgets/student_card.dart';
import 'student_details_screen.dart';
import 'compare_screen.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  rollAsc,
  rollDesc,
  avgDesc,
  avgAsc,
  sem1Desc,
  sem1Asc,
  sem2Desc,
  sem2Asc,
  marks10thDesc,
  marks12thDesc,
}

/// Dedicated Student Directory screen with instant search and comprehensive sorting.
/// Supports dynamic Light and Dark themes.
class StudentsScreen extends StatefulWidget {
  final bool autoFocusSearch;

  const StudentsScreen({
    super.key,
    this.autoFocusSearch = false,
  });

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';
  SortOption _activeSort = SortOption.nameAsc;

  @override
  void initState() {
    super.initState();
    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Student> _getFilteredAndSortedStudents(List<Student> sourceList) {
    // 1. Filter by query (Name or Roll Number, Case-Insensitive)
    List<Student> list = sourceList.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.rollNo.toLowerCase().contains(q);
    }).toList();

    // 2. Sort
    list.sort((a, b) {
      switch (_activeSort) {
        case SortOption.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortOption.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case SortOption.rollAsc:
          return a.rollNo.toLowerCase().compareTo(b.rollNo.toLowerCase());
        case SortOption.rollDesc:
          return b.rollNo.toLowerCase().compareTo(a.rollNo.toLowerCase());
        case SortOption.avgDesc:
          return (b.averageMark ?? -1).compareTo(a.averageMark ?? -1);
        case SortOption.avgAsc:
          return (a.averageMark ?? 999).compareTo(b.averageMark ?? 999);
        case SortOption.sem1Desc:
          return (b.sem1 ?? -1).compareTo(a.sem1 ?? -1);
        case SortOption.sem1Asc:
          return (a.sem1 ?? 999).compareTo(b.sem1 ?? 999);
        case SortOption.sem2Desc:
          return (b.sem2 ?? -1).compareTo(a.sem2 ?? -1);
        case SortOption.sem2Asc:
          return (a.sem2 ?? 999).compareTo(b.sem2 ?? 999);
        case SortOption.marks10thDesc:
          return (b.marks10th ?? -1).compareTo(a.marks10th ?? -1);
        case SortOption.marks12thDesc:
          return (b.marks12th ?? -1).compareTo(a.marks12th ?? -1);
      }
    });

    return list;
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'Name: A → Z';
      case SortOption.nameDesc:
        return 'Name: Z → A';
      case SortOption.rollAsc:
        return 'Roll No: Ascending';
      case SortOption.rollDesc:
        return 'Roll No: Descending';
      case SortOption.avgDesc:
        return 'Average: Highest first';
      case SortOption.avgAsc:
        return 'Average: Lowest first';
      case SortOption.sem1Desc:
        return 'Semester 1: High to Low';
      case SortOption.sem1Asc:
        return 'Semester 1: Low to High';
      case SortOption.sem2Desc:
        return 'Semester 2: High to Low';
      case SortOption.sem2Asc:
        return 'Semester 2: Low to High';
      case SortOption.marks10thDesc:
        return '10th Marks: High to Low';
      case SortOption.marks12thDesc:
        return '12th Marks: High to Low';
    }
  }

  void _showSortModal() {
    final surfaceColor = AppTheme.getSurface(context);
    final textPrimary = AppTheme.getTextPrimary(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort Directory By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: SortOption.values.map((option) {
                    final isSelected = _activeSort == option;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(
                        _getSortLabel(option),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.secondaryElectric : textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppTheme.secondaryElectric)
                          : null,
                      onTap: () {
                        setState(() {
                          _activeSort = option;
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentService = Provider.of<StudentService>(context);
    final displayedStudents = _getFilteredAndSortedStudents(studentService.students);
    final surfaceColor = AppTheme.getSurface(context);
    final borderColor = AppTheme.getBorder(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final pillBg = AppTheme.getPillBackground(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar / Search Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: surfaceColor,
              child: Column(
                children: [
                  // Search TextField
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by student name or roll no...',
                      hintStyle: TextStyle(color: textSecondary),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.secondaryElectric),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // Filter / Sort Status Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing ${displayedStudents.length} of ${studentService.totalStudents} student${studentService.totalStudents == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                      InkWell(
                        onTap: _showSortModal,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sort, size: 16, color: AppTheme.secondaryElectric),
                              const SizedBox(width: 6),
                              Text(
                                _getSortLabel(_activeSort),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Demo Mode indicator banner if in demo mode
            if (studentService.isDemoMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: AppTheme.warningOrangeBg,
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, size: 14, color: Color(0xFF92400E)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DEMO DATA: Showing sample department records. Configure API in Settings.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Student List View with RefreshIndicator
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => studentService.fetchStudents(forceRefresh: true),
                color: AppTheme.secondaryElectric,
                child: displayedStudents.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Icon(
                                    _searchQuery.isNotEmpty ? Icons.search_off : Icons.school_outlined,
                                    size: 54,
                                    color: textSecondary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No matching students found'
                                        : 'No student records available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No records match "$_searchQuery". Try checking roll number or spelling.'
                                        : 'Check your Google Sheets API connection or pull to refresh.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    OutlinedButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                      child: const Text('Clear Search Filter'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: displayedStudents.length,
                        itemBuilder: (context, index) {
                          final student = displayedStudents[index];
                          return StudentCard(
                            student: student,
                            maxMarks: studentService.maxMarks,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailsScreen(student: student),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.secondaryElectric,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.compare_arrows_rounded),
        label: const Text('Compare'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CompareScreen(),
            ),
          );
        },
      ),
    );
  }
}
