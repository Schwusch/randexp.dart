import 'package:randexp/randexp.dart';
import 'dart:math';

void main() {
  // supports grouping and piping
  RandExp(RegExp(r'hello+ (world|to you)')).gen();
  // => hellooooooooooooooooooo world

  // sets and ranges and references
  RandExp(RegExp(r'<([a-z]\w{0,20})>foo<\1>')).gen();
  // => <m5xhdg>foo<m5xhdg>

  // wildcard
  RandExp(RegExp('random stuff: .+')).gen();
  // => random stuff: l3m;Hf9XYbI [YPaxV>U*4-_F!WXQh9>;rH3i l!8.zoh?[utt1OWFQrE ^~8zEQm]~tK

  // ignore case
  RandExp(RegExp('xxx xtreme dragon warrior xxx', caseSensitive: false)).gen();
  // => xxx xtReME dRAGON warRiOR xXX

  // increase range of characters
  RandExp(RegExp('random stuff: .+'), range: DRange(0, 65535));
  // => random stuff: 湐箻ໜ䫴␩⶛㳸長���邓蕲뤀쑡篷皇硬剈궦佔칗븛뀃匫鴔事좍ﯣ⭼ꝏ䭍詳蒂䥂뽭

  // increase max repetition for infinite repetitionals
  RandExp(RegExp('no{1,}'), maxRepetition: 1000000);

  // change random character generator e.g. for unit tests
  // this is a simple "good enough" PRNG for repeatability.
  int Function(int, int) prng() {
    var seed = 15.0;
    return (int a, int b) {
      seed = pow(seed, 2) % 94906249;
      return seed.floor() % (1 + b - a) + a;
    };
  }

  RandExp(RegExp('.{5}'), randInt: prng()).gen();
  // always generates the same string => u'3iE
}
