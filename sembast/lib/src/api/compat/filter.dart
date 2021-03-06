import 'package:sembast/src/api/compat/record.dart';
import 'package:sembast/src/api/field.dart';
import 'package:sembast/src/api/filter.dart';
import 'package:sembast/src/filter_impl.dart';
import 'package:sembast/src/record_snapshot_impl.dart';
// ignore_for_file: public_member_api_docs

/// @deprecated v2
@deprecated
class CompositeFilter extends Filter {
  /// Deprecated.
  bool isAnd; // if false it is OR
  /// Deprecated.
  bool get isOr => !isAnd;

  /// Deprecated.
  List<Filter> filters;

  /// Deprecated.
  CompositeFilter.or(this.filters) : isAnd = false;

  /// Deprecated.
  CompositeFilter.and(this.filters) : isAnd = true;

  @override
  bool match(Record record) {
    if (!super.match(record)) {
      return false;
    }

    for (var filter in filters) {
      if (filter.match(record)) {
        if (isOr) {
          return true;
        }
      } else {
        if (isAnd) {
          return false;
        }
      }
    }
    // if isOr, nothing has matches so far
    return isAnd;
  }

  @override
  String toString() {
    return filters.join(' ${isAnd ? 'AND' : 'OR'} ');
  }
}

/// @deprecated v2
@deprecated
class FilterPredicate extends Filter {
  String field;
  FilterOperation operation;
  var value;

  FilterPredicate(this.field, this.operation, this.value) : super();

  @override
  bool match(Record record) {
    if (record.deleted) {
      return false;
    }

    int _safeCompare(dynamic value1, dynamic value2) {
      try {
        if (value1 is Comparable && value2 is Comparable) {
          return Comparable.compare(value1, value2);
        }
      } catch (_) {}
      return null;
    }

    bool _lessThan(dynamic value1, dynamic value2) {
      var cmp = _safeCompare(value1, value2);
      return cmp != null && cmp < 0;
    }

    bool _greaterThan(dynamic value1, dynamic value2) {
      var cmp = _safeCompare(value1, value2);
      return cmp != null && cmp > 0;
    }

    bool _matches(dynamic value1, dynamic value2) {
      final fieldValue = value1 as String;
      final regExp = value2 as RegExp;
      // a null value is never ok (use isNotNulllboth null is ok
      if (fieldValue == null) {
        return false;
      }
      return regExp.hasMatch(fieldValue);
    }

    dynamic recordValue = (record as RecordSnapshotMixin).value;
    if (!canMatch(field, recordValue)) {
      return false;
    }

    // empty record or not map? refuse
    if ((!(record.value is Map)) &&
        (field != Field.value && field != Field.key)) {
      return false;
    }

    var fieldValue = record[field];
    switch (operation) {
      case FilterOperation.equals:
        return fieldValue == value;
      case FilterOperation.notEquals:
        return fieldValue != value;
      case FilterOperation.lessThan:
        // return _safeCompare(record[field], value) < 0;
        return _lessThan(fieldValue, value);
      case FilterOperation.lessThanOrEquals:
        return _lessThan(fieldValue, value) || fieldValue == value;
      // return _safeCompare(record[field], value) <= 0;
      case FilterOperation.greaterThan:
        return _greaterThan(fieldValue, value);
      // return _safeCompare(record[field], value) > 0;
      case FilterOperation.greaterThanOrEquals:
        return _greaterThan(fieldValue, value) || fieldValue == value;
      // return _safeCompare(record[field], value) >= 0;
      case FilterOperation.inList:
        return (value as List).contains(record[field]);
      case FilterOperation.matches:
        return _matches(fieldValue, value);

      default:
        throw '${this} not supported';
    }
  }

  @override
  String toString() {
    return '${field} ${operation} ${value}';
  }
}

/// @deprecated v2
@deprecated
class FilterOperation {
  final int value;

  const FilterOperation._(this.value);

  static const FilterOperation equals = FilterOperation._(1);
  static const FilterOperation notEquals = FilterOperation._(2);
  static const FilterOperation lessThan = FilterOperation._(3);
  static const FilterOperation lessThanOrEquals = FilterOperation._(4);
  static const FilterOperation greaterThan = FilterOperation._(5);
  static const FilterOperation greaterThanOrEquals = FilterOperation._(6);
  static const FilterOperation inList = FilterOperation._(7);
  static const FilterOperation matches = FilterOperation._(8);

  @Deprecated('Use equals instead')
  static const FilterOperation EQUAL = equals;
  @Deprecated('Use notEquals instead')
  static const FilterOperation NOT_EQUAL = notEquals;
  @Deprecated('Use lessThan instead')
  static const FilterOperation LESS_THAN = lessThan;
  @Deprecated('Use lessThanOrEquals instead')
  static const FilterOperation LESS_THAN_OR_EQUAL = lessThanOrEquals;
  @Deprecated('Use greaterThan instead')
  static const FilterOperation GREATER_THAN = greaterThan;
  @Deprecated('Use greaterThanOrEquals instead')
  static const FilterOperation GREATER_THAN_OR_EQUAL = greaterThanOrEquals;
  @Deprecated('Use inList instead')
  static const FilterOperation IN = inList;

  @override
  String toString() {
    switch (this) {
      case FilterOperation.equals:
        return '=';
      case FilterOperation.notEquals:
        return '!=';
      case FilterOperation.lessThan:
        return '<';
      case FilterOperation.lessThanOrEquals:
        return '<=';
      case FilterOperation.greaterThan:
        return '>';
      case FilterOperation.greaterThanOrEquals:
        return '>=';
      case FilterOperation.inList:
        return 'IN';
      case FilterOperation.matches:
        return 'MATCHES';
      default:
        throw '${this} not supported';
    }
  }
}

/// @deprecated v2
@deprecated
class ByKeyFilter extends Filter {
  var key;

  ByKeyFilter(this.key) : super();

  @override
  bool match(Record record) {
    if (!super.match(record)) {
      return false;
    }
    return record.key == key;
  }

  @override
  String toString() {
    return '${Field.key} = ${key}';
  }
}
