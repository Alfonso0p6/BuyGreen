// ignore_for_file: avoid_print, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, unused_element

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart' as scanner;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'gui.dart';
import 'newProduct.dart';
import 'info.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buy Green',
      theme: ThemeData(
        primarySwatch: Colors.green,
        checkboxTheme: Theme.of(context).checkboxTheme.copyWith(
              fillColor:
                  MaterialStateColor.resolveWith((states) => Colors.green),
            ),
      ),
      home: const MyHomePage(),
    );
  }
}

class Prodotto {
  final String id;
  final String name;
  final String company;
  final String co2;
  final String energy;
  final String rec;

  const Prodotto({
    required this.id,
    required this.name,
    required this.company,
    required this.co2,
    required this.energy,
    required this.rec,
  });

  factory Prodotto.fromJson(Map<String, dynamic> json) {
    return Prodotto(
        id: json['id'],
        name: json['name'],
        company: json['company'],
        co2: json['co2'],
        energy: json['energy'],
        rec: json['rec']);
  }
}

Future<Prodotto?> fetchProdotto(String idn) async {
  var api = Uri(
    scheme: 'https',
    host: 'api.alfonso0p6.dev',
    path: 'BuyGreen/getproduct.php',
    queryParameters: {'id': idn},
  );

  final response = await http.get(api);

  if (response.statusCode == 200) {
    dynamic jsonResponse = jsonDecode(response.body);

    if (jsonResponse is Map<String, dynamic> &&
        jsonResponse.containsKey('error')) {
      print(jsonResponse['error']);
      return null;
    } else if (jsonResponse is List<dynamic> && jsonResponse.isNotEmpty) {
      return Prodotto.fromJson(jsonResponse[0]);
    } else {
      throw Exception('Invalid response format');
    }
  } else {
    throw Exception('Failed to load');
  }
}

enum MenuItem { item1, item2 }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Uri _url = Uri.parse('https://alfonso0p6.dev/buygreen/');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Prodotto? prodotto;
  Future<bool?> _scanQR() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      try {
        final scanner.ScanResult cameraScanResult =
            await scanner.BarcodeScanner.scan(
          options: scanner.ScanOptions(
            useCamera: -1,
            autoEnableFlash: false,
            strings: {
              'cancel': 'Cancel',
              'flash_on': 'Flash On',
              'flash_off': 'Flash Off',
            },
            android: scanner.AndroidOptions(
              aspectTolerance: 0.00,
              useAutoFocus: true,
            ),
          ),
        );
        if (cameraScanResult.rawContent.isNotEmpty) {
          prodotto = await fetchProdotto(cameraScanResult.rawContent);
          return true;
        } else {
          return false;
        }
      } on PlatformException catch (e) {
        print(e);
        prodotto = null;
      }
    } else {
      var per = await Permission.camera.request();
      if (per == PermissionStatus.granted) {
        return await _scanQR();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2.0, right: 15.0),
              child: SizedBox(
                width: 40,
                child: Image.asset("assets/logo_round.png"),
              ),
            ),
            const Text("Buy Green"),
            Spacer(),
            PopupMenuButton(
              onSelected: (value) {
                if (value == MenuItem.item1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewProduct(),
                    ),
                  );
                } else if (value == MenuItem.item2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoPage(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: MenuItem.item1, child: Text("Add a product")),
                PopupMenuItem(value: MenuItem.item2, child: Text("Info"))
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/cart.png',
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
            ),
            const SizedBox(height: 20),
            const Text(
              "Scan a product to begin!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        icon: const Icon(Icons.qr_code_scanner),
        onPressed: () async {
          bool? ret = await _scanQR();

          if (ret == false && ret != null) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Error"),
                content: Text("Something went wrong!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
            );
          } else if (prodotto != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Gui(),
                settings: RouteSettings(
                  arguments: prodotto,
                ),
              ),
            );
          } else if (prodotto == null && ret != null) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Product Not Found"),
                content: Text("No product found with the scanned ID."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
            );
          }
        },
        label: const Text("Scan"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
