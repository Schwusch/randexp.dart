# randexp.dart

A Dart port of [randexp.js](https://github.com/fent/randexp.js).

randexp will generate a random string that matches a given RegExp Javascript object.

# Usage

```dart
import 'package:randexp/randexp.dart';

void main() {
  // supports grouping and piping
  RandExp(RegExp(r'hello+ (world|to you)')).gen();
  // => hellooooooooooooooooooo world

  // sets and ranges and references
  RandExp(RegExp(r'<([a-z]\w{0,20})>foo<\1>')).gen();
  // => <m5xhdg>foo<m5xhdg>

  // wildcard
  RandExp(RegExp(r'random stuff: .+')).gen();
  // => random stuff: l3m;Hf9XYbI [YPaxV>U*4-_F!WXQh9>;rH3i l!8.zoh?[utt1OWFQrE ^~8zEQm]~tK

  // ignore case
  RandExp(RegExp(r'xxx xtreme dragon warrior xxx', caseSensitive: false)).gen();
  // => xxx xtReME dRAGON warRiOR xXX
}
```

# Default Range

The default generated character range includes printable [ASCII characters between 32-126](https://ascii.cl/).

```dart
RandExp(RegExp('random stuff: .+'), range: DRange(0, 65535));
// => random stuff: 湐箻ໜ䫴␩⶛㳸長���邓蕲뤀쑡篷皇硬剈궦佔칗븛뀃匫鴔事좍ﯣ⭼ꝏ䭍詳蒂䥂뽭
```

# Custom PRNG

The default randomness is provided by the `dart:math` default `Random` class. If you need to use a seedable or cryptographic PRNG, you can override it with the constructor argument `RandExp(randInt: customRandInt)`. The `randInt` function should accept an inclusive range and return a randomly selected number within that range.

# Infinite Repetitionals

Repetitional tokens such as *, +, and {3,} have an infinite max range. In this case, randexp looks at its min and adds 100 to it to get a useable max value. If you want to use another int other than 100 you can change the max with the constructor argument `maxRepetition`.

```dart
RandExp(RegExp('no{1,}'), maxRepetition: 1000000);
```

# Bad Regular Expressions

There are some regular expressions which can never match any string.

- Ones with badly placed positionals such as `a^` and `RegExp(r'$c', multiLine: true)`. Randexp will ignore positional tokens.

- Back references to non-existing groups like `(a)\1\2`. Randexp will ignore those references, returning an empty string for them. If the group exists only after the reference is used such as in `\1 (hey)`, it will too be ignored.

- Custom negated character sets with two sets inside that cancel each other out. Example: `[^\w\W]`. If you give this to randexp, it will return an empty string for this set since it can't match anything.
