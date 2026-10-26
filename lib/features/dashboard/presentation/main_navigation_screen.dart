import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/account_screen.dart';
import '../../incidents/domain/incident_status.dart';
import '../../incidents/presentation/incident_list_screen.dart';
import '../../incidents/presentation/report_incident_screen.dart';
import '../../profile/domain/user_profile.dart';
import 'dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selected = 0;
  int _reportVersion = 0;
  bool _onlyMine = false;
  IncidentStatus? _status;

  void _openReportForm() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportIncidentScreen(reporter: widget.profile),
      ),
    );
  }

  void _openReports({bool onlyMine = false, IncidentStatus? status}) {
    setState(() {
      _onlyMine = onlyMine;
      _status = status;
      _reportVersion++;
      _selected = 1;
    });
  }

  void _select(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (index == 2) {
      _openReportForm();
    } else {
      setState(() => _selected = index);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: _selected == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _select(0);
    },
    child: Scaffold(
      body: IndexedStack(
        index: _selected == 3 ? 2 : _selected,
        children: [
          TickerMode(
            enabled: _selected == 0,
            child: DashboardScreen(
              profile: widget.profile,
              onReport: _openReportForm,
              onProfile: () => _select(3),
              onBrowse: () => _openReports(),
              onMyReports: (status) =>
                  _openReports(onlyMine: true, status: status),
            ),
          ),
          TickerMode(
            enabled: _selected == 1,
            child: IncidentListScreen(
              key: ValueKey(_reportVersion),
              viewer: widget.profile,
              initiallyOnlyMine: _onlyMine,
              initialStatus: _status,
            ),
          ),
          TickerMode(
            enabled: _selected == 3,
            child: AccountScreen(
              onBrowseReports: () => _openReports(),
              onReportIncident: _openReportForm,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _selected,
          onDestinationSelected: _select,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.yellow,
          height: 76,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description_rounded),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.yellow,
                child: Icon(Icons.add_rounded, color: AppColors.ink),
              ),
              label: 'Report',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    ),
  );
}
