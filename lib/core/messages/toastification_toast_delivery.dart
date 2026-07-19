import 'package:flutter/material.dart';
import 'package:tinytunes/core/messages/toast_delivery.dart';
import 'package:toastification/toastification.dart';

/// Production [ToastDelivery] backed by toastification.
///
/// Purpose: Show short ephemeral feedback without requiring a [BuildContext] at
/// the call site. Requires a root [ToastificationWrapper] in the widget tree.
/// Usage Context: Default Riverpod override for [toastDeliveryProvider].
class ToastificationToastDelivery implements ToastDelivery {
  /// Creates the production toast delivery.
  const ToastificationToastDelivery();

  @override
  void showInfo(String message) {
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  @override
  void showError(String message) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }
}
