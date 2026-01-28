// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetActivityModelCollection on Isar {
  IsarCollection<ActivityModel> get activityModels => this.collection();
}

const ActivityModelSchema = CollectionSchema(
  name: r'ActivityModel',
  id: -6385501004358380311,
  properties: {
    r'activityType': PropertySchema(
      id: 0,
      name: r'activityType',
      type: IsarType.byte,
      enumMap: _ActivityModelactivityTypeEnumValueMap,
    ),
    r'client': PropertySchema(
      id: 1,
      name: r'client',
      type: IsarType.string,
    ),
    r'collaborator': PropertySchema(
      id: 2,
      name: r'collaborator',
      type: IsarType.string,
    ),
    r'dedupKey': PropertySchema(
      id: 3,
      name: r'dedupKey',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 4,
      name: r'description',
      type: IsarType.string,
    ),
    r'documentId': PropertySchema(
      id: 5,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 6,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'latitude': PropertySchema(
      id: 7,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 8,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'motive': PropertySchema(
      id: 9,
      name: r'motive',
      type: IsarType.byte,
      enumMap: _ActivityModelmotiveEnumValueMap,
    ),
    r'motiveText': PropertySchema(
      id: 10,
      name: r'motiveText',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 11,
      name: r'serverId',
      type: IsarType.long,
    ),
    r'task': PropertySchema(
      id: 12,
      name: r'task',
      type: IsarType.byte,
      enumMap: _ActivityModeltaskEnumValueMap,
    ),
    r'timestamp': PropertySchema(
      id: 13,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _activityModelEstimateSize,
  serialize: _activityModelSerialize,
  deserialize: _activityModelDeserialize,
  deserializeProp: _activityModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'serverId': IndexSchema(
      id: -7950187970872907662,
      name: r'serverId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'serverId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'client': IndexSchema(
      id: -7187598444406380305,
      name: r'client',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'client',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'motive': IndexSchema(
      id: 1157251974383467172,
      name: r'motive',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'motive',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'task': IndexSchema(
      id: 4607462848387024586,
      name: r'task',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'task',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'activityType': IndexSchema(
      id: 1012544980970652462,
      name: r'activityType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'activityType',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'dedupKey': IndexSchema(
      id: 2124236096506660101,
      name: r'dedupKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'dedupKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isSynced': IndexSchema(
      id: -39763503327887510,
      name: r'isSynced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSynced',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _activityModelGetId,
  getLinks: _activityModelGetLinks,
  attach: _activityModelAttach,
  version: '3.1.0+1',
);

int _activityModelEstimateSize(
  ActivityModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.client;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.collaborator;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.dedupKey.length * 3;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.documentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.motiveText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _activityModelSerialize(
  ActivityModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.activityType.index);
  writer.writeString(offsets[1], object.client);
  writer.writeString(offsets[2], object.collaborator);
  writer.writeString(offsets[3], object.dedupKey);
  writer.writeString(offsets[4], object.description);
  writer.writeString(offsets[5], object.documentId);
  writer.writeBool(offsets[6], object.isSynced);
  writer.writeDouble(offsets[7], object.latitude);
  writer.writeDouble(offsets[8], object.longitude);
  writer.writeByte(offsets[9], object.motive.index);
  writer.writeString(offsets[10], object.motiveText);
  writer.writeLong(offsets[11], object.serverId);
  writer.writeByte(offsets[12], object.task.index);
  writer.writeDateTime(offsets[13], object.timestamp);
}

ActivityModel _activityModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ActivityModel(
    activityType: _ActivityModelactivityTypeValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        AssigmentType.other,
    client: reader.readStringOrNull(offsets[1]),
    collaborator: reader.readStringOrNull(offsets[2]),
    description: reader.readStringOrNull(offsets[4]),
    documentId: reader.readStringOrNull(offsets[5]),
    isSynced: reader.readBoolOrNull(offsets[6]),
    latitude: reader.readDoubleOrNull(offsets[7]),
    longitude: reader.readDoubleOrNull(offsets[8]),
    motive:
        _ActivityModelmotiveValueEnumMap[reader.readByteOrNull(offsets[9])] ??
            MotiveType.entry,
    motiveText: reader.readStringOrNull(offsets[10]),
    serverId: reader.readLongOrNull(offsets[11]),
    task: _ActivityModeltaskValueEnumMap[reader.readByteOrNull(offsets[12])] ??
        TaskType.office,
    timestamp: reader.readDateTimeOrNull(offsets[13]),
  );
  object.dedupKey = reader.readString(offsets[3]);
  object.id = id;
  return object;
}

P _activityModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_ActivityModelactivityTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AssigmentType.other) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (_ActivityModelmotiveValueEnumMap[reader.readByteOrNull(offset)] ??
          MotiveType.entry) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (_ActivityModeltaskValueEnumMap[reader.readByteOrNull(offset)] ??
          TaskType.office) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ActivityModelactivityTypeEnumValueMap = {
  'projectOrder': 0,
  'serviceProject': 1,
  'projectAdditional': 2,
  'warrantyProject': 3,
  'emergency': 4,
  'technicalVisit': 5,
  'officeAssistance': 6,
  'transfer': 7,
  'other': 8,
};
const _ActivityModelactivityTypeValueEnumMap = {
  0: AssigmentType.projectOrder,
  1: AssigmentType.serviceProject,
  2: AssigmentType.projectAdditional,
  3: AssigmentType.warrantyProject,
  4: AssigmentType.emergency,
  5: AssigmentType.technicalVisit,
  6: AssigmentType.officeAssistance,
  7: AssigmentType.transfer,
  8: AssigmentType.other,
};
const _ActivityModelmotiveEnumValueMap = {
  'entry': 0,
  'exit': 1,
};
const _ActivityModelmotiveValueEnumMap = {
  0: MotiveType.entry,
  1: MotiveType.exit,
};
const _ActivityModeltaskEnumValueMap = {
  'office': 0,
  'workshop': 1,
  'service': 2,
  'transport': 3,
};
const _ActivityModeltaskValueEnumMap = {
  0: TaskType.office,
  1: TaskType.workshop,
  2: TaskType.service,
  3: TaskType.transport,
};

Id _activityModelGetId(ActivityModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _activityModelGetLinks(ActivityModel object) {
  return [];
}

void _activityModelAttach(
    IsarCollection<dynamic> col, Id id, ActivityModel object) {
  object.id = id;
}

extension ActivityModelByIndex on IsarCollection<ActivityModel> {
  Future<ActivityModel?> getByDedupKey(String dedupKey) {
    return getByIndex(r'dedupKey', [dedupKey]);
  }

  ActivityModel? getByDedupKeySync(String dedupKey) {
    return getByIndexSync(r'dedupKey', [dedupKey]);
  }

  Future<bool> deleteByDedupKey(String dedupKey) {
    return deleteByIndex(r'dedupKey', [dedupKey]);
  }

  bool deleteByDedupKeySync(String dedupKey) {
    return deleteByIndexSync(r'dedupKey', [dedupKey]);
  }

  Future<List<ActivityModel?>> getAllByDedupKey(List<String> dedupKeyValues) {
    final values = dedupKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'dedupKey', values);
  }

  List<ActivityModel?> getAllByDedupKeySync(List<String> dedupKeyValues) {
    final values = dedupKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'dedupKey', values);
  }

  Future<int> deleteAllByDedupKey(List<String> dedupKeyValues) {
    final values = dedupKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'dedupKey', values);
  }

  int deleteAllByDedupKeySync(List<String> dedupKeyValues) {
    final values = dedupKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'dedupKey', values);
  }

  Future<Id> putByDedupKey(ActivityModel object) {
    return putByIndex(r'dedupKey', object);
  }

  Id putByDedupKeySync(ActivityModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'dedupKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDedupKey(List<ActivityModel> objects) {
    return putAllByIndex(r'dedupKey', objects);
  }

  List<Id> putAllByDedupKeySync(List<ActivityModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'dedupKey', objects, saveLinks: saveLinks);
  }
}

extension ActivityModelQueryWhereSort
    on QueryBuilder<ActivityModel, ActivityModel, QWhere> {
  QueryBuilder<ActivityModel, ActivityModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhere> anyServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'serverId'),
      );
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhere> anyMotive() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'motive'),
      );
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhere> anyTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'task'),
      );
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhere> anyActivityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'activityType'),
      );
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhere> anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension ActivityModelQueryWhere
    on QueryBuilder<ActivityModel, ActivityModel, QWhereClause> {
  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [null],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serverId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> serverIdEqualTo(
      int? serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      serverIdNotEqualTo(int? serverId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [],
              upper: [serverId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [serverId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [serverId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [],
              upper: [serverId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      serverIdGreaterThan(
    int? serverId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serverId',
        lower: [serverId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      serverIdLessThan(
    int? serverId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serverId',
        lower: [],
        upper: [serverId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> serverIdBetween(
    int? lowerServerId,
    int? upperServerId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serverId',
        lower: [lowerServerId],
        includeLower: includeLower,
        upper: [upperServerId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      documentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [null],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      documentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'documentId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      documentIdEqualTo(String? documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      documentIdNotEqualTo(String? documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> clientIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'client',
        value: [null],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      clientIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'client',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> clientEqualTo(
      String? client) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'client',
        value: [client],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      clientNotEqualTo(String? client) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'client',
              lower: [],
              upper: [client],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'client',
              lower: [client],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'client',
              lower: [client],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'client',
              lower: [],
              upper: [client],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> motiveEqualTo(
      MotiveType motive) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'motive',
        value: [motive],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      motiveNotEqualTo(MotiveType motive) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'motive',
              lower: [],
              upper: [motive],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'motive',
              lower: [motive],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'motive',
              lower: [motive],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'motive',
              lower: [],
              upper: [motive],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      motiveGreaterThan(
    MotiveType motive, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'motive',
        lower: [motive],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> motiveLessThan(
    MotiveType motive, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'motive',
        lower: [],
        upper: [motive],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> motiveBetween(
    MotiveType lowerMotive,
    MotiveType upperMotive, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'motive',
        lower: [lowerMotive],
        includeLower: includeLower,
        upper: [upperMotive],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> taskEqualTo(
      TaskType task) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'task',
        value: [task],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> taskNotEqualTo(
      TaskType task) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'task',
              lower: [],
              upper: [task],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'task',
              lower: [task],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'task',
              lower: [task],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'task',
              lower: [],
              upper: [task],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> taskGreaterThan(
    TaskType task, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'task',
        lower: [task],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> taskLessThan(
    TaskType task, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'task',
        lower: [],
        upper: [task],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> taskBetween(
    TaskType lowerTask,
    TaskType upperTask, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'task',
        lower: [lowerTask],
        includeLower: includeLower,
        upper: [upperTask],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      activityTypeEqualTo(AssigmentType activityType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'activityType',
        value: [activityType],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      activityTypeNotEqualTo(AssigmentType activityType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityType',
              lower: [],
              upper: [activityType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityType',
              lower: [activityType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityType',
              lower: [activityType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityType',
              lower: [],
              upper: [activityType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      activityTypeGreaterThan(
    AssigmentType activityType, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activityType',
        lower: [activityType],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      activityTypeLessThan(
    AssigmentType activityType, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activityType',
        lower: [],
        upper: [activityType],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      activityTypeBetween(
    AssigmentType lowerActivityType,
    AssigmentType upperActivityType, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activityType',
        lower: [lowerActivityType],
        includeLower: includeLower,
        upper: [upperActivityType],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> dedupKeyEqualTo(
      String dedupKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dedupKey',
        value: [dedupKey],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      dedupKeyNotEqualTo(String dedupKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dedupKey',
              lower: [],
              upper: [dedupKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dedupKey',
              lower: [dedupKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dedupKey',
              lower: [dedupKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dedupKey',
              lower: [],
              upper: [dedupKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      isSyncedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [null],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      isSyncedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'isSynced',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> isSyncedEqualTo(
      bool? isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      isSyncedNotEqualTo(bool? isSynced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ActivityModelQueryFilter
    on QueryBuilder<ActivityModel, ActivityModel, QFilterCondition> {
  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      activityTypeEqualTo(AssigmentType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityType',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      activityTypeGreaterThan(
    AssigmentType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityType',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      activityTypeLessThan(
    AssigmentType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityType',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      activityTypeBetween(
    AssigmentType lower,
    AssigmentType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'client',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'client',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'client',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'client',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'client',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'client',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'client',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'client',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'client',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'client',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'client',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      clientIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'client',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'collaborator',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'collaborator',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collaborator',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collaborator',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collaborator',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collaborator',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collaborator',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collaborator',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collaborator',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collaborator',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collaborator',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collaborator',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      dedupKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dedupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      dedupKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dedupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      dedupKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dedupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      dedupKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dedupKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      dedupKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dedupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      dedupKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dedupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      dedupKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dedupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      dedupKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dedupKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      dedupKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dedupKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      dedupKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dedupKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'documentId',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'documentId',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      isSyncedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isSynced',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      isSyncedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isSynced',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      isSyncedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      latitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      latitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      latitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      latitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      latitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      latitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      longitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      longitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      longitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      longitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      longitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      longitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveEqualTo(MotiveType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motive',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveGreaterThan(
    MotiveType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motive',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveLessThan(
    MotiveType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motive',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveBetween(
    MotiveType lower,
    MotiveType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motive',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'motiveText',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'motiveText',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motiveText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motiveText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motiveText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motiveText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motiveText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motiveText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motiveText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motiveText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motiveText',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motiveText',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      serverIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      serverIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      serverIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      serverIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition> taskEqualTo(
      TaskType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'task',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      taskGreaterThan(
    TaskType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'task',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      taskLessThan(
    TaskType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'task',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition> taskBetween(
    TaskType lower,
    TaskType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'task',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      timestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      timestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      timestampEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      timestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      timestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ActivityModelQueryObject
    on QueryBuilder<ActivityModel, ActivityModel, QFilterCondition> {}

extension ActivityModelQueryLinks
    on QueryBuilder<ActivityModel, ActivityModel, QFilterCondition> {}

extension ActivityModelQuerySortBy
    on QueryBuilder<ActivityModel, ActivityModel, QSortBy> {
  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByActivityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByActivityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByClient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'client', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByClientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'client', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByCollaborator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaborator', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByCollaboratorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaborator', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByDedupKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupKey', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByDedupKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupKey', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByMotive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motive', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByMotiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motive', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByMotiveText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motiveText', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByMotiveTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motiveText', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByTaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ActivityModelQuerySortThenBy
    on QueryBuilder<ActivityModel, ActivityModel, QSortThenBy> {
  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByActivityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByActivityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByClient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'client', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByClientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'client', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByCollaborator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaborator', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByCollaboratorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaborator', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByDedupKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupKey', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByDedupKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupKey', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByMotive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motive', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByMotiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motive', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByMotiveText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motiveText', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByMotiveTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motiveText', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByTaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'task', Sort.desc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ActivityModelQueryWhereDistinct
    on QueryBuilder<ActivityModel, ActivityModel, QDistinct> {
  QueryBuilder<ActivityModel, ActivityModel, QDistinct>
      distinctByActivityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityType');
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByClient(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'client', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByCollaborator(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collaborator', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByDedupKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dedupKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByMotive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motive');
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByMotiveText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motiveText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByTask() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'task');
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension ActivityModelQueryProperty
    on QueryBuilder<ActivityModel, ActivityModel, QQueryProperty> {
  QueryBuilder<ActivityModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ActivityModel, AssigmentType, QQueryOperations>
      activityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityType');
    });
  }

  QueryBuilder<ActivityModel, String?, QQueryOperations> clientProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'client');
    });
  }

  QueryBuilder<ActivityModel, String?, QQueryOperations>
      collaboratorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collaborator');
    });
  }

  QueryBuilder<ActivityModel, String, QQueryOperations> dedupKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dedupKey');
    });
  }

  QueryBuilder<ActivityModel, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<ActivityModel, String?, QQueryOperations> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<ActivityModel, bool?, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<ActivityModel, double?, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<ActivityModel, double?, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<ActivityModel, MotiveType, QQueryOperations> motiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motive');
    });
  }

  QueryBuilder<ActivityModel, String?, QQueryOperations> motiveTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motiveText');
    });
  }

  QueryBuilder<ActivityModel, int?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<ActivityModel, TaskType, QQueryOperations> taskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'task');
    });
  }

  QueryBuilder<ActivityModel, DateTime?, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
