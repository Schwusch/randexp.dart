import 'package:randexp/randexp.dart';

void main() {
  final randexp = RandExp(
    RegExp('(foo|bar).*'),
    maxRepetition: 50,
  ).gen();

  print(randexp);
}
