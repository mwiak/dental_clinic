import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

Future<double?> readHtml() async {
  final response =
      await http.get(Uri.parse('https://sp-today.com/en/currency/us_dollar'));
  Document document = parse(response.body);
  List<Element> allSpans =
      document.querySelectorAll('a[href*="/currency/us_dollar/city/damascus"]');
  Element anchor = allSpans[0];
  Element? price = anchor.querySelector('.value');
  double value = double.parse(price!.text);

  return value;
}
