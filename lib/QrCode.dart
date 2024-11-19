import 'package:carhabty/Spincircle.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  String? qrText;
  bool permissionGranted = false;
  MobileScannerController scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  // Vérifier et demander la permission d'accès à la caméra
  Future<void> _checkPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      setState(() {
        permissionGranted = true;
      });
    } else {
      setState(() {
        permissionGranted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner QR Code'),
      ),
      body: permissionGranted
          ? Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: MobileScanner(
                    controller: scannerController,
                    onDetect: (barcode, args) async {
                      final String? code = barcode.rawValue;
                      setState(() {
                        qrText = code;
                      });

                      // Enregistrer le contenu du QR code dans SharedPreferences
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      
                      // Conversion en int
                      int? vehicleId = int.tryParse(code ?? '');

                      if (vehicleId != null) {
                        await prefs.setInt('selectedVehicleId', vehicleId);
                        print('ID du véhicule sauvegardé: $vehicleId');
                      } else {
                        print('Le code scanné n\'est pas un entier valide');
                      }

                      Navigator.pop(context, true); 
                        Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Spincircle (),
      ),
    );// Fermer la page après scan
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text('Résultat du scan: $qrText'),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                  'Permission caméra refusée. Veuillez l\'autoriser dans les paramètres.'),
            ),
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }
}