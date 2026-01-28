// ignore_for_file: file_names, prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously, avoid_print
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart' as scanner;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MaterialApp(
    title: 'Product App',
    home: NewProduct(),
  ));
}

class NewProduct extends StatefulWidget {
  const NewProduct({super.key});

  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  Future<String?> _scanQR() async {
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
          return cameraScanResult.rawContent;
        } else {
          return "";
        }
      } on Exception catch (e) {
        print(e);
        return "";
      }
    } else {
      var per = await Permission.camera.request();
      if (per == PermissionStatus.granted) {
        return await _scanQR();
      }
    }
    return null;
  }

  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController co2Controller = TextEditingController();
  TextEditingController energyController = TextEditingController();
  TextEditingController recyclabilityController = TextEditingController();

  int ver = 1;
  final Uri _url = Uri.parse('');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<bool> isAppUpdateRequired() async {
    var api = Uri(
      scheme: 'https',
      host: 'apibackend',
      path: 'BuyGreen/checkversion.php',
    );

    final response = await http.get(api);

    if (response.statusCode == 200) {
      final latestVersion = int.parse(response.body);
      return latestVersion > ver;
    } else {
      throw Exception('Failed to load version information');
    }
  }

  void showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Required"),
        content: Text(
            "A new version of the app is available. Please update to continue using the app."),
        actions: [
          TextButton(
            onPressed: () {
              _launchUrl();
              Navigator.of(context).pop();
            },
            child: Text("Update Now"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Product"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: 'ID',
                  suffixIcon: IconButton(
                    onPressed: () async {
                      final isUpdateRequired = await isAppUpdateRequired();
                      if (isUpdateRequired) {
                        showUpdateDialog();
                      } else {
                        String? scannedId = await _scanQR();
                        if (scannedId != null) {
                          setState(() {
                            idController.text = scannedId;
                          });
                        }
                      }
                    },
                    icon: Icon(Icons
                        .qr_code_scanner), // Icona per il tasto di scansione
                  ),
                ),
              ),
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name')),
              TextField(
                  controller: companyController,
                  decoration: InputDecoration(labelText: 'Company')),
              TextField(
                  controller: co2Controller,
                  decoration: InputDecoration(labelText: 'CO2')),
              TextField(
                  controller: energyController,
                  decoration: InputDecoration(labelText: 'Energy')),
              TextField(
                  controller: recyclabilityController,
                  decoration:
                      InputDecoration(labelText: 'Recyclability Percentage')),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final isUpdateRequired = await isAppUpdateRequired();
                  if (isUpdateRequired) {
                    showUpdateDialog();
                  } else {
                    _postNewProduct();
                  }
                },
                child: Text("Add Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _postNewProduct() async {
    var api = Uri(
      scheme: 'https',
      host: 'apibackend',
      path: 'BuyGreen/addproduct.php',
    );

    final body = {
      'id': idController.text,
      'name': nameController.text,
      'company': companyController.text,
      'co2': co2Controller.text,
      'energy': energyController.text,
      'rec': recyclabilityController.text,
    };

    try {
      final response = await http.post(api, body: body);

      if (response.statusCode == 201) {
        _showSuccessDialog(context);
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      _showErrorDialog();
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Product added successfully!"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Chiudi il dialog
                Navigator.of(context).pop(); // Torna alla pagina principale
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Failed to add product."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
