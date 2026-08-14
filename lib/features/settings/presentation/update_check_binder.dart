import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinytunes/core/routing/app_router.dart';
import 'package:tinytunes/core/settings/package_info_provider.dart';
import 'package:tinytunes/core/updates/github_release.dart';
import 'package:tinytunes/core/updates/update_providers.dart';
import 'package:tinytunes/features/settings/presentation/update_available_dialog.dart';

/// Runs a scheduled GitHub update check after first frame and shows a dialog.
///
/// Purpose: Keep the latest-release prompt out of [main] while still checking
/// once per cold start (subject to the 24h interval). Failures stay silent.
/// Usage Context: Wrap [MaterialApp.router]'s `builder` child in [TinyTunesApp].
/// Key Params: [child] — the navigator subtree under the app overlay.
class UpdateCheckBinder extends ConsumerStatefulWidget {
  /// Creates a binder around [child].
  const UpdateCheckBinder({required this.child, super.key});

  /// Navigator / router subtree.
  final Widget child;

  @override
  ConsumerState<UpdateCheckBinder> createState() => _UpdateCheckBinderState();
}

class _UpdateCheckBinderState extends ConsumerState<UpdateCheckBinder> {
  var _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(updateCheckControllerProvider.notifier).checkScheduled(),
      );
    });
  }

  Future<void> _prompt(GithubRelease release) async {
    if (_dialogOpen || !mounted) return;
    _dialogOpen = true;
    final info = await ref.read(packageInfoProvider.future);
    if (!mounted) {
      _dialogOpen = false;
      return;
    }
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) {
      _dialogOpen = false;
      return;
    }
    final choice = await showUpdateAvailableDialog(
      context: navContext,
      release: release,
      installedVersion: info.version,
    );
    if (!mounted) {
      _dialogOpen = false;
      return;
    }
    if (choice == UpdateAvailableChoice.later) {
      await ref.read(updateCheckControllerProvider.notifier).dismissTag(
        release.tagName,
      );
    }
    _dialogOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(updateCheckControllerProvider, (previous, next) {
      final release = next.release;
      if (release == null) return;
      if (previous?.release == release) return;
      unawaited(_prompt(release));
    });
    return widget.child;
  }
}
