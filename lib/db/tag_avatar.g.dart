// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_avatar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTagAvatarCollection on Isar {
  IsarCollection<TagAvatar> get tagAvatars => this.collection();
}

const TagAvatarSchema = CollectionSchema(
  name: r'TagAvatar',
  id: 647774155188990036,
  properties: {
    r'avatarId': PropertySchema(
      id: 0,
      name: r'avatarId',
      type: IsarType.string,
    )
  },
  estimateSize: _tagAvatarEstimateSize,
  serialize: _tagAvatarSerialize,
  deserialize: _tagAvatarDeserialize,
  deserializeProp: _tagAvatarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'tags': LinkSchema(
      id: 971814925069048451,
      name: r'tags',
      target: r'Tag',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _tagAvatarGetId,
  getLinks: _tagAvatarGetLinks,
  attach: _tagAvatarAttach,
  version: '3.1.0+1',
);

int _tagAvatarEstimateSize(
  TagAvatar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.avatarId.length * 3;
  return bytesCount;
}

void _tagAvatarSerialize(
  TagAvatar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.avatarId);
}

TagAvatar _tagAvatarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TagAvatar();
  object.avatarId = reader.readString(offsets[0]);
  object.id = id;
  return object;
}

P _tagAvatarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tagAvatarGetId(TagAvatar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tagAvatarGetLinks(TagAvatar object) {
  return [object.tags];
}

void _tagAvatarAttach(IsarCollection<dynamic> col, Id id, TagAvatar object) {
  object.id = id;
  object.tags.attach(col, col.isar.collection<Tag>(), r'tags', id);
}

extension TagAvatarQueryWhereSort
    on QueryBuilder<TagAvatar, TagAvatar, QWhere> {
  QueryBuilder<TagAvatar, TagAvatar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TagAvatarQueryWhere
    on QueryBuilder<TagAvatar, TagAvatar, QWhereClause> {
  QueryBuilder<TagAvatar, TagAvatar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<TagAvatar, TagAvatar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterWhereClause> idBetween(
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
}

extension TagAvatarQueryFilter
    on QueryBuilder<TagAvatar, TagAvatar, QFilterCondition> {
  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> avatarIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> avatarIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatarId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> avatarIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatarId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> avatarIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> avatarIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'avatarId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> avatarIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'avatarId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> avatarIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'avatarId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> avatarIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'avatarId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> avatarIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarId',
        value: '',
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition>
      avatarIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatarId',
        value: '',
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> idBetween(
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
}

extension TagAvatarQueryObject
    on QueryBuilder<TagAvatar, TagAvatar, QFilterCondition> {}

extension TagAvatarQueryLinks
    on QueryBuilder<TagAvatar, TagAvatar, QFilterCondition> {
  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> tags(
      FilterQuery<Tag> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'tags');
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> tagsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterFilterCondition> tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'tags', lower, includeLower, upper, includeUpper);
    });
  }
}

extension TagAvatarQuerySortBy on QueryBuilder<TagAvatar, TagAvatar, QSortBy> {
  QueryBuilder<TagAvatar, TagAvatar, QAfterSortBy> sortByAvatarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarId', Sort.asc);
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterSortBy> sortByAvatarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarId', Sort.desc);
    });
  }
}

extension TagAvatarQuerySortThenBy
    on QueryBuilder<TagAvatar, TagAvatar, QSortThenBy> {
  QueryBuilder<TagAvatar, TagAvatar, QAfterSortBy> thenByAvatarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarId', Sort.asc);
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterSortBy> thenByAvatarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarId', Sort.desc);
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TagAvatar, TagAvatar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension TagAvatarQueryWhereDistinct
    on QueryBuilder<TagAvatar, TagAvatar, QDistinct> {
  QueryBuilder<TagAvatar, TagAvatar, QDistinct> distinctByAvatarId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatarId', caseSensitive: caseSensitive);
    });
  }
}

extension TagAvatarQueryProperty
    on QueryBuilder<TagAvatar, TagAvatar, QQueryProperty> {
  QueryBuilder<TagAvatar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TagAvatar, String, QQueryOperations> avatarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatarId');
    });
  }
}
