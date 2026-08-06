import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Small queue-row cover loaded from an on-device artwork file.
///
/// Purpose: Show capped JPEG beside remove without a generic placeholder.
/// Usage Context: Playlist home [ListTile] trailing cluster, left of remove.
/// Key Params: [path] absolute `artworkCacheRef` file path.
class QueueCoverThumb extends StatefulWidget {
  /// Creates a thumb for the artwork file at [path].
  const QueueCoverThumb({super.key, required this.path});

  /// Absolute path to the capped cover JPEG.
  final String path;

  @override
  State<QueueCoverThumb> createState() => _QueueCoverThumbState();
}

class _QueueCoverThumbState extends State<QueueCoverThumb> {
  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant QueueCoverThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _bytes = null;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final bytes = await File(widget.path).readAsBytes();
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _failed = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _bytes = null;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    final bytes = _bytes;
    if (bytes == null) {
      // Reserve slot while reading so title does not jump when art arrives.
      return const SizedBox(width: 48, height: 48);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.memory(
        bytes,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
