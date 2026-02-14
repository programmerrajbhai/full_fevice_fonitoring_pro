import 'package:url_launcher/url_launcher.dart';

class HelperFunctions {
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  static Future<void> openWhatsApp(String number) async {
    final Uri url = Uri.parse("https://wa.me/$number");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch WhatsApp';
    }
  }
}