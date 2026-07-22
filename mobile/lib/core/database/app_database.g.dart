// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String? value;
  const AppSetting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppSetting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
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

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchoolProfileTable extends SchoolProfile
    with TableInfo<$SchoolProfileTable, SchoolProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicIdMeta = const VerificationMeta(
    'publicId',
  );
  @override
  late final GeneratedColumn<String> publicId = GeneratedColumn<String>(
    'public_id',
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
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileEnabledMeta = const VerificationMeta(
    'mobileEnabled',
  );
  @override
  late final GeneratedColumn<bool> mobileEnabled = GeneratedColumn<bool>(
    'mobile_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mobile_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _maintenanceModeMeta = const VerificationMeta(
    'maintenanceMode',
  );
  @override
  late final GeneratedColumn<bool> maintenanceMode = GeneratedColumn<bool>(
    'maintenance_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("maintenance_mode" IN (0, 1))',
    ),
  );
  static const VerificationMeta _maintenanceMessageMeta =
      const VerificationMeta('maintenanceMessage');
  @override
  late final GeneratedColumn<String> maintenanceMessage =
      GeneratedColumn<String>(
        'maintenance_message',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _minimumAppVersionMeta = const VerificationMeta(
    'minimumAppVersion',
  );
  @override
  late final GeneratedColumn<String> minimumAppVersion =
      GeneratedColumn<String>(
        'minimum_app_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    publicId,
    name,
    logoUrl,
    timezone,
    mobileEnabled,
    maintenanceMode,
    maintenanceMessage,
    notificationsEnabled,
    minimumAppVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'school_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('public_id')) {
      context.handle(
        _publicIdMeta,
        publicId.isAcceptableOrUnknown(data['public_id']!, _publicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_publicIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('mobile_enabled')) {
      context.handle(
        _mobileEnabledMeta,
        mobileEnabled.isAcceptableOrUnknown(
          data['mobile_enabled']!,
          _mobileEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mobileEnabledMeta);
    }
    if (data.containsKey('maintenance_mode')) {
      context.handle(
        _maintenanceModeMeta,
        maintenanceMode.isAcceptableOrUnknown(
          data['maintenance_mode']!,
          _maintenanceModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maintenanceModeMeta);
    }
    if (data.containsKey('maintenance_message')) {
      context.handle(
        _maintenanceMessageMeta,
        maintenanceMessage.isAcceptableOrUnknown(
          data['maintenance_message']!,
          _maintenanceMessageMeta,
        ),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationsEnabledMeta);
    }
    if (data.containsKey('minimum_app_version')) {
      context.handle(
        _minimumAppVersionMeta,
        minimumAppVersion.isAcceptableOrUnknown(
          data['minimum_app_version']!,
          _minimumAppVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minimumAppVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  SchoolProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolProfileData(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      publicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      mobileEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mobile_enabled'],
      )!,
      maintenanceMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}maintenance_mode'],
      )!,
      maintenanceMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maintenance_message'],
      ),
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      minimumAppVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}minimum_app_version'],
      )!,
    );
  }

  @override
  $SchoolProfileTable createAlias(String alias) {
    return $SchoolProfileTable(attachedDatabase, alias);
  }
}

class SchoolProfileData extends DataClass
    implements Insertable<SchoolProfileData> {
  final String uuid;
  final String publicId;
  final String name;
  final String? logoUrl;
  final String timezone;
  final bool mobileEnabled;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final bool notificationsEnabled;
  final String minimumAppVersion;
  const SchoolProfileData({
    required this.uuid,
    required this.publicId,
    required this.name,
    this.logoUrl,
    required this.timezone,
    required this.mobileEnabled,
    required this.maintenanceMode,
    this.maintenanceMessage,
    required this.notificationsEnabled,
    required this.minimumAppVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['public_id'] = Variable<String>(publicId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    map['timezone'] = Variable<String>(timezone);
    map['mobile_enabled'] = Variable<bool>(mobileEnabled);
    map['maintenance_mode'] = Variable<bool>(maintenanceMode);
    if (!nullToAbsent || maintenanceMessage != null) {
      map['maintenance_message'] = Variable<String>(maintenanceMessage);
    }
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['minimum_app_version'] = Variable<String>(minimumAppVersion);
    return map;
  }

  SchoolProfileCompanion toCompanion(bool nullToAbsent) {
    return SchoolProfileCompanion(
      uuid: Value(uuid),
      publicId: Value(publicId),
      name: Value(name),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      timezone: Value(timezone),
      mobileEnabled: Value(mobileEnabled),
      maintenanceMode: Value(maintenanceMode),
      maintenanceMessage: maintenanceMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(maintenanceMessage),
      notificationsEnabled: Value(notificationsEnabled),
      minimumAppVersion: Value(minimumAppVersion),
    );
  }

  factory SchoolProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchoolProfileData(
      uuid: serializer.fromJson<String>(json['uuid']),
      publicId: serializer.fromJson<String>(json['publicId']),
      name: serializer.fromJson<String>(json['name']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      timezone: serializer.fromJson<String>(json['timezone']),
      mobileEnabled: serializer.fromJson<bool>(json['mobileEnabled']),
      maintenanceMode: serializer.fromJson<bool>(json['maintenanceMode']),
      maintenanceMessage: serializer.fromJson<String?>(
        json['maintenanceMessage'],
      ),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      minimumAppVersion: serializer.fromJson<String>(json['minimumAppVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'publicId': serializer.toJson<String>(publicId),
      'name': serializer.toJson<String>(name),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'timezone': serializer.toJson<String>(timezone),
      'mobileEnabled': serializer.toJson<bool>(mobileEnabled),
      'maintenanceMode': serializer.toJson<bool>(maintenanceMode),
      'maintenanceMessage': serializer.toJson<String?>(maintenanceMessage),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'minimumAppVersion': serializer.toJson<String>(minimumAppVersion),
    };
  }

  SchoolProfileData copyWith({
    String? uuid,
    String? publicId,
    String? name,
    Value<String?> logoUrl = const Value.absent(),
    String? timezone,
    bool? mobileEnabled,
    bool? maintenanceMode,
    Value<String?> maintenanceMessage = const Value.absent(),
    bool? notificationsEnabled,
    String? minimumAppVersion,
  }) => SchoolProfileData(
    uuid: uuid ?? this.uuid,
    publicId: publicId ?? this.publicId,
    name: name ?? this.name,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    timezone: timezone ?? this.timezone,
    mobileEnabled: mobileEnabled ?? this.mobileEnabled,
    maintenanceMode: maintenanceMode ?? this.maintenanceMode,
    maintenanceMessage: maintenanceMessage.present
        ? maintenanceMessage.value
        : this.maintenanceMessage,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    minimumAppVersion: minimumAppVersion ?? this.minimumAppVersion,
  );
  SchoolProfileData copyWithCompanion(SchoolProfileCompanion data) {
    return SchoolProfileData(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      publicId: data.publicId.present ? data.publicId.value : this.publicId,
      name: data.name.present ? data.name.value : this.name,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      mobileEnabled: data.mobileEnabled.present
          ? data.mobileEnabled.value
          : this.mobileEnabled,
      maintenanceMode: data.maintenanceMode.present
          ? data.maintenanceMode.value
          : this.maintenanceMode,
      maintenanceMessage: data.maintenanceMessage.present
          ? data.maintenanceMessage.value
          : this.maintenanceMessage,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      minimumAppVersion: data.minimumAppVersion.present
          ? data.minimumAppVersion.value
          : this.minimumAppVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchoolProfileData(')
          ..write('uuid: $uuid, ')
          ..write('publicId: $publicId, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('timezone: $timezone, ')
          ..write('mobileEnabled: $mobileEnabled, ')
          ..write('maintenanceMode: $maintenanceMode, ')
          ..write('maintenanceMessage: $maintenanceMessage, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('minimumAppVersion: $minimumAppVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    publicId,
    name,
    logoUrl,
    timezone,
    mobileEnabled,
    maintenanceMode,
    maintenanceMessage,
    notificationsEnabled,
    minimumAppVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchoolProfileData &&
          other.uuid == this.uuid &&
          other.publicId == this.publicId &&
          other.name == this.name &&
          other.logoUrl == this.logoUrl &&
          other.timezone == this.timezone &&
          other.mobileEnabled == this.mobileEnabled &&
          other.maintenanceMode == this.maintenanceMode &&
          other.maintenanceMessage == this.maintenanceMessage &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.minimumAppVersion == this.minimumAppVersion);
}

class SchoolProfileCompanion extends UpdateCompanion<SchoolProfileData> {
  final Value<String> uuid;
  final Value<String> publicId;
  final Value<String> name;
  final Value<String?> logoUrl;
  final Value<String> timezone;
  final Value<bool> mobileEnabled;
  final Value<bool> maintenanceMode;
  final Value<String?> maintenanceMessage;
  final Value<bool> notificationsEnabled;
  final Value<String> minimumAppVersion;
  final Value<int> rowid;
  const SchoolProfileCompanion({
    this.uuid = const Value.absent(),
    this.publicId = const Value.absent(),
    this.name = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.timezone = const Value.absent(),
    this.mobileEnabled = const Value.absent(),
    this.maintenanceMode = const Value.absent(),
    this.maintenanceMessage = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.minimumAppVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolProfileCompanion.insert({
    required String uuid,
    required String publicId,
    required String name,
    this.logoUrl = const Value.absent(),
    required String timezone,
    required bool mobileEnabled,
    required bool maintenanceMode,
    this.maintenanceMessage = const Value.absent(),
    required bool notificationsEnabled,
    required String minimumAppVersion,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       publicId = Value(publicId),
       name = Value(name),
       timezone = Value(timezone),
       mobileEnabled = Value(mobileEnabled),
       maintenanceMode = Value(maintenanceMode),
       notificationsEnabled = Value(notificationsEnabled),
       minimumAppVersion = Value(minimumAppVersion);
  static Insertable<SchoolProfileData> custom({
    Expression<String>? uuid,
    Expression<String>? publicId,
    Expression<String>? name,
    Expression<String>? logoUrl,
    Expression<String>? timezone,
    Expression<bool>? mobileEnabled,
    Expression<bool>? maintenanceMode,
    Expression<String>? maintenanceMessage,
    Expression<bool>? notificationsEnabled,
    Expression<String>? minimumAppVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (publicId != null) 'public_id': publicId,
      if (name != null) 'name': name,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (timezone != null) 'timezone': timezone,
      if (mobileEnabled != null) 'mobile_enabled': mobileEnabled,
      if (maintenanceMode != null) 'maintenance_mode': maintenanceMode,
      if (maintenanceMessage != null) 'maintenance_message': maintenanceMessage,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (minimumAppVersion != null) 'minimum_app_version': minimumAppVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolProfileCompanion copyWith({
    Value<String>? uuid,
    Value<String>? publicId,
    Value<String>? name,
    Value<String?>? logoUrl,
    Value<String>? timezone,
    Value<bool>? mobileEnabled,
    Value<bool>? maintenanceMode,
    Value<String?>? maintenanceMessage,
    Value<bool>? notificationsEnabled,
    Value<String>? minimumAppVersion,
    Value<int>? rowid,
  }) {
    return SchoolProfileCompanion(
      uuid: uuid ?? this.uuid,
      publicId: publicId ?? this.publicId,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      timezone: timezone ?? this.timezone,
      mobileEnabled: mobileEnabled ?? this.mobileEnabled,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      minimumAppVersion: minimumAppVersion ?? this.minimumAppVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (publicId.present) {
      map['public_id'] = Variable<String>(publicId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (mobileEnabled.present) {
      map['mobile_enabled'] = Variable<bool>(mobileEnabled.value);
    }
    if (maintenanceMode.present) {
      map['maintenance_mode'] = Variable<bool>(maintenanceMode.value);
    }
    if (maintenanceMessage.present) {
      map['maintenance_message'] = Variable<String>(maintenanceMessage.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (minimumAppVersion.present) {
      map['minimum_app_version'] = Variable<String>(minimumAppVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolProfileCompanion(')
          ..write('uuid: $uuid, ')
          ..write('publicId: $publicId, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('timezone: $timezone, ')
          ..write('mobileEnabled: $mobileEnabled, ')
          ..write('maintenanceMode: $maintenanceMode, ')
          ..write('maintenanceMessage: $maintenanceMessage, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('minimumAppVersion: $minimumAppVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GuardianProfileTable extends GuardianProfile
    with TableInfo<$GuardianProfileTable, GuardianProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuardianProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileNumberMeta = const VerificationMeta(
    'mobileNumber',
  );
  @override
  late final GeneratedColumn<String> mobileNumber = GeneratedColumn<String>(
    'mobile_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notifyAttendanceMeta = const VerificationMeta(
    'notifyAttendance',
  );
  @override
  late final GeneratedColumn<bool> notifyAttendance = GeneratedColumn<bool>(
    'notify_attendance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_attendance" IN (0, 1))',
    ),
  );
  static const VerificationMeta _notifyAnnouncementsMeta =
      const VerificationMeta('notifyAnnouncements');
  @override
  late final GeneratedColumn<bool> notifyAnnouncements = GeneratedColumn<bool>(
    'notify_announcements',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_announcements" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    name,
    email,
    mobileNumber,
    status,
    notifyAttendance,
    notifyAnnouncements,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guardian_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<GuardianProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('mobile_number')) {
      context.handle(
        _mobileNumberMeta,
        mobileNumber.isAcceptableOrUnknown(
          data['mobile_number']!,
          _mobileNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mobileNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notify_attendance')) {
      context.handle(
        _notifyAttendanceMeta,
        notifyAttendance.isAcceptableOrUnknown(
          data['notify_attendance']!,
          _notifyAttendanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notifyAttendanceMeta);
    }
    if (data.containsKey('notify_announcements')) {
      context.handle(
        _notifyAnnouncementsMeta,
        notifyAnnouncements.isAcceptableOrUnknown(
          data['notify_announcements']!,
          _notifyAnnouncementsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notifyAnnouncementsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  GuardianProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GuardianProfileData(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      mobileNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notifyAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_attendance'],
      )!,
      notifyAnnouncements: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_announcements'],
      )!,
    );
  }

  @override
  $GuardianProfileTable createAlias(String alias) {
    return $GuardianProfileTable(attachedDatabase, alias);
  }
}

class GuardianProfileData extends DataClass
    implements Insertable<GuardianProfileData> {
  final String uuid;
  final String name;
  final String email;
  final String mobileNumber;
  final String status;
  final bool notifyAttendance;
  final bool notifyAnnouncements;
  const GuardianProfileData({
    required this.uuid,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.status,
    required this.notifyAttendance,
    required this.notifyAnnouncements,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['mobile_number'] = Variable<String>(mobileNumber);
    map['status'] = Variable<String>(status);
    map['notify_attendance'] = Variable<bool>(notifyAttendance);
    map['notify_announcements'] = Variable<bool>(notifyAnnouncements);
    return map;
  }

  GuardianProfileCompanion toCompanion(bool nullToAbsent) {
    return GuardianProfileCompanion(
      uuid: Value(uuid),
      name: Value(name),
      email: Value(email),
      mobileNumber: Value(mobileNumber),
      status: Value(status),
      notifyAttendance: Value(notifyAttendance),
      notifyAnnouncements: Value(notifyAnnouncements),
    );
  }

  factory GuardianProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GuardianProfileData(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      mobileNumber: serializer.fromJson<String>(json['mobileNumber']),
      status: serializer.fromJson<String>(json['status']),
      notifyAttendance: serializer.fromJson<bool>(json['notifyAttendance']),
      notifyAnnouncements: serializer.fromJson<bool>(
        json['notifyAnnouncements'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'mobileNumber': serializer.toJson<String>(mobileNumber),
      'status': serializer.toJson<String>(status),
      'notifyAttendance': serializer.toJson<bool>(notifyAttendance),
      'notifyAnnouncements': serializer.toJson<bool>(notifyAnnouncements),
    };
  }

  GuardianProfileData copyWith({
    String? uuid,
    String? name,
    String? email,
    String? mobileNumber,
    String? status,
    bool? notifyAttendance,
    bool? notifyAnnouncements,
  }) => GuardianProfileData(
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    email: email ?? this.email,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    status: status ?? this.status,
    notifyAttendance: notifyAttendance ?? this.notifyAttendance,
    notifyAnnouncements: notifyAnnouncements ?? this.notifyAnnouncements,
  );
  GuardianProfileData copyWithCompanion(GuardianProfileCompanion data) {
    return GuardianProfileData(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      mobileNumber: data.mobileNumber.present
          ? data.mobileNumber.value
          : this.mobileNumber,
      status: data.status.present ? data.status.value : this.status,
      notifyAttendance: data.notifyAttendance.present
          ? data.notifyAttendance.value
          : this.notifyAttendance,
      notifyAnnouncements: data.notifyAnnouncements.present
          ? data.notifyAnnouncements.value
          : this.notifyAnnouncements,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GuardianProfileData(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('status: $status, ')
          ..write('notifyAttendance: $notifyAttendance, ')
          ..write('notifyAnnouncements: $notifyAnnouncements')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    name,
    email,
    mobileNumber,
    status,
    notifyAttendance,
    notifyAnnouncements,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuardianProfileData &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.email == this.email &&
          other.mobileNumber == this.mobileNumber &&
          other.status == this.status &&
          other.notifyAttendance == this.notifyAttendance &&
          other.notifyAnnouncements == this.notifyAnnouncements);
}

class GuardianProfileCompanion extends UpdateCompanion<GuardianProfileData> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> email;
  final Value<String> mobileNumber;
  final Value<String> status;
  final Value<bool> notifyAttendance;
  final Value<bool> notifyAnnouncements;
  final Value<int> rowid;
  const GuardianProfileCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.mobileNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.notifyAttendance = const Value.absent(),
    this.notifyAnnouncements = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GuardianProfileCompanion.insert({
    required String uuid,
    required String name,
    required String email,
    required String mobileNumber,
    required String status,
    required bool notifyAttendance,
    required bool notifyAnnouncements,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       email = Value(email),
       mobileNumber = Value(mobileNumber),
       status = Value(status),
       notifyAttendance = Value(notifyAttendance),
       notifyAnnouncements = Value(notifyAnnouncements);
  static Insertable<GuardianProfileData> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? mobileNumber,
    Expression<String>? status,
    Expression<bool>? notifyAttendance,
    Expression<bool>? notifyAnnouncements,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (status != null) 'status': status,
      if (notifyAttendance != null) 'notify_attendance': notifyAttendance,
      if (notifyAnnouncements != null)
        'notify_announcements': notifyAnnouncements,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GuardianProfileCompanion copyWith({
    Value<String>? uuid,
    Value<String>? name,
    Value<String>? email,
    Value<String>? mobileNumber,
    Value<String>? status,
    Value<bool>? notifyAttendance,
    Value<bool>? notifyAnnouncements,
    Value<int>? rowid,
  }) {
    return GuardianProfileCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      status: status ?? this.status,
      notifyAttendance: notifyAttendance ?? this.notifyAttendance,
      notifyAnnouncements: notifyAnnouncements ?? this.notifyAnnouncements,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (mobileNumber.present) {
      map['mobile_number'] = Variable<String>(mobileNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notifyAttendance.present) {
      map['notify_attendance'] = Variable<bool>(notifyAttendance.value);
    }
    if (notifyAnnouncements.present) {
      map['notify_announcements'] = Variable<bool>(notifyAnnouncements.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuardianProfileCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('status: $status, ')
          ..write('notifyAttendance: $notifyAttendance, ')
          ..write('notifyAnnouncements: $notifyAnnouncements, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _lrnMeta = const VerificationMeta('lrn');
  @override
  late final GeneratedColumn<String> lrn = GeneratedColumn<String>(
    'lrn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentNumberMeta = const VerificationMeta(
    'studentNumber',
  );
  @override
  late final GeneratedColumn<String> studentNumber = GeneratedColumn<String>(
    'student_number',
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
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionMeta = const VerificationMeta(
    'section',
  );
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
    'section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolYearMeta = const VerificationMeta(
    'schoolYear',
  );
  @override
  late final GeneratedColumn<String> schoolYear = GeneratedColumn<String>(
    'school_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    lrn,
    studentNumber,
    name,
    sex,
    grade,
    section,
    schoolYear,
    status,
    photoUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('lrn')) {
      context.handle(
        _lrnMeta,
        lrn.isAcceptableOrUnknown(data['lrn']!, _lrnMeta),
      );
    } else if (isInserting) {
      context.missing(_lrnMeta);
    }
    if (data.containsKey('student_number')) {
      context.handle(
        _studentNumberMeta,
        studentNumber.isAcceptableOrUnknown(
          data['student_number']!,
          _studentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentNumberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('section')) {
      context.handle(
        _sectionMeta,
        section.isAcceptableOrUnknown(data['section']!, _sectionMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionMeta);
    }
    if (data.containsKey('school_year')) {
      context.handle(
        _schoolYearMeta,
        schoolYear.isAcceptableOrUnknown(data['school_year']!, _schoolYearMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolYearMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      lrn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lrn'],
      )!,
      studentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      )!,
      section: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section'],
      )!,
      schoolYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_year'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final String uuid;
  final int? serverId;
  final String lrn;
  final String studentNumber;
  final String name;
  final String sex;
  final String grade;
  final String section;
  final String schoolYear;
  final String status;
  final String? photoUrl;
  const Student({
    required this.uuid,
    this.serverId,
    required this.lrn,
    required this.studentNumber,
    required this.name,
    required this.sex,
    required this.grade,
    required this.section,
    required this.schoolYear,
    required this.status,
    this.photoUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['lrn'] = Variable<String>(lrn);
    map['student_number'] = Variable<String>(studentNumber);
    map['name'] = Variable<String>(name);
    map['sex'] = Variable<String>(sex);
    map['grade'] = Variable<String>(grade);
    map['section'] = Variable<String>(section);
    map['school_year'] = Variable<String>(schoolYear);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lrn: Value(lrn),
      studentNumber: Value(studentNumber),
      name: Value(name),
      sex: Value(sex),
      grade: Value(grade),
      section: Value(section),
      schoolYear: Value(schoolYear),
      status: Value(status),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      lrn: serializer.fromJson<String>(json['lrn']),
      studentNumber: serializer.fromJson<String>(json['studentNumber']),
      name: serializer.fromJson<String>(json['name']),
      sex: serializer.fromJson<String>(json['sex']),
      grade: serializer.fromJson<String>(json['grade']),
      section: serializer.fromJson<String>(json['section']),
      schoolYear: serializer.fromJson<String>(json['schoolYear']),
      status: serializer.fromJson<String>(json['status']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'lrn': serializer.toJson<String>(lrn),
      'studentNumber': serializer.toJson<String>(studentNumber),
      'name': serializer.toJson<String>(name),
      'sex': serializer.toJson<String>(sex),
      'grade': serializer.toJson<String>(grade),
      'section': serializer.toJson<String>(section),
      'schoolYear': serializer.toJson<String>(schoolYear),
      'status': serializer.toJson<String>(status),
      'photoUrl': serializer.toJson<String?>(photoUrl),
    };
  }

  Student copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    String? lrn,
    String? studentNumber,
    String? name,
    String? sex,
    String? grade,
    String? section,
    String? schoolYear,
    String? status,
    Value<String?> photoUrl = const Value.absent(),
  }) => Student(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    lrn: lrn ?? this.lrn,
    studentNumber: studentNumber ?? this.studentNumber,
    name: name ?? this.name,
    sex: sex ?? this.sex,
    grade: grade ?? this.grade,
    section: section ?? this.section,
    schoolYear: schoolYear ?? this.schoolYear,
    status: status ?? this.status,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lrn: data.lrn.present ? data.lrn.value : this.lrn,
      studentNumber: data.studentNumber.present
          ? data.studentNumber.value
          : this.studentNumber,
      name: data.name.present ? data.name.value : this.name,
      sex: data.sex.present ? data.sex.value : this.sex,
      grade: data.grade.present ? data.grade.value : this.grade,
      section: data.section.present ? data.section.value : this.section,
      schoolYear: data.schoolYear.present
          ? data.schoolYear.value
          : this.schoolYear,
      status: data.status.present ? data.status.value : this.status,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('lrn: $lrn, ')
          ..write('studentNumber: $studentNumber, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('grade: $grade, ')
          ..write('section: $section, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('status: $status, ')
          ..write('photoUrl: $photoUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    lrn,
    studentNumber,
    name,
    sex,
    grade,
    section,
    schoolYear,
    status,
    photoUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.lrn == this.lrn &&
          other.studentNumber == this.studentNumber &&
          other.name == this.name &&
          other.sex == this.sex &&
          other.grade == this.grade &&
          other.section == this.section &&
          other.schoolYear == this.schoolYear &&
          other.status == this.status &&
          other.photoUrl == this.photoUrl);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<String> lrn;
  final Value<String> studentNumber;
  final Value<String> name;
  final Value<String> sex;
  final Value<String> grade;
  final Value<String> section;
  final Value<String> schoolYear;
  final Value<String> status;
  final Value<String?> photoUrl;
  final Value<int> rowid;
  const StudentsCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lrn = const Value.absent(),
    this.studentNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.grade = const Value.absent(),
    this.section = const Value.absent(),
    this.schoolYear = const Value.absent(),
    this.status = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    required String lrn,
    required String studentNumber,
    required String name,
    required String sex,
    required String grade,
    required String section,
    required String schoolYear,
    required String status,
    this.photoUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       lrn = Value(lrn),
       studentNumber = Value(studentNumber),
       name = Value(name),
       sex = Value(sex),
       grade = Value(grade),
       section = Value(section),
       schoolYear = Value(schoolYear),
       status = Value(status);
  static Insertable<Student> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<String>? lrn,
    Expression<String>? studentNumber,
    Expression<String>? name,
    Expression<String>? sex,
    Expression<String>? grade,
    Expression<String>? section,
    Expression<String>? schoolYear,
    Expression<String>? status,
    Expression<String>? photoUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (lrn != null) 'lrn': lrn,
      if (studentNumber != null) 'student_number': studentNumber,
      if (name != null) 'name': name,
      if (sex != null) 'sex': sex,
      if (grade != null) 'grade': grade,
      if (section != null) 'section': section,
      if (schoolYear != null) 'school_year': schoolYear,
      if (status != null) 'status': status,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<String>? lrn,
    Value<String>? studentNumber,
    Value<String>? name,
    Value<String>? sex,
    Value<String>? grade,
    Value<String>? section,
    Value<String>? schoolYear,
    Value<String>? status,
    Value<String?>? photoUrl,
    Value<int>? rowid,
  }) {
    return StudentsCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      lrn: lrn ?? this.lrn,
      studentNumber: studentNumber ?? this.studentNumber,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      schoolYear: schoolYear ?? this.schoolYear,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (lrn.present) {
      map['lrn'] = Variable<String>(lrn.value);
    }
    if (studentNumber.present) {
      map['student_number'] = Variable<String>(studentNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    if (schoolYear.present) {
      map['school_year'] = Variable<String>(schoolYear.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('lrn: $lrn, ')
          ..write('studentNumber: $studentNumber, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('grade: $grade, ')
          ..write('section: $section, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('status: $status, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GuardianStudentLinksTable extends GuardianStudentLinks
    with TableInfo<$GuardianStudentLinksTable, GuardianStudentLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuardianStudentLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentServerIdMeta = const VerificationMeta(
    'studentServerId',
  );
  @override
  late final GeneratedColumn<int> studentServerId = GeneratedColumn<int>(
    'student_server_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _relationshipTypeMeta = const VerificationMeta(
    'relationshipType',
  );
  @override
  late final GeneratedColumn<String> relationshipType = GeneratedColumn<String>(
    'relationship_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPrimaryContactMeta = const VerificationMeta(
    'isPrimaryContact',
  );
  @override
  late final GeneratedColumn<bool> isPrimaryContact = GeneratedColumn<bool>(
    'is_primary_contact',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary_contact" IN (0, 1))',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    studentServerId,
    relationshipType,
    isPrimaryContact,
    status,
    notificationsEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guardian_student_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<GuardianStudentLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('student_server_id')) {
      context.handle(
        _studentServerIdMeta,
        studentServerId.isAcceptableOrUnknown(
          data['student_server_id']!,
          _studentServerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentServerIdMeta);
    }
    if (data.containsKey('relationship_type')) {
      context.handle(
        _relationshipTypeMeta,
        relationshipType.isAcceptableOrUnknown(
          data['relationship_type']!,
          _relationshipTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationshipTypeMeta);
    }
    if (data.containsKey('is_primary_contact')) {
      context.handle(
        _isPrimaryContactMeta,
        isPrimaryContact.isAcceptableOrUnknown(
          data['is_primary_contact']!,
          _isPrimaryContactMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isPrimaryContactMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationsEnabledMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  GuardianStudentLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GuardianStudentLink(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      studentServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_server_id'],
      )!,
      relationshipType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_type'],
      )!,
      isPrimaryContact: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary_contact'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
    );
  }

  @override
  $GuardianStudentLinksTable createAlias(String alias) {
    return $GuardianStudentLinksTable(attachedDatabase, alias);
  }
}

class GuardianStudentLink extends DataClass
    implements Insertable<GuardianStudentLink> {
  final String uuid;
  final int studentServerId;
  final String relationshipType;
  final bool isPrimaryContact;
  final String status;
  final bool notificationsEnabled;
  const GuardianStudentLink({
    required this.uuid,
    required this.studentServerId,
    required this.relationshipType,
    required this.isPrimaryContact,
    required this.status,
    required this.notificationsEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['student_server_id'] = Variable<int>(studentServerId);
    map['relationship_type'] = Variable<String>(relationshipType);
    map['is_primary_contact'] = Variable<bool>(isPrimaryContact);
    map['status'] = Variable<String>(status);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    return map;
  }

  GuardianStudentLinksCompanion toCompanion(bool nullToAbsent) {
    return GuardianStudentLinksCompanion(
      uuid: Value(uuid),
      studentServerId: Value(studentServerId),
      relationshipType: Value(relationshipType),
      isPrimaryContact: Value(isPrimaryContact),
      status: Value(status),
      notificationsEnabled: Value(notificationsEnabled),
    );
  }

  factory GuardianStudentLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GuardianStudentLink(
      uuid: serializer.fromJson<String>(json['uuid']),
      studentServerId: serializer.fromJson<int>(json['studentServerId']),
      relationshipType: serializer.fromJson<String>(json['relationshipType']),
      isPrimaryContact: serializer.fromJson<bool>(json['isPrimaryContact']),
      status: serializer.fromJson<String>(json['status']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'studentServerId': serializer.toJson<int>(studentServerId),
      'relationshipType': serializer.toJson<String>(relationshipType),
      'isPrimaryContact': serializer.toJson<bool>(isPrimaryContact),
      'status': serializer.toJson<String>(status),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
    };
  }

  GuardianStudentLink copyWith({
    String? uuid,
    int? studentServerId,
    String? relationshipType,
    bool? isPrimaryContact,
    String? status,
    bool? notificationsEnabled,
  }) => GuardianStudentLink(
    uuid: uuid ?? this.uuid,
    studentServerId: studentServerId ?? this.studentServerId,
    relationshipType: relationshipType ?? this.relationshipType,
    isPrimaryContact: isPrimaryContact ?? this.isPrimaryContact,
    status: status ?? this.status,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  );
  GuardianStudentLink copyWithCompanion(GuardianStudentLinksCompanion data) {
    return GuardianStudentLink(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      studentServerId: data.studentServerId.present
          ? data.studentServerId.value
          : this.studentServerId,
      relationshipType: data.relationshipType.present
          ? data.relationshipType.value
          : this.relationshipType,
      isPrimaryContact: data.isPrimaryContact.present
          ? data.isPrimaryContact.value
          : this.isPrimaryContact,
      status: data.status.present ? data.status.value : this.status,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GuardianStudentLink(')
          ..write('uuid: $uuid, ')
          ..write('studentServerId: $studentServerId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('isPrimaryContact: $isPrimaryContact, ')
          ..write('status: $status, ')
          ..write('notificationsEnabled: $notificationsEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    studentServerId,
    relationshipType,
    isPrimaryContact,
    status,
    notificationsEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuardianStudentLink &&
          other.uuid == this.uuid &&
          other.studentServerId == this.studentServerId &&
          other.relationshipType == this.relationshipType &&
          other.isPrimaryContact == this.isPrimaryContact &&
          other.status == this.status &&
          other.notificationsEnabled == this.notificationsEnabled);
}

class GuardianStudentLinksCompanion
    extends UpdateCompanion<GuardianStudentLink> {
  final Value<String> uuid;
  final Value<int> studentServerId;
  final Value<String> relationshipType;
  final Value<bool> isPrimaryContact;
  final Value<String> status;
  final Value<bool> notificationsEnabled;
  final Value<int> rowid;
  const GuardianStudentLinksCompanion({
    this.uuid = const Value.absent(),
    this.studentServerId = const Value.absent(),
    this.relationshipType = const Value.absent(),
    this.isPrimaryContact = const Value.absent(),
    this.status = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GuardianStudentLinksCompanion.insert({
    required String uuid,
    required int studentServerId,
    required String relationshipType,
    required bool isPrimaryContact,
    required String status,
    required bool notificationsEnabled,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       studentServerId = Value(studentServerId),
       relationshipType = Value(relationshipType),
       isPrimaryContact = Value(isPrimaryContact),
       status = Value(status),
       notificationsEnabled = Value(notificationsEnabled);
  static Insertable<GuardianStudentLink> custom({
    Expression<String>? uuid,
    Expression<int>? studentServerId,
    Expression<String>? relationshipType,
    Expression<bool>? isPrimaryContact,
    Expression<String>? status,
    Expression<bool>? notificationsEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (studentServerId != null) 'student_server_id': studentServerId,
      if (relationshipType != null) 'relationship_type': relationshipType,
      if (isPrimaryContact != null) 'is_primary_contact': isPrimaryContact,
      if (status != null) 'status': status,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GuardianStudentLinksCompanion copyWith({
    Value<String>? uuid,
    Value<int>? studentServerId,
    Value<String>? relationshipType,
    Value<bool>? isPrimaryContact,
    Value<String>? status,
    Value<bool>? notificationsEnabled,
    Value<int>? rowid,
  }) {
    return GuardianStudentLinksCompanion(
      uuid: uuid ?? this.uuid,
      studentServerId: studentServerId ?? this.studentServerId,
      relationshipType: relationshipType ?? this.relationshipType,
      isPrimaryContact: isPrimaryContact ?? this.isPrimaryContact,
      status: status ?? this.status,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (studentServerId.present) {
      map['student_server_id'] = Variable<int>(studentServerId.value);
    }
    if (relationshipType.present) {
      map['relationship_type'] = Variable<String>(relationshipType.value);
    }
    if (isPrimaryContact.present) {
      map['is_primary_contact'] = Variable<bool>(isPrimaryContact.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuardianStudentLinksCompanion(')
          ..write('uuid: $uuid, ')
          ..write('studentServerId: $studentServerId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('isPrimaryContact: $isPrimaryContact, ')
          ..write('status: $status, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceRecordsTable extends AttendanceRecords
    with TableInfo<$AttendanceRecordsTable, AttendanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _studentUuidMeta = const VerificationMeta(
    'studentUuid',
  );
  @override
  late final GeneratedColumn<String> studentUuid = GeneratedColumn<String>(
    'student_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (uuid)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arrivalMeta = const VerificationMeta(
    'arrival',
  );
  @override
  late final GeneratedColumn<DateTime> arrival = GeneratedColumn<DateTime>(
    'arrival',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _departureMeta = const VerificationMeta(
    'departure',
  );
  @override
  late final GeneratedColumn<DateTime> departure = GeneratedColumn<DateTime>(
    'departure',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLateMeta = const VerificationMeta('isLate');
  @override
  late final GeneratedColumn<bool> isLate = GeneratedColumn<bool>(
    'is_late',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_late" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isAbsentMeta = const VerificationMeta(
    'isAbsent',
  );
  @override
  late final GeneratedColumn<bool> isAbsent = GeneratedColumn<bool>(
    'is_absent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_absent" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    studentUuid,
    date,
    arrival,
    departure,
    isLate,
    isAbsent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('student_uuid')) {
      context.handle(
        _studentUuidMeta,
        studentUuid.isAcceptableOrUnknown(
          data['student_uuid']!,
          _studentUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentUuidMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('arrival')) {
      context.handle(
        _arrivalMeta,
        arrival.isAcceptableOrUnknown(data['arrival']!, _arrivalMeta),
      );
    }
    if (data.containsKey('departure')) {
      context.handle(
        _departureMeta,
        departure.isAcceptableOrUnknown(data['departure']!, _departureMeta),
      );
    }
    if (data.containsKey('is_late')) {
      context.handle(
        _isLateMeta,
        isLate.isAcceptableOrUnknown(data['is_late']!, _isLateMeta),
      );
    } else if (isInserting) {
      context.missing(_isLateMeta);
    }
    if (data.containsKey('is_absent')) {
      context.handle(
        _isAbsentMeta,
        isAbsent.isAcceptableOrUnknown(data['is_absent']!, _isAbsentMeta),
      );
    } else if (isInserting) {
      context.missing(_isAbsentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentUuid, date},
  ];
  @override
  AttendanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      studentUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_uuid'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      arrival: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrival'],
      ),
      departure: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}departure'],
      ),
      isLate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_late'],
      )!,
      isAbsent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_absent'],
      )!,
    );
  }

  @override
  $AttendanceRecordsTable createAlias(String alias) {
    return $AttendanceRecordsTable(attachedDatabase, alias);
  }
}

class AttendanceRecord extends DataClass
    implements Insertable<AttendanceRecord> {
  final int id;
  final int? serverId;
  final String studentUuid;
  final DateTime date;
  final DateTime? arrival;
  final DateTime? departure;
  final bool isLate;
  final bool isAbsent;
  const AttendanceRecord({
    required this.id,
    this.serverId,
    required this.studentUuid,
    required this.date,
    this.arrival,
    this.departure,
    required this.isLate,
    required this.isAbsent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['student_uuid'] = Variable<String>(studentUuid);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || arrival != null) {
      map['arrival'] = Variable<DateTime>(arrival);
    }
    if (!nullToAbsent || departure != null) {
      map['departure'] = Variable<DateTime>(departure);
    }
    map['is_late'] = Variable<bool>(isLate);
    map['is_absent'] = Variable<bool>(isAbsent);
    return map;
  }

  AttendanceRecordsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceRecordsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      studentUuid: Value(studentUuid),
      date: Value(date),
      arrival: arrival == null && nullToAbsent
          ? const Value.absent()
          : Value(arrival),
      departure: departure == null && nullToAbsent
          ? const Value.absent()
          : Value(departure),
      isLate: Value(isLate),
      isAbsent: Value(isAbsent),
    );
  }

  factory AttendanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceRecord(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      studentUuid: serializer.fromJson<String>(json['studentUuid']),
      date: serializer.fromJson<DateTime>(json['date']),
      arrival: serializer.fromJson<DateTime?>(json['arrival']),
      departure: serializer.fromJson<DateTime?>(json['departure']),
      isLate: serializer.fromJson<bool>(json['isLate']),
      isAbsent: serializer.fromJson<bool>(json['isAbsent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'studentUuid': serializer.toJson<String>(studentUuid),
      'date': serializer.toJson<DateTime>(date),
      'arrival': serializer.toJson<DateTime?>(arrival),
      'departure': serializer.toJson<DateTime?>(departure),
      'isLate': serializer.toJson<bool>(isLate),
      'isAbsent': serializer.toJson<bool>(isAbsent),
    };
  }

  AttendanceRecord copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? studentUuid,
    DateTime? date,
    Value<DateTime?> arrival = const Value.absent(),
    Value<DateTime?> departure = const Value.absent(),
    bool? isLate,
    bool? isAbsent,
  }) => AttendanceRecord(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    studentUuid: studentUuid ?? this.studentUuid,
    date: date ?? this.date,
    arrival: arrival.present ? arrival.value : this.arrival,
    departure: departure.present ? departure.value : this.departure,
    isLate: isLate ?? this.isLate,
    isAbsent: isAbsent ?? this.isAbsent,
  );
  AttendanceRecord copyWithCompanion(AttendanceRecordsCompanion data) {
    return AttendanceRecord(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      studentUuid: data.studentUuid.present
          ? data.studentUuid.value
          : this.studentUuid,
      date: data.date.present ? data.date.value : this.date,
      arrival: data.arrival.present ? data.arrival.value : this.arrival,
      departure: data.departure.present ? data.departure.value : this.departure,
      isLate: data.isLate.present ? data.isLate.value : this.isLate,
      isAbsent: data.isAbsent.present ? data.isAbsent.value : this.isAbsent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecord(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('studentUuid: $studentUuid, ')
          ..write('date: $date, ')
          ..write('arrival: $arrival, ')
          ..write('departure: $departure, ')
          ..write('isLate: $isLate, ')
          ..write('isAbsent: $isAbsent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    studentUuid,
    date,
    arrival,
    departure,
    isLate,
    isAbsent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceRecord &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.studentUuid == this.studentUuid &&
          other.date == this.date &&
          other.arrival == this.arrival &&
          other.departure == this.departure &&
          other.isLate == this.isLate &&
          other.isAbsent == this.isAbsent);
}

class AttendanceRecordsCompanion extends UpdateCompanion<AttendanceRecord> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> studentUuid;
  final Value<DateTime> date;
  final Value<DateTime?> arrival;
  final Value<DateTime?> departure;
  final Value<bool> isLate;
  final Value<bool> isAbsent;
  const AttendanceRecordsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.studentUuid = const Value.absent(),
    this.date = const Value.absent(),
    this.arrival = const Value.absent(),
    this.departure = const Value.absent(),
    this.isLate = const Value.absent(),
    this.isAbsent = const Value.absent(),
  });
  AttendanceRecordsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String studentUuid,
    required DateTime date,
    this.arrival = const Value.absent(),
    this.departure = const Value.absent(),
    required bool isLate,
    required bool isAbsent,
  }) : studentUuid = Value(studentUuid),
       date = Value(date),
       isLate = Value(isLate),
       isAbsent = Value(isAbsent);
  static Insertable<AttendanceRecord> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? studentUuid,
    Expression<DateTime>? date,
    Expression<DateTime>? arrival,
    Expression<DateTime>? departure,
    Expression<bool>? isLate,
    Expression<bool>? isAbsent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (studentUuid != null) 'student_uuid': studentUuid,
      if (date != null) 'date': date,
      if (arrival != null) 'arrival': arrival,
      if (departure != null) 'departure': departure,
      if (isLate != null) 'is_late': isLate,
      if (isAbsent != null) 'is_absent': isAbsent,
    });
  }

  AttendanceRecordsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? studentUuid,
    Value<DateTime>? date,
    Value<DateTime?>? arrival,
    Value<DateTime?>? departure,
    Value<bool>? isLate,
    Value<bool>? isAbsent,
  }) {
    return AttendanceRecordsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      studentUuid: studentUuid ?? this.studentUuid,
      date: date ?? this.date,
      arrival: arrival ?? this.arrival,
      departure: departure ?? this.departure,
      isLate: isLate ?? this.isLate,
      isAbsent: isAbsent ?? this.isAbsent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (studentUuid.present) {
      map['student_uuid'] = Variable<String>(studentUuid.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (arrival.present) {
      map['arrival'] = Variable<DateTime>(arrival.value);
    }
    if (departure.present) {
      map['departure'] = Variable<DateTime>(departure.value);
    }
    if (isLate.present) {
      map['is_late'] = Variable<bool>(isLate.value);
    }
    if (isAbsent.present) {
      map['is_absent'] = Variable<bool>(isAbsent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('studentUuid: $studentUuid, ')
          ..write('date: $date, ')
          ..write('arrival: $arrival, ')
          ..write('departure: $departure, ')
          ..write('isLate: $isLate, ')
          ..write('isAbsent: $isAbsent')
          ..write(')'))
        .toString();
  }
}

class $AnnouncementsTable extends Announcements
    with TableInfo<$AnnouncementsTable, Announcement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnouncementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    title,
    body,
    status,
    publishedAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'announcements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Announcement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Announcement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Announcement(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
    );
  }

  @override
  $AnnouncementsTable createAlias(String alias) {
    return $AnnouncementsTable(attachedDatabase, alias);
  }
}

class Announcement extends DataClass implements Insertable<Announcement> {
  final String uuid;
  final String title;
  final String body;
  final String status;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  const Announcement({
    required this.uuid,
    required this.title,
    required this.body,
    required this.status,
    this.publishedAt,
    this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    return map;
  }

  AnnouncementsCompanion toCompanion(bool nullToAbsent) {
    return AnnouncementsCompanion(
      uuid: Value(uuid),
      title: Value(title),
      body: Value(body),
      status: Value(status),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory Announcement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Announcement(
      uuid: serializer.fromJson<String>(json['uuid']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      status: serializer.fromJson<String>(json['status']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'status': serializer.toJson<String>(status),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
    };
  }

  Announcement copyWith({
    String? uuid,
    String? title,
    String? body,
    String? status,
    Value<DateTime?> publishedAt = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
  }) => Announcement(
    uuid: uuid ?? this.uuid,
    title: title ?? this.title,
    body: body ?? this.body,
    status: status ?? this.status,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
  );
  Announcement copyWithCompanion(AnnouncementsCompanion data) {
    return Announcement(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      status: data.status.present ? data.status.value : this.status,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Announcement(')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('status: $status, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, title, body, status, publishedAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Announcement &&
          other.uuid == this.uuid &&
          other.title == this.title &&
          other.body == this.body &&
          other.status == this.status &&
          other.publishedAt == this.publishedAt &&
          other.expiresAt == this.expiresAt);
}

class AnnouncementsCompanion extends UpdateCompanion<Announcement> {
  final Value<String> uuid;
  final Value<String> title;
  final Value<String> body;
  final Value<String> status;
  final Value<DateTime?> publishedAt;
  final Value<DateTime?> expiresAt;
  final Value<int> rowid;
  const AnnouncementsCompanion({
    this.uuid = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.status = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnnouncementsCompanion.insert({
    required String uuid,
    required String title,
    required String body,
    required String status,
    this.publishedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       title = Value(title),
       body = Value(body),
       status = Value(status);
  static Insertable<Announcement> custom({
    Expression<String>? uuid,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? status,
    Expression<DateTime>? publishedAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (status != null) 'status': status,
      if (publishedAt != null) 'published_at': publishedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnnouncementsCompanion copyWith({
    Value<String>? uuid,
    Value<String>? title,
    Value<String>? body,
    Value<String>? status,
    Value<DateTime?>? publishedAt,
    Value<DateTime?>? expiresAt,
    Value<int>? rowid,
  }) {
    return AnnouncementsCompanion(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnouncementsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('status: $status, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, NotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryStatusMeta = const VerificationMeta(
    'deliveryStatus',
  );
  @override
  late final GeneratedColumn<String> deliveryStatus = GeneratedColumn<String>(
    'delivery_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    type,
    title,
    body,
    payload,
    readAt,
    deliveryStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('delivery_status')) {
      context.handle(
        _deliveryStatusMeta,
        deliveryStatus.isAcceptableOrUnknown(
          data['delivery_status']!,
          _deliveryStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deliveryStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  NotificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      deliveryStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_status'],
      )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class NotificationRow extends DataClass implements Insertable<NotificationRow> {
  final String uuid;
  final String type;
  final String title;
  final String body;
  final String? payload;
  final DateTime? readAt;
  final String deliveryStatus;
  const NotificationRow({
    required this.uuid,
    required this.type,
    required this.title,
    required this.body,
    this.payload,
    this.readAt,
    required this.deliveryStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['delivery_status'] = Variable<String>(deliveryStatus);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      uuid: Value(uuid),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      deliveryStatus: Value(deliveryStatus),
    );
  }

  factory NotificationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      payload: serializer.fromJson<String?>(json['payload']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      deliveryStatus: serializer.fromJson<String>(json['deliveryStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'payload': serializer.toJson<String?>(payload),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'deliveryStatus': serializer.toJson<String>(deliveryStatus),
    };
  }

  NotificationRow copyWith({
    String? uuid,
    String? type,
    String? title,
    String? body,
    Value<String?> payload = const Value.absent(),
    Value<DateTime?> readAt = const Value.absent(),
    String? deliveryStatus,
  }) => NotificationRow(
    uuid: uuid ?? this.uuid,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    payload: payload.present ? payload.value : this.payload,
    readAt: readAt.present ? readAt.value : this.readAt,
    deliveryStatus: deliveryStatus ?? this.deliveryStatus,
  );
  NotificationRow copyWithCompanion(NotificationsCompanion data) {
    return NotificationRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      payload: data.payload.present ? data.payload.value : this.payload,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      deliveryStatus: data.deliveryStatus.present
          ? data.deliveryStatus.value
          : this.deliveryStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('uuid: $uuid, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payload: $payload, ')
          ..write('readAt: $readAt, ')
          ..write('deliveryStatus: $deliveryStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, type, title, body, payload, readAt, deliveryStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.uuid == this.uuid &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.payload == this.payload &&
          other.readAt == this.readAt &&
          other.deliveryStatus == this.deliveryStatus);
}

class NotificationsCompanion extends UpdateCompanion<NotificationRow> {
  final Value<String> uuid;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> payload;
  final Value<DateTime?> readAt;
  final Value<String> deliveryStatus;
  final Value<int> rowid;
  const NotificationsCompanion({
    this.uuid = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.payload = const Value.absent(),
    this.readAt = const Value.absent(),
    this.deliveryStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCompanion.insert({
    required String uuid,
    required String type,
    required String title,
    required String body,
    this.payload = const Value.absent(),
    this.readAt = const Value.absent(),
    required String deliveryStatus,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       type = Value(type),
       title = Value(title),
       body = Value(body),
       deliveryStatus = Value(deliveryStatus);
  static Insertable<NotificationRow> custom({
    Expression<String>? uuid,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? payload,
    Expression<DateTime>? readAt,
    Expression<String>? deliveryStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (payload != null) 'payload': payload,
      if (readAt != null) 'read_at': readAt,
      if (deliveryStatus != null) 'delivery_status': deliveryStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCompanion copyWith({
    Value<String>? uuid,
    Value<String>? type,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? payload,
    Value<DateTime?>? readAt,
    Value<String>? deliveryStatus,
    Value<int>? rowid,
  }) {
    return NotificationsCompanion(
      uuid: uuid ?? this.uuid,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      readAt: readAt ?? this.readAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (deliveryStatus.present) {
      map['delivery_status'] = Variable<String>(deliveryStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payload: $payload, ')
          ..write('readAt: $readAt, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cursor, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final int id;
  final String? cursor;
  final DateTime? lastSyncedAt;
  const SyncStateData({required this.id, this.cursor, this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || cursor != null) {
      map['cursor'] = Variable<String>(cursor);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      id: Value(id),
      cursor: cursor == null && nullToAbsent
          ? const Value.absent()
          : Value(cursor),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      id: serializer.fromJson<int>(json['id']),
      cursor: serializer.fromJson<String?>(json['cursor']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cursor': serializer.toJson<String?>(cursor),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SyncStateData copyWith({
    int? id,
    Value<String?> cursor = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => SyncStateData(
    id: id ?? this.id,
    cursor: cursor.present ? cursor.value : this.cursor,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      id: data.id.present ? data.id.value : this.id,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('id: $id, ')
          ..write('cursor: $cursor, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cursor, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.id == this.id &&
          other.cursor == this.cursor &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<int> id;
  final Value<String?> cursor;
  final Value<DateTime?> lastSyncedAt;
  const SyncStateCompanion({
    this.id = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  SyncStateCompanion.insert({
    this.id = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  static Insertable<SyncStateData> custom({
    Expression<int>? id,
    Expression<String>? cursor,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursor != null) 'cursor': cursor,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  SyncStateCompanion copyWith({
    Value<int>? id,
    Value<String?>? cursor,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return SyncStateCompanion(
      id: id ?? this.id,
      cursor: cursor ?? this.cursor,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('id: $id, ')
          ..write('cursor: $cursor, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $SchoolProfileTable schoolProfile = $SchoolProfileTable(this);
  late final $GuardianProfileTable guardianProfile = $GuardianProfileTable(
    this,
  );
  late final $StudentsTable students = $StudentsTable(this);
  late final $GuardianStudentLinksTable guardianStudentLinks =
      $GuardianStudentLinksTable(this);
  late final $AttendanceRecordsTable attendanceRecords =
      $AttendanceRecordsTable(this);
  late final $AnnouncementsTable announcements = $AnnouncementsTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  late final SchoolProfileDao schoolProfileDao = SchoolProfileDao(
    this as AppDatabase,
  );
  late final GuardianProfileDao guardianProfileDao = GuardianProfileDao(
    this as AppDatabase,
  );
  late final StudentsDao studentsDao = StudentsDao(this as AppDatabase);
  late final GuardianStudentLinksDao guardianStudentLinksDao =
      GuardianStudentLinksDao(this as AppDatabase);
  late final AttendanceRecordsDao attendanceRecordsDao = AttendanceRecordsDao(
    this as AppDatabase,
  );
  late final AnnouncementsDao announcementsDao = AnnouncementsDao(
    this as AppDatabase,
  );
  late final NotificationsDao notificationsDao = NotificationsDao(
    this as AppDatabase,
  );
  late final SyncStateDao syncStateDao = SyncStateDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    schoolProfile,
    guardianProfile,
    students,
    guardianStudentLinks,
    attendanceRecords,
    announcements,
    notifications,
    syncState,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$SchoolProfileTableCreateCompanionBuilder =
    SchoolProfileCompanion Function({
      required String uuid,
      required String publicId,
      required String name,
      Value<String?> logoUrl,
      required String timezone,
      required bool mobileEnabled,
      required bool maintenanceMode,
      Value<String?> maintenanceMessage,
      required bool notificationsEnabled,
      required String minimumAppVersion,
      Value<int> rowid,
    });
typedef $$SchoolProfileTableUpdateCompanionBuilder =
    SchoolProfileCompanion Function({
      Value<String> uuid,
      Value<String> publicId,
      Value<String> name,
      Value<String?> logoUrl,
      Value<String> timezone,
      Value<bool> mobileEnabled,
      Value<bool> maintenanceMode,
      Value<String?> maintenanceMessage,
      Value<bool> notificationsEnabled,
      Value<String> minimumAppVersion,
      Value<int> rowid,
    });

class $$SchoolProfileTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolProfileTable> {
  $$SchoolProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mobileEnabled => $composableBuilder(
    column: $table.mobileEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get maintenanceMode => $composableBuilder(
    column: $table.maintenanceMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maintenanceMessage => $composableBuilder(
    column: $table.maintenanceMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get minimumAppVersion => $composableBuilder(
    column: $table.minimumAppVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchoolProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolProfileTable> {
  $$SchoolProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicId => $composableBuilder(
    column: $table.publicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mobileEnabled => $composableBuilder(
    column: $table.mobileEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get maintenanceMode => $composableBuilder(
    column: $table.maintenanceMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maintenanceMessage => $composableBuilder(
    column: $table.maintenanceMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get minimumAppVersion => $composableBuilder(
    column: $table.minimumAppVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchoolProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolProfileTable> {
  $$SchoolProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get publicId =>
      $composableBuilder(column: $table.publicId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<bool> get mobileEnabled => $composableBuilder(
    column: $table.mobileEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get maintenanceMode => $composableBuilder(
    column: $table.maintenanceMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get maintenanceMessage => $composableBuilder(
    column: $table.maintenanceMessage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get minimumAppVersion => $composableBuilder(
    column: $table.minimumAppVersion,
    builder: (column) => column,
  );
}

class $$SchoolProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchoolProfileTable,
          SchoolProfileData,
          $$SchoolProfileTableFilterComposer,
          $$SchoolProfileTableOrderingComposer,
          $$SchoolProfileTableAnnotationComposer,
          $$SchoolProfileTableCreateCompanionBuilder,
          $$SchoolProfileTableUpdateCompanionBuilder,
          (
            SchoolProfileData,
            BaseReferences<
              _$AppDatabase,
              $SchoolProfileTable,
              SchoolProfileData
            >,
          ),
          SchoolProfileData,
          PrefetchHooks Function()
        > {
  $$SchoolProfileTableTableManager(_$AppDatabase db, $SchoolProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchoolProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchoolProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> publicId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<bool> mobileEnabled = const Value.absent(),
                Value<bool> maintenanceMode = const Value.absent(),
                Value<String?> maintenanceMessage = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String> minimumAppVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolProfileCompanion(
                uuid: uuid,
                publicId: publicId,
                name: name,
                logoUrl: logoUrl,
                timezone: timezone,
                mobileEnabled: mobileEnabled,
                maintenanceMode: maintenanceMode,
                maintenanceMessage: maintenanceMessage,
                notificationsEnabled: notificationsEnabled,
                minimumAppVersion: minimumAppVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String publicId,
                required String name,
                Value<String?> logoUrl = const Value.absent(),
                required String timezone,
                required bool mobileEnabled,
                required bool maintenanceMode,
                Value<String?> maintenanceMessage = const Value.absent(),
                required bool notificationsEnabled,
                required String minimumAppVersion,
                Value<int> rowid = const Value.absent(),
              }) => SchoolProfileCompanion.insert(
                uuid: uuid,
                publicId: publicId,
                name: name,
                logoUrl: logoUrl,
                timezone: timezone,
                mobileEnabled: mobileEnabled,
                maintenanceMode: maintenanceMode,
                maintenanceMessage: maintenanceMessage,
                notificationsEnabled: notificationsEnabled,
                minimumAppVersion: minimumAppVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchoolProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchoolProfileTable,
      SchoolProfileData,
      $$SchoolProfileTableFilterComposer,
      $$SchoolProfileTableOrderingComposer,
      $$SchoolProfileTableAnnotationComposer,
      $$SchoolProfileTableCreateCompanionBuilder,
      $$SchoolProfileTableUpdateCompanionBuilder,
      (
        SchoolProfileData,
        BaseReferences<_$AppDatabase, $SchoolProfileTable, SchoolProfileData>,
      ),
      SchoolProfileData,
      PrefetchHooks Function()
    >;
typedef $$GuardianProfileTableCreateCompanionBuilder =
    GuardianProfileCompanion Function({
      required String uuid,
      required String name,
      required String email,
      required String mobileNumber,
      required String status,
      required bool notifyAttendance,
      required bool notifyAnnouncements,
      Value<int> rowid,
    });
typedef $$GuardianProfileTableUpdateCompanionBuilder =
    GuardianProfileCompanion Function({
      Value<String> uuid,
      Value<String> name,
      Value<String> email,
      Value<String> mobileNumber,
      Value<String> status,
      Value<bool> notifyAttendance,
      Value<bool> notifyAnnouncements,
      Value<int> rowid,
    });

class $$GuardianProfileTableFilterComposer
    extends Composer<_$AppDatabase, $GuardianProfileTable> {
  $$GuardianProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyAttendance => $composableBuilder(
    column: $table.notifyAttendance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyAnnouncements => $composableBuilder(
    column: $table.notifyAnnouncements,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GuardianProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $GuardianProfileTable> {
  $$GuardianProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyAttendance => $composableBuilder(
    column: $table.notifyAttendance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyAnnouncements => $composableBuilder(
    column: $table.notifyAnnouncements,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GuardianProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $GuardianProfileTable> {
  $$GuardianProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get notifyAttendance => $composableBuilder(
    column: $table.notifyAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyAnnouncements => $composableBuilder(
    column: $table.notifyAnnouncements,
    builder: (column) => column,
  );
}

class $$GuardianProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GuardianProfileTable,
          GuardianProfileData,
          $$GuardianProfileTableFilterComposer,
          $$GuardianProfileTableOrderingComposer,
          $$GuardianProfileTableAnnotationComposer,
          $$GuardianProfileTableCreateCompanionBuilder,
          $$GuardianProfileTableUpdateCompanionBuilder,
          (
            GuardianProfileData,
            BaseReferences<
              _$AppDatabase,
              $GuardianProfileTable,
              GuardianProfileData
            >,
          ),
          GuardianProfileData,
          PrefetchHooks Function()
        > {
  $$GuardianProfileTableTableManager(
    _$AppDatabase db,
    $GuardianProfileTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuardianProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuardianProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GuardianProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> mobileNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> notifyAttendance = const Value.absent(),
                Value<bool> notifyAnnouncements = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuardianProfileCompanion(
                uuid: uuid,
                name: name,
                email: email,
                mobileNumber: mobileNumber,
                status: status,
                notifyAttendance: notifyAttendance,
                notifyAnnouncements: notifyAnnouncements,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String name,
                required String email,
                required String mobileNumber,
                required String status,
                required bool notifyAttendance,
                required bool notifyAnnouncements,
                Value<int> rowid = const Value.absent(),
              }) => GuardianProfileCompanion.insert(
                uuid: uuid,
                name: name,
                email: email,
                mobileNumber: mobileNumber,
                status: status,
                notifyAttendance: notifyAttendance,
                notifyAnnouncements: notifyAnnouncements,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GuardianProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GuardianProfileTable,
      GuardianProfileData,
      $$GuardianProfileTableFilterComposer,
      $$GuardianProfileTableOrderingComposer,
      $$GuardianProfileTableAnnotationComposer,
      $$GuardianProfileTableCreateCompanionBuilder,
      $$GuardianProfileTableUpdateCompanionBuilder,
      (
        GuardianProfileData,
        BaseReferences<
          _$AppDatabase,
          $GuardianProfileTable,
          GuardianProfileData
        >,
      ),
      GuardianProfileData,
      PrefetchHooks Function()
    >;
typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      required String uuid,
      Value<int?> serverId,
      required String lrn,
      required String studentNumber,
      required String name,
      required String sex,
      required String grade,
      required String section,
      required String schoolYear,
      required String status,
      Value<String?> photoUrl,
      Value<int> rowid,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<String> lrn,
      Value<String> studentNumber,
      Value<String> name,
      Value<String> sex,
      Value<String> grade,
      Value<String> section,
      Value<String> schoolYear,
      Value<String> status,
      Value<String?> photoUrl,
      Value<int> rowid,
    });

final class $$StudentsTableReferences
    extends BaseReferences<_$AppDatabase, $StudentsTable, Student> {
  $$StudentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AttendanceRecordsTable, List<AttendanceRecord>>
  _attendanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceRecords,
        aliasName: 'students__uuid__attendance_records__student_uuid',
      );

  $$AttendanceRecordsTableProcessedTableManager get attendanceRecordsRefs {
    final manager =
        $$AttendanceRecordsTableTableManager(
          $_db,
          $_db.attendanceRecords,
        ).filter(
          (f) => f.studentUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _attendanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lrn => $composableBuilder(
    column: $table.lrn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentNumber => $composableBuilder(
    column: $table.studentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> attendanceRecordsRefs(
    Expression<bool> Function($$AttendanceRecordsTableFilterComposer f) f,
  ) {
    final $$AttendanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.attendanceRecords,
      getReferencedColumn: (t) => t.studentUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lrn => $composableBuilder(
    column: $table.lrn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentNumber => $composableBuilder(
    column: $table.studentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get lrn =>
      $composableBuilder(column: $table.lrn, builder: (column) => column);

  GeneratedColumn<String> get studentNumber => $composableBuilder(
    column: $table.studentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  Expression<T> attendanceRecordsRefs<T extends Object>(
    Expression<T> Function($$AttendanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.uuid,
          referencedTable: $db.attendanceRecords,
          getReferencedColumn: (t) => t.studentUuid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, $$StudentsTableReferences),
          Student,
          PrefetchHooks Function({bool attendanceRecordsRefs})
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> lrn = const Value.absent(),
                Value<String> studentNumber = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<String> section = const Value.absent(),
                Value<String> schoolYear = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion(
                uuid: uuid,
                serverId: serverId,
                lrn: lrn,
                studentNumber: studentNumber,
                name: name,
                sex: sex,
                grade: grade,
                section: section,
                schoolYear: schoolYear,
                status: status,
                photoUrl: photoUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                required String lrn,
                required String studentNumber,
                required String name,
                required String sex,
                required String grade,
                required String section,
                required String schoolYear,
                required String status,
                Value<String?> photoUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                lrn: lrn,
                studentNumber: studentNumber,
                name: name,
                sex: sex,
                grade: grade,
                section: section,
                schoolYear: schoolYear,
                status: status,
                photoUrl: photoUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attendanceRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (attendanceRecordsRefs) db.attendanceRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attendanceRecordsRefs)
                    await $_getPrefetchedData<
                      Student,
                      $StudentsTable,
                      AttendanceRecord
                    >(
                      currentTable: table,
                      referencedTable: $$StudentsTableReferences
                          ._attendanceRecordsRefsTable(db),
                      managerFromTypedResult: (p0) => $$StudentsTableReferences(
                        db,
                        table,
                        p0,
                      ).attendanceRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.studentUuid == item.uuid,
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

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, $$StudentsTableReferences),
      Student,
      PrefetchHooks Function({bool attendanceRecordsRefs})
    >;
typedef $$GuardianStudentLinksTableCreateCompanionBuilder =
    GuardianStudentLinksCompanion Function({
      required String uuid,
      required int studentServerId,
      required String relationshipType,
      required bool isPrimaryContact,
      required String status,
      required bool notificationsEnabled,
      Value<int> rowid,
    });
typedef $$GuardianStudentLinksTableUpdateCompanionBuilder =
    GuardianStudentLinksCompanion Function({
      Value<String> uuid,
      Value<int> studentServerId,
      Value<String> relationshipType,
      Value<bool> isPrimaryContact,
      Value<String> status,
      Value<bool> notificationsEnabled,
      Value<int> rowid,
    });

class $$GuardianStudentLinksTableFilterComposer
    extends Composer<_$AppDatabase, $GuardianStudentLinksTable> {
  $$GuardianStudentLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentServerId => $composableBuilder(
    column: $table.studentServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimaryContact => $composableBuilder(
    column: $table.isPrimaryContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GuardianStudentLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $GuardianStudentLinksTable> {
  $$GuardianStudentLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentServerId => $composableBuilder(
    column: $table.studentServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimaryContact => $composableBuilder(
    column: $table.isPrimaryContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GuardianStudentLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $GuardianStudentLinksTable> {
  $$GuardianStudentLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get studentServerId => $composableBuilder(
    column: $table.studentServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrimaryContact => $composableBuilder(
    column: $table.isPrimaryContact,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );
}

class $$GuardianStudentLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GuardianStudentLinksTable,
          GuardianStudentLink,
          $$GuardianStudentLinksTableFilterComposer,
          $$GuardianStudentLinksTableOrderingComposer,
          $$GuardianStudentLinksTableAnnotationComposer,
          $$GuardianStudentLinksTableCreateCompanionBuilder,
          $$GuardianStudentLinksTableUpdateCompanionBuilder,
          (
            GuardianStudentLink,
            BaseReferences<
              _$AppDatabase,
              $GuardianStudentLinksTable,
              GuardianStudentLink
            >,
          ),
          GuardianStudentLink,
          PrefetchHooks Function()
        > {
  $$GuardianStudentLinksTableTableManager(
    _$AppDatabase db,
    $GuardianStudentLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuardianStudentLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuardianStudentLinksTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GuardianStudentLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int> studentServerId = const Value.absent(),
                Value<String> relationshipType = const Value.absent(),
                Value<bool> isPrimaryContact = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuardianStudentLinksCompanion(
                uuid: uuid,
                studentServerId: studentServerId,
                relationshipType: relationshipType,
                isPrimaryContact: isPrimaryContact,
                status: status,
                notificationsEnabled: notificationsEnabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required int studentServerId,
                required String relationshipType,
                required bool isPrimaryContact,
                required String status,
                required bool notificationsEnabled,
                Value<int> rowid = const Value.absent(),
              }) => GuardianStudentLinksCompanion.insert(
                uuid: uuid,
                studentServerId: studentServerId,
                relationshipType: relationshipType,
                isPrimaryContact: isPrimaryContact,
                status: status,
                notificationsEnabled: notificationsEnabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GuardianStudentLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GuardianStudentLinksTable,
      GuardianStudentLink,
      $$GuardianStudentLinksTableFilterComposer,
      $$GuardianStudentLinksTableOrderingComposer,
      $$GuardianStudentLinksTableAnnotationComposer,
      $$GuardianStudentLinksTableCreateCompanionBuilder,
      $$GuardianStudentLinksTableUpdateCompanionBuilder,
      (
        GuardianStudentLink,
        BaseReferences<
          _$AppDatabase,
          $GuardianStudentLinksTable,
          GuardianStudentLink
        >,
      ),
      GuardianStudentLink,
      PrefetchHooks Function()
    >;
typedef $$AttendanceRecordsTableCreateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      required String studentUuid,
      required DateTime date,
      Value<DateTime?> arrival,
      Value<DateTime?> departure,
      required bool isLate,
      required bool isAbsent,
    });
typedef $$AttendanceRecordsTableUpdateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      Value<String> studentUuid,
      Value<DateTime> date,
      Value<DateTime?> arrival,
      Value<DateTime?> departure,
      Value<bool> isLate,
      Value<bool> isAbsent,
    });

final class $$AttendanceRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord
        > {
  $$AttendanceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentUuidTable(_$AppDatabase db) => db.students
      .createAlias('attendance_records__student_uuid__students__uuid');

  $$StudentsTableProcessedTableManager get studentUuid {
    final $_column = $_itemColumn<String>('student_uuid')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrival => $composableBuilder(
    column: $table.arrival,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get departure => $composableBuilder(
    column: $table.departure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLate => $composableBuilder(
    column: $table.isLate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAbsent => $composableBuilder(
    column: $table.isAbsent,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentUuid {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentUuid,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrival => $composableBuilder(
    column: $table.arrival,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get departure => $composableBuilder(
    column: $table.departure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLate => $composableBuilder(
    column: $table.isLate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAbsent => $composableBuilder(
    column: $table.isAbsent,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentUuid {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentUuid,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get arrival =>
      $composableBuilder(column: $table.arrival, builder: (column) => column);

  GeneratedColumn<DateTime> get departure =>
      $composableBuilder(column: $table.departure, builder: (column) => column);

  GeneratedColumn<bool> get isLate =>
      $composableBuilder(column: $table.isLate, builder: (column) => column);

  GeneratedColumn<bool> get isAbsent =>
      $composableBuilder(column: $table.isAbsent, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentUuid {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentUuid,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRecord,
          $$AttendanceRecordsTableFilterComposer,
          $$AttendanceRecordsTableOrderingComposer,
          $$AttendanceRecordsTableAnnotationComposer,
          $$AttendanceRecordsTableCreateCompanionBuilder,
          $$AttendanceRecordsTableUpdateCompanionBuilder,
          (AttendanceRecord, $$AttendanceRecordsTableReferences),
          AttendanceRecord,
          PrefetchHooks Function({bool studentUuid})
        > {
  $$AttendanceRecordsTableTableManager(
    _$AppDatabase db,
    $AttendanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> studentUuid = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime?> arrival = const Value.absent(),
                Value<DateTime?> departure = const Value.absent(),
                Value<bool> isLate = const Value.absent(),
                Value<bool> isAbsent = const Value.absent(),
              }) => AttendanceRecordsCompanion(
                id: id,
                serverId: serverId,
                studentUuid: studentUuid,
                date: date,
                arrival: arrival,
                departure: departure,
                isLate: isLate,
                isAbsent: isAbsent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String studentUuid,
                required DateTime date,
                Value<DateTime?> arrival = const Value.absent(),
                Value<DateTime?> departure = const Value.absent(),
                required bool isLate,
                required bool isAbsent,
              }) => AttendanceRecordsCompanion.insert(
                id: id,
                serverId: serverId,
                studentUuid: studentUuid,
                date: date,
                arrival: arrival,
                departure: departure,
                isLate: isLate,
                isAbsent: isAbsent,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendanceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentUuid = false}) {
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
                    if (studentUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentUuid,
                                referencedTable:
                                    $$AttendanceRecordsTableReferences
                                        ._studentUuidTable(db),
                                referencedColumn:
                                    $$AttendanceRecordsTableReferences
                                        ._studentUuidTable(db)
                                        .uuid,
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

typedef $$AttendanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceRecordsTable,
      AttendanceRecord,
      $$AttendanceRecordsTableFilterComposer,
      $$AttendanceRecordsTableOrderingComposer,
      $$AttendanceRecordsTableAnnotationComposer,
      $$AttendanceRecordsTableCreateCompanionBuilder,
      $$AttendanceRecordsTableUpdateCompanionBuilder,
      (AttendanceRecord, $$AttendanceRecordsTableReferences),
      AttendanceRecord,
      PrefetchHooks Function({bool studentUuid})
    >;
typedef $$AnnouncementsTableCreateCompanionBuilder =
    AnnouncementsCompanion Function({
      required String uuid,
      required String title,
      required String body,
      required String status,
      Value<DateTime?> publishedAt,
      Value<DateTime?> expiresAt,
      Value<int> rowid,
    });
typedef $$AnnouncementsTableUpdateCompanionBuilder =
    AnnouncementsCompanion Function({
      Value<String> uuid,
      Value<String> title,
      Value<String> body,
      Value<String> status,
      Value<DateTime?> publishedAt,
      Value<DateTime?> expiresAt,
      Value<int> rowid,
    });

class $$AnnouncementsTableFilterComposer
    extends Composer<_$AppDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnnouncementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnnouncementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$AnnouncementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnnouncementsTable,
          Announcement,
          $$AnnouncementsTableFilterComposer,
          $$AnnouncementsTableOrderingComposer,
          $$AnnouncementsTableAnnotationComposer,
          $$AnnouncementsTableCreateCompanionBuilder,
          $$AnnouncementsTableUpdateCompanionBuilder,
          (
            Announcement,
            BaseReferences<_$AppDatabase, $AnnouncementsTable, Announcement>,
          ),
          Announcement,
          PrefetchHooks Function()
        > {
  $$AnnouncementsTableTableManager(_$AppDatabase db, $AnnouncementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnnouncementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnnouncementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnnouncementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnnouncementsCompanion(
                uuid: uuid,
                title: title,
                body: body,
                status: status,
                publishedAt: publishedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String title,
                required String body,
                required String status,
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnnouncementsCompanion.insert(
                uuid: uuid,
                title: title,
                body: body,
                status: status,
                publishedAt: publishedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnnouncementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnnouncementsTable,
      Announcement,
      $$AnnouncementsTableFilterComposer,
      $$AnnouncementsTableOrderingComposer,
      $$AnnouncementsTableAnnotationComposer,
      $$AnnouncementsTableCreateCompanionBuilder,
      $$AnnouncementsTableUpdateCompanionBuilder,
      (
        Announcement,
        BaseReferences<_$AppDatabase, $AnnouncementsTable, Announcement>,
      ),
      Announcement,
      PrefetchHooks Function()
    >;
typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      required String uuid,
      required String type,
      required String title,
      required String body,
      Value<String?> payload,
      Value<DateTime?> readAt,
      required String deliveryStatus,
      Value<int> rowid,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      Value<String> uuid,
      Value<String> type,
      Value<String> title,
      Value<String> body,
      Value<String?> payload,
      Value<DateTime?> readAt,
      Value<String> deliveryStatus,
      Value<int> rowid,
    });

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => column,
  );
}

class $$NotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsTable,
          NotificationRow,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (
            NotificationRow,
            BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRow>,
          ),
          NotificationRow,
          PrefetchHooks Function()
        > {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<String> deliveryStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCompanion(
                uuid: uuid,
                type: type,
                title: title,
                body: body,
                payload: payload,
                readAt: readAt,
                deliveryStatus: deliveryStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String type,
                required String title,
                required String body,
                Value<String?> payload = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                required String deliveryStatus,
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCompanion.insert(
                uuid: uuid,
                type: type,
                title: title,
                body: body,
                payload: payload,
                readAt: readAt,
                deliveryStatus: deliveryStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsTable,
      NotificationRow,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (
        NotificationRow,
        BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRow>,
      ),
      NotificationRow,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      Value<int> id,
      Value<String?> cursor,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<int> id,
      Value<String?> cursor,
      Value<DateTime?> lastSyncedAt,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
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

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
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

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => SyncStateCompanion(
                id: id,
                cursor: cursor,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => SyncStateCompanion.insert(
                id: id,
                cursor: cursor,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$SchoolProfileTableTableManager get schoolProfile =>
      $$SchoolProfileTableTableManager(_db, _db.schoolProfile);
  $$GuardianProfileTableTableManager get guardianProfile =>
      $$GuardianProfileTableTableManager(_db, _db.guardianProfile);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$GuardianStudentLinksTableTableManager get guardianStudentLinks =>
      $$GuardianStudentLinksTableTableManager(_db, _db.guardianStudentLinks);
  $$AttendanceRecordsTableTableManager get attendanceRecords =>
      $$AttendanceRecordsTableTableManager(_db, _db.attendanceRecords);
  $$AnnouncementsTableTableManager get announcements =>
      $$AnnouncementsTableTableManager(_db, _db.announcements);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
}
