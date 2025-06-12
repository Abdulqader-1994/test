import 'package:ailence/main/utils/app_vars.dart';
import 'package:flutter/material.dart';

ButtonStyle drawerBtnStyle({bool isActive = false}) {
  return ButtonStyle(
    padding: WidgetStateProperty.all(const EdgeInsets.all(10)),
    backgroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) return Colors.white.withValues(alpha: 0.3);
        if (states.contains(WidgetState.pressed)) return Colors.white.withValues(alpha: 0.5);
        return isActive ? Colors.green[900] : Colors.transparent;
      },
    ),
    overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return states.contains(WidgetState.pressed) ? Colors.white.withValues(alpha: 0.2) : null;
    }),
    elevation: WidgetStateProperty.all(0),
    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
  );
}

var deepBlueBtnStyle = ButtonStyle(
  padding: WidgetStateProperty.all(const EdgeInsets.all(10)),
  backgroundColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.hovered)) return background.withValues(alpha: 0.7);
      if (states.contains(WidgetState.pressed)) return background.withValues(alpha: 0.7);
      return background;
    },
  ),
  overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
    return states.contains(WidgetState.pressed) ? background.withValues(alpha: 0.7) : null;
  }),
  elevation: WidgetStateProperty.all(0),
  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
);
