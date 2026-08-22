// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameUrMeta = const VerificationMeta('nameUr');
  @override
  late final GeneratedColumn<String> nameUr = GeneratedColumn<String>(
      'name_ur', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<AccountType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AccountType>($AccountsTable.$convertertype);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _iconKeyMeta =
      const VerificationMeta('iconKey');
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
      'icon_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isSystemMeta =
      const VerificationMeta('isSystem');
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
      'is_system', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_system" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtHlcMeta =
      const VerificationMeta('createdAtHlc');
  @override
  late final GeneratedColumn<String> createdAtHlc = GeneratedColumn<String>(
      'created_at_hlc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtHlcMeta =
      const VerificationMeta('updatedAtHlc');
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
      'updated_at_hlc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        code,
        name,
        nameUr,
        type,
        parentId,
        iconKey,
        colorValue,
        isSystem,
        isArchived,
        sortOrder,
        createdAtHlc,
        updatedAtHlc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<AccountRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_ur')) {
      context.handle(_nameUrMeta,
          nameUr.isAcceptableOrUnknown(data['name_ur']!, _nameUrMeta));
    } else if (isInserting) {
      context.missing(_nameUrMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('icon_key')) {
      context.handle(_iconKeyMeta,
          iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta));
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    }
    if (data.containsKey('is_system')) {
      context.handle(_isSystemMeta,
          isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at_hlc')) {
      context.handle(
          _createdAtHlcMeta,
          createdAtHlc.isAcceptableOrUnknown(
              data['created_at_hlc']!, _createdAtHlcMeta));
    } else if (isInserting) {
      context.missing(_createdAtHlcMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
          _updatedAtHlcMeta,
          updatedAtHlc.isAcceptableOrUnknown(
              data['updated_at_hlc']!, _updatedAtHlcMeta));
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nameUr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_ur'])!,
      type: $AccountsTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      iconKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_key']),
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value']),
      isSystem: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_system'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAtHlc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at_hlc'])!,
      updatedAtHlc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at_hlc'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountType, int, int> $convertertype =
      const EnumIndexConverter<AccountType>(AccountType.values);
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String id;

  /// Stable slug such as `expense.groceries`. Seeded accounts derive their id
  /// from this, so two phones in the same household independently create the
  /// *same* id for "Groceries" and never end up with duplicate categories
  /// once they sync.
  final String code;
  final String name;
  final String nameUr;
  final AccountType type;
  final String? parentId;

  /// Icon name resolved by the UI layer. Kept as a string so the data layer
  /// never imports Flutter and stays testable without a device.
  final String? iconKey;
  final int? colorValue;

  /// Seeded accounts cannot be deleted, only hidden. Deleting one would orphan
  /// history the user still needs to read.
  final bool isSystem;
  final bool isArchived;
  final int sortOrder;
  final String createdAtHlc;
  final String updatedAtHlc;
  const AccountRow(
      {required this.id,
      required this.code,
      required this.name,
      required this.nameUr,
      required this.type,
      this.parentId,
      this.iconKey,
      this.colorValue,
      required this.isSystem,
      required this.isArchived,
      required this.sortOrder,
      required this.createdAtHlc,
      required this.updatedAtHlc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['name_ur'] = Variable<String>(nameUr);
    {
      map['type'] = Variable<int>($AccountsTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || iconKey != null) {
      map['icon_key'] = Variable<String>(iconKey);
    }
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['is_system'] = Variable<bool>(isSystem);
    map['is_archived'] = Variable<bool>(isArchived);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at_hlc'] = Variable<String>(createdAtHlc);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      nameUr: Value(nameUr),
      type: Value(type),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      iconKey: iconKey == null && nullToAbsent
          ? const Value.absent()
          : Value(iconKey),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      isSystem: Value(isSystem),
      isArchived: Value(isArchived),
      sortOrder: Value(sortOrder),
      createdAtHlc: Value(createdAtHlc),
      updatedAtHlc: Value(updatedAtHlc),
    );
  }

  factory AccountRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      nameUr: serializer.fromJson<String>(json['nameUr']),
      type: $AccountsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      parentId: serializer.fromJson<String?>(json['parentId']),
      iconKey: serializer.fromJson<String?>(json['iconKey']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAtHlc: serializer.fromJson<String>(json['createdAtHlc']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'nameUr': serializer.toJson<String>(nameUr),
      'type':
          serializer.toJson<int>($AccountsTable.$convertertype.toJson(type)),
      'parentId': serializer.toJson<String?>(parentId),
      'iconKey': serializer.toJson<String?>(iconKey),
      'colorValue': serializer.toJson<int?>(colorValue),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isArchived': serializer.toJson<bool>(isArchived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAtHlc': serializer.toJson<String>(createdAtHlc),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
    };
  }

  AccountRow copyWith(
          {String? id,
          String? code,
          String? name,
          String? nameUr,
          AccountType? type,
          Value<String?> parentId = const Value.absent(),
          Value<String?> iconKey = const Value.absent(),
          Value<int?> colorValue = const Value.absent(),
          bool? isSystem,
          bool? isArchived,
          int? sortOrder,
          String? createdAtHlc,
          String? updatedAtHlc}) =>
      AccountRow(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        nameUr: nameUr ?? this.nameUr,
        type: type ?? this.type,
        parentId: parentId.present ? parentId.value : this.parentId,
        iconKey: iconKey.present ? iconKey.value : this.iconKey,
        colorValue: colorValue.present ? colorValue.value : this.colorValue,
        isSystem: isSystem ?? this.isSystem,
        isArchived: isArchived ?? this.isArchived,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAtHlc: createdAtHlc ?? this.createdAtHlc,
        updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      nameUr: data.nameUr.present ? data.nameUr.value : this.nameUr,
      type: data.type.present ? data.type.value : this.type,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAtHlc: data.createdAtHlc.present
          ? data.createdAtHlc.value
          : this.createdAtHlc,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('nameUr: $nameUr, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorValue: $colorValue, ')
          ..write('isSystem: $isSystem, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      code,
      name,
      nameUr,
      type,
      parentId,
      iconKey,
      colorValue,
      isSystem,
      isArchived,
      sortOrder,
      createdAtHlc,
      updatedAtHlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.nameUr == this.nameUr &&
          other.type == this.type &&
          other.parentId == this.parentId &&
          other.iconKey == this.iconKey &&
          other.colorValue == this.colorValue &&
          other.isSystem == this.isSystem &&
          other.isArchived == this.isArchived &&
          other.sortOrder == this.sortOrder &&
          other.createdAtHlc == this.createdAtHlc &&
          other.updatedAtHlc == this.updatedAtHlc);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> nameUr;
  final Value<AccountType> type;
  final Value<String?> parentId;
  final Value<String?> iconKey;
  final Value<int?> colorValue;
  final Value<bool> isSystem;
  final Value<bool> isArchived;
  final Value<int> sortOrder;
  final Value<String> createdAtHlc;
  final Value<String> updatedAtHlc;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.nameUr = const Value.absent(),
    this.type = const Value.absent(),
    this.parentId = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAtHlc = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String code,
    required String name,
    required String nameUr,
    required AccountType type,
    this.parentId = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required String createdAtHlc,
    required String updatedAtHlc,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        code = Value(code),
        name = Value(name),
        nameUr = Value(nameUr),
        type = Value(type),
        createdAtHlc = Value(createdAtHlc),
        updatedAtHlc = Value(updatedAtHlc);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? nameUr,
    Expression<int>? type,
    Expression<String>? parentId,
    Expression<String>? iconKey,
    Expression<int>? colorValue,
    Expression<bool>? isSystem,
    Expression<bool>? isArchived,
    Expression<int>? sortOrder,
    Expression<String>? createdAtHlc,
    Expression<String>? updatedAtHlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (nameUr != null) 'name_ur': nameUr,
      if (type != null) 'type': type,
      if (parentId != null) 'parent_id': parentId,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorValue != null) 'color_value': colorValue,
      if (isSystem != null) 'is_system': isSystem,
      if (isArchived != null) 'is_archived': isArchived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAtHlc != null) 'created_at_hlc': createdAtHlc,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? code,
      Value<String>? name,
      Value<String>? nameUr,
      Value<AccountType>? type,
      Value<String?>? parentId,
      Value<String?>? iconKey,
      Value<int?>? colorValue,
      Value<bool>? isSystem,
      Value<bool>? isArchived,
      Value<int>? sortOrder,
      Value<String>? createdAtHlc,
      Value<String>? updatedAtHlc,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      nameUr: nameUr ?? this.nameUr,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      isSystem: isSystem ?? this.isSystem,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAtHlc: createdAtHlc ?? this.createdAtHlc,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameUr.present) {
      map['name_ur'] = Variable<String>(nameUr.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($AccountsTable.$convertertype.toSql(type.value));
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAtHlc.present) {
      map['created_at_hlc'] = Variable<String>(createdAtHlc.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('nameUr: $nameUr, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorValue: $colorValue, ')
          ..write('isSystem: $isSystem, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _occurredOnMeta =
      const VerificationMeta('occurredOn');
  @override
  late final GeneratedColumn<DateTime> occurredOn = GeneratedColumn<DateTime>(
      'occurred_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isVoidedMeta =
      const VerificationMeta('isVoided');
  @override
  late final GeneratedColumn<bool> isVoided = GeneratedColumn<bool>(
      'is_voided', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_voided" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _voidedByEventIdMeta =
      const VerificationMeta('voidedByEventId');
  @override
  late final GeneratedColumn<String> voidedByEventId = GeneratedColumn<String>(
      'voided_by_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtHlcMeta =
      const VerificationMeta('createdAtHlc');
  @override
  late final GeneratedColumn<String> createdAtHlc = GeneratedColumn<String>(
      'created_at_hlc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        occurredOn,
        description,
        note,
        isVoided,
        voidedByEventId,
        createdAtHlc,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LedgerEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('occurred_on')) {
      context.handle(
          _occurredOnMeta,
          occurredOn.isAcceptableOrUnknown(
              data['occurred_on']!, _occurredOnMeta));
    } else if (isInserting) {
      context.missing(_occurredOnMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('is_voided')) {
      context.handle(_isVoidedMeta,
          isVoided.isAcceptableOrUnknown(data['is_voided']!, _isVoidedMeta));
    }
    if (data.containsKey('voided_by_event_id')) {
      context.handle(
          _voidedByEventIdMeta,
          voidedByEventId.isAcceptableOrUnknown(
              data['voided_by_event_id']!, _voidedByEventIdMeta));
    }
    if (data.containsKey('created_at_hlc')) {
      context.handle(
          _createdAtHlcMeta,
          createdAtHlc.isAcceptableOrUnknown(
              data['created_at_hlc']!, _createdAtHlcMeta));
    } else if (isInserting) {
      context.missing(_createdAtHlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      occurredOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_on'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      isVoided: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_voided'])!,
      voidedByEventId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}voided_by_event_id']),
      createdAtHlc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at_hlc'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntryRow extends DataClass implements Insertable<LedgerEntryRow> {
  final String id;

  /// The day the money actually moved, normalised to local midnight. Distinct
  /// from when the row was typed in — people enter yesterday's shopping today.
  final DateTime occurredOn;
  final String description;
  final String? note;

  /// Entries are never deleted, only voided.
  ///
  /// A ledger that can lose rows is a ledger that can silently disagree with
  /// itself after a sync, and a household arguing about a maid's salary needs
  /// the original record to still exist. Voiding is itself an event.
  final bool isVoided;
  final String? voidedByEventId;
  final String createdAtHlc;
  final String deviceId;
  const LedgerEntryRow(
      {required this.id,
      required this.occurredOn,
      required this.description,
      this.note,
      required this.isVoided,
      this.voidedByEventId,
      required this.createdAtHlc,
      required this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['occurred_on'] = Variable<DateTime>(occurredOn);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_voided'] = Variable<bool>(isVoided);
    if (!nullToAbsent || voidedByEventId != null) {
      map['voided_by_event_id'] = Variable<String>(voidedByEventId);
    }
    map['created_at_hlc'] = Variable<String>(createdAtHlc);
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      occurredOn: Value(occurredOn),
      description: Value(description),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isVoided: Value(isVoided),
      voidedByEventId: voidedByEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedByEventId),
      createdAtHlc: Value(createdAtHlc),
      deviceId: Value(deviceId),
    );
  }

  factory LedgerEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntryRow(
      id: serializer.fromJson<String>(json['id']),
      occurredOn: serializer.fromJson<DateTime>(json['occurredOn']),
      description: serializer.fromJson<String>(json['description']),
      note: serializer.fromJson<String?>(json['note']),
      isVoided: serializer.fromJson<bool>(json['isVoided']),
      voidedByEventId: serializer.fromJson<String?>(json['voidedByEventId']),
      createdAtHlc: serializer.fromJson<String>(json['createdAtHlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'occurredOn': serializer.toJson<DateTime>(occurredOn),
      'description': serializer.toJson<String>(description),
      'note': serializer.toJson<String?>(note),
      'isVoided': serializer.toJson<bool>(isVoided),
      'voidedByEventId': serializer.toJson<String?>(voidedByEventId),
      'createdAtHlc': serializer.toJson<String>(createdAtHlc),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  LedgerEntryRow copyWith(
          {String? id,
          DateTime? occurredOn,
          String? description,
          Value<String?> note = const Value.absent(),
          bool? isVoided,
          Value<String?> voidedByEventId = const Value.absent(),
          String? createdAtHlc,
          String? deviceId}) =>
      LedgerEntryRow(
        id: id ?? this.id,
        occurredOn: occurredOn ?? this.occurredOn,
        description: description ?? this.description,
        note: note.present ? note.value : this.note,
        isVoided: isVoided ?? this.isVoided,
        voidedByEventId: voidedByEventId.present
            ? voidedByEventId.value
            : this.voidedByEventId,
        createdAtHlc: createdAtHlc ?? this.createdAtHlc,
        deviceId: deviceId ?? this.deviceId,
      );
  LedgerEntryRow copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntryRow(
      id: data.id.present ? data.id.value : this.id,
      occurredOn:
          data.occurredOn.present ? data.occurredOn.value : this.occurredOn,
      description:
          data.description.present ? data.description.value : this.description,
      note: data.note.present ? data.note.value : this.note,
      isVoided: data.isVoided.present ? data.isVoided.value : this.isVoided,
      voidedByEventId: data.voidedByEventId.present
          ? data.voidedByEventId.value
          : this.voidedByEventId,
      createdAtHlc: data.createdAtHlc.present
          ? data.createdAtHlc.value
          : this.createdAtHlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntryRow(')
          ..write('id: $id, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('description: $description, ')
          ..write('note: $note, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidedByEventId: $voidedByEventId, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, occurredOn, description, note, isVoided,
      voidedByEventId, createdAtHlc, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntryRow &&
          other.id == this.id &&
          other.occurredOn == this.occurredOn &&
          other.description == this.description &&
          other.note == this.note &&
          other.isVoided == this.isVoided &&
          other.voidedByEventId == this.voidedByEventId &&
          other.createdAtHlc == this.createdAtHlc &&
          other.deviceId == this.deviceId);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntryRow> {
  final Value<String> id;
  final Value<DateTime> occurredOn;
  final Value<String> description;
  final Value<String?> note;
  final Value<bool> isVoided;
  final Value<String?> voidedByEventId;
  final Value<String> createdAtHlc;
  final Value<String> deviceId;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.description = const Value.absent(),
    this.note = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidedByEventId = const Value.absent(),
    this.createdAtHlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String id,
    required DateTime occurredOn,
    required String description,
    this.note = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidedByEventId = const Value.absent(),
    required String createdAtHlc,
    required String deviceId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        occurredOn = Value(occurredOn),
        description = Value(description),
        createdAtHlc = Value(createdAtHlc),
        deviceId = Value(deviceId);
  static Insertable<LedgerEntryRow> custom({
    Expression<String>? id,
    Expression<DateTime>? occurredOn,
    Expression<String>? description,
    Expression<String>? note,
    Expression<bool>? isVoided,
    Expression<String>? voidedByEventId,
    Expression<String>? createdAtHlc,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (description != null) 'description': description,
      if (note != null) 'note': note,
      if (isVoided != null) 'is_voided': isVoided,
      if (voidedByEventId != null) 'voided_by_event_id': voidedByEventId,
      if (createdAtHlc != null) 'created_at_hlc': createdAtHlc,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? occurredOn,
      Value<String>? description,
      Value<String?>? note,
      Value<bool>? isVoided,
      Value<String?>? voidedByEventId,
      Value<String>? createdAtHlc,
      Value<String>? deviceId,
      Value<int>? rowid}) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      occurredOn: occurredOn ?? this.occurredOn,
      description: description ?? this.description,
      note: note ?? this.note,
      isVoided: isVoided ?? this.isVoided,
      voidedByEventId: voidedByEventId ?? this.voidedByEventId,
      createdAtHlc: createdAtHlc ?? this.createdAtHlc,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<DateTime>(occurredOn.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isVoided.present) {
      map['is_voided'] = Variable<bool>(isVoided.value);
    }
    if (voidedByEventId.present) {
      map['voided_by_event_id'] = Variable<String>(voidedByEventId.value);
    }
    if (createdAtHlc.present) {
      map['created_at_hlc'] = Variable<String>(createdAtHlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('description: $description, ')
          ..write('note: $note, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidedByEventId: $voidedByEventId, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostingsTable extends Postings
    with TableInfo<$PostingsTable, PostingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryIdMeta =
      const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
      'entry_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ledger_entries (id)'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isVoidedMeta =
      const VerificationMeta('isVoided');
  @override
  late final GeneratedColumn<bool> isVoided = GeneratedColumn<bool>(
      'is_voided', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_voided" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, entryId, accountId, amountMinor, memo, position, isVoided];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'postings';
  @override
  VerificationContext validateIntegrity(Insertable<PostingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta,
          entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('is_voided')) {
      context.handle(_isVoidedMeta,
          isVoided.isAcceptableOrUnknown(data['is_voided']!, _isVoidedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostingRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      isVoided: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_voided'])!,
    );
  }

  @override
  $PostingsTable createAlias(String alias) {
    return $PostingsTable(attachedDatabase, alias);
  }
}

class PostingRow extends DataClass implements Insertable<PostingRow> {
  final String id;
  final String entryId;
  final String accountId;

  /// Signed, in paisa. Positive is a debit, negative is a credit.
  final int amountMinor;
  final String? memo;

  /// Order of the lines inside one entry, so a receipt reads back the way it
  /// was written.
  final int position;

  /// Mirrors `LedgerEntries.isVoided`, maintained in the same transaction.
  ///
  /// Denormalised on purpose: balances are the hottest query in the app and
  /// this turns a three-table join into a two-table one. On a 4GB budget
  /// phone that difference is felt.
  final bool isVoided;
  const PostingRow(
      {required this.id,
      required this.entryId,
      required this.accountId,
      required this.amountMinor,
      this.memo,
      required this.position,
      required this.isVoided});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_id'] = Variable<String>(entryId);
    map['account_id'] = Variable<String>(accountId);
    map['amount_minor'] = Variable<int>(amountMinor);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['position'] = Variable<int>(position);
    map['is_voided'] = Variable<bool>(isVoided);
    return map;
  }

  PostingsCompanion toCompanion(bool nullToAbsent) {
    return PostingsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      accountId: Value(accountId),
      amountMinor: Value(amountMinor),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      position: Value(position),
      isVoided: Value(isVoided),
    );
  }

  factory PostingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostingRow(
      id: serializer.fromJson<String>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      memo: serializer.fromJson<String?>(json['memo']),
      position: serializer.fromJson<int>(json['position']),
      isVoided: serializer.fromJson<bool>(json['isVoided']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryId': serializer.toJson<String>(entryId),
      'accountId': serializer.toJson<String>(accountId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'memo': serializer.toJson<String?>(memo),
      'position': serializer.toJson<int>(position),
      'isVoided': serializer.toJson<bool>(isVoided),
    };
  }

  PostingRow copyWith(
          {String? id,
          String? entryId,
          String? accountId,
          int? amountMinor,
          Value<String?> memo = const Value.absent(),
          int? position,
          bool? isVoided}) =>
      PostingRow(
        id: id ?? this.id,
        entryId: entryId ?? this.entryId,
        accountId: accountId ?? this.accountId,
        amountMinor: amountMinor ?? this.amountMinor,
        memo: memo.present ? memo.value : this.memo,
        position: position ?? this.position,
        isVoided: isVoided ?? this.isVoided,
      );
  PostingRow copyWithCompanion(PostingsCompanion data) {
    return PostingRow(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      memo: data.memo.present ? data.memo.value : this.memo,
      position: data.position.present ? data.position.value : this.position,
      isVoided: data.isVoided.present ? data.isVoided.value : this.isVoided,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostingRow(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('accountId: $accountId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('memo: $memo, ')
          ..write('position: $position, ')
          ..write('isVoided: $isVoided')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entryId, accountId, amountMinor, memo, position, isVoided);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostingRow &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.accountId == this.accountId &&
          other.amountMinor == this.amountMinor &&
          other.memo == this.memo &&
          other.position == this.position &&
          other.isVoided == this.isVoided);
}

class PostingsCompanion extends UpdateCompanion<PostingRow> {
  final Value<String> id;
  final Value<String> entryId;
  final Value<String> accountId;
  final Value<int> amountMinor;
  final Value<String?> memo;
  final Value<int> position;
  final Value<bool> isVoided;
  final Value<int> rowid;
  const PostingsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.memo = const Value.absent(),
    this.position = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostingsCompanion.insert({
    required String id,
    required String entryId,
    required String accountId,
    required int amountMinor,
    this.memo = const Value.absent(),
    this.position = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entryId = Value(entryId),
        accountId = Value(accountId),
        amountMinor = Value(amountMinor);
  static Insertable<PostingRow> custom({
    Expression<String>? id,
    Expression<String>? entryId,
    Expression<String>? accountId,
    Expression<int>? amountMinor,
    Expression<String>? memo,
    Expression<int>? position,
    Expression<bool>? isVoided,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (accountId != null) 'account_id': accountId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (memo != null) 'memo': memo,
      if (position != null) 'position': position,
      if (isVoided != null) 'is_voided': isVoided,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entryId,
      Value<String>? accountId,
      Value<int>? amountMinor,
      Value<String?>? memo,
      Value<int>? position,
      Value<bool>? isVoided,
      Value<int>? rowid}) {
    return PostingsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      accountId: accountId ?? this.accountId,
      amountMinor: amountMinor ?? this.amountMinor,
      memo: memo ?? this.memo,
      position: position ?? this.position,
      isVoided: isVoided ?? this.isVoided,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isVoided.present) {
      map['is_voided'] = Variable<bool>(isVoided.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostingsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('accountId: $accountId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('memo: $memo, ')
          ..write('position: $position, ')
          ..write('isVoided: $isVoided, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEventsTable extends LedgerEvents
    with TableInfo<$LedgerEventsTable, LedgerEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
      'hlc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appliedAtMeta =
      const VerificationMeta('appliedAt');
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
      'applied_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isRemoteMeta =
      const VerificationMeta('isRemote');
  @override
  late final GeneratedColumn<bool> isRemote = GeneratedColumn<bool>(
      'is_remote', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_remote" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, hlc, deviceId, type, payload, appliedAt, isRemote];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_events';
  @override
  VerificationContext validateIntegrity(Insertable<LedgerEventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
          _hlcMeta, hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta));
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(_appliedAtMeta,
          appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta));
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    if (data.containsKey('is_remote')) {
      context.handle(_isRemoteMeta,
          isRemote.isAcceptableOrUnknown(data['is_remote']!, _isRemoteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hlc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hlc'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      appliedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}applied_at'])!,
      isRemote: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_remote'])!,
    );
  }

  @override
  $LedgerEventsTable createAlias(String alias) {
    return $LedgerEventsTable(attachedDatabase, alias);
  }
}

class LedgerEventRow extends DataClass implements Insertable<LedgerEventRow> {
  final String id;

  /// Packed HLC, fixed width so a plain TEXT index sorts causally.
  final String hlc;
  final String deviceId;
  final int type;
  final String payload;

  /// When this device applied the event — not when it was created. For a
  /// remote event these differ, and that gap is what a sync log needs to show.
  final DateTime appliedAt;
  final bool isRemote;
  const LedgerEventRow(
      {required this.id,
      required this.hlc,
      required this.deviceId,
      required this.type,
      required this.payload,
      required this.appliedAt,
      required this.isRemote});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['device_id'] = Variable<String>(deviceId);
    map['type'] = Variable<int>(type);
    map['payload'] = Variable<String>(payload);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    map['is_remote'] = Variable<bool>(isRemote);
    return map;
  }

  LedgerEventsCompanion toCompanion(bool nullToAbsent) {
    return LedgerEventsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deviceId: Value(deviceId),
      type: Value(type),
      payload: Value(payload),
      appliedAt: Value(appliedAt),
      isRemote: Value(isRemote),
    );
  }

  factory LedgerEventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEventRow(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      type: serializer.fromJson<int>(json['type']),
      payload: serializer.fromJson<String>(json['payload']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
      isRemote: serializer.fromJson<bool>(json['isRemote']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deviceId': serializer.toJson<String>(deviceId),
      'type': serializer.toJson<int>(type),
      'payload': serializer.toJson<String>(payload),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
      'isRemote': serializer.toJson<bool>(isRemote),
    };
  }

  LedgerEventRow copyWith(
          {String? id,
          String? hlc,
          String? deviceId,
          int? type,
          String? payload,
          DateTime? appliedAt,
          bool? isRemote}) =>
      LedgerEventRow(
        id: id ?? this.id,
        hlc: hlc ?? this.hlc,
        deviceId: deviceId ?? this.deviceId,
        type: type ?? this.type,
        payload: payload ?? this.payload,
        appliedAt: appliedAt ?? this.appliedAt,
        isRemote: isRemote ?? this.isRemote,
      );
  LedgerEventRow copyWithCompanion(LedgerEventsCompanion data) {
    return LedgerEventRow(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      isRemote: data.isRemote.present ? data.isRemote.value : this.isRemote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEventRow(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('isRemote: $isRemote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, hlc, deviceId, type, payload, appliedAt, isRemote);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEventRow &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deviceId == this.deviceId &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.appliedAt == this.appliedAt &&
          other.isRemote == this.isRemote);
}

class LedgerEventsCompanion extends UpdateCompanion<LedgerEventRow> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<String> deviceId;
  final Value<int> type;
  final Value<String> payload;
  final Value<DateTime> appliedAt;
  final Value<bool> isRemote;
  final Value<int> rowid;
  const LedgerEventsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.isRemote = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEventsCompanion.insert({
    required String id,
    required String hlc,
    required String deviceId,
    required int type,
    required String payload,
    required DateTime appliedAt,
    this.isRemote = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        hlc = Value(hlc),
        deviceId = Value(deviceId),
        type = Value(type),
        payload = Value(payload),
        appliedAt = Value(appliedAt);
  static Insertable<LedgerEventRow> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<String>? deviceId,
    Expression<int>? type,
    Expression<String>? payload,
    Expression<DateTime>? appliedAt,
    Expression<bool>? isRemote,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deviceId != null) 'device_id': deviceId,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (isRemote != null) 'is_remote': isRemote,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? hlc,
      Value<String>? deviceId,
      Value<int>? type,
      Value<String>? payload,
      Value<DateTime>? appliedAt,
      Value<bool>? isRemote,
      Value<int>? rowid}) {
    return LedgerEventsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deviceId: deviceId ?? this.deviceId,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      appliedAt: appliedAt ?? this.appliedAt,
      isRemote: isRemote ?? this.isRemote,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (isRemote.present) {
      map['is_remote'] = Variable<bool>(isRemote.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEventsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deviceId: $deviceId, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('isRemote: $isRemote, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTemplatesTable extends RecurringTemplates
    with TableInfo<$RecurringTemplatesTable, RecurringTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<RecurringKind, int> kind =
      GeneratedColumn<int>('kind', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<RecurringKind>(
              $RecurringTemplatesTable.$converterkind);
  static const VerificationMeta _categoryAccountIdMeta =
      const VerificationMeta('categoryAccountId');
  @override
  late final GeneratedColumn<String> categoryAccountId =
      GeneratedColumn<String>('category_account_id', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _sourceAccountIdMeta =
      const VerificationMeta('sourceAccountId');
  @override
  late final GeneratedColumn<String> sourceAccountId = GeneratedColumn<String>(
      'source_account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayOfMonthMeta =
      const VerificationMeta('dayOfMonth');
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
      'day_of_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastPostedPeriodMeta =
      const VerificationMeta('lastPostedPeriod');
  @override
  late final GeneratedColumn<String> lastPostedPeriod = GeneratedColumn<String>(
      'last_posted_period', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtHlcMeta =
      const VerificationMeta('createdAtHlc');
  @override
  late final GeneratedColumn<String> createdAtHlc = GeneratedColumn<String>(
      'created_at_hlc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtHlcMeta =
      const VerificationMeta('updatedAtHlc');
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
      'updated_at_hlc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        kind,
        categoryAccountId,
        sourceAccountId,
        amountMinor,
        description,
        dayOfMonth,
        isActive,
        lastPostedPeriod,
        createdAtHlc,
        updatedAtHlc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_templates';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecurringTemplateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_account_id')) {
      context.handle(
          _categoryAccountIdMeta,
          categoryAccountId.isAcceptableOrUnknown(
              data['category_account_id']!, _categoryAccountIdMeta));
    } else if (isInserting) {
      context.missing(_categoryAccountIdMeta);
    }
    if (data.containsKey('source_account_id')) {
      context.handle(
          _sourceAccountIdMeta,
          sourceAccountId.isAcceptableOrUnknown(
              data['source_account_id']!, _sourceAccountIdMeta));
    } else if (isInserting) {
      context.missing(_sourceAccountIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
          _dayOfMonthMeta,
          dayOfMonth.isAcceptableOrUnknown(
              data['day_of_month']!, _dayOfMonthMeta));
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('last_posted_period')) {
      context.handle(
          _lastPostedPeriodMeta,
          lastPostedPeriod.isAcceptableOrUnknown(
              data['last_posted_period']!, _lastPostedPeriodMeta));
    }
    if (data.containsKey('created_at_hlc')) {
      context.handle(
          _createdAtHlcMeta,
          createdAtHlc.isAcceptableOrUnknown(
              data['created_at_hlc']!, _createdAtHlcMeta));
    } else if (isInserting) {
      context.missing(_createdAtHlcMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
          _updatedAtHlcMeta,
          updatedAtHlc.isAcceptableOrUnknown(
              data['updated_at_hlc']!, _updatedAtHlcMeta));
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTemplateRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kind: $RecurringTemplatesTable.$converterkind.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!),
      categoryAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}category_account_id'])!,
      sourceAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_account_id'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      dayOfMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_month'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      lastPostedPeriod: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_posted_period']),
      createdAtHlc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at_hlc'])!,
      updatedAtHlc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at_hlc'])!,
    );
  }

  @override
  $RecurringTemplatesTable createAlias(String alias) {
    return $RecurringTemplatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecurringKind, int, int> $converterkind =
      const EnumIndexConverter<RecurringKind>(RecurringKind.values);
}

class RecurringTemplateRow extends DataClass
    implements Insertable<RecurringTemplateRow> {
  final String id;
  final RecurringKind kind;

  /// The category being spent on, or the source money arrives from.
  ///
  /// Both this and [sourceAccountId] point at `accounts`, so each needs an
  /// explicit reverse name — otherwise drift cannot tell the two apart when it
  /// generates the back-references and warns on every build.
  final String categoryAccountId;

  /// The pocket it is paid from, or received into.
  final String sourceAccountId;

  /// Zero means the amount changes every month and should be asked for.
  /// A bijli bill is never the same twice; rent usually is.
  final int amountMinor;
  final String description;

  /// Day of the month it falls due, 1–31. Clamped at read time for months that
  /// are too short — see `clampDayToMonth`.
  final int dayOfMonth;
  final bool isActive;

  /// The last month stamped as done, as `2026-08`. Null until first confirmed.
  ///
  /// This is the whole duplicate-protection mechanism: a template whose stamp
  /// matches the current month is not due, however many times the app opens.
  final String? lastPostedPeriod;
  final String createdAtHlc;
  final String updatedAtHlc;
  const RecurringTemplateRow(
      {required this.id,
      required this.kind,
      required this.categoryAccountId,
      required this.sourceAccountId,
      required this.amountMinor,
      required this.description,
      required this.dayOfMonth,
      required this.isActive,
      this.lastPostedPeriod,
      required this.createdAtHlc,
      required this.updatedAtHlc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] =
          Variable<int>($RecurringTemplatesTable.$converterkind.toSql(kind));
    }
    map['category_account_id'] = Variable<String>(categoryAccountId);
    map['source_account_id'] = Variable<String>(sourceAccountId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['description'] = Variable<String>(description);
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastPostedPeriod != null) {
      map['last_posted_period'] = Variable<String>(lastPostedPeriod);
    }
    map['created_at_hlc'] = Variable<String>(createdAtHlc);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    return map;
  }

  RecurringTemplatesCompanion toCompanion(bool nullToAbsent) {
    return RecurringTemplatesCompanion(
      id: Value(id),
      kind: Value(kind),
      categoryAccountId: Value(categoryAccountId),
      sourceAccountId: Value(sourceAccountId),
      amountMinor: Value(amountMinor),
      description: Value(description),
      dayOfMonth: Value(dayOfMonth),
      isActive: Value(isActive),
      lastPostedPeriod: lastPostedPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPostedPeriod),
      createdAtHlc: Value(createdAtHlc),
      updatedAtHlc: Value(updatedAtHlc),
    );
  }

  factory RecurringTemplateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTemplateRow(
      id: serializer.fromJson<String>(json['id']),
      kind: $RecurringTemplatesTable.$converterkind
          .fromJson(serializer.fromJson<int>(json['kind'])),
      categoryAccountId: serializer.fromJson<String>(json['categoryAccountId']),
      sourceAccountId: serializer.fromJson<String>(json['sourceAccountId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      description: serializer.fromJson<String>(json['description']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastPostedPeriod: serializer.fromJson<String?>(json['lastPostedPeriod']),
      createdAtHlc: serializer.fromJson<String>(json['createdAtHlc']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer
          .toJson<int>($RecurringTemplatesTable.$converterkind.toJson(kind)),
      'categoryAccountId': serializer.toJson<String>(categoryAccountId),
      'sourceAccountId': serializer.toJson<String>(sourceAccountId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'description': serializer.toJson<String>(description),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'isActive': serializer.toJson<bool>(isActive),
      'lastPostedPeriod': serializer.toJson<String?>(lastPostedPeriod),
      'createdAtHlc': serializer.toJson<String>(createdAtHlc),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
    };
  }

  RecurringTemplateRow copyWith(
          {String? id,
          RecurringKind? kind,
          String? categoryAccountId,
          String? sourceAccountId,
          int? amountMinor,
          String? description,
          int? dayOfMonth,
          bool? isActive,
          Value<String?> lastPostedPeriod = const Value.absent(),
          String? createdAtHlc,
          String? updatedAtHlc}) =>
      RecurringTemplateRow(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        categoryAccountId: categoryAccountId ?? this.categoryAccountId,
        sourceAccountId: sourceAccountId ?? this.sourceAccountId,
        amountMinor: amountMinor ?? this.amountMinor,
        description: description ?? this.description,
        dayOfMonth: dayOfMonth ?? this.dayOfMonth,
        isActive: isActive ?? this.isActive,
        lastPostedPeriod: lastPostedPeriod.present
            ? lastPostedPeriod.value
            : this.lastPostedPeriod,
        createdAtHlc: createdAtHlc ?? this.createdAtHlc,
        updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      );
  RecurringTemplateRow copyWithCompanion(RecurringTemplatesCompanion data) {
    return RecurringTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      categoryAccountId: data.categoryAccountId.present
          ? data.categoryAccountId.value
          : this.categoryAccountId,
      sourceAccountId: data.sourceAccountId.present
          ? data.sourceAccountId.value
          : this.sourceAccountId,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      description:
          data.description.present ? data.description.value : this.description,
      dayOfMonth:
          data.dayOfMonth.present ? data.dayOfMonth.value : this.dayOfMonth,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastPostedPeriod: data.lastPostedPeriod.present
          ? data.lastPostedPeriod.value
          : this.lastPostedPeriod,
      createdAtHlc: data.createdAtHlc.present
          ? data.createdAtHlc.value
          : this.createdAtHlc,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplateRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('categoryAccountId: $categoryAccountId, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('description: $description, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('isActive: $isActive, ')
          ..write('lastPostedPeriod: $lastPostedPeriod, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      kind,
      categoryAccountId,
      sourceAccountId,
      amountMinor,
      description,
      dayOfMonth,
      isActive,
      lastPostedPeriod,
      createdAtHlc,
      updatedAtHlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTemplateRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.categoryAccountId == this.categoryAccountId &&
          other.sourceAccountId == this.sourceAccountId &&
          other.amountMinor == this.amountMinor &&
          other.description == this.description &&
          other.dayOfMonth == this.dayOfMonth &&
          other.isActive == this.isActive &&
          other.lastPostedPeriod == this.lastPostedPeriod &&
          other.createdAtHlc == this.createdAtHlc &&
          other.updatedAtHlc == this.updatedAtHlc);
}

class RecurringTemplatesCompanion
    extends UpdateCompanion<RecurringTemplateRow> {
  final Value<String> id;
  final Value<RecurringKind> kind;
  final Value<String> categoryAccountId;
  final Value<String> sourceAccountId;
  final Value<int> amountMinor;
  final Value<String> description;
  final Value<int> dayOfMonth;
  final Value<bool> isActive;
  final Value<String?> lastPostedPeriod;
  final Value<String> createdAtHlc;
  final Value<String> updatedAtHlc;
  final Value<int> rowid;
  const RecurringTemplatesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.categoryAccountId = const Value.absent(),
    this.sourceAccountId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.description = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastPostedPeriod = const Value.absent(),
    this.createdAtHlc = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTemplatesCompanion.insert({
    required String id,
    required RecurringKind kind,
    required String categoryAccountId,
    required String sourceAccountId,
    this.amountMinor = const Value.absent(),
    required String description,
    required int dayOfMonth,
    this.isActive = const Value.absent(),
    this.lastPostedPeriod = const Value.absent(),
    required String createdAtHlc,
    required String updatedAtHlc,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        categoryAccountId = Value(categoryAccountId),
        sourceAccountId = Value(sourceAccountId),
        description = Value(description),
        dayOfMonth = Value(dayOfMonth),
        createdAtHlc = Value(createdAtHlc),
        updatedAtHlc = Value(updatedAtHlc);
  static Insertable<RecurringTemplateRow> custom({
    Expression<String>? id,
    Expression<int>? kind,
    Expression<String>? categoryAccountId,
    Expression<String>? sourceAccountId,
    Expression<int>? amountMinor,
    Expression<String>? description,
    Expression<int>? dayOfMonth,
    Expression<bool>? isActive,
    Expression<String>? lastPostedPeriod,
    Expression<String>? createdAtHlc,
    Expression<String>? updatedAtHlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (categoryAccountId != null) 'category_account_id': categoryAccountId,
      if (sourceAccountId != null) 'source_account_id': sourceAccountId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (description != null) 'description': description,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (isActive != null) 'is_active': isActive,
      if (lastPostedPeriod != null) 'last_posted_period': lastPostedPeriod,
      if (createdAtHlc != null) 'created_at_hlc': createdAtHlc,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<RecurringKind>? kind,
      Value<String>? categoryAccountId,
      Value<String>? sourceAccountId,
      Value<int>? amountMinor,
      Value<String>? description,
      Value<int>? dayOfMonth,
      Value<bool>? isActive,
      Value<String?>? lastPostedPeriod,
      Value<String>? createdAtHlc,
      Value<String>? updatedAtHlc,
      Value<int>? rowid}) {
    return RecurringTemplatesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      categoryAccountId: categoryAccountId ?? this.categoryAccountId,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      amountMinor: amountMinor ?? this.amountMinor,
      description: description ?? this.description,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
      lastPostedPeriod: lastPostedPeriod ?? this.lastPostedPeriod,
      createdAtHlc: createdAtHlc ?? this.createdAtHlc,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
          $RecurringTemplatesTable.$converterkind.toSql(kind.value));
    }
    if (categoryAccountId.present) {
      map['category_account_id'] = Variable<String>(categoryAccountId.value);
    }
    if (sourceAccountId.present) {
      map['source_account_id'] = Variable<String>(sourceAccountId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastPostedPeriod.present) {
      map['last_posted_period'] = Variable<String>(lastPostedPeriod.value);
    }
    if (createdAtHlc.present) {
      map['created_at_hlc'] = Variable<String>(createdAtHlc.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('categoryAccountId: $categoryAccountId, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('description: $description, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('isActive: $isActive, ')
          ..write('lastPostedPeriod: $lastPostedPeriod, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaffMembersTable extends StaffMembers
    with TableInfo<$StaffMembersTable, StaffMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _monthlySalaryMinorMeta =
      const VerificationMeta('monthlySalaryMinor');
  @override
  late final GeneratedColumn<int> monthlySalaryMinor = GeneratedColumn<int>(
      'monthly_salary_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _salaryAccountIdMeta =
      const VerificationMeta('salaryAccountId');
  @override
  late final GeneratedColumn<String> salaryAccountId = GeneratedColumn<String>(
      'salary_account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _advanceAccountIdMeta =
      const VerificationMeta('advanceAccountId');
  @override
  late final GeneratedColumn<String> advanceAccountId = GeneratedColumn<String>(
      'advance_account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _joinedOnMeta =
      const VerificationMeta('joinedOn');
  @override
  late final GeneratedColumn<DateTime> joinedOn = GeneratedColumn<DateTime>(
      'joined_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtHlcMeta =
      const VerificationMeta('createdAtHlc');
  @override
  late final GeneratedColumn<String> createdAtHlc = GeneratedColumn<String>(
      'created_at_hlc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtHlcMeta =
      const VerificationMeta('updatedAtHlc');
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
      'updated_at_hlc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        phone,
        monthlySalaryMinor,
        salaryAccountId,
        advanceAccountId,
        joinedOn,
        isActive,
        createdAtHlc,
        updatedAtHlc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_members';
  @override
  VerificationContext validateIntegrity(Insertable<StaffMemberRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('monthly_salary_minor')) {
      context.handle(
          _monthlySalaryMinorMeta,
          monthlySalaryMinor.isAcceptableOrUnknown(
              data['monthly_salary_minor']!, _monthlySalaryMinorMeta));
    } else if (isInserting) {
      context.missing(_monthlySalaryMinorMeta);
    }
    if (data.containsKey('salary_account_id')) {
      context.handle(
          _salaryAccountIdMeta,
          salaryAccountId.isAcceptableOrUnknown(
              data['salary_account_id']!, _salaryAccountIdMeta));
    } else if (isInserting) {
      context.missing(_salaryAccountIdMeta);
    }
    if (data.containsKey('advance_account_id')) {
      context.handle(
          _advanceAccountIdMeta,
          advanceAccountId.isAcceptableOrUnknown(
              data['advance_account_id']!, _advanceAccountIdMeta));
    } else if (isInserting) {
      context.missing(_advanceAccountIdMeta);
    }
    if (data.containsKey('joined_on')) {
      context.handle(_joinedOnMeta,
          joinedOn.isAcceptableOrUnknown(data['joined_on']!, _joinedOnMeta));
    } else if (isInserting) {
      context.missing(_joinedOnMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at_hlc')) {
      context.handle(
          _createdAtHlcMeta,
          createdAtHlc.isAcceptableOrUnknown(
              data['created_at_hlc']!, _createdAtHlcMeta));
    } else if (isInserting) {
      context.missing(_createdAtHlcMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
          _updatedAtHlcMeta,
          updatedAtHlc.isAcceptableOrUnknown(
              data['updated_at_hlc']!, _updatedAtHlcMeta));
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffMemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffMemberRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      monthlySalaryMinor: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}monthly_salary_minor'])!,
      salaryAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}salary_account_id'])!,
      advanceAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}advance_account_id'])!,
      joinedOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}joined_on'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAtHlc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at_hlc'])!,
      updatedAtHlc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at_hlc'])!,
    );
  }

  @override
  $StaffMembersTable createAlias(String alias) {
    return $StaffMembersTable(attachedDatabase, alias);
  }
}

class StaffMemberRow extends DataClass implements Insertable<StaffMemberRow> {
  final String id;
  final String name;

  /// For sending a salary receipt over WhatsApp. Optional — plenty of
  /// arrangements are entirely in person.
  final String? phone;
  final int monthlySalaryMinor;

  /// Expense account. Everything paid to this person accumulates here.
  ///
  /// Named explicitly for the same reason as the template columns: two
  /// foreign keys into `accounts` leave drift unable to name the reverse
  /// lookups on its own.
  final String salaryAccountId;

  /// Asset account. Peshgi sits here until a salary settles it.
  final String advanceAccountId;
  final DateTime joinedOn;
  final bool isActive;
  final String createdAtHlc;
  final String updatedAtHlc;
  const StaffMemberRow(
      {required this.id,
      required this.name,
      this.phone,
      required this.monthlySalaryMinor,
      required this.salaryAccountId,
      required this.advanceAccountId,
      required this.joinedOn,
      required this.isActive,
      required this.createdAtHlc,
      required this.updatedAtHlc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['monthly_salary_minor'] = Variable<int>(monthlySalaryMinor);
    map['salary_account_id'] = Variable<String>(salaryAccountId);
    map['advance_account_id'] = Variable<String>(advanceAccountId);
    map['joined_on'] = Variable<DateTime>(joinedOn);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at_hlc'] = Variable<String>(createdAtHlc);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    return map;
  }

  StaffMembersCompanion toCompanion(bool nullToAbsent) {
    return StaffMembersCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      monthlySalaryMinor: Value(monthlySalaryMinor),
      salaryAccountId: Value(salaryAccountId),
      advanceAccountId: Value(advanceAccountId),
      joinedOn: Value(joinedOn),
      isActive: Value(isActive),
      createdAtHlc: Value(createdAtHlc),
      updatedAtHlc: Value(updatedAtHlc),
    );
  }

  factory StaffMemberRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffMemberRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      monthlySalaryMinor: serializer.fromJson<int>(json['monthlySalaryMinor']),
      salaryAccountId: serializer.fromJson<String>(json['salaryAccountId']),
      advanceAccountId: serializer.fromJson<String>(json['advanceAccountId']),
      joinedOn: serializer.fromJson<DateTime>(json['joinedOn']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAtHlc: serializer.fromJson<String>(json['createdAtHlc']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'monthlySalaryMinor': serializer.toJson<int>(monthlySalaryMinor),
      'salaryAccountId': serializer.toJson<String>(salaryAccountId),
      'advanceAccountId': serializer.toJson<String>(advanceAccountId),
      'joinedOn': serializer.toJson<DateTime>(joinedOn),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAtHlc': serializer.toJson<String>(createdAtHlc),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
    };
  }

  StaffMemberRow copyWith(
          {String? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          int? monthlySalaryMinor,
          String? salaryAccountId,
          String? advanceAccountId,
          DateTime? joinedOn,
          bool? isActive,
          String? createdAtHlc,
          String? updatedAtHlc}) =>
      StaffMemberRow(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        monthlySalaryMinor: monthlySalaryMinor ?? this.monthlySalaryMinor,
        salaryAccountId: salaryAccountId ?? this.salaryAccountId,
        advanceAccountId: advanceAccountId ?? this.advanceAccountId,
        joinedOn: joinedOn ?? this.joinedOn,
        isActive: isActive ?? this.isActive,
        createdAtHlc: createdAtHlc ?? this.createdAtHlc,
        updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      );
  StaffMemberRow copyWithCompanion(StaffMembersCompanion data) {
    return StaffMemberRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      monthlySalaryMinor: data.monthlySalaryMinor.present
          ? data.monthlySalaryMinor.value
          : this.monthlySalaryMinor,
      salaryAccountId: data.salaryAccountId.present
          ? data.salaryAccountId.value
          : this.salaryAccountId,
      advanceAccountId: data.advanceAccountId.present
          ? data.advanceAccountId.value
          : this.advanceAccountId,
      joinedOn: data.joinedOn.present ? data.joinedOn.value : this.joinedOn,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAtHlc: data.createdAtHlc.present
          ? data.createdAtHlc.value
          : this.createdAtHlc,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffMemberRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('monthlySalaryMinor: $monthlySalaryMinor, ')
          ..write('salaryAccountId: $salaryAccountId, ')
          ..write('advanceAccountId: $advanceAccountId, ')
          ..write('joinedOn: $joinedOn, ')
          ..write('isActive: $isActive, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      phone,
      monthlySalaryMinor,
      salaryAccountId,
      advanceAccountId,
      joinedOn,
      isActive,
      createdAtHlc,
      updatedAtHlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffMemberRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.monthlySalaryMinor == this.monthlySalaryMinor &&
          other.salaryAccountId == this.salaryAccountId &&
          other.advanceAccountId == this.advanceAccountId &&
          other.joinedOn == this.joinedOn &&
          other.isActive == this.isActive &&
          other.createdAtHlc == this.createdAtHlc &&
          other.updatedAtHlc == this.updatedAtHlc);
}

class StaffMembersCompanion extends UpdateCompanion<StaffMemberRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<int> monthlySalaryMinor;
  final Value<String> salaryAccountId;
  final Value<String> advanceAccountId;
  final Value<DateTime> joinedOn;
  final Value<bool> isActive;
  final Value<String> createdAtHlc;
  final Value<String> updatedAtHlc;
  final Value<int> rowid;
  const StaffMembersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.monthlySalaryMinor = const Value.absent(),
    this.salaryAccountId = const Value.absent(),
    this.advanceAccountId = const Value.absent(),
    this.joinedOn = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAtHlc = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffMembersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    required int monthlySalaryMinor,
    required String salaryAccountId,
    required String advanceAccountId,
    required DateTime joinedOn,
    this.isActive = const Value.absent(),
    required String createdAtHlc,
    required String updatedAtHlc,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        monthlySalaryMinor = Value(monthlySalaryMinor),
        salaryAccountId = Value(salaryAccountId),
        advanceAccountId = Value(advanceAccountId),
        joinedOn = Value(joinedOn),
        createdAtHlc = Value(createdAtHlc),
        updatedAtHlc = Value(updatedAtHlc);
  static Insertable<StaffMemberRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<int>? monthlySalaryMinor,
    Expression<String>? salaryAccountId,
    Expression<String>? advanceAccountId,
    Expression<DateTime>? joinedOn,
    Expression<bool>? isActive,
    Expression<String>? createdAtHlc,
    Expression<String>? updatedAtHlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (monthlySalaryMinor != null)
        'monthly_salary_minor': monthlySalaryMinor,
      if (salaryAccountId != null) 'salary_account_id': salaryAccountId,
      if (advanceAccountId != null) 'advance_account_id': advanceAccountId,
      if (joinedOn != null) 'joined_on': joinedOn,
      if (isActive != null) 'is_active': isActive,
      if (createdAtHlc != null) 'created_at_hlc': createdAtHlc,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffMembersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<int>? monthlySalaryMinor,
      Value<String>? salaryAccountId,
      Value<String>? advanceAccountId,
      Value<DateTime>? joinedOn,
      Value<bool>? isActive,
      Value<String>? createdAtHlc,
      Value<String>? updatedAtHlc,
      Value<int>? rowid}) {
    return StaffMembersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      monthlySalaryMinor: monthlySalaryMinor ?? this.monthlySalaryMinor,
      salaryAccountId: salaryAccountId ?? this.salaryAccountId,
      advanceAccountId: advanceAccountId ?? this.advanceAccountId,
      joinedOn: joinedOn ?? this.joinedOn,
      isActive: isActive ?? this.isActive,
      createdAtHlc: createdAtHlc ?? this.createdAtHlc,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (monthlySalaryMinor.present) {
      map['monthly_salary_minor'] = Variable<int>(monthlySalaryMinor.value);
    }
    if (salaryAccountId.present) {
      map['salary_account_id'] = Variable<String>(salaryAccountId.value);
    }
    if (advanceAccountId.present) {
      map['advance_account_id'] = Variable<String>(advanceAccountId.value);
    }
    if (joinedOn.present) {
      map['joined_on'] = Variable<DateTime>(joinedOn.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAtHlc.present) {
      map['created_at_hlc'] = Variable<String>(createdAtHlc.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffMembersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('monthlySalaryMinor: $monthlySalaryMinor, ')
          ..write('salaryAccountId: $salaryAccountId, ')
          ..write('advanceAccountId: $advanceAccountId, ')
          ..write('joinedOn: $joinedOn, ')
          ..write('isActive: $isActive, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaffAttendanceTable extends StaffAttendance
    with TableInfo<$StaffAttendanceTable, StaffAttendanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffAttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _staffIdMeta =
      const VerificationMeta('staffId');
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
      'staff_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES staff_members (id)'));
  static const VerificationMeta _onDateMeta = const VerificationMeta('onDate');
  @override
  late final GeneratedColumn<DateTime> onDate = GeneratedColumn<DateTime>(
      'on_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<AttendanceStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AttendanceStatus>(
              $StaffAttendanceTable.$converterstatus);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtHlcMeta =
      const VerificationMeta('createdAtHlc');
  @override
  late final GeneratedColumn<String> createdAtHlc = GeneratedColumn<String>(
      'created_at_hlc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, staffId, onDate, status, note, createdAtHlc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_attendance';
  @override
  VerificationContext validateIntegrity(Insertable<StaffAttendanceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('staff_id')) {
      context.handle(_staffIdMeta,
          staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta));
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('on_date')) {
      context.handle(_onDateMeta,
          onDate.isAcceptableOrUnknown(data['on_date']!, _onDateMeta));
    } else if (isInserting) {
      context.missing(_onDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at_hlc')) {
      context.handle(
          _createdAtHlcMeta,
          createdAtHlc.isAcceptableOrUnknown(
              data['created_at_hlc']!, _createdAtHlcMeta));
    } else if (isInserting) {
      context.missing(_createdAtHlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffAttendanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffAttendanceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      staffId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}staff_id'])!,
      onDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}on_date'])!,
      status: $StaffAttendanceTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAtHlc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at_hlc'])!,
    );
  }

  @override
  $StaffAttendanceTable createAlias(String alias) {
    return $StaffAttendanceTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AttendanceStatus, int, int> $converterstatus =
      const EnumIndexConverter<AttendanceStatus>(AttendanceStatus.values);
}

class StaffAttendanceRow extends DataClass
    implements Insertable<StaffAttendanceRow> {
  final String id;
  final String staffId;

  /// Normalised to local midnight, so one day has exactly one row.
  final DateTime onDate;
  final AttendanceStatus status;
  final String? note;
  final String createdAtHlc;
  const StaffAttendanceRow(
      {required this.id,
      required this.staffId,
      required this.onDate,
      required this.status,
      this.note,
      required this.createdAtHlc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['staff_id'] = Variable<String>(staffId);
    map['on_date'] = Variable<DateTime>(onDate);
    {
      map['status'] =
          Variable<int>($StaffAttendanceTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_hlc'] = Variable<String>(createdAtHlc);
    return map;
  }

  StaffAttendanceCompanion toCompanion(bool nullToAbsent) {
    return StaffAttendanceCompanion(
      id: Value(id),
      staffId: Value(staffId),
      onDate: Value(onDate),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtHlc: Value(createdAtHlc),
    );
  }

  factory StaffAttendanceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffAttendanceRow(
      id: serializer.fromJson<String>(json['id']),
      staffId: serializer.fromJson<String>(json['staffId']),
      onDate: serializer.fromJson<DateTime>(json['onDate']),
      status: $StaffAttendanceTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      note: serializer.fromJson<String?>(json['note']),
      createdAtHlc: serializer.fromJson<String>(json['createdAtHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'staffId': serializer.toJson<String>(staffId),
      'onDate': serializer.toJson<DateTime>(onDate),
      'status': serializer
          .toJson<int>($StaffAttendanceTable.$converterstatus.toJson(status)),
      'note': serializer.toJson<String?>(note),
      'createdAtHlc': serializer.toJson<String>(createdAtHlc),
    };
  }

  StaffAttendanceRow copyWith(
          {String? id,
          String? staffId,
          DateTime? onDate,
          AttendanceStatus? status,
          Value<String?> note = const Value.absent(),
          String? createdAtHlc}) =>
      StaffAttendanceRow(
        id: id ?? this.id,
        staffId: staffId ?? this.staffId,
        onDate: onDate ?? this.onDate,
        status: status ?? this.status,
        note: note.present ? note.value : this.note,
        createdAtHlc: createdAtHlc ?? this.createdAtHlc,
      );
  StaffAttendanceRow copyWithCompanion(StaffAttendanceCompanion data) {
    return StaffAttendanceRow(
      id: data.id.present ? data.id.value : this.id,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      onDate: data.onDate.present ? data.onDate.value : this.onDate,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      createdAtHlc: data.createdAtHlc.present
          ? data.createdAtHlc.value
          : this.createdAtHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffAttendanceRow(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('onDate: $onDate, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAtHlc: $createdAtHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, staffId, onDate, status, note, createdAtHlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffAttendanceRow &&
          other.id == this.id &&
          other.staffId == this.staffId &&
          other.onDate == this.onDate &&
          other.status == this.status &&
          other.note == this.note &&
          other.createdAtHlc == this.createdAtHlc);
}

class StaffAttendanceCompanion extends UpdateCompanion<StaffAttendanceRow> {
  final Value<String> id;
  final Value<String> staffId;
  final Value<DateTime> onDate;
  final Value<AttendanceStatus> status;
  final Value<String?> note;
  final Value<String> createdAtHlc;
  final Value<int> rowid;
  const StaffAttendanceCompanion({
    this.id = const Value.absent(),
    this.staffId = const Value.absent(),
    this.onDate = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffAttendanceCompanion.insert({
    required String id,
    required String staffId,
    required DateTime onDate,
    required AttendanceStatus status,
    this.note = const Value.absent(),
    required String createdAtHlc,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        staffId = Value(staffId),
        onDate = Value(onDate),
        status = Value(status),
        createdAtHlc = Value(createdAtHlc);
  static Insertable<StaffAttendanceRow> custom({
    Expression<String>? id,
    Expression<String>? staffId,
    Expression<DateTime>? onDate,
    Expression<int>? status,
    Expression<String>? note,
    Expression<String>? createdAtHlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (staffId != null) 'staff_id': staffId,
      if (onDate != null) 'on_date': onDate,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (createdAtHlc != null) 'created_at_hlc': createdAtHlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffAttendanceCompanion copyWith(
      {Value<String>? id,
      Value<String>? staffId,
      Value<DateTime>? onDate,
      Value<AttendanceStatus>? status,
      Value<String?>? note,
      Value<String>? createdAtHlc,
      Value<int>? rowid}) {
    return StaffAttendanceCompanion(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      onDate: onDate ?? this.onDate,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAtHlc: createdAtHlc ?? this.createdAtHlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (onDate.present) {
      map['on_date'] = Variable<DateTime>(onDate.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
          $StaffAttendanceTable.$converterstatus.toSql(status.value));
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtHlc.present) {
      map['created_at_hlc'] = Variable<String>(createdAtHlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffAttendanceCompanion(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('onDate: $onDate, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(Insertable<AppMetaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  final String key;
  final String value;
  const AppMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppMetaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaRow copyWith({String? key, String? value}) => AppMetaRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $PostingsTable postings = $PostingsTable(this);
  late final $LedgerEventsTable ledgerEvents = $LedgerEventsTable(this);
  late final $RecurringTemplatesTable recurringTemplates =
      $RecurringTemplatesTable(this);
  late final $StaffMembersTable staffMembers = $StaffMembersTable(this);
  late final $StaffAttendanceTable staffAttendance =
      $StaffAttendanceTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accounts,
        ledgerEntries,
        postings,
        ledgerEvents,
        recurringTemplates,
        staffMembers,
        staffAttendance,
        appMeta
      ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String code,
  required String name,
  required String nameUr,
  required AccountType type,
  Value<String?> parentId,
  Value<String?> iconKey,
  Value<int?> colorValue,
  Value<bool> isSystem,
  Value<bool> isArchived,
  Value<int> sortOrder,
  required String createdAtHlc,
  required String updatedAtHlc,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<String> name,
  Value<String> nameUr,
  Value<AccountType> type,
  Value<String?> parentId,
  Value<String?> iconKey,
  Value<int?> colorValue,
  Value<bool> isSystem,
  Value<bool> isArchived,
  Value<int> sortOrder,
  Value<String> createdAtHlc,
  Value<String> updatedAtHlc,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _parentIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('accounts__parent_id__accounts__id');

  $$AccountsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PostingsTable, List<PostingRow>>
      _postingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.postings,
              aliasName: 'accounts__id__postings__account_id');

  $$PostingsTableProcessedTableManager get postingsRefs {
    final manager = $$PostingsTableTableManager($_db, $_db.postings)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_postingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecurringTemplatesTable,
      List<RecurringTemplateRow>> _templatesByCategoryTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.recurringTemplates,
          aliasName: 'accounts__id__recurring_templates__category_account_id');

  $$RecurringTemplatesTableProcessedTableManager get templatesByCategory {
    final manager =
        $$RecurringTemplatesTableTableManager($_db, $_db.recurringTemplates)
            .filter((f) =>
                f.categoryAccountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_templatesByCategoryTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecurringTemplatesTable,
      List<RecurringTemplateRow>> _templatesBySourceTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.recurringTemplates,
          aliasName: 'accounts__id__recurring_templates__source_account_id');

  $$RecurringTemplatesTableProcessedTableManager get templatesBySource {
    final manager = $$RecurringTemplatesTableTableManager(
            $_db, $_db.recurringTemplates)
        .filter(
            (f) => f.sourceAccountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_templatesBySourceTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$StaffMembersTable, List<StaffMemberRow>>
      _staffBySalaryAccountTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.staffMembers,
              aliasName: 'accounts__id__staff_members__salary_account_id');

  $$StaffMembersTableProcessedTableManager get staffBySalaryAccount {
    final manager = $$StaffMembersTableTableManager($_db, $_db.staffMembers)
        .filter(
            (f) => f.salaryAccountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_staffBySalaryAccountTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$StaffMembersTable, List<StaffMemberRow>>
      _staffByAdvanceAccountTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.staffMembers,
              aliasName: 'accounts__id__staff_members__advance_account_id');

  $$StaffMembersTableProcessedTableManager get staffByAdvanceAccount {
    final manager = $$StaffMembersTableTableManager($_db, $_db.staffMembers)
        .filter((f) =>
            f.advanceAccountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_staffByAdvanceAccountTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameUr => $composableBuilder(
      column: $table.nameUr, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AccountType, AccountType, int> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get iconKey => $composableBuilder(
      column: $table.iconKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSystem => $composableBuilder(
      column: $table.isSystem, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
      column: $table.updatedAtHlc, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get parentId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> postingsRefs(
      Expression<bool> Function($$PostingsTableFilterComposer f) f) {
    final $$PostingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postings,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingsTableFilterComposer(
              $db: $db,
              $table: $db.postings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> templatesByCategory(
      Expression<bool> Function($$RecurringTemplatesTableFilterComposer f) f) {
    final $$RecurringTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.categoryAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> templatesBySource(
      Expression<bool> Function($$RecurringTemplatesTableFilterComposer f) f) {
    final $$RecurringTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.sourceAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> staffBySalaryAccount(
      Expression<bool> Function($$StaffMembersTableFilterComposer f) f) {
    final $$StaffMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.staffMembers,
        getReferencedColumn: (t) => t.salaryAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffMembersTableFilterComposer(
              $db: $db,
              $table: $db.staffMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> staffByAdvanceAccount(
      Expression<bool> Function($$StaffMembersTableFilterComposer f) f) {
    final $$StaffMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.staffMembers,
        getReferencedColumn: (t) => t.advanceAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffMembersTableFilterComposer(
              $db: $db,
              $table: $db.staffMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameUr => $composableBuilder(
      column: $table.nameUr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconKey => $composableBuilder(
      column: $table.iconKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSystem => $composableBuilder(
      column: $table.isSystem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
      column: $table.updatedAtHlc,
      builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get parentId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameUr =>
      $composableBuilder(column: $table.nameUr, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
      column: $table.updatedAtHlc, builder: (column) => column);

  $$AccountsTableAnnotationComposer get parentId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> postingsRefs<T extends Object>(
      Expression<T> Function($$PostingsTableAnnotationComposer a) f) {
    final $$PostingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postings,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingsTableAnnotationComposer(
              $db: $db,
              $table: $db.postings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> templatesByCategory<T extends Object>(
      Expression<T> Function($$RecurringTemplatesTableAnnotationComposer a) f) {
    final $$RecurringTemplatesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTemplates,
            getReferencedColumn: (t) => t.categoryAccountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTemplatesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTemplates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> templatesBySource<T extends Object>(
      Expression<T> Function($$RecurringTemplatesTableAnnotationComposer a) f) {
    final $$RecurringTemplatesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTemplates,
            getReferencedColumn: (t) => t.sourceAccountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTemplatesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTemplates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> staffBySalaryAccount<T extends Object>(
      Expression<T> Function($$StaffMembersTableAnnotationComposer a) f) {
    final $$StaffMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.staffMembers,
        getReferencedColumn: (t) => t.salaryAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.staffMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> staffByAdvanceAccount<T extends Object>(
      Expression<T> Function($$StaffMembersTableAnnotationComposer a) f) {
    final $$StaffMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.staffMembers,
        getReferencedColumn: (t) => t.advanceAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.staffMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    AccountRow,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (AccountRow, $$AccountsTableReferences),
    AccountRow,
    PrefetchHooks Function(
        {bool parentId,
        bool postingsRefs,
        bool templatesByCategory,
        bool templatesBySource,
        bool staffBySalaryAccount,
        bool staffByAdvanceAccount})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nameUr = const Value.absent(),
            Value<AccountType> type = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String?> iconKey = const Value.absent(),
            Value<int?> colorValue = const Value.absent(),
            Value<bool> isSystem = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> createdAtHlc = const Value.absent(),
            Value<String> updatedAtHlc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            code: code,
            name: name,
            nameUr: nameUr,
            type: type,
            parentId: parentId,
            iconKey: iconKey,
            colorValue: colorValue,
            isSystem: isSystem,
            isArchived: isArchived,
            sortOrder: sortOrder,
            createdAtHlc: createdAtHlc,
            updatedAtHlc: updatedAtHlc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String code,
            required String name,
            required String nameUr,
            required AccountType type,
            Value<String?> parentId = const Value.absent(),
            Value<String?> iconKey = const Value.absent(),
            Value<int?> colorValue = const Value.absent(),
            Value<bool> isSystem = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required String createdAtHlc,
            required String updatedAtHlc,
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            code: code,
            name: name,
            nameUr: nameUr,
            type: type,
            parentId: parentId,
            iconKey: iconKey,
            colorValue: colorValue,
            isSystem: isSystem,
            isArchived: isArchived,
            sortOrder: sortOrder,
            createdAtHlc: createdAtHlc,
            updatedAtHlc: updatedAtHlc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {parentId = false,
              postingsRefs = false,
              templatesByCategory = false,
              templatesBySource = false,
              staffBySalaryAccount = false,
              staffByAdvanceAccount = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (postingsRefs) db.postings,
                if (templatesByCategory) db.recurringTemplates,
                if (templatesBySource) db.recurringTemplates,
                if (staffBySalaryAccount) db.staffMembers,
                if (staffByAdvanceAccount) db.staffMembers
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (parentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentId,
                    referencedTable:
                        $$AccountsTableReferences._parentIdTable(db),
                    referencedColumn:
                        $$AccountsTableReferences._parentIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (postingsRefs)
                    await $_getPrefetchedData<AccountRow, $AccountsTable,
                            PostingRow>(
                        currentTable: table,
                        referencedTable:
                            $$AccountsTableReferences._postingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .postingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items),
                  if (templatesByCategory)
                    await $_getPrefetchedData<AccountRow, $AccountsTable,
                            RecurringTemplateRow>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._templatesByCategoryTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .templatesByCategory,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryAccountId == item.id),
                        typedResults: items),
                  if (templatesBySource)
                    await $_getPrefetchedData<AccountRow, $AccountsTable,
                            RecurringTemplateRow>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._templatesBySourceTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .templatesBySource,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sourceAccountId == item.id),
                        typedResults: items),
                  if (staffBySalaryAccount)
                    await $_getPrefetchedData<AccountRow, $AccountsTable,
                            StaffMemberRow>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._staffBySalaryAccountTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .staffBySalaryAccount,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.salaryAccountId == item.id),
                        typedResults: items),
                  if (staffByAdvanceAccount)
                    await $_getPrefetchedData<AccountRow, $AccountsTable,
                            StaffMemberRow>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._staffByAdvanceAccountTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .staffByAdvanceAccount,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.advanceAccountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    AccountRow,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (AccountRow, $$AccountsTableReferences),
    AccountRow,
    PrefetchHooks Function(
        {bool parentId,
        bool postingsRefs,
        bool templatesByCategory,
        bool templatesBySource,
        bool staffBySalaryAccount,
        bool staffByAdvanceAccount})>;
typedef $$LedgerEntriesTableCreateCompanionBuilder = LedgerEntriesCompanion
    Function({
  required String id,
  required DateTime occurredOn,
  required String description,
  Value<String?> note,
  Value<bool> isVoided,
  Value<String?> voidedByEventId,
  required String createdAtHlc,
  required String deviceId,
  Value<int> rowid,
});
typedef $$LedgerEntriesTableUpdateCompanionBuilder = LedgerEntriesCompanion
    Function({
  Value<String> id,
  Value<DateTime> occurredOn,
  Value<String> description,
  Value<String?> note,
  Value<bool> isVoided,
  Value<String?> voidedByEventId,
  Value<String> createdAtHlc,
  Value<String> deviceId,
  Value<int> rowid,
});

final class $$LedgerEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntryRow> {
  $$LedgerEntriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PostingsTable, List<PostingRow>>
      _postingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.postings,
              aliasName: 'ledger_entries__id__postings__entry_id');

  $$PostingsTableProcessedTableManager get postingsRefs {
    final manager = $$PostingsTableTableManager($_db, $_db.postings)
        .filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_postingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredOn => $composableBuilder(
      column: $table.occurredOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVoided => $composableBuilder(
      column: $table.isVoided, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voidedByEventId => $composableBuilder(
      column: $table.voidedByEventId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  Expression<bool> postingsRefs(
      Expression<bool> Function($$PostingsTableFilterComposer f) f) {
    final $$PostingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postings,
        getReferencedColumn: (t) => t.entryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingsTableFilterComposer(
              $db: $db,
              $table: $db.postings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredOn => $composableBuilder(
      column: $table.occurredOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVoided => $composableBuilder(
      column: $table.isVoided, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voidedByEventId => $composableBuilder(
      column: $table.voidedByEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredOn => $composableBuilder(
      column: $table.occurredOn, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isVoided =>
      $composableBuilder(column: $table.isVoided, builder: (column) => column);

  GeneratedColumn<String> get voidedByEventId => $composableBuilder(
      column: $table.voidedByEventId, builder: (column) => column);

  GeneratedColumn<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  Expression<T> postingsRefs<T extends Object>(
      Expression<T> Function($$PostingsTableAnnotationComposer a) f) {
    final $$PostingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.postings,
        getReferencedColumn: (t) => t.entryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PostingsTableAnnotationComposer(
              $db: $db,
              $table: $db.postings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LedgerEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerEntryRow,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (LedgerEntryRow, $$LedgerEntriesTableReferences),
    LedgerEntryRow,
    PrefetchHooks Function({bool postingsRefs})> {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> occurredOn = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> isVoided = const Value.absent(),
            Value<String?> voidedByEventId = const Value.absent(),
            Value<String> createdAtHlc = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerEntriesCompanion(
            id: id,
            occurredOn: occurredOn,
            description: description,
            note: note,
            isVoided: isVoided,
            voidedByEventId: voidedByEventId,
            createdAtHlc: createdAtHlc,
            deviceId: deviceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime occurredOn,
            required String description,
            Value<String?> note = const Value.absent(),
            Value<bool> isVoided = const Value.absent(),
            Value<String?> voidedByEventId = const Value.absent(),
            required String createdAtHlc,
            required String deviceId,
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerEntriesCompanion.insert(
            id: id,
            occurredOn: occurredOn,
            description: description,
            note: note,
            isVoided: isVoided,
            voidedByEventId: voidedByEventId,
            createdAtHlc: createdAtHlc,
            deviceId: deviceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LedgerEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({postingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (postingsRefs) db.postings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (postingsRefs)
                    await $_getPrefetchedData<LedgerEntryRow, $LedgerEntriesTable,
                            PostingRow>(
                        currentTable: table,
                        referencedTable: $$LedgerEntriesTableReferences
                            ._postingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LedgerEntriesTableReferences(db, table, p0)
                                .postingsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.entryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LedgerEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerEntryRow,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (LedgerEntryRow, $$LedgerEntriesTableReferences),
    LedgerEntryRow,
    PrefetchHooks Function({bool postingsRefs})>;
typedef $$PostingsTableCreateCompanionBuilder = PostingsCompanion Function({
  required String id,
  required String entryId,
  required String accountId,
  required int amountMinor,
  Value<String?> memo,
  Value<int> position,
  Value<bool> isVoided,
  Value<int> rowid,
});
typedef $$PostingsTableUpdateCompanionBuilder = PostingsCompanion Function({
  Value<String> id,
  Value<String> entryId,
  Value<String> accountId,
  Value<int> amountMinor,
  Value<String?> memo,
  Value<int> position,
  Value<bool> isVoided,
  Value<int> rowid,
});

final class $$PostingsTableReferences
    extends BaseReferences<_$AppDatabase, $PostingsTable, PostingRow> {
  $$PostingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LedgerEntriesTable _entryIdTable(_$AppDatabase db) =>
      db.ledgerEntries.createAlias('postings__entry_id__ledger_entries__id');

  $$LedgerEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$LedgerEntriesTableTableManager($_db, $_db.ledgerEntries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('postings__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PostingsTableFilterComposer
    extends Composer<_$AppDatabase, $PostingsTable> {
  $$PostingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVoided => $composableBuilder(
      column: $table.isVoided, builder: (column) => ColumnFilters(column));

  $$LedgerEntriesTableFilterComposer get entryId {
    final $$LedgerEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.entryId,
        referencedTable: $db.ledgerEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LedgerEntriesTableFilterComposer(
              $db: $db,
              $table: $db.ledgerEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PostingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostingsTable> {
  $$PostingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVoided => $composableBuilder(
      column: $table.isVoided, builder: (column) => ColumnOrderings(column));

  $$LedgerEntriesTableOrderingComposer get entryId {
    final $$LedgerEntriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.entryId,
        referencedTable: $db.ledgerEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LedgerEntriesTableOrderingComposer(
              $db: $db,
              $table: $db.ledgerEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PostingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostingsTable> {
  $$PostingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isVoided =>
      $composableBuilder(column: $table.isVoided, builder: (column) => column);

  $$LedgerEntriesTableAnnotationComposer get entryId {
    final $$LedgerEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.entryId,
        referencedTable: $db.ledgerEntries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LedgerEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.ledgerEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PostingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PostingsTable,
    PostingRow,
    $$PostingsTableFilterComposer,
    $$PostingsTableOrderingComposer,
    $$PostingsTableAnnotationComposer,
    $$PostingsTableCreateCompanionBuilder,
    $$PostingsTableUpdateCompanionBuilder,
    (PostingRow, $$PostingsTableReferences),
    PostingRow,
    PrefetchHooks Function({bool entryId, bool accountId})> {
  $$PostingsTableTableManager(_$AppDatabase db, $PostingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entryId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<bool> isVoided = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PostingsCompanion(
            id: id,
            entryId: entryId,
            accountId: accountId,
            amountMinor: amountMinor,
            memo: memo,
            position: position,
            isVoided: isVoided,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entryId,
            required String accountId,
            required int amountMinor,
            Value<String?> memo = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<bool> isVoided = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PostingsCompanion.insert(
            id: id,
            entryId: entryId,
            accountId: accountId,
            amountMinor: amountMinor,
            memo: memo,
            position: position,
            isVoided: isVoided,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PostingsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({entryId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (entryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.entryId,
                    referencedTable:
                        $$PostingsTableReferences._entryIdTable(db),
                    referencedColumn:
                        $$PostingsTableReferences._entryIdTable(db).id,
                  ) as T;
                }
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$PostingsTableReferences._accountIdTable(db),
                    referencedColumn:
                        $$PostingsTableReferences._accountIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PostingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PostingsTable,
    PostingRow,
    $$PostingsTableFilterComposer,
    $$PostingsTableOrderingComposer,
    $$PostingsTableAnnotationComposer,
    $$PostingsTableCreateCompanionBuilder,
    $$PostingsTableUpdateCompanionBuilder,
    (PostingRow, $$PostingsTableReferences),
    PostingRow,
    PrefetchHooks Function({bool entryId, bool accountId})>;
typedef $$LedgerEventsTableCreateCompanionBuilder = LedgerEventsCompanion
    Function({
  required String id,
  required String hlc,
  required String deviceId,
  required int type,
  required String payload,
  required DateTime appliedAt,
  Value<bool> isRemote,
  Value<int> rowid,
});
typedef $$LedgerEventsTableUpdateCompanionBuilder = LedgerEventsCompanion
    Function({
  Value<String> id,
  Value<String> hlc,
  Value<String> deviceId,
  Value<int> type,
  Value<String> payload,
  Value<DateTime> appliedAt,
  Value<bool> isRemote,
  Value<int> rowid,
});

class $$LedgerEventsTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEventsTable> {
  $$LedgerEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hlc => $composableBuilder(
      column: $table.hlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
      column: $table.appliedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRemote => $composableBuilder(
      column: $table.isRemote, builder: (column) => ColumnFilters(column));
}

class $$LedgerEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEventsTable> {
  $$LedgerEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc => $composableBuilder(
      column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
      column: $table.appliedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRemote => $composableBuilder(
      column: $table.isRemote, builder: (column) => ColumnOrderings(column));
}

class $$LedgerEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEventsTable> {
  $$LedgerEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<bool> get isRemote =>
      $composableBuilder(column: $table.isRemote, builder: (column) => column);
}

class $$LedgerEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LedgerEventsTable,
    LedgerEventRow,
    $$LedgerEventsTableFilterComposer,
    $$LedgerEventsTableOrderingComposer,
    $$LedgerEventsTableAnnotationComposer,
    $$LedgerEventsTableCreateCompanionBuilder,
    $$LedgerEventsTableUpdateCompanionBuilder,
    (
      LedgerEventRow,
      BaseReferences<_$AppDatabase, $LedgerEventsTable, LedgerEventRow>
    ),
    LedgerEventRow,
    PrefetchHooks Function()> {
  $$LedgerEventsTableTableManager(_$AppDatabase db, $LedgerEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> hlc = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> appliedAt = const Value.absent(),
            Value<bool> isRemote = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerEventsCompanion(
            id: id,
            hlc: hlc,
            deviceId: deviceId,
            type: type,
            payload: payload,
            appliedAt: appliedAt,
            isRemote: isRemote,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String hlc,
            required String deviceId,
            required int type,
            required String payload,
            required DateTime appliedAt,
            Value<bool> isRemote = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerEventsCompanion.insert(
            id: id,
            hlc: hlc,
            deviceId: deviceId,
            type: type,
            payload: payload,
            appliedAt: appliedAt,
            isRemote: isRemote,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LedgerEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LedgerEventsTable,
    LedgerEventRow,
    $$LedgerEventsTableFilterComposer,
    $$LedgerEventsTableOrderingComposer,
    $$LedgerEventsTableAnnotationComposer,
    $$LedgerEventsTableCreateCompanionBuilder,
    $$LedgerEventsTableUpdateCompanionBuilder,
    (
      LedgerEventRow,
      BaseReferences<_$AppDatabase, $LedgerEventsTable, LedgerEventRow>
    ),
    LedgerEventRow,
    PrefetchHooks Function()>;
typedef $$RecurringTemplatesTableCreateCompanionBuilder
    = RecurringTemplatesCompanion Function({
  required String id,
  required RecurringKind kind,
  required String categoryAccountId,
  required String sourceAccountId,
  Value<int> amountMinor,
  required String description,
  required int dayOfMonth,
  Value<bool> isActive,
  Value<String?> lastPostedPeriod,
  required String createdAtHlc,
  required String updatedAtHlc,
  Value<int> rowid,
});
typedef $$RecurringTemplatesTableUpdateCompanionBuilder
    = RecurringTemplatesCompanion Function({
  Value<String> id,
  Value<RecurringKind> kind,
  Value<String> categoryAccountId,
  Value<String> sourceAccountId,
  Value<int> amountMinor,
  Value<String> description,
  Value<int> dayOfMonth,
  Value<bool> isActive,
  Value<String?> lastPostedPeriod,
  Value<String> createdAtHlc,
  Value<String> updatedAtHlc,
  Value<int> rowid,
});

final class $$RecurringTemplatesTableReferences extends BaseReferences<
    _$AppDatabase, $RecurringTemplatesTable, RecurringTemplateRow> {
  $$RecurringTemplatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _categoryAccountIdTable(_$AppDatabase db) => db.accounts
      .createAlias('recurring_templates__category_account_id__accounts__id');

  $$AccountsTableProcessedTableManager get categoryAccountId {
    final $_column = $_itemColumn<String>('category_account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _sourceAccountIdTable(_$AppDatabase db) => db.accounts
      .createAlias('recurring_templates__source_account_id__accounts__id');

  $$AccountsTableProcessedTableManager get sourceAccountId {
    final $_column = $_itemColumn<String>('source_account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecurringTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RecurringKind, RecurringKind, int> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastPostedPeriod => $composableBuilder(
      column: $table.lastPostedPeriod,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
      column: $table.updatedAtHlc, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get categoryAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get sourceAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastPostedPeriod => $composableBuilder(
      column: $table.lastPostedPeriod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
      column: $table.updatedAtHlc,
      builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get categoryAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get sourceAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurringKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get lastPostedPeriod => $composableBuilder(
      column: $table.lastPostedPeriod, builder: (column) => column);

  GeneratedColumn<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
      column: $table.updatedAtHlc, builder: (column) => column);

  $$AccountsTableAnnotationComposer get categoryAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get sourceAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringTemplatesTable,
    RecurringTemplateRow,
    $$RecurringTemplatesTableFilterComposer,
    $$RecurringTemplatesTableOrderingComposer,
    $$RecurringTemplatesTableAnnotationComposer,
    $$RecurringTemplatesTableCreateCompanionBuilder,
    $$RecurringTemplatesTableUpdateCompanionBuilder,
    (RecurringTemplateRow, $$RecurringTemplatesTableReferences),
    RecurringTemplateRow,
    PrefetchHooks Function({bool categoryAccountId, bool sourceAccountId})> {
  $$RecurringTemplatesTableTableManager(
      _$AppDatabase db, $RecurringTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringTemplatesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<RecurringKind> kind = const Value.absent(),
            Value<String> categoryAccountId = const Value.absent(),
            Value<String> sourceAccountId = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> dayOfMonth = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> lastPostedPeriod = const Value.absent(),
            Value<String> createdAtHlc = const Value.absent(),
            Value<String> updatedAtHlc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTemplatesCompanion(
            id: id,
            kind: kind,
            categoryAccountId: categoryAccountId,
            sourceAccountId: sourceAccountId,
            amountMinor: amountMinor,
            description: description,
            dayOfMonth: dayOfMonth,
            isActive: isActive,
            lastPostedPeriod: lastPostedPeriod,
            createdAtHlc: createdAtHlc,
            updatedAtHlc: updatedAtHlc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required RecurringKind kind,
            required String categoryAccountId,
            required String sourceAccountId,
            Value<int> amountMinor = const Value.absent(),
            required String description,
            required int dayOfMonth,
            Value<bool> isActive = const Value.absent(),
            Value<String?> lastPostedPeriod = const Value.absent(),
            required String createdAtHlc,
            required String updatedAtHlc,
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTemplatesCompanion.insert(
            id: id,
            kind: kind,
            categoryAccountId: categoryAccountId,
            sourceAccountId: sourceAccountId,
            amountMinor: amountMinor,
            description: description,
            dayOfMonth: dayOfMonth,
            isActive: isActive,
            lastPostedPeriod: lastPostedPeriod,
            createdAtHlc: createdAtHlc,
            updatedAtHlc: updatedAtHlc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringTemplatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryAccountId = false, sourceAccountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryAccountId,
                    referencedTable: $$RecurringTemplatesTableReferences
                        ._categoryAccountIdTable(db),
                    referencedColumn: $$RecurringTemplatesTableReferences
                        ._categoryAccountIdTable(db)
                        .id,
                  ) as T;
                }
                if (sourceAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceAccountId,
                    referencedTable: $$RecurringTemplatesTableReferences
                        ._sourceAccountIdTable(db),
                    referencedColumn: $$RecurringTemplatesTableReferences
                        ._sourceAccountIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecurringTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringTemplatesTable,
    RecurringTemplateRow,
    $$RecurringTemplatesTableFilterComposer,
    $$RecurringTemplatesTableOrderingComposer,
    $$RecurringTemplatesTableAnnotationComposer,
    $$RecurringTemplatesTableCreateCompanionBuilder,
    $$RecurringTemplatesTableUpdateCompanionBuilder,
    (RecurringTemplateRow, $$RecurringTemplatesTableReferences),
    RecurringTemplateRow,
    PrefetchHooks Function({bool categoryAccountId, bool sourceAccountId})>;
typedef $$StaffMembersTableCreateCompanionBuilder = StaffMembersCompanion
    Function({
  required String id,
  required String name,
  Value<String?> phone,
  required int monthlySalaryMinor,
  required String salaryAccountId,
  required String advanceAccountId,
  required DateTime joinedOn,
  Value<bool> isActive,
  required String createdAtHlc,
  required String updatedAtHlc,
  Value<int> rowid,
});
typedef $$StaffMembersTableUpdateCompanionBuilder = StaffMembersCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<int> monthlySalaryMinor,
  Value<String> salaryAccountId,
  Value<String> advanceAccountId,
  Value<DateTime> joinedOn,
  Value<bool> isActive,
  Value<String> createdAtHlc,
  Value<String> updatedAtHlc,
  Value<int> rowid,
});

final class $$StaffMembersTableReferences
    extends BaseReferences<_$AppDatabase, $StaffMembersTable, StaffMemberRow> {
  $$StaffMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _salaryAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('staff_members__salary_account_id__accounts__id');

  $$AccountsTableProcessedTableManager get salaryAccountId {
    final $_column = $_itemColumn<String>('salary_account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_salaryAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _advanceAccountIdTable(_$AppDatabase db) => db.accounts
      .createAlias('staff_members__advance_account_id__accounts__id');

  $$AccountsTableProcessedTableManager get advanceAccountId {
    final $_column = $_itemColumn<String>('advance_account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_advanceAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$StaffAttendanceTable, List<StaffAttendanceRow>>
      _attendanceByStaffTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.staffAttendance,
              aliasName: 'staff_members__id__staff_attendance__staff_id');

  $$StaffAttendanceTableProcessedTableManager get attendanceByStaff {
    final manager =
        $$StaffAttendanceTableTableManager($_db, $_db.staffAttendance)
            .filter((f) => f.staffId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendanceByStaffTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$StaffMembersTableFilterComposer
    extends Composer<_$AppDatabase, $StaffMembersTable> {
  $$StaffMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthlySalaryMinor => $composableBuilder(
      column: $table.monthlySalaryMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get joinedOn => $composableBuilder(
      column: $table.joinedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
      column: $table.updatedAtHlc, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get salaryAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.salaryAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get advanceAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.advanceAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> attendanceByStaff(
      Expression<bool> Function($$StaffAttendanceTableFilterComposer f) f) {
    final $$StaffAttendanceTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.staffAttendance,
        getReferencedColumn: (t) => t.staffId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffAttendanceTableFilterComposer(
              $db: $db,
              $table: $db.staffAttendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StaffMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffMembersTable> {
  $$StaffMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthlySalaryMinor => $composableBuilder(
      column: $table.monthlySalaryMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joinedOn => $composableBuilder(
      column: $table.joinedOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
      column: $table.updatedAtHlc,
      builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get salaryAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.salaryAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get advanceAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.advanceAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StaffMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffMembersTable> {
  $$StaffMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get monthlySalaryMinor => $composableBuilder(
      column: $table.monthlySalaryMinor, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedOn =>
      $composableBuilder(column: $table.joinedOn, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
      column: $table.updatedAtHlc, builder: (column) => column);

  $$AccountsTableAnnotationComposer get salaryAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.salaryAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get advanceAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.advanceAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> attendanceByStaff<T extends Object>(
      Expression<T> Function($$StaffAttendanceTableAnnotationComposer a) f) {
    final $$StaffAttendanceTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.staffAttendance,
        getReferencedColumn: (t) => t.staffId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffAttendanceTableAnnotationComposer(
              $db: $db,
              $table: $db.staffAttendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StaffMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StaffMembersTable,
    StaffMemberRow,
    $$StaffMembersTableFilterComposer,
    $$StaffMembersTableOrderingComposer,
    $$StaffMembersTableAnnotationComposer,
    $$StaffMembersTableCreateCompanionBuilder,
    $$StaffMembersTableUpdateCompanionBuilder,
    (StaffMemberRow, $$StaffMembersTableReferences),
    StaffMemberRow,
    PrefetchHooks Function(
        {bool salaryAccountId,
        bool advanceAccountId,
        bool attendanceByStaff})> {
  $$StaffMembersTableTableManager(_$AppDatabase db, $StaffMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<int> monthlySalaryMinor = const Value.absent(),
            Value<String> salaryAccountId = const Value.absent(),
            Value<String> advanceAccountId = const Value.absent(),
            Value<DateTime> joinedOn = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> createdAtHlc = const Value.absent(),
            Value<String> updatedAtHlc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffMembersCompanion(
            id: id,
            name: name,
            phone: phone,
            monthlySalaryMinor: monthlySalaryMinor,
            salaryAccountId: salaryAccountId,
            advanceAccountId: advanceAccountId,
            joinedOn: joinedOn,
            isActive: isActive,
            createdAtHlc: createdAtHlc,
            updatedAtHlc: updatedAtHlc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> phone = const Value.absent(),
            required int monthlySalaryMinor,
            required String salaryAccountId,
            required String advanceAccountId,
            required DateTime joinedOn,
            Value<bool> isActive = const Value.absent(),
            required String createdAtHlc,
            required String updatedAtHlc,
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffMembersCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            monthlySalaryMinor: monthlySalaryMinor,
            salaryAccountId: salaryAccountId,
            advanceAccountId: advanceAccountId,
            joinedOn: joinedOn,
            isActive: isActive,
            createdAtHlc: createdAtHlc,
            updatedAtHlc: updatedAtHlc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StaffMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {salaryAccountId = false,
              advanceAccountId = false,
              attendanceByStaff = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (attendanceByStaff) db.staffAttendance
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (salaryAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.salaryAccountId,
                    referencedTable:
                        $$StaffMembersTableReferences._salaryAccountIdTable(db),
                    referencedColumn: $$StaffMembersTableReferences
                        ._salaryAccountIdTable(db)
                        .id,
                  ) as T;
                }
                if (advanceAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.advanceAccountId,
                    referencedTable: $$StaffMembersTableReferences
                        ._advanceAccountIdTable(db),
                    referencedColumn: $$StaffMembersTableReferences
                        ._advanceAccountIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attendanceByStaff)
                    await $_getPrefetchedData<StaffMemberRow,
                            $StaffMembersTable, StaffAttendanceRow>(
                        currentTable: table,
                        referencedTable: $$StaffMembersTableReferences
                            ._attendanceByStaffTable(db),
                        managerFromTypedResult: (p0) =>
                            $$StaffMembersTableReferences(db, table, p0)
                                .attendanceByStaff,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.staffId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$StaffMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StaffMembersTable,
    StaffMemberRow,
    $$StaffMembersTableFilterComposer,
    $$StaffMembersTableOrderingComposer,
    $$StaffMembersTableAnnotationComposer,
    $$StaffMembersTableCreateCompanionBuilder,
    $$StaffMembersTableUpdateCompanionBuilder,
    (StaffMemberRow, $$StaffMembersTableReferences),
    StaffMemberRow,
    PrefetchHooks Function(
        {bool salaryAccountId, bool advanceAccountId, bool attendanceByStaff})>;
typedef $$StaffAttendanceTableCreateCompanionBuilder = StaffAttendanceCompanion
    Function({
  required String id,
  required String staffId,
  required DateTime onDate,
  required AttendanceStatus status,
  Value<String?> note,
  required String createdAtHlc,
  Value<int> rowid,
});
typedef $$StaffAttendanceTableUpdateCompanionBuilder = StaffAttendanceCompanion
    Function({
  Value<String> id,
  Value<String> staffId,
  Value<DateTime> onDate,
  Value<AttendanceStatus> status,
  Value<String?> note,
  Value<String> createdAtHlc,
  Value<int> rowid,
});

final class $$StaffAttendanceTableReferences extends BaseReferences<
    _$AppDatabase, $StaffAttendanceTable, StaffAttendanceRow> {
  $$StaffAttendanceTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $StaffMembersTable _staffIdTable(_$AppDatabase db) => db.staffMembers
      .createAlias('staff_attendance__staff_id__staff_members__id');

  $$StaffMembersTableProcessedTableManager get staffId {
    final $_column = $_itemColumn<String>('staff_id')!;

    final manager = $$StaffMembersTableTableManager($_db, $_db.staffMembers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_staffIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StaffAttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $StaffAttendanceTable> {
  $$StaffAttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get onDate => $composableBuilder(
      column: $table.onDate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AttendanceStatus, AttendanceStatus, int>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc, builder: (column) => ColumnFilters(column));

  $$StaffMembersTableFilterComposer get staffId {
    final $$StaffMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.staffId,
        referencedTable: $db.staffMembers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffMembersTableFilterComposer(
              $db: $db,
              $table: $db.staffMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StaffAttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffAttendanceTable> {
  $$StaffAttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get onDate => $composableBuilder(
      column: $table.onDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc,
      builder: (column) => ColumnOrderings(column));

  $$StaffMembersTableOrderingComposer get staffId {
    final $$StaffMembersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.staffId,
        referencedTable: $db.staffMembers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffMembersTableOrderingComposer(
              $db: $db,
              $table: $db.staffMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StaffAttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffAttendanceTable> {
  $$StaffAttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get onDate =>
      $composableBuilder(column: $table.onDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AttendanceStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get createdAtHlc => $composableBuilder(
      column: $table.createdAtHlc, builder: (column) => column);

  $$StaffMembersTableAnnotationComposer get staffId {
    final $$StaffMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.staffId,
        referencedTable: $db.staffMembers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.staffMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StaffAttendanceTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StaffAttendanceTable,
    StaffAttendanceRow,
    $$StaffAttendanceTableFilterComposer,
    $$StaffAttendanceTableOrderingComposer,
    $$StaffAttendanceTableAnnotationComposer,
    $$StaffAttendanceTableCreateCompanionBuilder,
    $$StaffAttendanceTableUpdateCompanionBuilder,
    (StaffAttendanceRow, $$StaffAttendanceTableReferences),
    StaffAttendanceRow,
    PrefetchHooks Function({bool staffId})> {
  $$StaffAttendanceTableTableManager(
      _$AppDatabase db, $StaffAttendanceTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffAttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffAttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffAttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> staffId = const Value.absent(),
            Value<DateTime> onDate = const Value.absent(),
            Value<AttendanceStatus> status = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> createdAtHlc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffAttendanceCompanion(
            id: id,
            staffId: staffId,
            onDate: onDate,
            status: status,
            note: note,
            createdAtHlc: createdAtHlc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String staffId,
            required DateTime onDate,
            required AttendanceStatus status,
            Value<String?> note = const Value.absent(),
            required String createdAtHlc,
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffAttendanceCompanion.insert(
            id: id,
            staffId: staffId,
            onDate: onDate,
            status: status,
            note: note,
            createdAtHlc: createdAtHlc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StaffAttendanceTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({staffId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (staffId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.staffId,
                    referencedTable:
                        $$StaffAttendanceTableReferences._staffIdTable(db),
                    referencedColumn:
                        $$StaffAttendanceTableReferences._staffIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StaffAttendanceTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StaffAttendanceTable,
    StaffAttendanceRow,
    $$StaffAttendanceTableFilterComposer,
    $$StaffAttendanceTableOrderingComposer,
    $$StaffAttendanceTableAnnotationComposer,
    $$StaffAttendanceTableCreateCompanionBuilder,
    $$StaffAttendanceTableUpdateCompanionBuilder,
    (StaffAttendanceRow, $$StaffAttendanceTableReferences),
    StaffAttendanceRow,
    PrefetchHooks Function({bool staffId})>;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppMetaTable,
    AppMetaRow,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
    AppMetaRow,
    PrefetchHooks Function()> {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppMetaTable,
    AppMetaRow,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
    AppMetaRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$PostingsTableTableManager get postings =>
      $$PostingsTableTableManager(_db, _db.postings);
  $$LedgerEventsTableTableManager get ledgerEvents =>
      $$LedgerEventsTableTableManager(_db, _db.ledgerEvents);
  $$RecurringTemplatesTableTableManager get recurringTemplates =>
      $$RecurringTemplatesTableTableManager(_db, _db.recurringTemplates);
  $$StaffMembersTableTableManager get staffMembers =>
      $$StaffMembersTableTableManager(_db, _db.staffMembers);
  $$StaffAttendanceTableTableManager get staffAttendance =>
      $$StaffAttendanceTableTableManager(_db, _db.staffAttendance);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
}
