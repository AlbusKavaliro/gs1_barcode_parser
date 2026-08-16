import 'package:gs1_barcode_parser/gs1_barcode_parser.dart';
import 'package:gs1_barcode_parser/src/ai.dart';
import 'package:gs1_barcode_parser/src/exception.dart';
import 'package:test/test.dart';

main() {
  group('AI code/regExpString consistency', () {
    final aiCodesToVerify = [
      '3120',
      '3143',
      '3144',
      '3145',
      '3150',
      '3163',
      '3164',
      '3165',
      '3204',
      '3205',
      '3212',
      '3215',
      '3235',
      '3300',
      '3463',
      '98',
    ];

    for (final aiCode in aiCodesToVerify) {
      test('AI $aiCode: code field matches map key', () {
        final ai = AI.AIS[aiCode];
        expect(ai, isNotNull);
        expect(ai!.code, equals(aiCode));
      });

      test('AI $aiCode: regExpString matches code', () {
        final ai = AI.AIS[aiCode];
        final String data = aiCode.length == 4
            ? '0' * 6
            : 'A' * 20;
        final sample = '$aiCode$data';
        expect(ai!.regExp.hasMatch(sample), isTrue,
            reason:
                "regExpString '${ai.regExp.pattern}' should match '$sample' for AI $aiCode");
      });
    }
  });

  group('Parse fixed-length measure AIs', () {
    test('3143 parse succeeds', () {
      final parser = GS1BarcodeParser.defaultParser();
      final result = parser.parse('3143005250');
      expect(result.hasAI('3143'), true);
      expect(result.getAIRawData('3143'), '005250');
    });

    test('3150 parse succeeds', () {
      final parser = GS1BarcodeParser.defaultParser();
      final result = parser.parse('3150005250');
      expect(result.hasAI('3150'), true);
      expect(result.getAIRawData('3150'), '005250');
    });

    test('3163 parse succeeds', () {
      final parser = GS1BarcodeParser.defaultParser();
      final result = parser.parse('3163005250');
      expect(result.hasAI('3163'), true);
      expect(result.getAIRawData('3163'), '005250');
    });

    test('3204 parse succeeds', () {
      final parser = GS1BarcodeParser.defaultParser();
      final result = parser.parse('3204005250');
      expect(result.hasAI('3204'), true);
      expect(result.getAIRawData('3204'), '005250');
    });

    test('3235 parse succeeds', () {
      final parser = GS1BarcodeParser.defaultParser();
      final result = parser.parse('3235005250');
      expect(result.hasAI('3235'), true);
      expect(result.getAIRawData('3235'), '005250');
    });

    test('3300 parse succeeds', () {
      final parser = GS1BarcodeParser.defaultParser();
      final result = parser.parse('3300005250');
      expect(result.hasAI('3300'), true);
      expect(result.getAIRawData('3300'), '005250');
    });

    test('3463 parse succeeds', () {
      final parser = GS1BarcodeParser.defaultParser();
      final result = parser.parse('3463005250');
      expect(result.hasAI('3463'), true);
      expect(result.getAIRawData('3463'), '005250');
    });
  });

  group('Parse 2-digit variable-length AI 98', () {
    test('98 parse succeeds', () {
      final parser = GS1BarcodeParser.defaultParser();
      final result = parser.parse('98TESTDATA123');
      expect(result.hasAI('98'), true);
      expect(result.getAIRawData('98'), 'TESTDATA123');
    });
  });

  group('Issue 16 scenario - barcode with 3143', () {
    test('Barcode with 3143 no longer throws data format mismatch', () {
      final parser = GS1BarcodeParser.defaultParser();
      final barcode = '010020406700035931430052503700100';
      final result = parser.parse(barcode);
      expect(result.hasAI('01'), true);
      expect(result.hasAI('3143'), true);
      expect(result.hasAI('37'), true);
      expect(result.getAIRawData('3143'), '005250');
    });
  });
}
