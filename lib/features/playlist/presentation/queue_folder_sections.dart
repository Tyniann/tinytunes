import 'package:tinytunes/core/database/catalog_dao.dart';

/// Consecutive queue rows that share a containing folder.
///
/// Purpose: Drive sticky section headers without embedding grouping in the
/// list widget. [firstIndex] is the index of [tracks].first in the full queue.
class QueueFolderSection {
  /// Creates a folder run starting at [firstIndex].
  const QueueFolderSection({
    required this.folderName,
    required this.tracks,
    required this.firstIndex,
  });

  /// Sticky header label (parent folder, else library root).
  final String folderName;

  /// Queue rows in this folder run, in canonical order.
  final List<QueueTrackView> tracks;

  /// Index of the first row in the ungrouped queue.
  final int firstIndex;
}

/// Groups [queue] into consecutive runs of the same containing folder.
///
/// Purpose: Keep CD / chapter boundaries visible while leaving shuffle's
/// canonical `sortIndex` order unchanged. Adjacent roots with the same folder
/// name stay separate sections.
List<QueueFolderSection> groupQueueByContainingFolder(
  List<QueueTrackView> queue,
) {
  if (queue.isEmpty) return const [];
  final sections = <QueueFolderSection>[];
  var start = 0;
  var key = queue.first.folderSectionKey;
  for (var i = 1; i <= queue.length; i++) {
    final nextKey = i < queue.length ? queue[i].folderSectionKey : null;
    if (nextKey == key) continue;
    sections.add(
      QueueFolderSection(
        folderName: queue[start].containingFolderName,
        tracks: queue.sublist(start, i),
        firstIndex: start,
      ),
    );
    start = i;
    key = nextKey ?? '';
  }
  return sections;
}
