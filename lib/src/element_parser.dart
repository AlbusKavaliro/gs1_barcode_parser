import 'dart:math';

import 'package:gs1_barcode_parser/src/ai.dart';
import 'package:gs1_barcode_parser/src/barcode_parser.dart';

import 'exception.dart';

class ParsedElementWithRest {
  final GS1ParsedElement element;
  final String rest;

  const ParsedElementWithRest({
    required this.element,
    required this.rest,
  });
}

abstract class GS1ElementParser {
  ParsedElementWithRest call(String data, AI ai, GS1BarcodeParserConfig config);

  GS1ParsedElement parseFromParts(
      String aiCode, String value, AI ai, GS1BarcodeParserConfig config);

  bool verify(String elementData, AI ai) {
    return ai.regExp.hasMatch(elementData);
  }

  double parseFloatingPoint(String numberPart, int numberOfDecimals) {
    final offset = numberPart.length - numberOfDecimals;
    final numberPartFloat =
        numberPart.substring(0, offset) + '.' + numberPart.substring(offset);
    return double.parse(numberPartFloat);
  }

  String getRest(String data, int offset, GS1BarcodeParserConfig config) {
    var result = data.length < offset ? '' : data.substring(offset);
    while (result.startsWith(config.groupSeparator)) {
      result = result.substring(1);
    }
    return result;
  }
}

class GS1DateParser extends GS1ElementParser {
  @override
  ParsedElementWithRest call(
      String data, AI ai, GS1BarcodeParserConfig config) {
    final offset = ai.code.length + ai.fixLength;
    final elementStr = data.substring(0, min(offset, data.length));

    if (!verify(elementStr, ai)) {
      throw GS1ParseException(
          message: 'Data format mismatch ${ai.regExp} for AI ${ai.code}');
    }

    final elementDate = elementStr.substring(ai.code.length);
    final element = parseFromParts(ai.code, elementDate, ai, config);

    final rest = getRest(data, offset, config);
    return ParsedElementWithRest(element: element, rest: rest);
  }

  @override
  GS1ParsedElement parseFromParts(
      String aiCode, String value, AI ai, GS1BarcodeParserConfig config) {
    if (value.length != ai.fixLength) {
      throw GS1ParseException(
          message:
              'Invalid date length for AI $aiCode: expected ${ai.fixLength}, got ${value.length}');
    }

    if (value.length < 6) {
      throw GS1ParseException(message: 'Date value too short for AI $aiCode');
    }

    var year = _year2ToYear4(int.parse(value.substring(0, 2), radix: 10));
    final month = int.parse(value.substring(2, 4), radix: 10);
    final day = int.parse(value.substring(4), radix: 10);

    return GS1ParsedElement<DateTime>(
      rawData: value,
      aiCode: aiCode,
      data: DateTime(year, month, day),
    );
  }

  _year2ToYear4(int year) {
    return year > 50 ? year + 1900 : year = year + 2000;
  }
}

class GS1DateTimeParser extends GS1ElementParser {
  @override
  ParsedElementWithRest call(
      String data, AI ai, GS1BarcodeParserConfig config) {
    final posOfGS = data.indexOf(config.groupSeparator);
    final offset = posOfGS == -1 ? data.length : posOfGS;
    final elementStr = data.substring(0, offset);

    if (!verify(elementStr, ai)) {
      throw GS1ParseException(
          message: 'Data format mismatch ${ai.regExp} for AI ${ai.code}');
    }

    final rawData = elementStr.substring(ai.code.length);
    final element = parseFromParts(ai.code, rawData, ai, config);

    final rest = getRest(data, offset, config);
    return ParsedElementWithRest(element: element, rest: rest);
  }

  @override
  GS1ParsedElement parseFromParts(
      String aiCode, String value, AI ai, GS1BarcodeParserConfig config) {
    final elementDateTime = value.padRight(12, '0');
    var year =
        _year2ToYear4(int.parse(elementDateTime.substring(0, 2), radix: 10));
    final month = int.parse(elementDateTime.substring(2, 4), radix: 10);
    final day = int.parse(elementDateTime.substring(4, 6), radix: 10);
    final hour = int.parse(elementDateTime.substring(6, 8), radix: 10);
    final minute = int.parse(elementDateTime.substring(8, 10), radix: 10);
    final second = int.parse(elementDateTime.substring(10), radix: 10);

    return GS1ParsedElement<DateTime>(
      rawData: value,
      aiCode: aiCode,
      data: DateTime(year, month, day, hour, minute, second),
    );
  }

  _year2ToYear4(int year) {
    return year > 50 ? year + 1900 : year = year + 2000;
  }
}

class GS1ElementFixLengthParser extends GS1ElementParser {
  @override
  ParsedElementWithRest call(
      String data, AI ai, GS1BarcodeParserConfig config) {
    final offset = ai.code.length + ai.fixLength;

    final elementStr = data.substring(0, min(offset, data.length));

    if (!verify(elementStr, ai)) {
      throw GS1ParseException(
          message: 'Data format mismatch ${ai.regExp} for AI ${ai.code}');
    }
    final elementValue = elementStr.substring(ai.code.length);
    final element = parseFromParts(ai.code, elementValue, ai, config);
    final rest = getRest(data, offset, config);

    return ParsedElementWithRest(element: element, rest: rest);
  }

  @override
  GS1ParsedElement parseFromParts(
      String aiCode, String value, AI ai, GS1BarcodeParserConfig config) {
    if (value.length != ai.fixLength) {
      throw GS1ParseException(
          message:
              'Fixed length mismatch for AI $aiCode: expected ${ai.fixLength}, got ${value.length}');
    }

    return GS1ParsedElement<String>(
      rawData: value,
      aiCode: aiCode,
      data: value,
    );
  }
}

class GS1ElementFixLengthMeasureParser extends GS1ElementParser {
  @override
  ParsedElementWithRest call(
      String data, AI ai, GS1BarcodeParserConfig config) {
    final offset = ai.code.length + ai.fixLength;

    final elementStr = data.substring(0, min(offset, data.length));

    if (!verify(elementStr, ai)) {
      throw GS1ParseException(
          message: 'Data format mismatch ${ai.regExp} for AI ${ai.code}');
    }

    final elementValue = elementStr.substring(ai.code.length);
    final element = parseFromParts(ai.code, elementValue, ai, config);
    final rest = getRest(data, offset, config);

    return ParsedElementWithRest(element: element, rest: rest);
  }

  @override
  GS1ParsedElement parseFromParts(
      String aiCode, String value, AI ai, GS1BarcodeParserConfig config) {
    if (value.isEmpty) {
      throw GS1ParseException(message: 'Empty measure value for AI $aiCode');
    }
    if (value.length != ai.fixLength) {
      throw GS1ParseException(
          message:
              'Fixed length mismatch for AI $aiCode: expected ${ai.fixLength}, got ${value.length}');
    }

    final doubleValue = parseFloatingPoint(value, ai.numberOfDecimalPlaces);
    return GS1ParsedElement<double>(
        rawData: value, aiCode: aiCode, data: doubleValue);
  }
}

class GS1VariableLengthParser extends GS1ElementParser {
  @override
  ParsedElementWithRest call(
      String data, AI ai, GS1BarcodeParserConfig config) {
    final posOfGS = data.indexOf(config.groupSeparator);
    final offset = posOfGS == -1 ? data.length : posOfGS;
    final elementStr = data.substring(0, offset);

    if (!verify(elementStr, ai)) {
      throw GS1ParseException(
          message: 'Data format mismatch ${ai.regExp} for AI ${ai.code}');
    }

    final elementValue = elementStr.substring(ai.code.length);
    final element = parseFromParts(ai.code, elementValue, ai, config);
    final rest = getRest(data, offset, config);

    return ParsedElementWithRest(
      element: element,
      rest: rest,
    );
  }

  @override
  GS1ParsedElement parseFromParts(
      String aiCode, String value, AI ai, GS1BarcodeParserConfig config) {
    return GS1ParsedElement<String>(
      aiCode: aiCode,
      rawData: value,
      data: value,
    );
  }
}

class GS1VariableLengthMeasureParser extends GS1ElementParser {
  @override
  ParsedElementWithRest call(
      String data, AI ai, GS1BarcodeParserConfig config) {
    final posOfGS = data.indexOf(config.groupSeparator);
    final offset = posOfGS == -1 ? data.length : posOfGS;
    final elementStr = data.substring(0, offset);

    if (!verify(elementStr, ai)) {
      throw GS1ParseException(
          message: 'Data format mismatch ${ai.regExp} for AI ${ai.code}');
    }

    final numberPart = data.substring(ai.code.length, offset);
    final element = parseFromParts(ai.code, numberPart, ai, config);
    final rest = getRest(data, offset, config);
    return ParsedElementWithRest(element: element, rest: rest);
  }

  @override
  GS1ParsedElement parseFromParts(
      String aiCode, String value, AI ai, GS1BarcodeParserConfig config) {
    if (value.isEmpty) {
      throw GS1ParseException(message: 'Empty measure value for AI $aiCode');
    }

    final doubleValue = parseFloatingPoint(value, ai.numberOfDecimalPlaces);
    return GS1ParsedElement<double>(
        rawData: value, aiCode: aiCode, data: doubleValue);
  }
}

class GS1VariableLengthWithISONumbersParser extends GS1ElementParser {
  @override
  ParsedElementWithRest call(
      String data, AI ai, GS1BarcodeParserConfig config) {
    final posOfGS = data.indexOf(config.groupSeparator);
    final offset = posOfGS == -1 ? data.length : posOfGS;
    final elementStr = data.substring(0, offset);

    if (!verify(elementStr, ai)) {
      throw GS1ParseException(
          message: 'Data format mismatch ${ai.regExp} for AI ${ai.code}');
    }

    final rawValue = elementStr.substring(ai.code.length);
    final element = parseFromParts(ai.code, rawValue, ai, config);
    final rest = getRest(data, offset, config);

    return ParsedElementWithRest(element: element, rest: rest);
  }

  @override
  GS1ParsedElement parseFromParts(
      String aiCode, String value, AI ai, GS1BarcodeParserConfig config) {
    if (value.length < 3) {
      throw GS1ParseException(
          message: 'Value too short for ISO numbers AI $aiCode');
    }

    final isoPart = value.substring(0, 3);
    final numberPart = value.substring(3);
    final doubleValue =
        parseFloatingPoint(numberPart, ai.numberOfDecimalPlaces);
    return GS1ParsedElement<double>(
        rawData: value, aiCode: aiCode, iso: isoPart, data: doubleValue);
  }
}

class GS1VariableLengthWithISOCharsParser extends GS1ElementParser {
  @override
  ParsedElementWithRest call(
      String data, AI ai, GS1BarcodeParserConfig config) {
    final posOfGS = data.indexOf(config.groupSeparator);
    final offset = posOfGS == -1 ? data.length : posOfGS;
    final elementStr = data.substring(0, offset);

    if (!verify(elementStr, ai)) {
      throw GS1ParseException(
          message: 'Data format mismatch ${ai.regExp} for AI ${ai.code}');
    }

    final rawValue = elementStr.substring(ai.code.length);
    final element = parseFromParts(ai.code, rawValue, ai, config);
    final rest = getRest(data, offset, config);

    return ParsedElementWithRest(element: element, rest: rest);
  }

  @override
  GS1ParsedElement parseFromParts(
      String aiCode, String value, AI ai, GS1BarcodeParserConfig config) {
    if (value.length < 3) {
      throw GS1ParseException(
          message: 'Value too short for ISO chars AI $aiCode');
    }

    final isoPart = value.substring(0, 3);
    final charPart = value.substring(3);

    return GS1ParsedElement<String>(
      rawData: value,
      aiCode: aiCode,
      iso: isoPart,
      data: charPart,
    );
  }
}
