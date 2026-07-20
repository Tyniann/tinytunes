import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'package_info_provider.g.dart';

/// App [PackageInfo] for Settings About and similar surfaces.
///
/// Purpose: Load version metadata once and allow tests to override without a
/// live platform channel.
/// Usage Context: Watched by Settings; override in widget tests.
@Riverpod(keepAlive: true)
Future<PackageInfo> packageInfo(Ref ref) => PackageInfo.fromPlatform();
