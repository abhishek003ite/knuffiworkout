import 'package:flutter/material.dart';
import 'package:knuffiworkout/src/app_drawer.dart';
import 'package:knuffiworkout/src/db/exercise.dart' as exercise_db;
import 'package:knuffiworkout/src/db/rotation.dart' as rotation_db;
import 'package:knuffiworkout/src/plan/exercises_view.dart';
import 'package:knuffiworkout/src/plan/rotation_view.dart';
import 'package:knuffiworkout/src/progress/progress_view.dart';
import 'package:knuffiworkout/src/widgets/colors.dart';
import 'package:knuffiworkout/src/workout/current_view.dart';
import 'package:knuffiworkout/src/workout/past_view.dart';
import 'package:meta/meta.dart';

/// A screen that shows either the current workout or past workouts, selectable
/// via a drawer.
class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<_View> _views;
  List<DrawerItem> _drawerItems;
  _View _currentView;

  @override
  void initState() {
    super.initState();
    _views = <_View>[
      _View(
        "Current workout",
        _DrawerConfig(icon: Icons.assignment, hasDividerAfter: true),
        (_) => CurrentView(),
      ),
      _View(
        "Past workouts",
        _DrawerConfig(icon: Icons.assignment_turned_in),
        (_) => PastView(),
      ),
      _View(
        "Progress",
        _DrawerConfig(icon: Icons.equalizer, hasDividerAfter: true),
        (_) => ProgressView(),
      ),
      _View(
        "Exercises",
        _DrawerConfig(icon: Icons.settings),
        (_) => PlanExercisesView(),
        fabBuilder: (_) => renderFab(onPressed: () {
              exercise_db.createNew();
            }),
      ),
      _View(
        "Rotation",
        _DrawerConfig(icon: Icons.event),
        (_) => RotationView(),
        fabBuilder: (_) => renderFab(onPressed: () {
              rotation_db.newDay();
            }),
      ),
    ];
    _drawerItems = _views.map(_createDrawerItem).toList();

    _currentView = _views.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(_currentView.title)),
        drawer: AppDrawer(_drawerItems),
        body: _currentView.builder(context),
        floatingActionButton: _currentView.fabBuilder == null
            ? null
            : _currentView.fabBuilder(context));
  }

  DrawerItem _createDrawerItem(_View view) => DrawerItem(
        view.drawerConfig.icon,
        view.title,
        onTap: () {
          setState(() {
            if (view == _currentView) return;
            _currentView = view;
            // Close the drawer.
            Navigator.pop(context);
          });
        },
        isSelected: view == _currentView,
        hasDividerAfter: view.drawerConfig.hasDividerAfter,
      );
}

/// A View in the [MainScreen].
class _View {
  /// Title of the view in the app bar.
  final String title;

  /// How to render this view in the app drawer.
  final _DrawerConfig drawerConfig;

  /// [WidgetBuilder] that builds the view.
  final WidgetBuilder builder;

  /// How to render a FAB for the view, if any.
  final _FabBuilder fabBuilder;

  _View(this.title, this.drawerConfig, this.builder, {this.fabBuilder});
}

/// Configuration of how the view should be shown in the app drawer.
class _DrawerConfig {
  final IconData icon;
  final bool hasDividerAfter;

  _DrawerConfig({@required this.icon, this.hasDividerAfter = false});
}

/// Renders a floating plus button (FAB).
FloatingActionButton renderFab({VoidCallback onPressed}) =>
    FloatingActionButton(
        backgroundColor: fabColor,
        child: Icon(Icons.add),
        onPressed: onPressed);

typedef FloatingActionButton _FabBuilder(BuildContext context);
