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
    r'assigmentId': PropertySchema(
      id: 1,
      name: r'assigmentId',
      type: IsarType.long,
    ),
    r'client': PropertySchema(
      id: 2,
      name: r'client',
      type: IsarType.string,
    ),
    r'collaboratordocumentId': PropertySchema(
      id: 3,
      name: r'collaboratordocumentId',
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
    r'keyGroup': PropertySchema(
      id: 7,
      name: r'keyGroup',
      type: IsarType.string,
    ),
    r'latitude': PropertySchema(
      id: 8,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 9,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'motiveActivity': PropertySchema(
      id: 10,
      name: r'motiveActivity',
      type: IsarType.byte,
      enumMap: _ActivityModelmotiveActivityEnumValueMap,
    ),
    r'task': PropertySchema(
      id: 11,
      name: r'task',
      type: IsarType.byte,
      enumMap: _ActivityModeltaskEnumValueMap,
    ),
    r'timestamp': PropertySchema(
      id: 12,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'zone': PropertySchema(
      id: 13,
      name: r'zone',
      type: IsarType.byte,
      enumMap: _ActivityModelzoneEnumValueMap,
    )
  },
  estimateSize: _activityModelEstimateSize,
  serialize: _activityModelSerialize,
  deserialize: _activityModelDeserialize,
  deserializeProp: _activityModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'keyGroup': IndexSchema(
      id: -210063213096258777,
      name: r'keyGroup',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'keyGroup',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'assigmentId': IndexSchema(
      id: 8364864272711985178,
      name: r'assigmentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'assigmentId',
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
    r'motiveActivity': IndexSchema(
      id: 1864299120324990635,
      name: r'motiveActivity',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'motiveActivity',
          type: IndexType.value,
          caseSensitive: false,
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
    final value = object.collaboratordocumentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
    final value = object.keyGroup;
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
  writer.writeLong(offsets[1], object.assigmentId);
  writer.writeString(offsets[2], object.client);
  writer.writeString(offsets[3], object.collaboratordocumentId);
  writer.writeString(offsets[4], object.description);
  writer.writeString(offsets[5], object.documentId);
  writer.writeBool(offsets[6], object.isSynced);
  writer.writeString(offsets[7], object.keyGroup);
  writer.writeDouble(offsets[8], object.latitude);
  writer.writeDouble(offsets[9], object.longitude);
  writer.writeByte(offsets[10], object.motiveActivity.index);
  writer.writeByte(offsets[11], object.task.index);
  writer.writeDateTime(offsets[12], object.timestamp);
  writer.writeByte(offsets[13], object.zone.index);
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
    assigmentId: reader.readLong(offsets[1]),
    client: reader.readStringOrNull(offsets[2]),
    collaboratordocumentId: reader.readStringOrNull(offsets[3]),
    description: reader.readStringOrNull(offsets[4]),
    documentId: reader.readStringOrNull(offsets[5]),
    isSynced: reader.readBoolOrNull(offsets[6]) ?? false,
    keyGroup: reader.readStringOrNull(offsets[7]),
    latitude: reader.readDoubleOrNull(offsets[8]),
    longitude: reader.readDoubleOrNull(offsets[9]),
    motiveActivity: _ActivityModelmotiveActivityValueEnumMap[
            reader.readByteOrNull(offsets[10])] ??
        MotiveActivity.startWork,
    task: _ActivityModeltaskValueEnumMap[reader.readByteOrNull(offsets[11])] ??
        TaskType.office,
    timestamp: reader.readDateTimeOrNull(offsets[12]),
    zone: _ActivityModelzoneValueEnumMap[reader.readByteOrNull(offsets[13])] ??
        UserZone.centro,
  );
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
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (_ActivityModelmotiveActivityValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MotiveActivity.startWork) as P;
    case 11:
      return (_ActivityModeltaskValueEnumMap[reader.readByteOrNull(offset)] ??
          TaskType.office) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (_ActivityModelzoneValueEnumMap[reader.readByteOrNull(offset)] ??
          UserZone.centro) as P;
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
const _ActivityModelmotiveActivityEnumValueMap = {
  'endWork': 0,
  'startWork': 1,
};
const _ActivityModelmotiveActivityValueEnumMap = {
  0: MotiveActivity.endWork,
  1: MotiveActivity.startWork,
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
const _ActivityModelzoneEnumValueMap = {
  'sur': 0,
  'centro': 1,
  'norte': 2,
};
const _ActivityModelzoneValueEnumMap = {
  0: UserZone.sur,
  1: UserZone.centro,
  2: UserZone.norte,
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

extension ActivityModelQueryWhereSort
    on QueryBuilder<ActivityModel, ActivityModel, QWhere> {
  QueryBuilder<ActivityModel, ActivityModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhere> anyAssigmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'assigmentId'),
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhere> anyMotiveActivity() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'motiveActivity'),
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
      keyGroupIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'keyGroup',
        value: [null],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      keyGroupIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'keyGroup',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> keyGroupEqualTo(
      String? keyGroup) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'keyGroup',
        value: [keyGroup],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      keyGroupNotEqualTo(String? keyGroup) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyGroup',
              lower: [],
              upper: [keyGroup],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyGroup',
              lower: [keyGroup],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyGroup',
              lower: [keyGroup],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyGroup',
              lower: [],
              upper: [keyGroup],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      assigmentIdEqualTo(int assigmentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'assigmentId',
        value: [assigmentId],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      assigmentIdNotEqualTo(int assigmentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assigmentId',
              lower: [],
              upper: [assigmentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assigmentId',
              lower: [assigmentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assigmentId',
              lower: [assigmentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assigmentId',
              lower: [],
              upper: [assigmentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      assigmentIdGreaterThan(
    int assigmentId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'assigmentId',
        lower: [assigmentId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      assigmentIdLessThan(
    int assigmentId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'assigmentId',
        lower: [],
        upper: [assigmentId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      assigmentIdBetween(
    int lowerAssigmentId,
    int upperAssigmentId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'assigmentId',
        lower: [lowerAssigmentId],
        includeLower: includeLower,
        upper: [upperAssigmentId],
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      motiveActivityEqualTo(MotiveActivity motiveActivity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'motiveActivity',
        value: [motiveActivity],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      motiveActivityNotEqualTo(MotiveActivity motiveActivity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'motiveActivity',
              lower: [],
              upper: [motiveActivity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'motiveActivity',
              lower: [motiveActivity],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'motiveActivity',
              lower: [motiveActivity],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'motiveActivity',
              lower: [],
              upper: [motiveActivity],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      motiveActivityGreaterThan(
    MotiveActivity motiveActivity, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'motiveActivity',
        lower: [motiveActivity],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      motiveActivityLessThan(
    MotiveActivity motiveActivity, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'motiveActivity',
        lower: [],
        upper: [motiveActivity],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      motiveActivityBetween(
    MotiveActivity lowerMotiveActivity,
    MotiveActivity upperMotiveActivity, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'motiveActivity',
        lower: [lowerMotiveActivity],
        includeLower: includeLower,
        upper: [upperMotiveActivity],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause> isSyncedEqualTo(
      bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterWhereClause>
      isSyncedNotEqualTo(bool isSynced) {
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
      assigmentIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assigmentId',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      assigmentIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assigmentId',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      assigmentIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assigmentId',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      assigmentIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assigmentId',
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
      collaboratordocumentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'collaboratordocumentId',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'collaboratordocumentId',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collaboratordocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collaboratordocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collaboratordocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collaboratordocumentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collaboratordocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collaboratordocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collaboratordocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collaboratordocumentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collaboratordocumentId',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      collaboratordocumentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collaboratordocumentId',
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
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'keyGroup',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'keyGroup',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyGroup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keyGroup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keyGroup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keyGroup',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'keyGroup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'keyGroup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keyGroup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keyGroup',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyGroup',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      keyGroupIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keyGroup',
        value: '',
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
      motiveActivityEqualTo(MotiveActivity value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motiveActivity',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveActivityGreaterThan(
    MotiveActivity value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motiveActivity',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveActivityLessThan(
    MotiveActivity value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motiveActivity',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      motiveActivityBetween(
    MotiveActivity lower,
    MotiveActivity upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motiveActivity',
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition> zoneEqualTo(
      UserZone value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zone',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      zoneGreaterThan(
    UserZone value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zone',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition>
      zoneLessThan(
    UserZone value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zone',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterFilterCondition> zoneBetween(
    UserZone lower,
    UserZone upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zone',
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByAssigmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigmentId', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByAssigmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigmentId', Sort.desc);
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
      sortByCollaboratordocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaboratordocumentId', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByCollaboratordocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaboratordocumentId', Sort.desc);
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByKeyGroup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyGroup', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByKeyGroupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyGroup', Sort.desc);
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByMotiveActivity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motiveActivity', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      sortByMotiveActivityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motiveActivity', Sort.desc);
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByZone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zone', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> sortByZoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zone', Sort.desc);
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByAssigmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigmentId', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByAssigmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigmentId', Sort.desc);
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
      thenByCollaboratordocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaboratordocumentId', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByCollaboratordocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaboratordocumentId', Sort.desc);
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByKeyGroup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyGroup', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByKeyGroupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyGroup', Sort.desc);
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByMotiveActivity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motiveActivity', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy>
      thenByMotiveActivityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motiveActivity', Sort.desc);
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

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByZone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zone', Sort.asc);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QAfterSortBy> thenByZoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zone', Sort.desc);
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

  QueryBuilder<ActivityModel, ActivityModel, QDistinct>
      distinctByAssigmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assigmentId');
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByClient(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'client', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityModel, ActivityModel, QDistinct>
      distinctByCollaboratordocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collaboratordocumentId',
          caseSensitive: caseSensitive);
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

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByKeyGroup(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keyGroup', caseSensitive: caseSensitive);
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

  QueryBuilder<ActivityModel, ActivityModel, QDistinct>
      distinctByMotiveActivity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motiveActivity');
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

  QueryBuilder<ActivityModel, ActivityModel, QDistinct> distinctByZone() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zone');
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

  QueryBuilder<ActivityModel, int, QQueryOperations> assigmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assigmentId');
    });
  }

  QueryBuilder<ActivityModel, String?, QQueryOperations> clientProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'client');
    });
  }

  QueryBuilder<ActivityModel, String?, QQueryOperations>
      collaboratordocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collaboratordocumentId');
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

  QueryBuilder<ActivityModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<ActivityModel, String?, QQueryOperations> keyGroupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keyGroup');
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

  QueryBuilder<ActivityModel, MotiveActivity, QQueryOperations>
      motiveActivityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motiveActivity');
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

  QueryBuilder<ActivityModel, UserZone, QQueryOperations> zoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zone');
    });
  }
}
