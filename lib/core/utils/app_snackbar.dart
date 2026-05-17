import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final theme = Theme.of(context);
  final background =
      isError ? theme.colorScheme.error : theme.colorScheme.primary;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: background,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

