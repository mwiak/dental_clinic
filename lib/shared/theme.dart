import 'package:fluent_ui/fluent_ui.dart';

//file for defining dark and light themes values
FluentThemeData lightMode = FluentThemeData(
  brightness: Brightness.light,
  accentColor: Colors.purple,
  cardColor: Color(0xFFE8EAF6),
);

FluentThemeData darkMode = FluentThemeData(
  brightness: Brightness.dark,
  accentColor: Colors.orange,
  navigationPaneTheme:
      NavigationPaneThemeData(backgroundColor: Color(0xFF1C1F26)),

  scaffoldBackgroundColor: Color(0xFF1C1F26), // Deep blue-gray background

  micaBackgroundColor:
      Color(0xFF2A2F3A), // Slightly lighter dark blue-gray for panels and cards
  shadowColor: Color(0xFF000000), // Dark shadows (but not pure black)
  inactiveBackgroundColor:
      Color(0xFF383F49), // Muted blue-gray for inactive elements
  inactiveColor:
      Color(0xFF9A9A9A), // Subtle inactive text/icons in lighter gray
  // Soft blue-gray borders
  cardColor: Color(0xFF212731), // Dark card background with blue tint
  typography: Typography.raw(
    display: TextStyle(color: Color(0xFFE0E0E0)), // Light gray text for headers
    title: TextStyle(
        color: Color(0xFFE0E0E0), fontSize: 26), // Titles and emphasized text
    body: TextStyle(color: Color(0xFFD1D1D1)), // Regular body text
    caption:
        TextStyle(color: Color(0xFFB0B0B0)), // Captions and less important text
  ),

  // Cards and containers
);

//constants
double fontSizeForTextBox = 20;
double fontSizeForLargeTextBox = 14;
