// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LibraryRootsTable extends LibraryRoots
    with TableInfo<$LibraryRootsTable, LibraryRoot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryRootsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _locatorMeta = const VerificationMeta(
    'locator',
  );
  @override
  late final GeneratedColumn<String> locator = GeneratedColumn<String>(
    'locator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceKindMeta = const VerificationMeta(
    'sourceKind',
  );
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _cloudProviderMeta = const VerificationMeta(
    'cloudProvider',
  );
  @override
  late final GeneratedColumn<String> cloudProvider = GeneratedColumn<String>(
    'cloud_provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudAccountKeyMeta = const VerificationMeta(
    'cloudAccountKey',
  );
  @override
  late final GeneratedColumn<String> cloudAccountKey = GeneratedColumn<String>(
    'cloud_account_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    locator,
    displayName,
    sourceKind,
    cloudProvider,
    cloudAccountKey,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_roots';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryRoot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('locator')) {
      context.handle(
        _locatorMeta,
        locator.isAcceptableOrUnknown(data['locator']!, _locatorMeta),
      );
    } else if (isInserting) {
      context.missing(_locatorMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('source_kind')) {
      context.handle(
        _sourceKindMeta,
        sourceKind.isAcceptableOrUnknown(data['source_kind']!, _sourceKindMeta),
      );
    }
    if (data.containsKey('cloud_provider')) {
      context.handle(
        _cloudProviderMeta,
        cloudProvider.isAcceptableOrUnknown(
          data['cloud_provider']!,
          _cloudProviderMeta,
        ),
      );
    }
    if (data.containsKey('cloud_account_key')) {
      context.handle(
        _cloudAccountKeyMeta,
        cloudAccountKey.isAcceptableOrUnknown(
          data['cloud_account_key']!,
          _cloudAccountKeyMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryRoot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryRoot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      locator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      sourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_kind'],
      )!,
      cloudProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_provider'],
      ),
      cloudAccountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_account_key'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $LibraryRootsTable createAlias(String alias) {
    return $LibraryRootsTable(attachedDatabase, alias);
  }
}

class LibraryRoot extends DataClass implements Insertable<LibraryRoot> {
  /// Auto-increment primary key.
  final int id;

  /// Opaque root [MediaLocator] string (tree URI on Android); unique.
  final String locator;

  /// Best-effort folder label (decoded URI segment).
  final String displayName;

  /// Catalog source kind; Phase 2 always writes `local`.
  final String sourceKind;

  /// Cloud provider token (`gdrive` / `onedrive`); null for local roots.
  final String? cloudProvider;

  /// Stable provider account id owning this root; null until first bind.
  final String? cloudAccountKey;

  /// When the root was first added.
  final DateTime addedAt;
  const LibraryRoot({
    required this.id,
    required this.locator,
    required this.displayName,
    required this.sourceKind,
    this.cloudProvider,
    this.cloudAccountKey,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['locator'] = Variable<String>(locator);
    map['display_name'] = Variable<String>(displayName);
    map['source_kind'] = Variable<String>(sourceKind);
    if (!nullToAbsent || cloudProvider != null) {
      map['cloud_provider'] = Variable<String>(cloudProvider);
    }
    if (!nullToAbsent || cloudAccountKey != null) {
      map['cloud_account_key'] = Variable<String>(cloudAccountKey);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  LibraryRootsCompanion toCompanion(bool nullToAbsent) {
    return LibraryRootsCompanion(
      id: Value(id),
      locator: Value(locator),
      displayName: Value(displayName),
      sourceKind: Value(sourceKind),
      cloudProvider: cloudProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudProvider),
      cloudAccountKey: cloudAccountKey == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudAccountKey),
      addedAt: Value(addedAt),
    );
  }

  factory LibraryRoot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryRoot(
      id: serializer.fromJson<int>(json['id']),
      locator: serializer.fromJson<String>(json['locator']),
      displayName: serializer.fromJson<String>(json['displayName']),
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
      cloudProvider: serializer.fromJson<String?>(json['cloudProvider']),
      cloudAccountKey: serializer.fromJson<String?>(json['cloudAccountKey']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'locator': serializer.toJson<String>(locator),
      'displayName': serializer.toJson<String>(displayName),
      'sourceKind': serializer.toJson<String>(sourceKind),
      'cloudProvider': serializer.toJson<String?>(cloudProvider),
      'cloudAccountKey': serializer.toJson<String?>(cloudAccountKey),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  LibraryRoot copyWith({
    int? id,
    String? locator,
    String? displayName,
    String? sourceKind,
    Value<String?> cloudProvider = const Value.absent(),
    Value<String?> cloudAccountKey = const Value.absent(),
    DateTime? addedAt,
  }) => LibraryRoot(
    id: id ?? this.id,
    locator: locator ?? this.locator,
    displayName: displayName ?? this.displayName,
    sourceKind: sourceKind ?? this.sourceKind,
    cloudProvider: cloudProvider.present
        ? cloudProvider.value
        : this.cloudProvider,
    cloudAccountKey: cloudAccountKey.present
        ? cloudAccountKey.value
        : this.cloudAccountKey,
    addedAt: addedAt ?? this.addedAt,
  );
  LibraryRoot copyWithCompanion(LibraryRootsCompanion data) {
    return LibraryRoot(
      id: data.id.present ? data.id.value : this.id,
      locator: data.locator.present ? data.locator.value : this.locator,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      cloudProvider: data.cloudProvider.present
          ? data.cloudProvider.value
          : this.cloudProvider,
      cloudAccountKey: data.cloudAccountKey.present
          ? data.cloudAccountKey.value
          : this.cloudAccountKey,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryRoot(')
          ..write('id: $id, ')
          ..write('locator: $locator, ')
          ..write('displayName: $displayName, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('cloudProvider: $cloudProvider, ')
          ..write('cloudAccountKey: $cloudAccountKey, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    locator,
    displayName,
    sourceKind,
    cloudProvider,
    cloudAccountKey,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryRoot &&
          other.id == this.id &&
          other.locator == this.locator &&
          other.displayName == this.displayName &&
          other.sourceKind == this.sourceKind &&
          other.cloudProvider == this.cloudProvider &&
          other.cloudAccountKey == this.cloudAccountKey &&
          other.addedAt == this.addedAt);
}

class LibraryRootsCompanion extends UpdateCompanion<LibraryRoot> {
  final Value<int> id;
  final Value<String> locator;
  final Value<String> displayName;
  final Value<String> sourceKind;
  final Value<String?> cloudProvider;
  final Value<String?> cloudAccountKey;
  final Value<DateTime> addedAt;
  const LibraryRootsCompanion({
    this.id = const Value.absent(),
    this.locator = const Value.absent(),
    this.displayName = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.cloudProvider = const Value.absent(),
    this.cloudAccountKey = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  LibraryRootsCompanion.insert({
    this.id = const Value.absent(),
    required String locator,
    required String displayName,
    this.sourceKind = const Value.absent(),
    this.cloudProvider = const Value.absent(),
    this.cloudAccountKey = const Value.absent(),
    required DateTime addedAt,
  }) : locator = Value(locator),
       displayName = Value(displayName),
       addedAt = Value(addedAt);
  static Insertable<LibraryRoot> custom({
    Expression<int>? id,
    Expression<String>? locator,
    Expression<String>? displayName,
    Expression<String>? sourceKind,
    Expression<String>? cloudProvider,
    Expression<String>? cloudAccountKey,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (locator != null) 'locator': locator,
      if (displayName != null) 'display_name': displayName,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (cloudProvider != null) 'cloud_provider': cloudProvider,
      if (cloudAccountKey != null) 'cloud_account_key': cloudAccountKey,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  LibraryRootsCompanion copyWith({
    Value<int>? id,
    Value<String>? locator,
    Value<String>? displayName,
    Value<String>? sourceKind,
    Value<String?>? cloudProvider,
    Value<String?>? cloudAccountKey,
    Value<DateTime>? addedAt,
  }) {
    return LibraryRootsCompanion(
      id: id ?? this.id,
      locator: locator ?? this.locator,
      displayName: displayName ?? this.displayName,
      sourceKind: sourceKind ?? this.sourceKind,
      cloudProvider: cloudProvider ?? this.cloudProvider,
      cloudAccountKey: cloudAccountKey ?? this.cloudAccountKey,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (locator.present) {
      map['locator'] = Variable<String>(locator.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
    }
    if (cloudProvider.present) {
      map['cloud_provider'] = Variable<String>(cloudProvider.value);
    }
    if (cloudAccountKey.present) {
      map['cloud_account_key'] = Variable<String>(cloudAccountKey.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryRootsCompanion(')
          ..write('id: $id, ')
          ..write('locator: $locator, ')
          ..write('displayName: $displayName, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('cloudProvider: $cloudProvider, ')
          ..write('cloudAccountKey: $cloudAccountKey, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, Track> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<int> rootId = GeneratedColumn<int>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_roots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceItemIdMeta = const VerificationMeta(
    'sourceItemId',
  );
  @override
  late final GeneratedColumn<String> sourceItemId = GeneratedColumn<String>(
    'source_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locatorMeta = const VerificationMeta(
    'locator',
  );
  @override
  late final GeneratedColumn<String> locator = GeneratedColumn<String>(
    'locator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
    'modified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkCacheRefMeta = const VerificationMeta(
    'artworkCacheRef',
  );
  @override
  late final GeneratedColumn<String> artworkCacheRef = GeneratedColumn<String>(
    'artwork_cache_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceKindMeta = const VerificationMeta(
    'sourceKind',
  );
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _parentFolderNameMeta = const VerificationMeta(
    'parentFolderName',
  );
  @override
  late final GeneratedColumn<String> parentFolderName = GeneratedColumn<String>(
    'parent_folder_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rootId,
    sourceItemId,
    locator,
    displayName,
    sizeBytes,
    modifiedAt,
    title,
    artist,
    album,
    artworkCacheRef,
    sourceKind,
    parentFolderName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Track> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('source_item_id')) {
      context.handle(
        _sourceItemIdMeta,
        sourceItemId.isAcceptableOrUnknown(
          data['source_item_id']!,
          _sourceItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceItemIdMeta);
    }
    if (data.containsKey('locator')) {
      context.handle(
        _locatorMeta,
        locator.isAcceptableOrUnknown(data['locator']!, _locatorMeta),
      );
    } else if (isInserting) {
      context.missing(_locatorMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('artwork_cache_ref')) {
      context.handle(
        _artworkCacheRefMeta,
        artworkCacheRef.isAcceptableOrUnknown(
          data['artwork_cache_ref']!,
          _artworkCacheRefMeta,
        ),
      );
    }
    if (data.containsKey('source_kind')) {
      context.handle(
        _sourceKindMeta,
        sourceKind.isAcceptableOrUnknown(data['source_kind']!, _sourceKindMeta),
      );
    }
    if (data.containsKey('parent_folder_name')) {
      context.handle(
        _parentFolderNameMeta,
        parentFolderName.isAcceptableOrUnknown(
          data['parent_folder_name']!,
          _parentFolderNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {rootId, sourceItemId},
  ];
  @override
  Track map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Track(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}root_id'],
      )!,
      sourceItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_item_id'],
      )!,
      locator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_at'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      artworkCacheRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_cache_ref'],
      ),
      sourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_kind'],
      )!,
      parentFolderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_folder_name'],
      ),
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class Track extends DataClass implements Insertable<Track> {
  /// Auto-increment primary key.
  final int id;

  /// Owning library root; cascade-deletes with the root.
  final int rootId;

  /// Stable item id within the root (`MediaLocator.value` in Phase 2).
  final String sourceItemId;

  /// Opaque item locator (same as [sourceItemId] in Phase 2).
  final String locator;

  /// File display name from the platform listing.
  final String displayName;

  /// Reserved; always null in Phase 2 (SAF listing has no size).
  final int? sizeBytes;

  /// Reserved; always null in Phase 2 (SAF listing has no mtime).
  final DateTime? modifiedAt;

  /// Optional tag title.
  final String? title;

  /// Optional tag artist.
  final String? artist;

  /// Optional tag album.
  final String? album;

  /// Absolute path to capped on-device cover JPEG (`artwork/<trackId>.jpg`).
  final String? artworkCacheRef;

  /// Catalog source kind; Phase 2 always writes `local`.
  final String sourceKind;

  /// Display name of the folder this file sits in (root or nested).
  ///
  /// Purpose: Sticky queue section headers show CD / chapter folders without
  /// parsing opaque locators. Null on rows ingested before schema v4 until
  /// the next Add / Re-scan.
  final String? parentFolderName;
  const Track({
    required this.id,
    required this.rootId,
    required this.sourceItemId,
    required this.locator,
    required this.displayName,
    this.sizeBytes,
    this.modifiedAt,
    this.title,
    this.artist,
    this.album,
    this.artworkCacheRef,
    required this.sourceKind,
    this.parentFolderName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['root_id'] = Variable<int>(rootId);
    map['source_item_id'] = Variable<String>(sourceItemId);
    map['locator'] = Variable<String>(locator);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || modifiedAt != null) {
      map['modified_at'] = Variable<DateTime>(modifiedAt);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || artworkCacheRef != null) {
      map['artwork_cache_ref'] = Variable<String>(artworkCacheRef);
    }
    map['source_kind'] = Variable<String>(sourceKind);
    if (!nullToAbsent || parentFolderName != null) {
      map['parent_folder_name'] = Variable<String>(parentFolderName);
    }
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      rootId: Value(rootId),
      sourceItemId: Value(sourceItemId),
      locator: Value(locator),
      displayName: Value(displayName),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      modifiedAt: modifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedAt),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      artworkCacheRef: artworkCacheRef == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkCacheRef),
      sourceKind: Value(sourceKind),
      parentFolderName: parentFolderName == null && nullToAbsent
          ? const Value.absent()
          : Value(parentFolderName),
    );
  }

  factory Track.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Track(
      id: serializer.fromJson<int>(json['id']),
      rootId: serializer.fromJson<int>(json['rootId']),
      sourceItemId: serializer.fromJson<String>(json['sourceItemId']),
      locator: serializer.fromJson<String>(json['locator']),
      displayName: serializer.fromJson<String>(json['displayName']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      modifiedAt: serializer.fromJson<DateTime?>(json['modifiedAt']),
      title: serializer.fromJson<String?>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      artworkCacheRef: serializer.fromJson<String?>(json['artworkCacheRef']),
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
      parentFolderName: serializer.fromJson<String?>(json['parentFolderName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rootId': serializer.toJson<int>(rootId),
      'sourceItemId': serializer.toJson<String>(sourceItemId),
      'locator': serializer.toJson<String>(locator),
      'displayName': serializer.toJson<String>(displayName),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'modifiedAt': serializer.toJson<DateTime?>(modifiedAt),
      'title': serializer.toJson<String?>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'artworkCacheRef': serializer.toJson<String?>(artworkCacheRef),
      'sourceKind': serializer.toJson<String>(sourceKind),
      'parentFolderName': serializer.toJson<String?>(parentFolderName),
    };
  }

  Track copyWith({
    int? id,
    int? rootId,
    String? sourceItemId,
    String? locator,
    String? displayName,
    Value<int?> sizeBytes = const Value.absent(),
    Value<DateTime?> modifiedAt = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> artworkCacheRef = const Value.absent(),
    String? sourceKind,
    Value<String?> parentFolderName = const Value.absent(),
  }) => Track(
    id: id ?? this.id,
    rootId: rootId ?? this.rootId,
    sourceItemId: sourceItemId ?? this.sourceItemId,
    locator: locator ?? this.locator,
    displayName: displayName ?? this.displayName,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    modifiedAt: modifiedAt.present ? modifiedAt.value : this.modifiedAt,
    title: title.present ? title.value : this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    artworkCacheRef: artworkCacheRef.present
        ? artworkCacheRef.value
        : this.artworkCacheRef,
    sourceKind: sourceKind ?? this.sourceKind,
    parentFolderName: parentFolderName.present
        ? parentFolderName.value
        : this.parentFolderName,
  );
  Track copyWithCompanion(TracksCompanion data) {
    return Track(
      id: data.id.present ? data.id.value : this.id,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      sourceItemId: data.sourceItemId.present
          ? data.sourceItemId.value
          : this.sourceItemId,
      locator: data.locator.present ? data.locator.value : this.locator,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      artworkCacheRef: data.artworkCacheRef.present
          ? data.artworkCacheRef.value
          : this.artworkCacheRef,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      parentFolderName: data.parentFolderName.present
          ? data.parentFolderName.value
          : this.parentFolderName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Track(')
          ..write('id: $id, ')
          ..write('rootId: $rootId, ')
          ..write('sourceItemId: $sourceItemId, ')
          ..write('locator: $locator, ')
          ..write('displayName: $displayName, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('artworkCacheRef: $artworkCacheRef, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('parentFolderName: $parentFolderName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rootId,
    sourceItemId,
    locator,
    displayName,
    sizeBytes,
    modifiedAt,
    title,
    artist,
    album,
    artworkCacheRef,
    sourceKind,
    parentFolderName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          other.id == this.id &&
          other.rootId == this.rootId &&
          other.sourceItemId == this.sourceItemId &&
          other.locator == this.locator &&
          other.displayName == this.displayName &&
          other.sizeBytes == this.sizeBytes &&
          other.modifiedAt == this.modifiedAt &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.artworkCacheRef == this.artworkCacheRef &&
          other.sourceKind == this.sourceKind &&
          other.parentFolderName == this.parentFolderName);
}

class TracksCompanion extends UpdateCompanion<Track> {
  final Value<int> id;
  final Value<int> rootId;
  final Value<String> sourceItemId;
  final Value<String> locator;
  final Value<String> displayName;
  final Value<int?> sizeBytes;
  final Value<DateTime?> modifiedAt;
  final Value<String?> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<String?> artworkCacheRef;
  final Value<String> sourceKind;
  final Value<String?> parentFolderName;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.rootId = const Value.absent(),
    this.sourceItemId = const Value.absent(),
    this.locator = const Value.absent(),
    this.displayName = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.artworkCacheRef = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.parentFolderName = const Value.absent(),
  });
  TracksCompanion.insert({
    this.id = const Value.absent(),
    required int rootId,
    required String sourceItemId,
    required String locator,
    required String displayName,
    this.sizeBytes = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.artworkCacheRef = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.parentFolderName = const Value.absent(),
  }) : rootId = Value(rootId),
       sourceItemId = Value(sourceItemId),
       locator = Value(locator),
       displayName = Value(displayName);
  static Insertable<Track> custom({
    Expression<int>? id,
    Expression<int>? rootId,
    Expression<String>? sourceItemId,
    Expression<String>? locator,
    Expression<String>? displayName,
    Expression<int>? sizeBytes,
    Expression<DateTime>? modifiedAt,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? artworkCacheRef,
    Expression<String>? sourceKind,
    Expression<String>? parentFolderName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rootId != null) 'root_id': rootId,
      if (sourceItemId != null) 'source_item_id': sourceItemId,
      if (locator != null) 'locator': locator,
      if (displayName != null) 'display_name': displayName,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (artworkCacheRef != null) 'artwork_cache_ref': artworkCacheRef,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (parentFolderName != null) 'parent_folder_name': parentFolderName,
    });
  }

  TracksCompanion copyWith({
    Value<int>? id,
    Value<int>? rootId,
    Value<String>? sourceItemId,
    Value<String>? locator,
    Value<String>? displayName,
    Value<int?>? sizeBytes,
    Value<DateTime?>? modifiedAt,
    Value<String?>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<String?>? artworkCacheRef,
    Value<String>? sourceKind,
    Value<String?>? parentFolderName,
  }) {
    return TracksCompanion(
      id: id ?? this.id,
      rootId: rootId ?? this.rootId,
      sourceItemId: sourceItemId ?? this.sourceItemId,
      locator: locator ?? this.locator,
      displayName: displayName ?? this.displayName,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artworkCacheRef: artworkCacheRef ?? this.artworkCacheRef,
      sourceKind: sourceKind ?? this.sourceKind,
      parentFolderName: parentFolderName ?? this.parentFolderName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<int>(rootId.value);
    }
    if (sourceItemId.present) {
      map['source_item_id'] = Variable<String>(sourceItemId.value);
    }
    if (locator.present) {
      map['locator'] = Variable<String>(locator.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (artworkCacheRef.present) {
      map['artwork_cache_ref'] = Variable<String>(artworkCacheRef.value);
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
    }
    if (parentFolderName.present) {
      map['parent_folder_name'] = Variable<String>(parentFolderName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('rootId: $rootId, ')
          ..write('sourceItemId: $sourceItemId, ')
          ..write('locator: $locator, ')
          ..write('displayName: $displayName, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('artworkCacheRef: $artworkCacheRef, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('parentFolderName: $parentFolderName')
          ..write(')'))
        .toString();
  }
}

class $QueueEntriesTable extends QueueEntries
    with TableInfo<$QueueEntriesTable, QueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, trackId, sortIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_id'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $QueueEntriesTable createAlias(String alias) {
    return $QueueEntriesTable(attachedDatabase, alias);
  }
}

class QueueEntry extends DataClass implements Insertable<QueueEntry> {
  /// Auto-increment primary key.
  final int id;

  /// Catalog track; unique so a track appears at most once in the queue.
  final int trackId;

  /// Canonical queue order (append at max+1).
  final int sortIndex;
  const QueueEntry({
    required this.id,
    required this.trackId,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_id'] = Variable<int>(trackId);
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  QueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return QueueEntriesCompanion(
      id: Value(id),
      trackId: Value(trackId),
      sortIndex: Value(sortIndex),
    );
  }

  factory QueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueEntry(
      id: serializer.fromJson<int>(json['id']),
      trackId: serializer.fromJson<int>(json['trackId']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackId': serializer.toJson<int>(trackId),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  QueueEntry copyWith({int? id, int? trackId, int? sortIndex}) => QueueEntry(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  QueueEntry copyWithCompanion(QueueEntriesCompanion data) {
    return QueueEntry(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueEntry(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trackId, sortIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueEntry &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.sortIndex == this.sortIndex);
}

class QueueEntriesCompanion extends UpdateCompanion<QueueEntry> {
  final Value<int> id;
  final Value<int> trackId;
  final Value<int> sortIndex;
  const QueueEntriesCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.sortIndex = const Value.absent(),
  });
  QueueEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int trackId,
    required int sortIndex,
  }) : trackId = Value(trackId),
       sortIndex = Value(sortIndex);
  static Insertable<QueueEntry> custom({
    Expression<int>? id,
    Expression<int>? trackId,
    Expression<int>? sortIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (sortIndex != null) 'sort_index': sortIndex,
    });
  }

  QueueEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? trackId,
    Value<int>? sortIndex,
  }) {
    return QueueEntriesCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      sortIndex: sortIndex ?? this.sortIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<int>(trackId.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }
}

class $PlaybackStateTable extends PlaybackState
    with TableInfo<$PlaybackStateTable, PlaybackStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentQueueEntryIdMeta =
      const VerificationMeta('currentQueueEntryId');
  @override
  late final GeneratedColumn<int> currentQueueEntryId = GeneratedColumn<int>(
    'current_queue_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES queue_entries (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shuffleEnabledMeta = const VerificationMeta(
    'shuffleEnabled',
  );
  @override
  late final GeneratedColumn<bool> shuffleEnabled = GeneratedColumn<bool>(
    'shuffle_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('off'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentQueueEntryId,
    positionMs,
    shuffleEnabled,
    repeatMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_queue_entry_id')) {
      context.handle(
        _currentQueueEntryIdMeta,
        currentQueueEntryId.isAcceptableOrUnknown(
          data['current_queue_entry_id']!,
          _currentQueueEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('shuffle_enabled')) {
      context.handle(
        _shuffleEnabledMeta,
        shuffleEnabled.isAcceptableOrUnknown(
          data['shuffle_enabled']!,
          _shuffleEnabledMeta,
        ),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentQueueEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_queue_entry_id'],
      ),
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      shuffleEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_enabled'],
      )!,
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
    );
  }

  @override
  $PlaybackStateTable createAlias(String alias) {
    return $PlaybackStateTable(attachedDatabase, alias);
  }
}

class PlaybackStateData extends DataClass
    implements Insertable<PlaybackStateData> {
  /// Singleton primary key; always `1`.
  final int id;

  /// Current queue entry; cleared when that entry is deleted.
  final int? currentQueueEntryId;

  /// Resume position in milliseconds.
  final int positionMs;

  /// Whether shuffle is on (`true`) or off (`false`).
  ///
  /// Purpose: Persist the transport toggle across process death; permutation /
  /// history stay in-memory only.
  final bool shuffleEnabled;

  /// Repeat cycle value: `off` / `one` / `all`.
  ///
  /// Purpose: Persist the transport toggle; unknown stored values fall back to
  /// `off` when read by the player layer.
  final String repeatMode;
  const PlaybackStateData({
    required this.id,
    this.currentQueueEntryId,
    required this.positionMs,
    required this.shuffleEnabled,
    required this.repeatMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || currentQueueEntryId != null) {
      map['current_queue_entry_id'] = Variable<int>(currentQueueEntryId);
    }
    map['position_ms'] = Variable<int>(positionMs);
    map['shuffle_enabled'] = Variable<bool>(shuffleEnabled);
    map['repeat_mode'] = Variable<String>(repeatMode);
    return map;
  }

  PlaybackStateCompanion toCompanion(bool nullToAbsent) {
    return PlaybackStateCompanion(
      id: Value(id),
      currentQueueEntryId: currentQueueEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentQueueEntryId),
      positionMs: Value(positionMs),
      shuffleEnabled: Value(shuffleEnabled),
      repeatMode: Value(repeatMode),
    );
  }

  factory PlaybackStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackStateData(
      id: serializer.fromJson<int>(json['id']),
      currentQueueEntryId: serializer.fromJson<int?>(
        json['currentQueueEntryId'],
      ),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      shuffleEnabled: serializer.fromJson<bool>(json['shuffleEnabled']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentQueueEntryId': serializer.toJson<int?>(currentQueueEntryId),
      'positionMs': serializer.toJson<int>(positionMs),
      'shuffleEnabled': serializer.toJson<bool>(shuffleEnabled),
      'repeatMode': serializer.toJson<String>(repeatMode),
    };
  }

  PlaybackStateData copyWith({
    int? id,
    Value<int?> currentQueueEntryId = const Value.absent(),
    int? positionMs,
    bool? shuffleEnabled,
    String? repeatMode,
  }) => PlaybackStateData(
    id: id ?? this.id,
    currentQueueEntryId: currentQueueEntryId.present
        ? currentQueueEntryId.value
        : this.currentQueueEntryId,
    positionMs: positionMs ?? this.positionMs,
    shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    repeatMode: repeatMode ?? this.repeatMode,
  );
  PlaybackStateData copyWithCompanion(PlaybackStateCompanion data) {
    return PlaybackStateData(
      id: data.id.present ? data.id.value : this.id,
      currentQueueEntryId: data.currentQueueEntryId.present
          ? data.currentQueueEntryId.value
          : this.currentQueueEntryId,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      shuffleEnabled: data.shuffleEnabled.present
          ? data.shuffleEnabled.value
          : this.shuffleEnabled,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStateData(')
          ..write('id: $id, ')
          ..write('currentQueueEntryId: $currentQueueEntryId, ')
          ..write('positionMs: $positionMs, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('repeatMode: $repeatMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentQueueEntryId,
    positionMs,
    shuffleEnabled,
    repeatMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackStateData &&
          other.id == this.id &&
          other.currentQueueEntryId == this.currentQueueEntryId &&
          other.positionMs == this.positionMs &&
          other.shuffleEnabled == this.shuffleEnabled &&
          other.repeatMode == this.repeatMode);
}

class PlaybackStateCompanion extends UpdateCompanion<PlaybackStateData> {
  final Value<int> id;
  final Value<int?> currentQueueEntryId;
  final Value<int> positionMs;
  final Value<bool> shuffleEnabled;
  final Value<String> repeatMode;
  const PlaybackStateCompanion({
    this.id = const Value.absent(),
    this.currentQueueEntryId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.repeatMode = const Value.absent(),
  });
  PlaybackStateCompanion.insert({
    this.id = const Value.absent(),
    this.currentQueueEntryId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.repeatMode = const Value.absent(),
  });
  static Insertable<PlaybackStateData> custom({
    Expression<int>? id,
    Expression<int>? currentQueueEntryId,
    Expression<int>? positionMs,
    Expression<bool>? shuffleEnabled,
    Expression<String>? repeatMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentQueueEntryId != null)
        'current_queue_entry_id': currentQueueEntryId,
      if (positionMs != null) 'position_ms': positionMs,
      if (shuffleEnabled != null) 'shuffle_enabled': shuffleEnabled,
      if (repeatMode != null) 'repeat_mode': repeatMode,
    });
  }

  PlaybackStateCompanion copyWith({
    Value<int>? id,
    Value<int?>? currentQueueEntryId,
    Value<int>? positionMs,
    Value<bool>? shuffleEnabled,
    Value<String>? repeatMode,
  }) {
    return PlaybackStateCompanion(
      id: id ?? this.id,
      currentQueueEntryId: currentQueueEntryId ?? this.currentQueueEntryId,
      positionMs: positionMs ?? this.positionMs,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentQueueEntryId.present) {
      map['current_queue_entry_id'] = Variable<int>(currentQueueEntryId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (shuffleEnabled.present) {
      map['shuffle_enabled'] = Variable<bool>(shuffleEnabled.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStateCompanion(')
          ..write('id: $id, ')
          ..write('currentQueueEntryId: $currentQueueEntryId, ')
          ..write('positionMs: $positionMs, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('repeatMode: $repeatMode')
          ..write(')'))
        .toString();
  }
}

class $CloudCacheEntriesTable extends CloudCacheEntries
    with TableInfo<$CloudCacheEntriesTable, CloudCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CloudCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _remoteLocatorMeta = const VerificationMeta(
    'remoteLocator',
  );
  @override
  late final GeneratedColumn<String> remoteLocator = GeneratedColumn<String>(
    'remote_locator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    remoteLocator,
    localPath,
    sizeBytes,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cloud_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CloudCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    }
    if (data.containsKey('remote_locator')) {
      context.handle(
        _remoteLocatorMeta,
        remoteLocator.isAcceptableOrUnknown(
          data['remote_locator']!,
          _remoteLocatorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteLocatorMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  CloudCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CloudCacheEntry(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_id'],
      )!,
      remoteLocator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_locator'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      )!,
    );
  }

  @override
  $CloudCacheEntriesTable createAlias(String alias) {
    return $CloudCacheEntriesTable(attachedDatabase, alias);
  }
}

class CloudCacheEntry extends DataClass implements Insertable<CloudCacheEntry> {
  /// Catalog track this cache file belongs to.
  final int trackId;

  /// Remote `gdrive:` [MediaLocator] string for the cached item.
  final String remoteLocator;

  /// Absolute local filesystem path of the cached file.
  final String localPath;

  /// Cached file size in bytes.
  final int sizeBytes;

  /// Last play / download access time (UTC) for LRU eviction.
  final DateTime lastAccessedAt;
  const CloudCacheEntry({
    required this.trackId,
    required this.remoteLocator,
    required this.localPath,
    required this.sizeBytes,
    required this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<int>(trackId);
    map['remote_locator'] = Variable<String>(remoteLocator);
    map['local_path'] = Variable<String>(localPath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    return map;
  }

  CloudCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return CloudCacheEntriesCompanion(
      trackId: Value(trackId),
      remoteLocator: Value(remoteLocator),
      localPath: Value(localPath),
      sizeBytes: Value(sizeBytes),
      lastAccessedAt: Value(lastAccessedAt),
    );
  }

  factory CloudCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CloudCacheEntry(
      trackId: serializer.fromJson<int>(json['trackId']),
      remoteLocator: serializer.fromJson<String>(json['remoteLocator']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<int>(trackId),
      'remoteLocator': serializer.toJson<String>(remoteLocator),
      'localPath': serializer.toJson<String>(localPath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
    };
  }

  CloudCacheEntry copyWith({
    int? trackId,
    String? remoteLocator,
    String? localPath,
    int? sizeBytes,
    DateTime? lastAccessedAt,
  }) => CloudCacheEntry(
    trackId: trackId ?? this.trackId,
    remoteLocator: remoteLocator ?? this.remoteLocator,
    localPath: localPath ?? this.localPath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
  );
  CloudCacheEntry copyWithCompanion(CloudCacheEntriesCompanion data) {
    return CloudCacheEntry(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      remoteLocator: data.remoteLocator.present
          ? data.remoteLocator.value
          : this.remoteLocator,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CloudCacheEntry(')
          ..write('trackId: $trackId, ')
          ..write('remoteLocator: $remoteLocator, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(trackId, remoteLocator, localPath, sizeBytes, lastAccessedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CloudCacheEntry &&
          other.trackId == this.trackId &&
          other.remoteLocator == this.remoteLocator &&
          other.localPath == this.localPath &&
          other.sizeBytes == this.sizeBytes &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class CloudCacheEntriesCompanion extends UpdateCompanion<CloudCacheEntry> {
  final Value<int> trackId;
  final Value<String> remoteLocator;
  final Value<String> localPath;
  final Value<int> sizeBytes;
  final Value<DateTime> lastAccessedAt;
  const CloudCacheEntriesCompanion({
    this.trackId = const Value.absent(),
    this.remoteLocator = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
  });
  CloudCacheEntriesCompanion.insert({
    this.trackId = const Value.absent(),
    required String remoteLocator,
    required String localPath,
    required int sizeBytes,
    required DateTime lastAccessedAt,
  }) : remoteLocator = Value(remoteLocator),
       localPath = Value(localPath),
       sizeBytes = Value(sizeBytes),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<CloudCacheEntry> custom({
    Expression<int>? trackId,
    Expression<String>? remoteLocator,
    Expression<String>? localPath,
    Expression<int>? sizeBytes,
    Expression<DateTime>? lastAccessedAt,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (remoteLocator != null) 'remote_locator': remoteLocator,
      if (localPath != null) 'local_path': localPath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
    });
  }

  CloudCacheEntriesCompanion copyWith({
    Value<int>? trackId,
    Value<String>? remoteLocator,
    Value<String>? localPath,
    Value<int>? sizeBytes,
    Value<DateTime>? lastAccessedAt,
  }) {
    return CloudCacheEntriesCompanion(
      trackId: trackId ?? this.trackId,
      remoteLocator: remoteLocator ?? this.remoteLocator,
      localPath: localPath ?? this.localPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<int>(trackId.value);
    }
    if (remoteLocator.present) {
      map['remote_locator'] = Variable<String>(remoteLocator.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CloudCacheEntriesCompanion(')
          ..write('trackId: $trackId, ')
          ..write('remoteLocator: $remoteLocator, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LibraryRootsTable libraryRoots = $LibraryRootsTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $QueueEntriesTable queueEntries = $QueueEntriesTable(this);
  late final $PlaybackStateTable playbackState = $PlaybackStateTable(this);
  late final $CloudCacheEntriesTable cloudCacheEntries =
      $CloudCacheEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryRoots,
    tracks,
    queueEntries,
    playbackState,
    cloudCacheEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'library_roots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tracks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('queue_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'queue_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playback_state', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cloud_cache_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LibraryRootsTableCreateCompanionBuilder =
    LibraryRootsCompanion Function({
      Value<int> id,
      required String locator,
      required String displayName,
      Value<String> sourceKind,
      Value<String?> cloudProvider,
      Value<String?> cloudAccountKey,
      required DateTime addedAt,
    });
typedef $$LibraryRootsTableUpdateCompanionBuilder =
    LibraryRootsCompanion Function({
      Value<int> id,
      Value<String> locator,
      Value<String> displayName,
      Value<String> sourceKind,
      Value<String?> cloudProvider,
      Value<String?> cloudAccountKey,
      Value<DateTime> addedAt,
    });

final class $$LibraryRootsTableReferences
    extends BaseReferences<_$AppDatabase, $LibraryRootsTable, LibraryRoot> {
  $$LibraryRootsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TracksTable, List<Track>> _tracksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tracks,
    aliasName: 'library_roots__id__tracks__root_id',
  );

  $$TracksTableProcessedTableManager get tracksRefs {
    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.rootId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LibraryRootsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryRootsTable> {
  $$LibraryRootsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudProvider => $composableBuilder(
    column: $table.cloudProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudAccountKey => $composableBuilder(
    column: $table.cloudAccountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tracksRefs(
    Expression<bool> Function($$TracksTableFilterComposer f) f,
  ) {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.rootId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryRootsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryRootsTable> {
  $$LibraryRootsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudProvider => $composableBuilder(
    column: $table.cloudProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudAccountKey => $composableBuilder(
    column: $table.cloudAccountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryRootsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryRootsTable> {
  $$LibraryRootsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locator =>
      $composableBuilder(column: $table.locator, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cloudProvider => $composableBuilder(
    column: $table.cloudProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cloudAccountKey => $composableBuilder(
    column: $table.cloudAccountKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  Expression<T> tracksRefs<T extends Object>(
    Expression<T> Function($$TracksTableAnnotationComposer a) f,
  ) {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.rootId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryRootsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryRootsTable,
          LibraryRoot,
          $$LibraryRootsTableFilterComposer,
          $$LibraryRootsTableOrderingComposer,
          $$LibraryRootsTableAnnotationComposer,
          $$LibraryRootsTableCreateCompanionBuilder,
          $$LibraryRootsTableUpdateCompanionBuilder,
          (LibraryRoot, $$LibraryRootsTableReferences),
          LibraryRoot,
          PrefetchHooks Function({bool tracksRefs})
        > {
  $$LibraryRootsTableTableManager(_$AppDatabase db, $LibraryRootsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryRootsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryRootsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryRootsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> locator = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String?> cloudProvider = const Value.absent(),
                Value<String?> cloudAccountKey = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => LibraryRootsCompanion(
                id: id,
                locator: locator,
                displayName: displayName,
                sourceKind: sourceKind,
                cloudProvider: cloudProvider,
                cloudAccountKey: cloudAccountKey,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String locator,
                required String displayName,
                Value<String> sourceKind = const Value.absent(),
                Value<String?> cloudProvider = const Value.absent(),
                Value<String?> cloudAccountKey = const Value.absent(),
                required DateTime addedAt,
              }) => LibraryRootsCompanion.insert(
                id: id,
                locator: locator,
                displayName: displayName,
                sourceKind: sourceKind,
                cloudProvider: cloudProvider,
                cloudAccountKey: cloudAccountKey,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LibraryRootsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tracksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tracksRefs) db.tracks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tracksRefs)
                    await $_getPrefetchedData<
                      LibraryRoot,
                      $LibraryRootsTable,
                      Track
                    >(
                      currentTable: table,
                      referencedTable: $$LibraryRootsTableReferences
                          ._tracksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LibraryRootsTableReferences(
                            db,
                            table,
                            p0,
                          ).tracksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.rootId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LibraryRootsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryRootsTable,
      LibraryRoot,
      $$LibraryRootsTableFilterComposer,
      $$LibraryRootsTableOrderingComposer,
      $$LibraryRootsTableAnnotationComposer,
      $$LibraryRootsTableCreateCompanionBuilder,
      $$LibraryRootsTableUpdateCompanionBuilder,
      (LibraryRoot, $$LibraryRootsTableReferences),
      LibraryRoot,
      PrefetchHooks Function({bool tracksRefs})
    >;
typedef $$TracksTableCreateCompanionBuilder =
    TracksCompanion Function({
      Value<int> id,
      required int rootId,
      required String sourceItemId,
      required String locator,
      required String displayName,
      Value<int?> sizeBytes,
      Value<DateTime?> modifiedAt,
      Value<String?> title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> artworkCacheRef,
      Value<String> sourceKind,
      Value<String?> parentFolderName,
    });
typedef $$TracksTableUpdateCompanionBuilder =
    TracksCompanion Function({
      Value<int> id,
      Value<int> rootId,
      Value<String> sourceItemId,
      Value<String> locator,
      Value<String> displayName,
      Value<int?> sizeBytes,
      Value<DateTime?> modifiedAt,
      Value<String?> title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> artworkCacheRef,
      Value<String> sourceKind,
      Value<String?> parentFolderName,
    });

final class $$TracksTableReferences
    extends BaseReferences<_$AppDatabase, $TracksTable, Track> {
  $$TracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LibraryRootsTable _rootIdTable(_$AppDatabase db) =>
      db.libraryRoots.createAlias('tracks__root_id__library_roots__id');

  $$LibraryRootsTableProcessedTableManager get rootId {
    final $_column = $_itemColumn<int>('root_id')!;

    final manager = $$LibraryRootsTableTableManager(
      $_db,
      $_db.libraryRoots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rootIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QueueEntriesTable, List<QueueEntry>>
  _queueEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queueEntries,
    aliasName: 'tracks__id__queue_entries__track_id',
  );

  $$QueueEntriesTableProcessedTableManager get queueEntriesRefs {
    final manager = $$QueueEntriesTableTableManager(
      $_db,
      $_db.queueEntries,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CloudCacheEntriesTable, List<CloudCacheEntry>>
  _cloudCacheEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cloudCacheEntries,
        aliasName: 'tracks__id__cloud_cache_entries__track_id',
      );

  $$CloudCacheEntriesTableProcessedTableManager get cloudCacheEntriesRefs {
    final manager = $$CloudCacheEntriesTableTableManager(
      $_db,
      $_db.cloudCacheEntries,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cloudCacheEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TracksTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceItemId => $composableBuilder(
    column: $table.sourceItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkCacheRef => $composableBuilder(
    column: $table.artworkCacheRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentFolderName => $composableBuilder(
    column: $table.parentFolderName,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryRootsTableFilterComposer get rootId {
    final $$LibraryRootsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootId,
      referencedTable: $db.libraryRoots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryRootsTableFilterComposer(
            $db: $db,
            $table: $db.libraryRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> queueEntriesRefs(
    Expression<bool> Function($$QueueEntriesTableFilterComposer f) f,
  ) {
    final $$QueueEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueEntries,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueEntriesTableFilterComposer(
            $db: $db,
            $table: $db.queueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cloudCacheEntriesRefs(
    Expression<bool> Function($$CloudCacheEntriesTableFilterComposer f) f,
  ) {
    final $$CloudCacheEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cloudCacheEntries,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CloudCacheEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cloudCacheEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TracksTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceItemId => $composableBuilder(
    column: $table.sourceItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkCacheRef => $composableBuilder(
    column: $table.artworkCacheRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentFolderName => $composableBuilder(
    column: $table.parentFolderName,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryRootsTableOrderingComposer get rootId {
    final $$LibraryRootsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootId,
      referencedTable: $db.libraryRoots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryRootsTableOrderingComposer(
            $db: $db,
            $table: $db.libraryRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceItemId => $composableBuilder(
    column: $table.sourceItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locator =>
      $composableBuilder(column: $table.locator, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get artworkCacheRef => $composableBuilder(
    column: $table.artworkCacheRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentFolderName => $composableBuilder(
    column: $table.parentFolderName,
    builder: (column) => column,
  );

  $$LibraryRootsTableAnnotationComposer get rootId {
    final $$LibraryRootsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootId,
      referencedTable: $db.libraryRoots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryRootsTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> queueEntriesRefs<T extends Object>(
    Expression<T> Function($$QueueEntriesTableAnnotationComposer a) f,
  ) {
    final $$QueueEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueEntries,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.queueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cloudCacheEntriesRefs<T extends Object>(
    Expression<T> Function($$CloudCacheEntriesTableAnnotationComposer a) f,
  ) {
    final $$CloudCacheEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cloudCacheEntries,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CloudCacheEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.cloudCacheEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TracksTable,
          Track,
          $$TracksTableFilterComposer,
          $$TracksTableOrderingComposer,
          $$TracksTableAnnotationComposer,
          $$TracksTableCreateCompanionBuilder,
          $$TracksTableUpdateCompanionBuilder,
          (Track, $$TracksTableReferences),
          Track,
          PrefetchHooks Function({
            bool rootId,
            bool queueEntriesRefs,
            bool cloudCacheEntriesRefs,
          })
        > {
  $$TracksTableTableManager(_$AppDatabase db, $TracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rootId = const Value.absent(),
                Value<String> sourceItemId = const Value.absent(),
                Value<String> locator = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<DateTime?> modifiedAt = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> artworkCacheRef = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String?> parentFolderName = const Value.absent(),
              }) => TracksCompanion(
                id: id,
                rootId: rootId,
                sourceItemId: sourceItemId,
                locator: locator,
                displayName: displayName,
                sizeBytes: sizeBytes,
                modifiedAt: modifiedAt,
                title: title,
                artist: artist,
                album: album,
                artworkCacheRef: artworkCacheRef,
                sourceKind: sourceKind,
                parentFolderName: parentFolderName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rootId,
                required String sourceItemId,
                required String locator,
                required String displayName,
                Value<int?> sizeBytes = const Value.absent(),
                Value<DateTime?> modifiedAt = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> artworkCacheRef = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String?> parentFolderName = const Value.absent(),
              }) => TracksCompanion.insert(
                id: id,
                rootId: rootId,
                sourceItemId: sourceItemId,
                locator: locator,
                displayName: displayName,
                sizeBytes: sizeBytes,
                modifiedAt: modifiedAt,
                title: title,
                artist: artist,
                album: album,
                artworkCacheRef: artworkCacheRef,
                sourceKind: sourceKind,
                parentFolderName: parentFolderName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TracksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                rootId = false,
                queueEntriesRefs = false,
                cloudCacheEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (queueEntriesRefs) db.queueEntries,
                    if (cloudCacheEntriesRefs) db.cloudCacheEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (rootId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.rootId,
                                    referencedTable: $$TracksTableReferences
                                        ._rootIdTable(db),
                                    referencedColumn: $$TracksTableReferences
                                        ._rootIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (queueEntriesRefs)
                        await $_getPrefetchedData<
                          Track,
                          $TracksTable,
                          QueueEntry
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._queueEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).queueEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cloudCacheEntriesRefs)
                        await $_getPrefetchedData<
                          Track,
                          $TracksTable,
                          CloudCacheEntry
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._cloudCacheEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).cloudCacheEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TracksTable,
      Track,
      $$TracksTableFilterComposer,
      $$TracksTableOrderingComposer,
      $$TracksTableAnnotationComposer,
      $$TracksTableCreateCompanionBuilder,
      $$TracksTableUpdateCompanionBuilder,
      (Track, $$TracksTableReferences),
      Track,
      PrefetchHooks Function({
        bool rootId,
        bool queueEntriesRefs,
        bool cloudCacheEntriesRefs,
      })
    >;
typedef $$QueueEntriesTableCreateCompanionBuilder =
    QueueEntriesCompanion Function({
      Value<int> id,
      required int trackId,
      required int sortIndex,
    });
typedef $$QueueEntriesTableUpdateCompanionBuilder =
    QueueEntriesCompanion Function({
      Value<int> id,
      Value<int> trackId,
      Value<int> sortIndex,
    });

final class $$QueueEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $QueueEntriesTable, QueueEntry> {
  $$QueueEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TracksTable _trackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('queue_entries__track_id__tracks__id');

  $$TracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<int>('track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlaybackStateTable, List<PlaybackStateData>>
  _playbackStateRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playbackState,
    aliasName: 'queue_entries__id__playback_state__current_queue_entry_id',
  );

  $$PlaybackStateTableProcessedTableManager get playbackStateRefs {
    final manager = $$PlaybackStateTableTableManager($_db, $_db.playbackState)
        .filter(
          (f) => f.currentQueueEntryId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_playbackStateRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $QueueEntriesTable> {
  $$QueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get trackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> playbackStateRefs(
    Expression<bool> Function($$PlaybackStateTableFilterComposer f) f,
  ) {
    final $$PlaybackStateTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playbackState,
      getReferencedColumn: (t) => t.currentQueueEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaybackStateTableFilterComposer(
            $db: $db,
            $table: $db.playbackState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueEntriesTable> {
  $$QueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get trackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueEntriesTable> {
  $$QueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  $$TracksTableAnnotationComposer get trackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> playbackStateRefs<T extends Object>(
    Expression<T> Function($$PlaybackStateTableAnnotationComposer a) f,
  ) {
    final $$PlaybackStateTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playbackState,
      getReferencedColumn: (t) => t.currentQueueEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaybackStateTableAnnotationComposer(
            $db: $db,
            $table: $db.playbackState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueEntriesTable,
          QueueEntry,
          $$QueueEntriesTableFilterComposer,
          $$QueueEntriesTableOrderingComposer,
          $$QueueEntriesTableAnnotationComposer,
          $$QueueEntriesTableCreateCompanionBuilder,
          $$QueueEntriesTableUpdateCompanionBuilder,
          (QueueEntry, $$QueueEntriesTableReferences),
          QueueEntry,
          PrefetchHooks Function({bool trackId, bool playbackStateRefs})
        > {
  $$QueueEntriesTableTableManager(_$AppDatabase db, $QueueEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> trackId = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
              }) => QueueEntriesCompanion(
                id: id,
                trackId: trackId,
                sortIndex: sortIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int trackId,
                required int sortIndex,
              }) => QueueEntriesCompanion.insert(
                id: id,
                trackId: trackId,
                sortIndex: sortIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QueueEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({trackId = false, playbackStateRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playbackStateRefs) db.playbackState,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (trackId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.trackId,
                                    referencedTable:
                                        $$QueueEntriesTableReferences
                                            ._trackIdTable(db),
                                    referencedColumn:
                                        $$QueueEntriesTableReferences
                                            ._trackIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playbackStateRefs)
                        await $_getPrefetchedData<
                          QueueEntry,
                          $QueueEntriesTable,
                          PlaybackStateData
                        >(
                          currentTable: table,
                          referencedTable: $$QueueEntriesTableReferences
                              ._playbackStateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QueueEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).playbackStateRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.currentQueueEntryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueEntriesTable,
      QueueEntry,
      $$QueueEntriesTableFilterComposer,
      $$QueueEntriesTableOrderingComposer,
      $$QueueEntriesTableAnnotationComposer,
      $$QueueEntriesTableCreateCompanionBuilder,
      $$QueueEntriesTableUpdateCompanionBuilder,
      (QueueEntry, $$QueueEntriesTableReferences),
      QueueEntry,
      PrefetchHooks Function({bool trackId, bool playbackStateRefs})
    >;
typedef $$PlaybackStateTableCreateCompanionBuilder =
    PlaybackStateCompanion Function({
      Value<int> id,
      Value<int?> currentQueueEntryId,
      Value<int> positionMs,
      Value<bool> shuffleEnabled,
      Value<String> repeatMode,
    });
typedef $$PlaybackStateTableUpdateCompanionBuilder =
    PlaybackStateCompanion Function({
      Value<int> id,
      Value<int?> currentQueueEntryId,
      Value<int> positionMs,
      Value<bool> shuffleEnabled,
      Value<String> repeatMode,
    });

final class $$PlaybackStateTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlaybackStateTable, PlaybackStateData> {
  $$PlaybackStateTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QueueEntriesTable _currentQueueEntryIdTable(_$AppDatabase db) => db
      .queueEntries
      .createAlias('playback_state__current_queue_entry_id__queue_entries__id');

  $$QueueEntriesTableProcessedTableManager? get currentQueueEntryId {
    final $_column = $_itemColumn<int>('current_queue_entry_id');
    if ($_column == null) return null;
    final manager = $$QueueEntriesTableTableManager(
      $_db,
      $_db.queueEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currentQueueEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaybackStateTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackStateTable> {
  $$PlaybackStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  $$QueueEntriesTableFilterComposer get currentQueueEntryId {
    final $$QueueEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentQueueEntryId,
      referencedTable: $db.queueEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueEntriesTableFilterComposer(
            $db: $db,
            $table: $db.queueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackStateTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackStateTable> {
  $$PlaybackStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  $$QueueEntriesTableOrderingComposer get currentQueueEntryId {
    final $$QueueEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentQueueEntryId,
      referencedTable: $db.queueEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.queueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackStateTable> {
  $$PlaybackStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  $$QueueEntriesTableAnnotationComposer get currentQueueEntryId {
    final $$QueueEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentQueueEntryId,
      referencedTable: $db.queueEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.queueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackStateTable,
          PlaybackStateData,
          $$PlaybackStateTableFilterComposer,
          $$PlaybackStateTableOrderingComposer,
          $$PlaybackStateTableAnnotationComposer,
          $$PlaybackStateTableCreateCompanionBuilder,
          $$PlaybackStateTableUpdateCompanionBuilder,
          (PlaybackStateData, $$PlaybackStateTableReferences),
          PlaybackStateData,
          PrefetchHooks Function({bool currentQueueEntryId})
        > {
  $$PlaybackStateTableTableManager(_$AppDatabase db, $PlaybackStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> currentQueueEntryId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
              }) => PlaybackStateCompanion(
                id: id,
                currentQueueEntryId: currentQueueEntryId,
                positionMs: positionMs,
                shuffleEnabled: shuffleEnabled,
                repeatMode: repeatMode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> currentQueueEntryId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
              }) => PlaybackStateCompanion.insert(
                id: id,
                currentQueueEntryId: currentQueueEntryId,
                positionMs: positionMs,
                shuffleEnabled: shuffleEnabled,
                repeatMode: repeatMode,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaybackStateTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({currentQueueEntryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (currentQueueEntryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.currentQueueEntryId,
                                referencedTable: $$PlaybackStateTableReferences
                                    ._currentQueueEntryIdTable(db),
                                referencedColumn: $$PlaybackStateTableReferences
                                    ._currentQueueEntryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaybackStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackStateTable,
      PlaybackStateData,
      $$PlaybackStateTableFilterComposer,
      $$PlaybackStateTableOrderingComposer,
      $$PlaybackStateTableAnnotationComposer,
      $$PlaybackStateTableCreateCompanionBuilder,
      $$PlaybackStateTableUpdateCompanionBuilder,
      (PlaybackStateData, $$PlaybackStateTableReferences),
      PlaybackStateData,
      PrefetchHooks Function({bool currentQueueEntryId})
    >;
typedef $$CloudCacheEntriesTableCreateCompanionBuilder =
    CloudCacheEntriesCompanion Function({
      Value<int> trackId,
      required String remoteLocator,
      required String localPath,
      required int sizeBytes,
      required DateTime lastAccessedAt,
    });
typedef $$CloudCacheEntriesTableUpdateCompanionBuilder =
    CloudCacheEntriesCompanion Function({
      Value<int> trackId,
      Value<String> remoteLocator,
      Value<String> localPath,
      Value<int> sizeBytes,
      Value<DateTime> lastAccessedAt,
    });

final class $$CloudCacheEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CloudCacheEntriesTable,
          CloudCacheEntry
        > {
  $$CloudCacheEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTable _trackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('cloud_cache_entries__track_id__tracks__id');

  $$TracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<int>('track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CloudCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CloudCacheEntriesTable> {
  $$CloudCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteLocator => $composableBuilder(
    column: $table.remoteLocator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get trackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CloudCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CloudCacheEntriesTable> {
  $$CloudCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteLocator => $composableBuilder(
    column: $table.remoteLocator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get trackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CloudCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CloudCacheEntriesTable> {
  $$CloudCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteLocator => $composableBuilder(
    column: $table.remoteLocator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  $$TracksTableAnnotationComposer get trackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CloudCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CloudCacheEntriesTable,
          CloudCacheEntry,
          $$CloudCacheEntriesTableFilterComposer,
          $$CloudCacheEntriesTableOrderingComposer,
          $$CloudCacheEntriesTableAnnotationComposer,
          $$CloudCacheEntriesTableCreateCompanionBuilder,
          $$CloudCacheEntriesTableUpdateCompanionBuilder,
          (CloudCacheEntry, $$CloudCacheEntriesTableReferences),
          CloudCacheEntry,
          PrefetchHooks Function({bool trackId})
        > {
  $$CloudCacheEntriesTableTableManager(
    _$AppDatabase db,
    $CloudCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CloudCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CloudCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CloudCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> trackId = const Value.absent(),
                Value<String> remoteLocator = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> lastAccessedAt = const Value.absent(),
              }) => CloudCacheEntriesCompanion(
                trackId: trackId,
                remoteLocator: remoteLocator,
                localPath: localPath,
                sizeBytes: sizeBytes,
                lastAccessedAt: lastAccessedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> trackId = const Value.absent(),
                required String remoteLocator,
                required String localPath,
                required int sizeBytes,
                required DateTime lastAccessedAt,
              }) => CloudCacheEntriesCompanion.insert(
                trackId: trackId,
                remoteLocator: remoteLocator,
                localPath: localPath,
                sizeBytes: sizeBytes,
                lastAccessedAt: lastAccessedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CloudCacheEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable:
                                    $$CloudCacheEntriesTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$CloudCacheEntriesTableReferences
                                        ._trackIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CloudCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CloudCacheEntriesTable,
      CloudCacheEntry,
      $$CloudCacheEntriesTableFilterComposer,
      $$CloudCacheEntriesTableOrderingComposer,
      $$CloudCacheEntriesTableAnnotationComposer,
      $$CloudCacheEntriesTableCreateCompanionBuilder,
      $$CloudCacheEntriesTableUpdateCompanionBuilder,
      (CloudCacheEntry, $$CloudCacheEntriesTableReferences),
      CloudCacheEntry,
      PrefetchHooks Function({bool trackId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LibraryRootsTableTableManager get libraryRoots =>
      $$LibraryRootsTableTableManager(_db, _db.libraryRoots);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$QueueEntriesTableTableManager get queueEntries =>
      $$QueueEntriesTableTableManager(_db, _db.queueEntries);
  $$PlaybackStateTableTableManager get playbackState =>
      $$PlaybackStateTableTableManager(_db, _db.playbackState);
  $$CloudCacheEntriesTableTableManager get cloudCacheEntries =>
      $$CloudCacheEntriesTableTableManager(_db, _db.cloudCacheEntries);
}
