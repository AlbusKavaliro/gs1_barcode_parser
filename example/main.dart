import 'package:gs1_barcode_parser/gs1_barcode_parser.dart';

main() {
  final String barcode =
      ']C101040123456789011715012910ABC1233932971471131030005253922471142127649716';
  // GS1 Digital Link official examples
  final digitalLink1 = 'https://id.gs1.org/01/09506000134352/21/12345';
  final digitalLink2 =
      'https://id.gs1.org/01/09506000134376/10/ABC/21/12345?17=231231';
  final digitalLink3 =
      'https://example.com/some/path/01/12345678901231/21/ABC?10=LOT123';

  final parser = GS1BarcodeParser.defaultParser();

  final result = parser.parse(barcode);
  print(result);

  print('GS1 Digital Link Example 1:');
  print(parser.parse(digitalLink1));

  print('\nGS1 Digital Link Example 2:');
  print(parser.parse(digitalLink2));

  print('\nGS1 Digital Link Example 3:');
  print(parser.parse(digitalLink3));
}
