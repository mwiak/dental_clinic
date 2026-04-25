import 'package:dental_clinic/shared/custom_widgets/shortcuts_sidemenu.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../modified_widgets/text_box.dart' as ct;
import 'package:flutter/material.dart' as m;

import '../overlay_manager/overlay_manager.dart';

class EditorTextBoxExp extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isEditing;
  const EditorTextBoxExp({
    super.key,
    required this.controller,
    required this.label,
    required this.isEditing,
  });

  @override
  State<EditorTextBoxExp> createState() => _EditorTextBoxExpState();
}

class _EditorTextBoxExpState extends State<EditorTextBoxExp> {
  bool _contextMenuShown = false;
  OverlayEntry? _contextMenuEntry;

  // Centralized method to dismiss the context menu
  void _dismissContextMenu() {
    if (_contextMenuEntry != null) {
      _contextMenuEntry!.remove();
      _contextMenuEntry = null;
      _contextMenuShown = false;
    }
  }

  void _showContextMenu(
    BuildContext context,
    Offset tapPosition,
    EditableTextState editableTextState,
    bool hasTextSelected,
  ) {
    if (_contextMenuShown) return; // Prevent showing multiple menus
    _contextMenuShown = true;

    final overlay = Overlay.of(context);

    _contextMenuEntry = OverlayEntry(
      builder: (context) {
        // We use a Stack.expand() here to ensure the stack itself
        // covers the entire overlay area.
        return Stack(
          children: [
            // This GestureDetector covers the entire screen behind the menu
            // and dismisses the menu when tapped. It uses opaque behavior
            // to ensure it captures all taps.
            GestureDetector(
              behavior: HitTestBehavior.opaque, // Changed to opaque
              onTap:
                  _dismissContextMenu, // Dismiss when anything outside menu is tapped
              child: const SizedBox.expand(), // Make it cover the whole screen
            ),
            // Position the actual context menu widget
            Positioned(
              top: tapPosition.dy,
              left: tapPosition.dx - 160, // Adjust position as needed
              child: hasTextSelected
                  ? _AnimatedContextMenu(
                      onClose:
                          _dismissContextMenu, // Menu item actions also dismiss
                      editableTextState: editableTextState,
                    )
                  : AnimatedNoTextContextMenu(
                      onClose:
                          _dismissContextMenu, // Menu item actions also dismiss
                      editableTextState: editableTextState,
                      controller: widget.controller,
                    ),
            ),
          ],
        );
      },
    );

    overlay.insert(_contextMenuEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.label),
        const SizedBox(
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

            // If a custom context menu is already shown, do nothing.
            if (_contextMenuShown) {
              return const SizedBox.shrink();
            }

            final offset = editableTextState.contextMenuAnchors.primaryAnchor;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_contextMenuShown) {
                // Double check before showing
                if (isTextEmpty || isSelectionCollapsed) {
                  _showContextMenu(context, offset, editableTextState, false);
                } else {
                  _showContextMenu(context, offset, editableTextState, true);
                }
              }
            });

            return const SizedBox.shrink(); // Always hide default context menu
          },
          autofillHints: const [
            'المريض يعاني من داء',
            'المريضة ليست في حالة جيدة'
          ],
          minLines: 7,
          maxLines: 10,
        )
      ],
    );
  }
}

// Keep _AnimatedContextMenu and AnimatedNoTextContextMenu exactly as they were in the last response.
// They correctly call widget.onClose(), which now links to _dismissContextMenu.

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
                widget.onClose(); // Crucial: Call onClose to dismiss the menu
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isHovered
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(label,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
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
  final TextEditingController controller;

  const AnimatedNoTextContextMenu({
    required this.onClose,
    required this.editableTextState,
    required this.controller,
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
                widget.onClose(); // Crucial: Call onClose to dismiss the menu
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isHovered
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(label,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
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
                  _buildItem('إدراج اختصار', FluentIcons.pen_workspace, () {
                    // Implement your "insert shortcut" logic here
                    final renderBox = context.findRenderObject() as RenderBox;
                    FloatingMenuManager().show(
                        context: context,
                        target: renderBox,
                        menu: ShortcutsSidemenu(
                          onClose: () {
                            FloatingMenuManager().remove();
                          },
                          controller: widget.controller,
                        ));
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
