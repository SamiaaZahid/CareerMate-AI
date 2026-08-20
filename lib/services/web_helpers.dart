import 'package:web/web.dart' as web;

void openWebUrl(String url) {
  try {
    web.window.open(url, '_blank');
  } catch (_) {}
}
