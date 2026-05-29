import 'package:flutter/material.dart';
import 'package:webview_flutter_kpostal/webview_flutter_kpostal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kpostal Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Kpostal Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String postCode = '-';
  String roadAddress = '-';
  String jibunAddress = '-';
  String latitude = '-';
  String longitude = '-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => KpostalView(
                      callback: (Kpostal result) {
                        setState(() {
                          postCode = result.postCode;
                          roadAddress = result.address;
                          jibunAddress = result.jibunAddress;
                          latitude = result.latitude.toString();
                          longitude = result.longitude.toString();
                        });
                      },
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.blue)),
              child: const Text(
                'Search Address',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  const Text('postCode',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('result: $postCode'),
                  const Text('road_address',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('result: $roadAddress'),
                  const Text('jibun_address',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('result: $jibunAddress'),
                  const Text('LatLng',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('latitude: $latitude / longitude: $longitude'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
