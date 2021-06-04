import 'dart:math';

import 'package:discontinuous_range/discontinuous_range.dart';
import 'package:ret/ret.dart';

class RandExp {
  final RegExp _regexp;
  final Root _tokens;

  /// When a repetitional token has its max set to Infinite,
  /// randexp won't actually generate a random amount between min and Infinite
  /// instead it will see Infinite as min + 100
  final int _maxRepetition;

  /// Default range of characters to generate from.
  late final DRange _defaultRange;

  final _groupNumbers = <Tokens, int>{};

  final int Function(int a, int b) randInt;

  RandExp(
    this._regexp, {
    int maxRepetition = 100,
    DRange? range,
    this.randInt = _randInt,
  })  : _tokens = tokenizer(_regexp.pattern),
        _maxRepetition = maxRepetition {
    _defaultRange = range ?? DRange(32, 126);
  }

  /// Randomly selects and returns a [List] of [Token]s from the array.
  List<Token> _randSelectTokens(List<List<Token>> arr) =>
      arr[randInt(0, arr.length - 1)];

  /// Randomly selects and returns an [int] from the range.
  int _randSelectRange(DRange range) =>
      range.index(randInt(0, range.length - 1));

  /// If code is alphabetic, converts to other case.
  /// If not alphabetic, returns back code.
  int _toOtherCase(int code) =>
      code +
      (97 <= code && code <= 122
          ? -32
          : 65 <= code && code <= 90
              ? 32
              : 0);

  DRange _expand(SetToken token) {
    if (token is Char) {
      return DRange(token.value);
    } else if (token is Range) {
      return DRange(token.from, token.to);
    } else if (token is Set) {
      final drange = DRange();
      for (var i = 0; i < token.set.length; i++) {
        final subrange = _expand(token.set[i]);
        drange.add(subrange);
        if (!_regexp.isCaseSensitive) {
          for (var j = 0; j < subrange.length; j++) {
            final code = subrange.index(j);
            final otherCaseCode = _toOtherCase(code);

            if (code != otherCaseCode) {
              drange.add(DRange(otherCaseCode));
            }
          }
        }
      }

      if (token.not) {
        return _defaultRange.clone()..subtract(drange);
      } else {
        return _defaultRange.clone()..intersect(drange);
      }
    }

    throw Exception('Unknown SetToken: $token');
  }

  /// Generate random string modeled after given tokens.
  String _gen(Tokens token, List<String?> groups) {
    switch (token.type) {
      case Types.ROOT:
      case Types.GROUP:
        final tkn = token as RootOrGroup;
        final groupNumber = groups.length;
        if (tkn is Group) {
          if (tkn.followedBy != null || tkn.notFollowedBy != null) {
            // Ignore lookaheads for now.
            return '';
          }

          // Insert placeholder until group string is generated.
          if (tkn.remember && _groupNumbers[token] == null) {
            _groupNumbers[token] = groupNumber;
            groups.add(null);
          }
        }

        var stack = tkn.options != null
            ? _randSelectTokens(tkn.options!)
            : tkn.stack ?? [];
        var str = '';

        for (var i = 0; i < stack.length; i++) {
          str += _gen(stack[i], groups);
        }

        if (tkn is Group && tkn.remember) {
          groups[groupNumber] = str;
        }

        return str;

      case Types.POSITION:
        // Do nothing for now
        return '';

      case Types.SET:
        final expandedSet = _expand(token as SetToken);
        if (expandedSet.length == 0) return '';
        return String.fromCharCode(_randSelectRange(expandedSet));

      case Types.RANGE:
        // Do nothing for now
        return '';

      case Types.REPETITION:
        // Randomly generate number between min and max.
        token as Repetition;
        final n = randInt(token.min,
            token.max == -1 ? token.min + _maxRepetition : token.max);
        var str = '';

        for (var i = 0; i < n; i++) {
          str += _gen(token.value, groups);
        }

        return str;

      case Types.REFERENCE:
        token as Reference;
        return groups[token.value - 1] ?? '';

      case Types.CHAR:
        token as Char;
        final code = !_regexp.isCaseSensitive && Random().nextBool()
            ? _toOtherCase(token.value)
            : token.value;
        return String.fromCharCode(code);
    }
  }

  /// Generates the random string.
  String gen() => _gen(_tokens, []);

  /// Randomly generates and returns a number between a and b (inclusive).
  static int _randInt(int a, int b) =>
      a + (Random().nextDouble() * (1 + b - a)).floor();
}

extension RegExpExtensions on RegExp {
  String get randomMatchingString => RandExp(this).gen();
}
