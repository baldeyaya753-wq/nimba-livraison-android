
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

const String siteUrl = 'https://nimba.xo.je/login.php';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NIMBA LIVRAISON',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1F3A5F),
          useMaterial3: true,
        ),
        home: const WebPage(),
      );
}

class WebPage extends StatefulWidget {
  const WebPage({super.key});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController controller;
  bool chargement = true;
  bool erreur = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              chargement = true;
              erreur = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => chargement = false);
          },
          onWebResourceError: (e) {
            if (e.isForMainFrame != false && mounted) {
              setState(() {
                erreur = true;
                chargement = false;
              });
            }
          },
          onNavigationRequest: (req) async {
            final uri = Uri.tryParse(req.url);

            if (uri != null &&
                (['tel', 'sms', 'mailto', 'whatsapp'].contains(uri.scheme) ||
                    uri.host == 'wa.me' ||
                    uri.host == 'api.whatsapp.com')) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..load
