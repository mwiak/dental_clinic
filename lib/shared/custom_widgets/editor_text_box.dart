import 'package:fluent_ui/fluent_ui.dart';
import '../modified_widgets/text_box.dart' as ct;
import 'package:flutter/material.dart' as m;

class EditorTextBox extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isEditing;
  const EditorTextBox(
      {super.key,
      required this.controller,
      required this.label,
      required this.isEditing});

  @override
  State<EditorTextBox> createState() => _EditorTextBoxState();
}

class _EditorTextBoxState extends State<EditorTextBox> {
  bool _contextMenuShown = false;
  OverlayEntry? _contextMenuEntry;

  //
  //
  //

  void showContextMenuAtOffset2(
    BuildContext context,
    Offset tapPosition,
    EditableTextState editableTextState,
  ) {
    if (_contextMenuShown) return; // 🛑 Already showing
    _contextMenuShown = true;

    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                entry.remove();
                _contextMenuShown = false;
                _contextMenuEntry = null;
              },
            ),
            Positioned(
              top: tapPosition.dy,
              left: tapPosition.dx - 160,
              child: _AnimatedContextMenu(
                onClose: () {
                  entry.remove();
                  _contextMenuShown = false;
                  _contextMenuEntry = null;
                },
                editableTextState: editableTextState,
              ),
            ),
          ],
        );
      },
    );

    _contextMenuEntry = entry;
    overlay.insert(entry);
  }

  void showContextMenuAtOffset3(
    BuildContext context,
    Offset tapPosition,
    EditableTextState editableTextState,
  ) {
    if (_contextMenuShown) return; // 🛑 Already showing
    _contextMenuShown = true;

    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                entry.remove();
                _contextMenuShown = false;
                _contextMenuEntry = null;
              },
            ),
            Positioned(
              top: tapPosition.dy,
              left: tapPosition.dx - 160,
              child: AnimatedNoTextContextMenu(
                onClose: () {
                  entry.remove();
                  _contextMenuShown = false;
                  _contextMenuEntry = null;
                },
                editableTextState: editableTextState,
              ),
            ),
          ],
        );
      },
    );

    _contextMenuEntry = entry;
    overlay.insert(entry);
  }

  void _showContextMenu(
    BuildContext context,
    Offset tapPosition,
    EditableTextState editableTextState,
    bool hasTextSelected, // New parameter to determine which menu to show
  ) {
    if (_contextMenuShown) return;
    _contextMenuShown = true;

    final overlay = Overlay.of(context);
    final BuildContext? overlayContext = overlay.context;
    if (overlayContext == null) return; // Guard against null context

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Listener(
          // Use Listener to capture pointer events at a low level
          onPointerDown: (event) {
            // Check if the tap occurred outside the context menu itself
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final Size size = renderBox.size;
            final Offset localPosition =
                renderBox.globalToLocal(event.position);

            if (!Rect.fromLTWH(0, 0, size.width, size.height)
                .contains(localPosition)) {
              entry.remove();
              _contextMenuShown = false;
              _contextMenuEntry = null;
            }
          },
          child: Stack(
            children: [
              // The transparent GestureDetector ensures the area outside the menu
              // is still tappable, but the Listener above will handle the dismissal.
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  // This onTap is a fallback or for general hit testing.
                  // The Listener above is more precise for dismissal.
                },
              ),
              Positioned(
                top: tapPosition.dy,
                left: tapPosition.dx - 160,
                child: hasTextSelected
                    ? _AnimatedContextMenu(
                        onClose: () {
                          entry.remove();
                          _contextMenuShown = false;
                          _contextMenuEntry = null;
                        },
                        editableTextState: editableTextState,
                      )
                    : AnimatedNoTextContextMenu(
                        onClose: () {
                          entry.remove();
                          _contextMenuShown = false;
                          _contextMenuEntry = null;
                        },
                        editableTextState: editableTextState,
                      ),
              ),
            ],
          ),
        );
      },
    );

    _contextMenuEntry = entry;
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.label),
        SizedBox(
          height: 10,
        ),
        ct.TextBox(
          controller: widget.controller,
          enabled: widget.isEditing,
          contextMenuBuilder: (context, editableTextState) {
            final selection = editableTextState.textEditingValue.selection;
            final bool isTextEmpty =
                editableTextState.textEditingValue.text.isEmpty;
            final bool isSelectionCollapsed = selection.isCollapsed;

            // If a custom context menu is already shown, let it handle its state.
            // This prevents multiple context menus from appearing.
            if (_contextMenuShown) {
              return const SizedBox.shrink();
            }

            // Determine if we should show the "no text" menu or the standard menu.
            // The primaryAnchor is generally where the default context menu would appear.
            final offset = editableTextState.contextMenuAnchors.primaryAnchor;

            // If text is empty, or selection is collapsed (no text selected), show the "no text" menu.
            if (isTextEmpty || isSelectionCollapsed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showContextMenu(context, offset, editableTextState,
                    false); // false for no text selected
              });
              return const SizedBox.shrink(); // Hide the default menu
            } else {
              // If text is selected, show the standard context menu.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showContextMenu(context, offset, editableTextState,
                    true); // true for text selected
              });
              return const SizedBox.shrink(); // Hide the default menu
            }
          },
          autofillHints: ['المريض يعاني من داء', 'المريضة ليست في حالة جيدة'],
          minLines: 7,
          maxLines: 10,
        )
      ],
    );
  }
}

class _AnimatedContextMenu extends StatefulWidget {
  final VoidCallback onClose;
  final EditableTextState editableTextState;

  const _AnimatedContextMenu({
    required this.onClose,
    required this.editableTextState,
  });

  @override
  State<_AnimatedContextMenu> createState() => _AnimatedContextMenuState();
}

class _AnimatedContextMenuState extends State<_AnimatedContextMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItem(String label, IconData icon, VoidCallback action) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;
          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: GestureDetector(
              onTap: () {
                action();
                widget.onClose();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14),
                    const SizedBox(width: 6),
                    Text(label, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        alignment: Alignment.topRight,
        child: m.Material(
          color: const Color(0xFFACACAC),
          borderRadius: BorderRadius.circular(8),
          elevation: 8,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildItem('نسخ', FluentIcons.copy, () {
                    widget.editableTextState
                        .copySelection(SelectionChangedCause.tap);
                  }),
                  _buildItem('لصق', FluentIcons.paste, () {
                    widget.editableTextState
                        .pasteText(SelectionChangedCause.tap);
                  }),
                  _buildItem('قص', FluentIcons.cut, () {
                    widget.editableTextState
                        .cutSelection(SelectionChangedCause.tap);
                  }),
                  const Divider(),
                  _buildItem('مسح', FluentIcons.clear, () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedNoTextContextMenu extends StatefulWidget {
  final VoidCallback onClose;
  final EditableTextState editableTextState;

  const AnimatedNoTextContextMenu({
    required this.onClose,
    required this.editableTextState,
  });

  @override
  State<AnimatedNoTextContextMenu> createState() =>
      AnimatedNoTextContextMenuState();
}

class AnimatedNoTextContextMenuState extends State<AnimatedNoTextContextMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItem(String label, IconData icon, VoidCallback action) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;
          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: GestureDetector(
              onTap: () {
                action();
                widget.onClose();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14),
                    const SizedBox(width: 6),
                    Text(label, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        alignment: Alignment.topRight,
        child: m.Material(
          color: const Color(0xFFACACAC),
          borderRadius: BorderRadius.circular(8),
          elevation: 8,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildItem('إدراج اختصار', FluentIcons.pen_workspace, () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
