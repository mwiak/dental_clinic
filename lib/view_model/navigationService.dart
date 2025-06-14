import 'package:fluent_ui/fluent_ui.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static BuildContext? _overlayContext;
  static void setOverlayContext(BuildContext ctx) => _overlayContext = ctx;

  static BuildContext? get overlayContext => _overlayContext;
}
