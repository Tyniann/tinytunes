import 'package:flutter_test/flutter_test.dart';
import 'package:tinytunes/core/database/catalog_dao.dart';
import 'package:tinytunes/features/playlist/presentation/queue_folder_sections.dart';

void main() {
  QueueTrackView row({
    required int id,
    required int rootId,
    required String folder,
    String? parent,
  }) {
    return QueueTrackView(
      queueEntryId: id,
      trackId: id,
      sortIndex: id,
      displayName: '$id.mp3',
      locator: '$id',
      rootId: rootId,
      rootDisplayName: folder,
      parentFolderName: parent,
    );
  }

  test('empty queue yields no sections', () {
    expect(groupQueueByContainingFolder(const []), isEmpty);
  });

  test('consecutive same folder is one section', () {
    final queue = [
      row(id: 1, rootId: 1, folder: 'Book', parent: 'CD 1'),
      row(id: 2, rootId: 1, folder: 'Book', parent: 'CD 1'),
      row(id: 3, rootId: 1, folder: 'Book', parent: 'CD 2'),
    ];

    final sections = groupQueueByContainingFolder(queue);
    expect(sections, hasLength(2));
    expect(sections[0].folderName, 'CD 1');
    expect(sections[0].tracks, hasLength(2));
    expect(sections[0].firstIndex, 0);
    expect(sections[1].folderName, 'CD 2');
    expect(sections[1].firstIndex, 2);
  });

  test('same folder name in different roots stays two sections', () {
    final queue = [
      row(id: 1, rootId: 1, folder: 'Book A', parent: 'CD 1'),
      row(id: 2, rootId: 2, folder: 'Book B', parent: 'CD 1'),
    ];

    final sections = groupQueueByContainingFolder(queue);
    expect(sections, hasLength(2));
    expect(sections[0].folderName, 'CD 1');
    expect(sections[1].folderName, 'CD 1');
  });

  test('missing parent folder falls back to library root name', () {
    final queue = [row(id: 1, rootId: 1, folder: 'Music')];
    expect(groupQueueByContainingFolder(queue).single.folderName, 'Music');
  });
}
