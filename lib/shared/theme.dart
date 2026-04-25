import 'package:fluent_ui/fluent_ui.dart';

//file for defining dark and light themes values
final FluentThemeData lightMode = FluentThemeData(
  brightness: Brightness.light,

  accentColor: AccentColor.swatch(
    {
      'darkest': Color(0xFFEBA8B8), // soft medium pink
      'darker': Color(0xFFF0B7C1), // lighter medium pink
      'dark': Color(0xFFF5C5CA), // soft pink
      'normal': Color(0xFFF9D4D3), // pastel pink - your main accent
      'light': Color(0xFFFCDDE0), // very light pink
      'lighter': Color(0xFFFFE9EC), // near white pink
      'lightest': Color(0xFFFFF5F6), // almost white
    },
  ),
  // Soft, warm pink accent for primary actions and highlights

  // Background of cards/panels
  cardColor: const Color(0xFFFFF1F4), // Light blush pink

  // Background of the app's scaffold
  // scaffoldBackgroundColor: const Color(0xFFFFFBFC), // Slightly warmer white

  // Optional: general window background color
  // backgroundColor: const Color(0xFFFFF5F7),

  // Optional: consistent text styling
  typography: Typography.raw(
    display: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black, // global text color
    ),
    title: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    body: TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
  ),

  visualDensity: VisualDensity.standard,
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
