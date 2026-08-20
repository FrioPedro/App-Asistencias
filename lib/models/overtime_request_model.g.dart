// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overtime_request_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOvertimeRequestModelCollection on Isar {
  IsarCollection<OvertimeRequestModel> get overtimeRequestModels =>
      this.collection();
}

const OvertimeRequestModelSchema = CollectionSchema(
  name: r'OvertimeRequestModel',
  id: -4773019173707968068,
  properties: {
    r'collaborator': PropertySchema(
      id: 0,
      name: r'collaborator',
      type: IsarType.string,
    ),
    r'dedupKey': PropertySchema(
      id: 1,
      name: r'dedupKey',
      type: IsarType.string,
    ),
    r'end': PropertySchema(
      id: 2,
      name: r'end',
      type: IsarType.dateTime,
    ),
    r'justification': PropertySchema(
      id: 3,
      name: r'justification',
      type: IsarType.string,
    ),
    r'projectId': PropertySchema(
      id: 4,
      name: r'projectId',
      type: IsarType.long,
    ),
    r'start': PropertySchema(
      id: 5,
      name: r'start',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 6,
      name: r'status',
      type: IsarType.byte,
      enumMap: _OvertimeRequestModelstatusEnumValueMap,
    ),
    r'submittedAt': PropertySchema(
      id: 7,
      name: r'submittedAt',
      type: IsarType.dateTime,
    ),
    r'syncStatus': PropertySchema(
      id: 8,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _OvertimeRequestModelsyncStatusEnumValueMap,
    )
  },
  estimateSize: _overtimeRequestModelEstimateSize,
  serialize: _overtimeRequestModelSerialize,
  deserialize: _overtimeRequestModelDeserialize,
  deserializeProp: _overtimeRequestModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'projectId': IndexSchema(
      id: 3305656282123791113,
      name: r'projectId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'projectId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'submittedAt': IndexSchema(
      id: -3399775295061090955,
      name: r'submittedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'submittedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'syncStatus': IndexSchema(
      id: 8239539375045684509,
      name: r'syncStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncStatus',
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _overtimeRequestModelGetId,
  getLinks: _overtimeRequestModelGetLinks,
  attach: _overtimeRequestModelAttach,
  version: '3.1.0+1',
);

int _overtimeRequestModelEstimateSize(
  OvertimeRequestModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.collaborator;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.dedupKey.length * 3;
  bytesCount += 3 + object.justification.length * 3;
  return bytesCount;
}

void _overtimeRequestModelSerialize(
  OvertimeRequestModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.collaborator);
  writer.writeString(offsets[1], object.dedupKey);
  writer.writeDateTime(offsets[2], object.end);
  writer.writeString(offsets[3], object.justification);
  writer.writeLong(offsets[4], object.projectId);
  writer.writeDateTime(offsets[5], object.start);
  writer.writeByte(offsets[6], object.status.index);
  writer.writeDateTime(offsets[7], object.submittedAt);
  writer.writeByte(offsets[8], object.syncStatus.index);
}

OvertimeRequestModel _overtimeRequestModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OvertimeRequestModel(
    collaborator: reader.readStringOrNull(offsets[0]),
    end: reader.readDateTime(offsets[2]),
    justification: reader.readString(offsets[3]),
    projectId: reader.readLong(offsets[4]),
    start: reader.readDateTime(offsets[5]),
    status: _OvertimeRequestModelstatusValueEnumMap[
            reader.readByteOrNull(offsets[6])] ??
        OvertimeStatus.pending,
    submittedAt: reader.readDateTimeOrNull(offsets[7]),
    syncStatus: _OvertimeRequestModelsyncStatusValueEnumMap[
            reader.readByteOrNull(offsets[8])] ??
        SyncStatus.pending,
  );
  object.dedupKey = reader.readString(offsets[1]);
  object.id = id;
  return object;
}

P _overtimeRequestModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (_OvertimeRequestModelstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          OvertimeStatus.pending) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (_OvertimeRequestModelsyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _OvertimeRequestModelstatusEnumValueMap = {
  'pending': 0,
  'approved': 1,
  'rejected': 2,
};
const _OvertimeRequestModelstatusValueEnumMap = {
  0: OvertimeStatus.pending,
  1: OvertimeStatus.approved,
  2: OvertimeStatus.rejected,
};
const _OvertimeRequestModelsyncStatusEnumValueMap = {
  'pending': 0,
  'uploading': 1,
  'synced': 2,
  'failed': 3,
};
const _OvertimeRequestModelsyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.uploading,
  2: SyncStatus.synced,
  3: SyncStatus.failed,
};

Id _overtimeRequestModelGetId(OvertimeRequestModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _overtimeRequestModelGetLinks(
    OvertimeRequestModel object) {
  return [];
}

void _overtimeRequestModelAttach(
    IsarCollection<dynamic> col, Id id, OvertimeRequestModel object) {
  object.id = id;
}

extension OvertimeRequestModelByIndex on IsarCollection<OvertimeRequestModel> {
  Future<OvertimeRequestModel?> getByDedupKey(String dedupKey) {
    return getByIndex(r'dedupKey', [dedupKey]);
  }

  OvertimeRequestModel? getByDedupKeySync(String dedupKey) {
    return getByIndexSync(r'dedupKey', [dedupKey]);
  }

  Future<bool> deleteByDedupKey(String dedupKey) {
    return deleteByIndex(r'dedupKey', [dedupKey]);
  }

  bool deleteByDedupKeySync(String dedupKey) {
    return deleteByIndexSync(r'dedupKey', [dedupKey]);
  }

  Future<List<OvertimeRequestModel?>> getAllByDedupKey(
      List<String> dedupKeyValues) {
    final values = dedupKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'dedupKey', values);
  }

  List<OvertimeRequestModel?> getAllByDedupKeySync(
      List<String> dedupKeyValues) {
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

  Future<Id> putByDedupKey(OvertimeRequestModel object) {
    return putByIndex(r'dedupKey', object);
  }

  Id putByDedupKeySync(OvertimeRequestModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'dedupKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDedupKey(List<OvertimeRequestModel> objects) {
    return putAllByIndex(r'dedupKey', objects);
  }

  List<Id> putAllByDedupKeySync(List<OvertimeRequestModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'dedupKey', objects, saveLinks: saveLinks);
  }
}

extension OvertimeRequestModelQueryWhereSort
    on QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QWhere> {
  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhere>
      anyProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'projectId'),
      );
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhere>
      anySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'submittedAt'),
      );
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhere>
      anySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'syncStatus'),
      );
    });
  }
}

extension OvertimeRequestModelQueryWhere
    on QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QWhereClause> {
  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      projectIdEqualTo(int projectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'projectId',
        value: [projectId],
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      projectIdNotEqualTo(int projectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [],
              upper: [projectId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [projectId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [projectId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'projectId',
              lower: [],
              upper: [projectId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      projectIdGreaterThan(
    int projectId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'projectId',
        lower: [projectId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      projectIdLessThan(
    int projectId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'projectId',
        lower: [],
        upper: [projectId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      projectIdBetween(
    int lowerProjectId,
    int upperProjectId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'projectId',
        lower: [lowerProjectId],
        includeLower: includeLower,
        upper: [upperProjectId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      submittedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'submittedAt',
        value: [null],
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      submittedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'submittedAt',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      submittedAtEqualTo(DateTime? submittedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'submittedAt',
        value: [submittedAt],
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      submittedAtNotEqualTo(DateTime? submittedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'submittedAt',
              lower: [],
              upper: [submittedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'submittedAt',
              lower: [submittedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'submittedAt',
              lower: [submittedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'submittedAt',
              lower: [],
              upper: [submittedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      submittedAtGreaterThan(
    DateTime? submittedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'submittedAt',
        lower: [submittedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      submittedAtLessThan(
    DateTime? submittedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'submittedAt',
        lower: [],
        upper: [submittedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      submittedAtBetween(
    DateTime? lowerSubmittedAt,
    DateTime? upperSubmittedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'submittedAt',
        lower: [lowerSubmittedAt],
        includeLower: includeLower,
        upper: [upperSubmittedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      syncStatusEqualTo(SyncStatus syncStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncStatus',
        value: [syncStatus],
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      syncStatusNotEqualTo(SyncStatus syncStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      syncStatusGreaterThan(
    SyncStatus syncStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'syncStatus',
        lower: [syncStatus],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      syncStatusLessThan(
    SyncStatus syncStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'syncStatus',
        lower: [],
        upper: [syncStatus],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      syncStatusBetween(
    SyncStatus lowerSyncStatus,
    SyncStatus upperSyncStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'syncStatus',
        lower: [lowerSyncStatus],
        includeLower: includeLower,
        upper: [upperSyncStatus],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
      dedupKeyEqualTo(String dedupKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dedupKey',
        value: [dedupKey],
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterWhereClause>
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
}

extension OvertimeRequestModelQueryFilter on QueryBuilder<OvertimeRequestModel,
    OvertimeRequestModel, QFilterCondition> {
  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> collaboratorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'collaborator',
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> collaboratorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'collaborator',
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> collaboratorEqualTo(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> collaboratorGreaterThan(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> collaboratorLessThan(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> collaboratorBetween(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> collaboratorStartsWith(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> collaboratorEndsWith(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
          QAfterFilterCondition>
      collaboratorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collaborator',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
          QAfterFilterCondition>
      collaboratorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collaborator',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> collaboratorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collaborator',
        value: '',
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> collaboratorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collaborator',
        value: '',
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> dedupKeyEqualTo(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> dedupKeyGreaterThan(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> dedupKeyLessThan(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> dedupKeyBetween(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> dedupKeyStartsWith(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> dedupKeyEndsWith(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
          QAfterFilterCondition>
      dedupKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dedupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
          QAfterFilterCondition>
      dedupKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dedupKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> dedupKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dedupKey',
        value: '',
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> dedupKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dedupKey',
        value: '',
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> endEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'end',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> endGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'end',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> endLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'end',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> endBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'end',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> justificationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'justification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> justificationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'justification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> justificationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'justification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> justificationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'justification',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> justificationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'justification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> justificationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'justification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
          QAfterFilterCondition>
      justificationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'justification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
          QAfterFilterCondition>
      justificationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'justification',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> justificationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'justification',
        value: '',
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> justificationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'justification',
        value: '',
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> projectIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectId',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> projectIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectId',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> projectIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectId',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> projectIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> startEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> startGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> startLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> startBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'start',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> statusEqualTo(OvertimeStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> statusGreaterThan(
    OvertimeStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> statusLessThan(
    OvertimeStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> statusBetween(
    OvertimeStatus lower,
    OvertimeStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> submittedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'submittedAt',
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> submittedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'submittedAt',
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> submittedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> submittedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> submittedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> submittedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'submittedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> syncStatusGreaterThan(
    SyncStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> syncStatusLessThan(
    SyncStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel,
      QAfterFilterCondition> syncStatusBetween(
    SyncStatus lower,
    SyncStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension OvertimeRequestModelQueryObject on QueryBuilder<OvertimeRequestModel,
    OvertimeRequestModel, QFilterCondition> {}

extension OvertimeRequestModelQueryLinks on QueryBuilder<OvertimeRequestModel,
    OvertimeRequestModel, QFilterCondition> {}

extension OvertimeRequestModelQuerySortBy
    on QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QSortBy> {
  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByCollaborator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaborator', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByCollaboratorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaborator', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByDedupKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupKey', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByDedupKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupKey', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByJustification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'justification', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByJustificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'justification', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }
}

extension OvertimeRequestModelQuerySortThenBy
    on QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QSortThenBy> {
  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByCollaborator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaborator', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByCollaboratorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaborator', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByDedupKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupKey', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByDedupKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupKey', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByJustification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'justification', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByJustificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'justification', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByProjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectId', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }
}

extension OvertimeRequestModelQueryWhereDistinct
    on QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QDistinct> {
  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QDistinct>
      distinctByCollaborator({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collaborator', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QDistinct>
      distinctByDedupKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dedupKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QDistinct>
      distinctByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'end');
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QDistinct>
      distinctByJustification({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'justification',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QDistinct>
      distinctByProjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectId');
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QDistinct>
      distinctByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'start');
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QDistinct>
      distinctBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'submittedAt');
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeRequestModel, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }
}

extension OvertimeRequestModelQueryProperty on QueryBuilder<
    OvertimeRequestModel, OvertimeRequestModel, QQueryProperty> {
  QueryBuilder<OvertimeRequestModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OvertimeRequestModel, String?, QQueryOperations>
      collaboratorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collaborator');
    });
  }

  QueryBuilder<OvertimeRequestModel, String, QQueryOperations>
      dedupKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dedupKey');
    });
  }

  QueryBuilder<OvertimeRequestModel, DateTime, QQueryOperations> endProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'end');
    });
  }

  QueryBuilder<OvertimeRequestModel, String, QQueryOperations>
      justificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'justification');
    });
  }

  QueryBuilder<OvertimeRequestModel, int, QQueryOperations>
      projectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectId');
    });
  }

  QueryBuilder<OvertimeRequestModel, DateTime, QQueryOperations>
      startProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'start');
    });
  }

  QueryBuilder<OvertimeRequestModel, OvertimeStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<OvertimeRequestModel, DateTime?, QQueryOperations>
      submittedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'submittedAt');
    });
  }

  QueryBuilder<OvertimeRequestModel, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }
}
