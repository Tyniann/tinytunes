// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Production [ToastDelivery]; override with [NoopToastDelivery] in tests.

@ProviderFor(toastDelivery)
final toastDeliveryProvider = ToastDeliveryProvider._();

/// Production [ToastDelivery]; override with [NoopToastDelivery] in tests.

final class ToastDeliveryProvider
    extends $FunctionalProvider<ToastDelivery, ToastDelivery, ToastDelivery>
    with $Provider<ToastDelivery> {
  /// Production [ToastDelivery]; override with [NoopToastDelivery] in tests.
  ToastDeliveryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toastDeliveryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toastDeliveryHash();

  @$internal
  @override
  $ProviderElement<ToastDelivery> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ToastDelivery create(Ref ref) {
    return toastDelivery(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToastDelivery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToastDelivery>(value),
    );
  }
}

String _$toastDeliveryHash() => r'00421490a9b0d26834a233c4a2d362272e58063c';

/// Session message mutations; state is a monotonic revision for listeners.
///
/// Purpose: Bump revision on add/mark-read so unread badge updates even when
/// the message list contents are unchanged (watermark-only updates).

@ProviderFor(SessionMessages)
final sessionMessagesProvider = SessionMessagesProvider._();

/// Session message mutations; state is a monotonic revision for listeners.
///
/// Purpose: Bump revision on add/mark-read so unread badge updates even when
/// the message list contents are unchanged (watermark-only updates).
final class SessionMessagesProvider
    extends $NotifierProvider<SessionMessages, int> {
  /// Session message mutations; state is a monotonic revision for listeners.
  ///
  /// Purpose: Bump revision on add/mark-read so unread badge updates even when
  /// the message list contents are unchanged (watermark-only updates).
  SessionMessagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionMessagesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionMessagesHash();

  @$internal
  @override
  SessionMessages create() => SessionMessages();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sessionMessagesHash() => r'a7b3d5489e1353db6864b932cb84e499b8afef93';

/// Session message mutations; state is a monotonic revision for listeners.
///
/// Purpose: Bump revision on add/mark-read so unread badge updates even when
/// the message list contents are unchanged (watermark-only updates).

abstract class _$SessionMessages extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Derived unread count for the home app-bar badge.

@ProviderFor(unreadMessageCount)
final unreadMessageCountProvider = UnreadMessageCountProvider._();

/// Derived unread count for the home app-bar badge.

final class UnreadMessageCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Derived unread count for the home app-bar badge.
  UnreadMessageCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadMessageCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadMessageCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return unreadMessageCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadMessageCountHash() =>
    r'ed22ac27d2de22b1ef23edd7d770edc03263dd7f';

/// Newest-first messages for the Messages screen.

@ProviderFor(sessionMessagesNewestFirst)
final sessionMessagesNewestFirstProvider =
    SessionMessagesNewestFirstProvider._();

/// Newest-first messages for the Messages screen.

final class SessionMessagesNewestFirstProvider
    extends
        $FunctionalProvider<
          List<SessionMessage>,
          List<SessionMessage>,
          List<SessionMessage>
        >
    with $Provider<List<SessionMessage>> {
  /// Newest-first messages for the Messages screen.
  SessionMessagesNewestFirstProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionMessagesNewestFirstProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionMessagesNewestFirstHash();

  @$internal
  @override
  $ProviderElement<List<SessionMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SessionMessage> create(Ref ref) {
    return sessionMessagesNewestFirst(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SessionMessage> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SessionMessage>>(value),
    );
  }
}

String _$sessionMessagesNewestFirstHash() =>
    r'be0c9693241fbde4218b9fcd7bad05fb4f65f80a';

/// Context-free [MessageReporter] for UI and controllers.

@ProviderFor(messageReporter)
final messageReporterProvider = MessageReporterProvider._();

/// Context-free [MessageReporter] for UI and controllers.

final class MessageReporterProvider
    extends
        $FunctionalProvider<MessageReporter, MessageReporter, MessageReporter>
    with $Provider<MessageReporter> {
  /// Context-free [MessageReporter] for UI and controllers.
  MessageReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageReporterHash();

  @$internal
  @override
  $ProviderElement<MessageReporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MessageReporter create(Ref ref) {
    return messageReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageReporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageReporter>(value),
    );
  }
}

String _$messageReporterHash() => r'0fd2497197589340291135ea9b76acaa3a3ae338';
