import 'package:fluent_ui/fluent_ui.dart';

class BasicFlyout extends StatelessWidget {
  final String warning;
  final Function onProceed;
  final String buttonText;
  final String action;
  BasicFlyout(
      {super.key,
      required this.warning,
      required this.onProceed,
      required this.action,
      required this.buttonText});
  final FlyoutController controller = FlyoutController();
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
        controller: controller,
        child: FilledButton(
          style: ButtonStyle(
            backgroundColor: ButtonState.resolveWith<Color>((states) {
              if (states.isHovering) {
                return Color(0x96FF0000);
              }
              // Deeper red when hovering
              return Color(0xE7AC2929); // Default red
            }),
          ),
          child: Text(buttonText),
          onPressed: () {
            controller.showFlyout(
              autoModeConfiguration: FlyoutAutoConfiguration(
                preferredMode: FlyoutPlacementMode.topCenter,
              ),
              barrierDismissible: true,
              dismissOnPointerMoveAway: false,
              dismissWithEsc: true,
              navigatorKey: rootNavigatorKey.currentState,
              builder: (context) {
                return FlyoutContent(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        warning,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12.0),
                      Button(
                        onPressed: () {
                          Flyout.of(context).close();
                          onProceed();
                        },
                        child: Text(action),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ));
  }
}
