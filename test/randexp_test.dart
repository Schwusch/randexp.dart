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
