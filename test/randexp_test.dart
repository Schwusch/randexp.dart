import 'dart:math';

import 'package:randexp/randexp.dart';
import 'package:test/test.dart';

// This is a simple "good enough" PRNG.
final initialSeed =
    Random().nextDouble() * pow(2, 32) + DateTime.now().millisecondsSinceEpoch;

int Function(int, int) prng() {
  var seed = initialSeed;
  return (int a, int b) {
    seed = pow(seed, 2) % 94906249;
    return seed.floor() % (1 + b - a) + a;
  };
}

void genTest(
  String description,
  String regexp, {
  bool? multiLine,
  bool? caseSensitive,
  bool? bad,
}) {
  test(description, () {
    final re = RegExp(
      regexp,
      multiLine: multiLine ?? false,
      caseSensitive: caseSensitive ?? true,
    );
    final randStr = RandExp(re).gen();

    expect(
      re.firstMatch(randStr),
      bad ?? false ? isNull : isNotNull,
    );
  });
}

void main() {
  test(
      'Modify PRNG - Should generate the same string with the same the PRNG seed',
      () {
    final aRE = RandExp(RegExp('.{100}'), randInt: prng());
    final a = aRE.gen();

    final bRE = RandExp(RegExp('.{100}'), randInt: prng());
    final b = bRE.gen();

    expect(a, equals(b));
  });

  test('Should generate infinite repetitionals with new max', () {
    final randStr = RandExp(RegExp('.*'), maxRepetition: 0).gen();
    expect(randStr, equals(''));
  });

  genTest(
    'Ignore the case of alphabetic characters',
    'hey there',
    caseSensitive: false,
  );

  genTest(
      r'Multiline mode. Causes ^ to match beginning of line or beginning of string. Causes $ to match end of line or end of string.',
      r'hip$\nhop',
      multiLine: true);

  genTest(
    'Only matches the beginning of a string.',
    r'^The',
  );

  genTest(
    'Only matches the end of a string.',
    r'and$',
  );

  genTest(
    'Matches any word boundary (test characters must exist at the beginning or end of a word within the string)',
    r'ly\b',
  );

  genTest(
    'Matches any non-word boundary.',
    'm\Bore',
  );

  for (final re in ['a^', r'$c']) {
    genTest(
      'A string that matches "$re" does not exist.',
      re,
      multiLine: true,
      bad: true,
    );
  }

  for (final re in ['b^', r'$d', r'e\bf', r'\Bg']) {
    genTest(
      'A string that matches "$re" does not exist.',
      re,
      bad: true,
    );
  }

  genTest(
    r'All characters except []{}^$.|?*+() match a single instance of themselves.',
    'a',
  );

  genTest(
    'A backslash escapes special characters to suppress their special meaning.',
    r'\+',
  );

  genTest('Matches NUL character.', r'nully: \0');

  genTest('Matches a new line character.', r'a new\nline');

  genTest('Matches a form feed character.', r'\f');

  genTest('Matches a tab character.', r'col1\tcol2\tcol3');

  genTest('Matches a vertical tab character.', r'row1\vrow2');

  genTest('Matches a backspace.', r'something[\b]');

  genTest(
      'Matches the ASCII character expressed by the octal number XXX.', r'\50');

  genTest(
      'Matches the ASCII character expressed by the hex number XX.', r'\xA9');

  genTest(
      'Matches the ASCII character expressed by the UNICODE XXXX.', r'\u00A3');

  for (final re in [
    r'[abcD!]',
    r'[a-z]',
    r'[0-4]',
    r'[a-zA-Z0-9]',
    r'[\w]',
    r'[\d]',
    r'[\s]',
    r'[\W]',
    r'[\D]',
    r'[\S]',
  ]) {
    genTest('Matches any one character enclosed in $re.', re);
  }

  for (final re in [
    r'[^AN]BC',
    r'[^\w]',
    r'[^\d]',
    r'[^\s]',
    r'[^\W]',
    r'[^\D]',
    r'[^\S]',
  ]) {
    genTest('Matches any one characer not enclosed in $re', re);
  }

  for (final re in [r'[^\W\w]', r'[^\D\d]', r'[^\S\s]', r'[^\W\w]']) {
    genTest('A string that matches $re does not exist', re, bad: true);
  }

  genTest(
    'Matches any character except newline or another Unicode line terminator.',
    r'b.t',
  );

  genTest(
    'Matches any alphanumeric character including the underscore. Equivalent to [a-zA-Z0-9].',
    r'\w',
  );

  genTest(
    'Matches any single non-word character. Equivalent to [^a-zA-Z0-9].',
    r'\W',
  );

  genTest('Matches any single digit. Equivalent to [0-9].', r'\d\d\d\d');

  genTest('Matches any non-digit, Equivalent to [^0-9].', r'\D');

  genTest(
    'Matches any single space character. Equivalent to [ \\f\\n\\r\\t\\v\\u00A0\\u1680\\u180e\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2007\\u2008\\u2009\\u200a\\u2028\\u2029\\u2028\\u2029\\u202f\\u205f\\u3000].',
    r'in\sbetween',
  );

  genTest(
    'Matches any single non-sace character. Equivalent to [^ \\f\\n\\r\\t\\v\\u00A0\\u1680\\u180e\\u2000\\u2001\\u2002\\u2003\\u2004\\u2005\\u2006\\u2007\\u2008\\u2009\\u200a\\u2028\\u2029\\u2028\\u2029\\u202f\\u205f\\u3000].',
    r'\S',
  );

  genTest('Matches exactly x occurrences of a regular expression.', r'\d{5}');

  genTest('Matches x or more occurrences of a regular expression.', r'\s{2,}');

  genTest(
    'Matches x to y number of occurrences of a regular expression.',
    r'\d{2,4}',
  );

  genTest('Matches zero or one occurrences. Equivalent to {0,1}.', r'a\s?b');

  genTest('Matches zero or more occurrences. Equivalent to {0,}.', r'we*');

  genTest('Matches one ore more occurrences. Equivalent to {1,}.', r'fe+d');

  genTest(
    'Grouping characters together to create a clause. May be nested. Also captures the desired subpattern.',
    r'(abc)+(def)',
  );

  genTest('Matches x but does not capture it.', r'(?:.d){2}');

  genTest(
      'Matches only one clause on either side of the pipe.', r'forever|young');

  for (final re in [
    r'(\w+)\s+\1',
    r'(a)(\2\1)',
    r'(a|b){5}\1',
    r'(a)(b)\1\2'
  ]) {
    genTest(
      '"\\x" (where x is a number from 1 to 9) when added to the end of a regular expression pattern allows you to back reference a subpattern within the pattern, so the value of the subpatterns is remembered and used as part of the matching.',
      re,
    );
  }
}
