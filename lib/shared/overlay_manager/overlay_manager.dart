import 'package:fluent_ui/fluent_ui.dart';

class FloatingMenuManager {
  static final FloatingMenuManager _instance = FloatingMenuManager._internal();

  factory FloatingMenuManager() => _instance;

  FloatingMenuManager._internal();

  LayerLink? _layerLink;
  OverlayEntry? _entry;

  void show({
    required BuildContext context,
    required RenderBox target,
    required Widget menu,
  }) {
    remove(); // Remove any existing overlay

    final overlay = Overlay.of(context);
    final targetPosition = target.localToGlobal(Offset.zero);
    final targetSize = target.size;

    _layerLink = LayerLink();

    _entry = OverlayEntry(
      builder: (context) => Positioned(
        top: targetPosition.dy + targetSize.height,
        left: targetPosition.dx,
        child: CompositedTransformFollower(
          link: _layerLink!,
          offset: Offset(0, 4),
          child: FlyoutContent(
            child: Acrylic(
              tint: FluentTheme.of(context).accentColor,
              child: menu,
            ),
          ),
        ),
      ),
    );

    overlay.insert(_entry!);
  }

  void remove() {
    _entry?.remove();
    _entry = null;
    _layerLink = null;
  }

  bool get isShowing => _entry != null;
}
