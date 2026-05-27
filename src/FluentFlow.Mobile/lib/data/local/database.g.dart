// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DeckTableTable extends DeckTable
    with TableInfo<$DeckTableTable, DeckTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nativeLanguageMeta = const VerificationMeta(
    'nativeLanguage',
  );
  @override
  late final GeneratedColumn<String> nativeLanguage = GeneratedColumn<String>(
    'native_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxNewCardsPerDayMeta = const VerificationMeta(
    'maxNewCardsPerDay',
  );
  @override
  late final GeneratedColumn<int> maxNewCardsPerDay = GeneratedColumn<int>(
    'max_new_cards_per_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _maxReviewsPerDayMeta = const VerificationMeta(
    'maxReviewsPerDay',
  );
  @override
  late final GeneratedColumn<int> maxReviewsPerDay = GeneratedColumn<int>(
    'max_reviews_per_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    description,
    language,
    nativeLanguage,
    maxNewCardsPerDay,
    maxReviewsPerDay,
    isActive,
    createdAt,
    updatedAt,
    lastSyncAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('native_language')) {
      context.handle(
        _nativeLanguageMeta,
        nativeLanguage.isAcceptableOrUnknown(
          data['native_language']!,
          _nativeLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nativeLanguageMeta);
    }
    if (data.containsKey('max_new_cards_per_day')) {
      context.handle(
        _maxNewCardsPerDayMeta,
        maxNewCardsPerDay.isAcceptableOrUnknown(
          data['max_new_cards_per_day']!,
          _maxNewCardsPerDayMeta,
        ),
      );
    }
    if (data.containsKey('max_reviews_per_day')) {
      context.handle(
        _maxReviewsPerDayMeta,
        maxReviewsPerDay.isAcceptableOrUnknown(
          data['max_reviews_per_day']!,
          _maxReviewsPerDayMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      nativeLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_language'],
      )!,
      maxNewCardsPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_new_cards_per_day'],
      )!,
      maxReviewsPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_reviews_per_day'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
    );
  }

  @override
  $DeckTableTable createAlias(String alias) {
    return $DeckTableTable(attachedDatabase, alias);
  }
}

class DeckTableData extends DataClass implements Insertable<DeckTableData> {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String language;
  final String nativeLanguage;
  final int maxNewCardsPerDay;
  final int maxReviewsPerDay;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncAt;
  const DeckTableData({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.language,
    required this.nativeLanguage,
    required this.maxNewCardsPerDay,
    required this.maxReviewsPerDay,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['language'] = Variable<String>(language);
    map['native_language'] = Variable<String>(nativeLanguage);
    map['max_new_cards_per_day'] = Variable<int>(maxNewCardsPerDay);
    map['max_reviews_per_day'] = Variable<int>(maxReviewsPerDay);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    return map;
  }

  DeckTableCompanion toCompanion(bool nullToAbsent) {
    return DeckTableCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      language: Value(language),
      nativeLanguage: Value(nativeLanguage),
      maxNewCardsPerDay: Value(maxNewCardsPerDay),
      maxReviewsPerDay: Value(maxReviewsPerDay),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
    );
  }

  factory DeckTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      language: serializer.fromJson<String>(json['language']),
      nativeLanguage: serializer.fromJson<String>(json['nativeLanguage']),
      maxNewCardsPerDay: serializer.fromJson<int>(json['maxNewCardsPerDay']),
      maxReviewsPerDay: serializer.fromJson<int>(json['maxReviewsPerDay']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'language': serializer.toJson<String>(language),
      'nativeLanguage': serializer.toJson<String>(nativeLanguage),
      'maxNewCardsPerDay': serializer.toJson<int>(maxNewCardsPerDay),
      'maxReviewsPerDay': serializer.toJson<int>(maxReviewsPerDay),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
    };
  }

  DeckTableData copyWith({
    String? id,
    String? userId,
    String? name,
    Value<String?> description = const Value.absent(),
    String? language,
    String? nativeLanguage,
    int? maxNewCardsPerDay,
    int? maxReviewsPerDay,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncAt = const Value.absent(),
  }) => DeckTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    language: language ?? this.language,
    nativeLanguage: nativeLanguage ?? this.nativeLanguage,
    maxNewCardsPerDay: maxNewCardsPerDay ?? this.maxNewCardsPerDay,
    maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
  );
  DeckTableData copyWithCompanion(DeckTableCompanion data) {
    return DeckTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      language: data.language.present ? data.language.value : this.language,
      nativeLanguage: data.nativeLanguage.present
          ? data.nativeLanguage.value
          : this.nativeLanguage,
      maxNewCardsPerDay: data.maxNewCardsPerDay.present
          ? data.maxNewCardsPerDay.value
          : this.maxNewCardsPerDay,
      maxReviewsPerDay: data.maxReviewsPerDay.present
          ? data.maxReviewsPerDay.value
          : this.maxReviewsPerDay,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('language: $language, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('maxNewCardsPerDay: $maxNewCardsPerDay, ')
          ..write('maxReviewsPerDay: $maxReviewsPerDay, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    description,
    language,
    nativeLanguage,
    maxNewCardsPerDay,
    maxReviewsPerDay,
    isActive,
    createdAt,
    updatedAt,
    lastSyncAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.description == this.description &&
          other.language == this.language &&
          other.nativeLanguage == this.nativeLanguage &&
          other.maxNewCardsPerDay == this.maxNewCardsPerDay &&
          other.maxReviewsPerDay == this.maxReviewsPerDay &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncAt == this.lastSyncAt);
}

class DeckTableCompanion extends UpdateCompanion<DeckTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> language;
  final Value<String> nativeLanguage;
  final Value<int> maxNewCardsPerDay;
  final Value<int> maxReviewsPerDay;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncAt;
  final Value<int> rowid;
  const DeckTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.language = const Value.absent(),
    this.nativeLanguage = const Value.absent(),
    this.maxNewCardsPerDay = const Value.absent(),
    this.maxReviewsPerDay = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeckTableCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.description = const Value.absent(),
    required String language,
    required String nativeLanguage,
    this.maxNewCardsPerDay = const Value.absent(),
    this.maxReviewsPerDay = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       language = Value(language),
       nativeLanguage = Value(nativeLanguage),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DeckTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? language,
    Expression<String>? nativeLanguage,
    Expression<int>? maxNewCardsPerDay,
    Expression<int>? maxReviewsPerDay,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (language != null) 'language': language,
      if (nativeLanguage != null) 'native_language': nativeLanguage,
      if (maxNewCardsPerDay != null) 'max_new_cards_per_day': maxNewCardsPerDay,
      if (maxReviewsPerDay != null) 'max_reviews_per_day': maxReviewsPerDay,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeckTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? language,
    Value<String>? nativeLanguage,
    Value<int>? maxNewCardsPerDay,
    Value<int>? maxReviewsPerDay,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncAt,
    Value<int>? rowid,
  }) {
    return DeckTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      language: language ?? this.language,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      maxNewCardsPerDay: maxNewCardsPerDay ?? this.maxNewCardsPerDay,
      maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (nativeLanguage.present) {
      map['native_language'] = Variable<String>(nativeLanguage.value);
    }
    if (maxNewCardsPerDay.present) {
      map['max_new_cards_per_day'] = Variable<int>(maxNewCardsPerDay.value);
    }
    if (maxReviewsPerDay.present) {
      map['max_reviews_per_day'] = Variable<int>(maxReviewsPerDay.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('language: $language, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('maxNewCardsPerDay: $maxNewCardsPerDay, ')
          ..write('maxReviewsPerDay: $maxReviewsPerDay, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTableTable extends CardTable
    with TableInfo<$CardTableTable, CardTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
    'front',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
    'back',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pronunciationMeta = const VerificationMeta(
    'pronunciation',
  );
  @override
  late final GeneratedColumn<String> pronunciation = GeneratedColumn<String>(
    'pronunciation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listeningRepetitionsMeta =
      const VerificationMeta('listeningRepetitions');
  @override
  late final GeneratedColumn<int> listeningRepetitions = GeneratedColumn<int>(
    'listening_repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _listeningEaseFactorMeta =
      const VerificationMeta('listeningEaseFactor');
  @override
  late final GeneratedColumn<double> listeningEaseFactor =
      GeneratedColumn<double>(
        'listening_ease_factor',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(2.5),
      );
  static const VerificationMeta _listeningIntervalMeta = const VerificationMeta(
    'listeningInterval',
  );
  @override
  late final GeneratedColumn<int> listeningInterval = GeneratedColumn<int>(
    'listening_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _listeningNextReviewMeta =
      const VerificationMeta('listeningNextReview');
  @override
  late final GeneratedColumn<DateTime> listeningNextReview =
      GeneratedColumn<DateTime>(
        'listening_next_review',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _speakingRepetitionsMeta =
      const VerificationMeta('speakingRepetitions');
  @override
  late final GeneratedColumn<int> speakingRepetitions = GeneratedColumn<int>(
    'speaking_repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _speakingEaseFactorMeta =
      const VerificationMeta('speakingEaseFactor');
  @override
  late final GeneratedColumn<double> speakingEaseFactor =
      GeneratedColumn<double>(
        'speaking_ease_factor',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(2.5),
      );
  static const VerificationMeta _speakingIntervalMeta = const VerificationMeta(
    'speakingInterval',
  );
  @override
  late final GeneratedColumn<int> speakingInterval = GeneratedColumn<int>(
    'speaking_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _speakingNextReviewMeta =
      const VerificationMeta('speakingNextReview');
  @override
  late final GeneratedColumn<DateTime> speakingNextReview =
      GeneratedColumn<DateTime>(
        'speaking_next_review',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    front,
    back,
    pronunciation,
    audioPath,
    listeningRepetitions,
    listeningEaseFactor,
    listeningInterval,
    listeningNextReview,
    speakingRepetitions,
    speakingEaseFactor,
    speakingInterval,
    speakingNextReview,
    isActive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('front')) {
      context.handle(
        _frontMeta,
        front.isAcceptableOrUnknown(data['front']!, _frontMeta),
      );
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
        _backMeta,
        back.isAcceptableOrUnknown(data['back']!, _backMeta),
      );
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('pronunciation')) {
      context.handle(
        _pronunciationMeta,
        pronunciation.isAcceptableOrUnknown(
          data['pronunciation']!,
          _pronunciationMeta,
        ),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('listening_repetitions')) {
      context.handle(
        _listeningRepetitionsMeta,
        listeningRepetitions.isAcceptableOrUnknown(
          data['listening_repetitions']!,
          _listeningRepetitionsMeta,
        ),
      );
    }
    if (data.containsKey('listening_ease_factor')) {
      context.handle(
        _listeningEaseFactorMeta,
        listeningEaseFactor.isAcceptableOrUnknown(
          data['listening_ease_factor']!,
          _listeningEaseFactorMeta,
        ),
      );
    }
    if (data.containsKey('listening_interval')) {
      context.handle(
        _listeningIntervalMeta,
        listeningInterval.isAcceptableOrUnknown(
          data['listening_interval']!,
          _listeningIntervalMeta,
        ),
      );
    }
    if (data.containsKey('listening_next_review')) {
      context.handle(
        _listeningNextReviewMeta,
        listeningNextReview.isAcceptableOrUnknown(
          data['listening_next_review']!,
          _listeningNextReviewMeta,
        ),
      );
    }
    if (data.containsKey('speaking_repetitions')) {
      context.handle(
        _speakingRepetitionsMeta,
        speakingRepetitions.isAcceptableOrUnknown(
          data['speaking_repetitions']!,
          _speakingRepetitionsMeta,
        ),
      );
    }
    if (data.containsKey('speaking_ease_factor')) {
      context.handle(
        _speakingEaseFactorMeta,
        speakingEaseFactor.isAcceptableOrUnknown(
          data['speaking_ease_factor']!,
          _speakingEaseFactorMeta,
        ),
      );
    }
    if (data.containsKey('speaking_interval')) {
      context.handle(
        _speakingIntervalMeta,
        speakingInterval.isAcceptableOrUnknown(
          data['speaking_interval']!,
          _speakingIntervalMeta,
        ),
      );
    }
    if (data.containsKey('speaking_next_review')) {
      context.handle(
        _speakingNextReviewMeta,
        speakingNextReview.isAcceptableOrUnknown(
          data['speaking_next_review']!,
          _speakingNextReviewMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      front: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}front'],
      )!,
      back: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}back'],
      )!,
      pronunciation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pronunciation'],
      ),
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      listeningRepetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listening_repetitions'],
      )!,
      listeningEaseFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}listening_ease_factor'],
      )!,
      listeningInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listening_interval'],
      )!,
      listeningNextReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}listening_next_review'],
      ),
      speakingRepetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speaking_repetitions'],
      )!,
      speakingEaseFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speaking_ease_factor'],
      )!,
      speakingInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speaking_interval'],
      )!,
      speakingNextReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}speaking_next_review'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CardTableTable createAlias(String alias) {
    return $CardTableTable(attachedDatabase, alias);
  }
}

class CardTableData extends DataClass implements Insertable<CardTableData> {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? pronunciation;
  final String? audioPath;
  final int listeningRepetitions;
  final double listeningEaseFactor;
  final int listeningInterval;
  final DateTime? listeningNextReview;
  final int speakingRepetitions;
  final double speakingEaseFactor;
  final int speakingInterval;
  final DateTime? speakingNextReview;
  final bool isActive;
  final DateTime updatedAt;
  const CardTableData({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.pronunciation,
    this.audioPath,
    required this.listeningRepetitions,
    required this.listeningEaseFactor,
    required this.listeningInterval,
    this.listeningNextReview,
    required this.speakingRepetitions,
    required this.speakingEaseFactor,
    required this.speakingInterval,
    this.speakingNextReview,
    required this.isActive,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    if (!nullToAbsent || pronunciation != null) {
      map['pronunciation'] = Variable<String>(pronunciation);
    }
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['listening_repetitions'] = Variable<int>(listeningRepetitions);
    map['listening_ease_factor'] = Variable<double>(listeningEaseFactor);
    map['listening_interval'] = Variable<int>(listeningInterval);
    if (!nullToAbsent || listeningNextReview != null) {
      map['listening_next_review'] = Variable<DateTime>(listeningNextReview);
    }
    map['speaking_repetitions'] = Variable<int>(speakingRepetitions);
    map['speaking_ease_factor'] = Variable<double>(speakingEaseFactor);
    map['speaking_interval'] = Variable<int>(speakingInterval);
    if (!nullToAbsent || speakingNextReview != null) {
      map['speaking_next_review'] = Variable<DateTime>(speakingNextReview);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CardTableCompanion toCompanion(bool nullToAbsent) {
    return CardTableCompanion(
      id: Value(id),
      deckId: Value(deckId),
      front: Value(front),
      back: Value(back),
      pronunciation: pronunciation == null && nullToAbsent
          ? const Value.absent()
          : Value(pronunciation),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      listeningRepetitions: Value(listeningRepetitions),
      listeningEaseFactor: Value(listeningEaseFactor),
      listeningInterval: Value(listeningInterval),
      listeningNextReview: listeningNextReview == null && nullToAbsent
          ? const Value.absent()
          : Value(listeningNextReview),
      speakingRepetitions: Value(speakingRepetitions),
      speakingEaseFactor: Value(speakingEaseFactor),
      speakingInterval: Value(speakingInterval),
      speakingNextReview: speakingNextReview == null && nullToAbsent
          ? const Value.absent()
          : Value(speakingNextReview),
      isActive: Value(isActive),
      updatedAt: Value(updatedAt),
    );
  }

  factory CardTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTableData(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      pronunciation: serializer.fromJson<String?>(json['pronunciation']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      listeningRepetitions: serializer.fromJson<int>(
        json['listeningRepetitions'],
      ),
      listeningEaseFactor: serializer.fromJson<double>(
        json['listeningEaseFactor'],
      ),
      listeningInterval: serializer.fromJson<int>(json['listeningInterval']),
      listeningNextReview: serializer.fromJson<DateTime?>(
        json['listeningNextReview'],
      ),
      speakingRepetitions: serializer.fromJson<int>(
        json['speakingRepetitions'],
      ),
      speakingEaseFactor: serializer.fromJson<double>(
        json['speakingEaseFactor'],
      ),
      speakingInterval: serializer.fromJson<int>(json['speakingInterval']),
      speakingNextReview: serializer.fromJson<DateTime?>(
        json['speakingNextReview'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'pronunciation': serializer.toJson<String?>(pronunciation),
      'audioPath': serializer.toJson<String?>(audioPath),
      'listeningRepetitions': serializer.toJson<int>(listeningRepetitions),
      'listeningEaseFactor': serializer.toJson<double>(listeningEaseFactor),
      'listeningInterval': serializer.toJson<int>(listeningInterval),
      'listeningNextReview': serializer.toJson<DateTime?>(listeningNextReview),
      'speakingRepetitions': serializer.toJson<int>(speakingRepetitions),
      'speakingEaseFactor': serializer.toJson<double>(speakingEaseFactor),
      'speakingInterval': serializer.toJson<int>(speakingInterval),
      'speakingNextReview': serializer.toJson<DateTime?>(speakingNextReview),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CardTableData copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    Value<String?> pronunciation = const Value.absent(),
    Value<String?> audioPath = const Value.absent(),
    int? listeningRepetitions,
    double? listeningEaseFactor,
    int? listeningInterval,
    Value<DateTime?> listeningNextReview = const Value.absent(),
    int? speakingRepetitions,
    double? speakingEaseFactor,
    int? speakingInterval,
    Value<DateTime?> speakingNextReview = const Value.absent(),
    bool? isActive,
    DateTime? updatedAt,
  }) => CardTableData(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    front: front ?? this.front,
    back: back ?? this.back,
    pronunciation: pronunciation.present
        ? pronunciation.value
        : this.pronunciation,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    listeningRepetitions: listeningRepetitions ?? this.listeningRepetitions,
    listeningEaseFactor: listeningEaseFactor ?? this.listeningEaseFactor,
    listeningInterval: listeningInterval ?? this.listeningInterval,
    listeningNextReview: listeningNextReview.present
        ? listeningNextReview.value
        : this.listeningNextReview,
    speakingRepetitions: speakingRepetitions ?? this.speakingRepetitions,
    speakingEaseFactor: speakingEaseFactor ?? this.speakingEaseFactor,
    speakingInterval: speakingInterval ?? this.speakingInterval,
    speakingNextReview: speakingNextReview.present
        ? speakingNextReview.value
        : this.speakingNextReview,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CardTableData copyWithCompanion(CardTableCompanion data) {
    return CardTableData(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      pronunciation: data.pronunciation.present
          ? data.pronunciation.value
          : this.pronunciation,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      listeningRepetitions: data.listeningRepetitions.present
          ? data.listeningRepetitions.value
          : this.listeningRepetitions,
      listeningEaseFactor: data.listeningEaseFactor.present
          ? data.listeningEaseFactor.value
          : this.listeningEaseFactor,
      listeningInterval: data.listeningInterval.present
          ? data.listeningInterval.value
          : this.listeningInterval,
      listeningNextReview: data.listeningNextReview.present
          ? data.listeningNextReview.value
          : this.listeningNextReview,
      speakingRepetitions: data.speakingRepetitions.present
          ? data.speakingRepetitions.value
          : this.speakingRepetitions,
      speakingEaseFactor: data.speakingEaseFactor.present
          ? data.speakingEaseFactor.value
          : this.speakingEaseFactor,
      speakingInterval: data.speakingInterval.present
          ? data.speakingInterval.value
          : this.speakingInterval,
      speakingNextReview: data.speakingNextReview.present
          ? data.speakingNextReview.value
          : this.speakingNextReview,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTableData(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('audioPath: $audioPath, ')
          ..write('listeningRepetitions: $listeningRepetitions, ')
          ..write('listeningEaseFactor: $listeningEaseFactor, ')
          ..write('listeningInterval: $listeningInterval, ')
          ..write('listeningNextReview: $listeningNextReview, ')
          ..write('speakingRepetitions: $speakingRepetitions, ')
          ..write('speakingEaseFactor: $speakingEaseFactor, ')
          ..write('speakingInterval: $speakingInterval, ')
          ..write('speakingNextReview: $speakingNextReview, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    front,
    back,
    pronunciation,
    audioPath,
    listeningRepetitions,
    listeningEaseFactor,
    listeningInterval,
    listeningNextReview,
    speakingRepetitions,
    speakingEaseFactor,
    speakingInterval,
    speakingNextReview,
    isActive,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTableData &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.front == this.front &&
          other.back == this.back &&
          other.pronunciation == this.pronunciation &&
          other.audioPath == this.audioPath &&
          other.listeningRepetitions == this.listeningRepetitions &&
          other.listeningEaseFactor == this.listeningEaseFactor &&
          other.listeningInterval == this.listeningInterval &&
          other.listeningNextReview == this.listeningNextReview &&
          other.speakingRepetitions == this.speakingRepetitions &&
          other.speakingEaseFactor == this.speakingEaseFactor &&
          other.speakingInterval == this.speakingInterval &&
          other.speakingNextReview == this.speakingNextReview &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class CardTableCompanion extends UpdateCompanion<CardTableData> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> front;
  final Value<String> back;
  final Value<String?> pronunciation;
  final Value<String?> audioPath;
  final Value<int> listeningRepetitions;
  final Value<double> listeningEaseFactor;
  final Value<int> listeningInterval;
  final Value<DateTime?> listeningNextReview;
  final Value<int> speakingRepetitions;
  final Value<double> speakingEaseFactor;
  final Value<int> speakingInterval;
  final Value<DateTime?> speakingNextReview;
  final Value<bool> isActive;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CardTableCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.pronunciation = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.listeningRepetitions = const Value.absent(),
    this.listeningEaseFactor = const Value.absent(),
    this.listeningInterval = const Value.absent(),
    this.listeningNextReview = const Value.absent(),
    this.speakingRepetitions = const Value.absent(),
    this.speakingEaseFactor = const Value.absent(),
    this.speakingInterval = const Value.absent(),
    this.speakingNextReview = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTableCompanion.insert({
    required String id,
    required String deckId,
    required String front,
    required String back,
    this.pronunciation = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.listeningRepetitions = const Value.absent(),
    this.listeningEaseFactor = const Value.absent(),
    this.listeningInterval = const Value.absent(),
    this.listeningNextReview = const Value.absent(),
    this.speakingRepetitions = const Value.absent(),
    this.speakingEaseFactor = const Value.absent(),
    this.speakingInterval = const Value.absent(),
    this.speakingNextReview = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deckId = Value(deckId),
       front = Value(front),
       back = Value(back),
       updatedAt = Value(updatedAt);
  static Insertable<CardTableData> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? pronunciation,
    Expression<String>? audioPath,
    Expression<int>? listeningRepetitions,
    Expression<double>? listeningEaseFactor,
    Expression<int>? listeningInterval,
    Expression<DateTime>? listeningNextReview,
    Expression<int>? speakingRepetitions,
    Expression<double>? speakingEaseFactor,
    Expression<int>? speakingInterval,
    Expression<DateTime>? speakingNextReview,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (pronunciation != null) 'pronunciation': pronunciation,
      if (audioPath != null) 'audio_path': audioPath,
      if (listeningRepetitions != null)
        'listening_repetitions': listeningRepetitions,
      if (listeningEaseFactor != null)
        'listening_ease_factor': listeningEaseFactor,
      if (listeningInterval != null) 'listening_interval': listeningInterval,
      if (listeningNextReview != null)
        'listening_next_review': listeningNextReview,
      if (speakingRepetitions != null)
        'speaking_repetitions': speakingRepetitions,
      if (speakingEaseFactor != null)
        'speaking_ease_factor': speakingEaseFactor,
      if (speakingInterval != null) 'speaking_interval': speakingInterval,
      if (speakingNextReview != null)
        'speaking_next_review': speakingNextReview,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTableCompanion copyWith({
    Value<String>? id,
    Value<String>? deckId,
    Value<String>? front,
    Value<String>? back,
    Value<String?>? pronunciation,
    Value<String?>? audioPath,
    Value<int>? listeningRepetitions,
    Value<double>? listeningEaseFactor,
    Value<int>? listeningInterval,
    Value<DateTime?>? listeningNextReview,
    Value<int>? speakingRepetitions,
    Value<double>? speakingEaseFactor,
    Value<int>? speakingInterval,
    Value<DateTime?>? speakingNextReview,
    Value<bool>? isActive,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CardTableCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      pronunciation: pronunciation ?? this.pronunciation,
      audioPath: audioPath ?? this.audioPath,
      listeningRepetitions: listeningRepetitions ?? this.listeningRepetitions,
      listeningEaseFactor: listeningEaseFactor ?? this.listeningEaseFactor,
      listeningInterval: listeningInterval ?? this.listeningInterval,
      listeningNextReview: listeningNextReview ?? this.listeningNextReview,
      speakingRepetitions: speakingRepetitions ?? this.speakingRepetitions,
      speakingEaseFactor: speakingEaseFactor ?? this.speakingEaseFactor,
      speakingInterval: speakingInterval ?? this.speakingInterval,
      speakingNextReview: speakingNextReview ?? this.speakingNextReview,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (pronunciation.present) {
      map['pronunciation'] = Variable<String>(pronunciation.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (listeningRepetitions.present) {
      map['listening_repetitions'] = Variable<int>(listeningRepetitions.value);
    }
    if (listeningEaseFactor.present) {
      map['listening_ease_factor'] = Variable<double>(
        listeningEaseFactor.value,
      );
    }
    if (listeningInterval.present) {
      map['listening_interval'] = Variable<int>(listeningInterval.value);
    }
    if (listeningNextReview.present) {
      map['listening_next_review'] = Variable<DateTime>(
        listeningNextReview.value,
      );
    }
    if (speakingRepetitions.present) {
      map['speaking_repetitions'] = Variable<int>(speakingRepetitions.value);
    }
    if (speakingEaseFactor.present) {
      map['speaking_ease_factor'] = Variable<double>(speakingEaseFactor.value);
    }
    if (speakingInterval.present) {
      map['speaking_interval'] = Variable<int>(speakingInterval.value);
    }
    if (speakingNextReview.present) {
      map['speaking_next_review'] = Variable<DateTime>(
        speakingNextReview.value,
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTableCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('audioPath: $audioPath, ')
          ..write('listeningRepetitions: $listeningRepetitions, ')
          ..write('listeningEaseFactor: $listeningEaseFactor, ')
          ..write('listeningInterval: $listeningInterval, ')
          ..write('listeningNextReview: $listeningNextReview, ')
          ..write('speakingRepetitions: $speakingRepetitions, ')
          ..write('speakingEaseFactor: $speakingEaseFactor, ')
          ..write('speakingInterval: $speakingInterval, ')
          ..write('speakingNextReview: $speakingNextReview, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingSyncTableTable extends PendingSyncTable
    with TableInfo<$PendingSyncTableTable, PendingSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSyncTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operation,
    payload,
    createdAt,
    retryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingSyncData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSyncData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
    );
  }

  @override
  $PendingSyncTableTable createAlias(String alias) {
    return $PendingSyncTableTable(attachedDatabase, alias);
  }
}

class PendingSyncData extends DataClass implements Insertable<PendingSyncData> {
  final int id;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  const PendingSyncData({
    required this.id,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  PendingSyncTableCompanion toCompanion(bool nullToAbsent) {
    return PendingSyncTableCompanion(
      id: Value(id),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory PendingSyncData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSyncData(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  PendingSyncData copyWith({
    int? id,
    String? operation,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
  }) => PendingSyncData(
    id: id ?? this.id,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
  );
  PendingSyncData copyWithCompanion(PendingSyncTableCompanion data) {
    return PendingSyncData(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncData(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, operation, payload, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSyncData &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class PendingSyncTableCompanion extends UpdateCompanion<PendingSyncData> {
  final Value<int> id;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const PendingSyncTableCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  PendingSyncTableCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required String payload,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
  }) : operation = Value(operation),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<PendingSyncData> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  PendingSyncTableCompanion copyWith({
    Value<int>? id,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
  }) {
    return PendingSyncTableCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncTableCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DeckTableTable deckTable = $DeckTableTable(this);
  late final $CardTableTable cardTable = $CardTableTable(this);
  late final $PendingSyncTableTable pendingSyncTable = $PendingSyncTableTable(
    this,
  );
  late final DeckDao deckDao = DeckDao(this as AppDatabase);
  late final CardDao cardDao = CardDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    deckTable,
    cardTable,
    pendingSyncTable,
  ];
}

typedef $$DeckTableTableCreateCompanionBuilder =
    DeckTableCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String?> description,
      required String language,
      required String nativeLanguage,
      Value<int> maxNewCardsPerDay,
      Value<int> maxReviewsPerDay,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> lastSyncAt,
      Value<int> rowid,
    });
typedef $$DeckTableTableUpdateCompanionBuilder =
    DeckTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String?> description,
      Value<String> language,
      Value<String> nativeLanguage,
      Value<int> maxNewCardsPerDay,
      Value<int> maxReviewsPerDay,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncAt,
      Value<int> rowid,
    });

class $$DeckTableTableFilterComposer
    extends Composer<_$AppDatabase, $DeckTableTable> {
  $$DeckTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxNewCardsPerDay => $composableBuilder(
    column: $table.maxNewCardsPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxReviewsPerDay => $composableBuilder(
    column: $table.maxReviewsPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeckTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DeckTableTable> {
  $$DeckTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxNewCardsPerDay => $composableBuilder(
    column: $table.maxNewCardsPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxReviewsPerDay => $composableBuilder(
    column: $table.maxReviewsPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeckTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeckTableTable> {
  $$DeckTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxNewCardsPerDay => $composableBuilder(
    column: $table.maxNewCardsPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxReviewsPerDay => $composableBuilder(
    column: $table.maxReviewsPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );
}

class $$DeckTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeckTableTable,
          DeckTableData,
          $$DeckTableTableFilterComposer,
          $$DeckTableTableOrderingComposer,
          $$DeckTableTableAnnotationComposer,
          $$DeckTableTableCreateCompanionBuilder,
          $$DeckTableTableUpdateCompanionBuilder,
          (
            DeckTableData,
            BaseReferences<_$AppDatabase, $DeckTableTable, DeckTableData>,
          ),
          DeckTableData,
          PrefetchHooks Function()
        > {
  $$DeckTableTableTableManager(_$AppDatabase db, $DeckTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeckTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> nativeLanguage = const Value.absent(),
                Value<int> maxNewCardsPerDay = const Value.absent(),
                Value<int> maxReviewsPerDay = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeckTableCompanion(
                id: id,
                userId: userId,
                name: name,
                description: description,
                language: language,
                nativeLanguage: nativeLanguage,
                maxNewCardsPerDay: maxNewCardsPerDay,
                maxReviewsPerDay: maxReviewsPerDay,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String?> description = const Value.absent(),
                required String language,
                required String nativeLanguage,
                Value<int> maxNewCardsPerDay = const Value.absent(),
                Value<int> maxReviewsPerDay = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeckTableCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                description: description,
                language: language,
                nativeLanguage: nativeLanguage,
                maxNewCardsPerDay: maxNewCardsPerDay,
                maxReviewsPerDay: maxReviewsPerDay,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeckTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeckTableTable,
      DeckTableData,
      $$DeckTableTableFilterComposer,
      $$DeckTableTableOrderingComposer,
      $$DeckTableTableAnnotationComposer,
      $$DeckTableTableCreateCompanionBuilder,
      $$DeckTableTableUpdateCompanionBuilder,
      (
        DeckTableData,
        BaseReferences<_$AppDatabase, $DeckTableTable, DeckTableData>,
      ),
      DeckTableData,
      PrefetchHooks Function()
    >;
typedef $$CardTableTableCreateCompanionBuilder =
    CardTableCompanion Function({
      required String id,
      required String deckId,
      required String front,
      required String back,
      Value<String?> pronunciation,
      Value<String?> audioPath,
      Value<int> listeningRepetitions,
      Value<double> listeningEaseFactor,
      Value<int> listeningInterval,
      Value<DateTime?> listeningNextReview,
      Value<int> speakingRepetitions,
      Value<double> speakingEaseFactor,
      Value<int> speakingInterval,
      Value<DateTime?> speakingNextReview,
      Value<bool> isActive,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CardTableTableUpdateCompanionBuilder =
    CardTableCompanion Function({
      Value<String> id,
      Value<String> deckId,
      Value<String> front,
      Value<String> back,
      Value<String?> pronunciation,
      Value<String?> audioPath,
      Value<int> listeningRepetitions,
      Value<double> listeningEaseFactor,
      Value<int> listeningInterval,
      Value<DateTime?> listeningNextReview,
      Value<int> speakingRepetitions,
      Value<double> speakingEaseFactor,
      Value<int> speakingInterval,
      Value<DateTime?> speakingNextReview,
      Value<bool> isActive,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CardTableTableFilterComposer
    extends Composer<_$AppDatabase, $CardTableTable> {
  $$CardTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listeningRepetitions => $composableBuilder(
    column: $table.listeningRepetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get listeningEaseFactor => $composableBuilder(
    column: $table.listeningEaseFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listeningInterval => $composableBuilder(
    column: $table.listeningInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get listeningNextReview => $composableBuilder(
    column: $table.listeningNextReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speakingRepetitions => $composableBuilder(
    column: $table.speakingRepetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speakingEaseFactor => $composableBuilder(
    column: $table.speakingEaseFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speakingInterval => $composableBuilder(
    column: $table.speakingInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get speakingNextReview => $composableBuilder(
    column: $table.speakingNextReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTableTable> {
  $$CardTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listeningRepetitions => $composableBuilder(
    column: $table.listeningRepetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get listeningEaseFactor => $composableBuilder(
    column: $table.listeningEaseFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listeningInterval => $composableBuilder(
    column: $table.listeningInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get listeningNextReview => $composableBuilder(
    column: $table.listeningNextReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speakingRepetitions => $composableBuilder(
    column: $table.speakingRepetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speakingEaseFactor => $composableBuilder(
    column: $table.speakingEaseFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speakingInterval => $composableBuilder(
    column: $table.speakingInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get speakingNextReview => $composableBuilder(
    column: $table.speakingNextReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTableTable> {
  $$CardTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<int> get listeningRepetitions => $composableBuilder(
    column: $table.listeningRepetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get listeningEaseFactor => $composableBuilder(
    column: $table.listeningEaseFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get listeningInterval => $composableBuilder(
    column: $table.listeningInterval,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get listeningNextReview => $composableBuilder(
    column: $table.listeningNextReview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speakingRepetitions => $composableBuilder(
    column: $table.speakingRepetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speakingEaseFactor => $composableBuilder(
    column: $table.speakingEaseFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speakingInterval => $composableBuilder(
    column: $table.speakingInterval,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get speakingNextReview => $composableBuilder(
    column: $table.speakingNextReview,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CardTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardTableTable,
          CardTableData,
          $$CardTableTableFilterComposer,
          $$CardTableTableOrderingComposer,
          $$CardTableTableAnnotationComposer,
          $$CardTableTableCreateCompanionBuilder,
          $$CardTableTableUpdateCompanionBuilder,
          (
            CardTableData,
            BaseReferences<_$AppDatabase, $CardTableTable, CardTableData>,
          ),
          CardTableData,
          PrefetchHooks Function()
        > {
  $$CardTableTableTableManager(_$AppDatabase db, $CardTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String> front = const Value.absent(),
                Value<String> back = const Value.absent(),
                Value<String?> pronunciation = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<int> listeningRepetitions = const Value.absent(),
                Value<double> listeningEaseFactor = const Value.absent(),
                Value<int> listeningInterval = const Value.absent(),
                Value<DateTime?> listeningNextReview = const Value.absent(),
                Value<int> speakingRepetitions = const Value.absent(),
                Value<double> speakingEaseFactor = const Value.absent(),
                Value<int> speakingInterval = const Value.absent(),
                Value<DateTime?> speakingNextReview = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardTableCompanion(
                id: id,
                deckId: deckId,
                front: front,
                back: back,
                pronunciation: pronunciation,
                audioPath: audioPath,
                listeningRepetitions: listeningRepetitions,
                listeningEaseFactor: listeningEaseFactor,
                listeningInterval: listeningInterval,
                listeningNextReview: listeningNextReview,
                speakingRepetitions: speakingRepetitions,
                speakingEaseFactor: speakingEaseFactor,
                speakingInterval: speakingInterval,
                speakingNextReview: speakingNextReview,
                isActive: isActive,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deckId,
                required String front,
                required String back,
                Value<String?> pronunciation = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<int> listeningRepetitions = const Value.absent(),
                Value<double> listeningEaseFactor = const Value.absent(),
                Value<int> listeningInterval = const Value.absent(),
                Value<DateTime?> listeningNextReview = const Value.absent(),
                Value<int> speakingRepetitions = const Value.absent(),
                Value<double> speakingEaseFactor = const Value.absent(),
                Value<int> speakingInterval = const Value.absent(),
                Value<DateTime?> speakingNextReview = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CardTableCompanion.insert(
                id: id,
                deckId: deckId,
                front: front,
                back: back,
                pronunciation: pronunciation,
                audioPath: audioPath,
                listeningRepetitions: listeningRepetitions,
                listeningEaseFactor: listeningEaseFactor,
                listeningInterval: listeningInterval,
                listeningNextReview: listeningNextReview,
                speakingRepetitions: speakingRepetitions,
                speakingEaseFactor: speakingEaseFactor,
                speakingInterval: speakingInterval,
                speakingNextReview: speakingNextReview,
                isActive: isActive,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardTableTable,
      CardTableData,
      $$CardTableTableFilterComposer,
      $$CardTableTableOrderingComposer,
      $$CardTableTableAnnotationComposer,
      $$CardTableTableCreateCompanionBuilder,
      $$CardTableTableUpdateCompanionBuilder,
      (
        CardTableData,
        BaseReferences<_$AppDatabase, $CardTableTable, CardTableData>,
      ),
      CardTableData,
      PrefetchHooks Function()
    >;
typedef $$PendingSyncTableTableCreateCompanionBuilder =
    PendingSyncTableCompanion Function({
      Value<int> id,
      required String operation,
      required String payload,
      required DateTime createdAt,
      Value<int> retryCount,
    });
typedef $$PendingSyncTableTableUpdateCompanionBuilder =
    PendingSyncTableCompanion Function({
      Value<int> id,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> retryCount,
    });

class $$PendingSyncTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingSyncTableTable> {
  $$PendingSyncTableTableFilterComposer({
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

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingSyncTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingSyncTableTable> {
  $$PendingSyncTableTableOrderingComposer({
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

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingSyncTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingSyncTableTable> {
  $$PendingSyncTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );
}

class $$PendingSyncTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingSyncTableTable,
          PendingSyncData,
          $$PendingSyncTableTableFilterComposer,
          $$PendingSyncTableTableOrderingComposer,
          $$PendingSyncTableTableAnnotationComposer,
          $$PendingSyncTableTableCreateCompanionBuilder,
          $$PendingSyncTableTableUpdateCompanionBuilder,
          (
            PendingSyncData,
            BaseReferences<
              _$AppDatabase,
              $PendingSyncTableTable,
              PendingSyncData
            >,
          ),
          PendingSyncData,
          PrefetchHooks Function()
        > {
  $$PendingSyncTableTableTableManager(
    _$AppDatabase db,
    $PendingSyncTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSyncTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingSyncTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingSyncTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => PendingSyncTableCompanion(
                id: id,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operation,
                required String payload,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
              }) => PendingSyncTableCompanion.insert(
                id: id,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingSyncTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingSyncTableTable,
      PendingSyncData,
      $$PendingSyncTableTableFilterComposer,
      $$PendingSyncTableTableOrderingComposer,
      $$PendingSyncTableTableAnnotationComposer,
      $$PendingSyncTableTableCreateCompanionBuilder,
      $$PendingSyncTableTableUpdateCompanionBuilder,
      (
        PendingSyncData,
        BaseReferences<_$AppDatabase, $PendingSyncTableTable, PendingSyncData>,
      ),
      PendingSyncData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DeckTableTableTableManager get deckTable =>
      $$DeckTableTableTableManager(_db, _db.deckTable);
  $$CardTableTableTableManager get cardTable =>
      $$CardTableTableTableManager(_db, _db.cardTable);
  $$PendingSyncTableTableTableManager get pendingSyncTable =>
      $$PendingSyncTableTableTableManager(_db, _db.pendingSyncTable);
}
