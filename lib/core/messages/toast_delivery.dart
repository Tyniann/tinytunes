/// Context-free toast delivery seam for [MessageReporter].
///
/// Purpose: Let production show toastification while tests inject a noop so
/// assertions target store/badge/list, not overlay pixels.
/// Usage Context: Wired via Riverpod; called only from [MessageReporter].
abstract class ToastDelivery {
  /// Shows a short info toast for [message].
  void showInfo(String message);

  /// Shows a short error toast for [message].
  void showError(String message);
}

/// No-op [ToastDelivery] for unit and widget tests.
class NoopToastDelivery implements ToastDelivery {
  /// Creates a delivery that discards all toast requests.
  const NoopToastDelivery();

  @override
  void showInfo(String message) {}

  @override
  void showError(String message) {}
}
