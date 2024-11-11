import 'dart:convert';

import 'package:carhabty/ProfilePage.dart';
import 'package:carhabty/TyoeDepense/depense.dart';
import 'package:carhabty/TypeEntretien/entretien.dart';
import 'package:carhabty/addCarburant.dart';
import 'package:carhabty/addEntretien.dart';
import 'package:carhabty/addRappel.dart';
import 'package:carhabty/adddepenses.dart';
import 'package:carhabty/auth_screens.dart';
import 'package:carhabty/maps/maps.dart';
import 'package:carhabty/service/api_service.dart';
import 'package:carhabty/vehicule/vehicule.dart';
import 'package:flutter/material.dart';
import 'package:carhabty/pages/tabbarRapport.dart';
import 'package:carhabty/pages/home.dart';
import 'package:carhabty/pages/message.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';



class Spincircle extends StatefulWidget {
  @override
  _SpincircleState createState() => _SpincircleState();
}

class _SpincircleState extends State<Spincircle> {
 

    String? _imageUrl;
    
    
     
    @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
   // Variable pour stocker l'URL de l'image
    Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId'); // Récupérer l'ID utilisateur
  final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
    if (userId != null) {
      // Effectuer une requête HTTP pour obtenir l'URL de l'image
      final response = await http.get(
        Uri.parse('$url/user/$userId/profile'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
         print(data);
        setState(() {
          _imageUrl = data['avatar']; // Supposons que l'URL de l'image se trouve dans 'profile_image'
        });
      } else {
        print('Erreur lors de la récupération de l\'image');
      }
    }
  }


  
  Future _logout() async {
    // Accède à SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Supprime les données spécifiques de SharedPreferences (par exemple, l'ID utilisateur, token, etc.)
   await prefs.remove('token');// Ou utilise remove('clé') pour supprimer des clés spécifiques
   await prefs.remove('userId');
 
    // Redirige vers la page de login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
   int selectedIndex = 0;

  // Liste des pages que vous voulez afficher
  List<Widget> pages = [
    Home(), // Page Home
    Add(),  // Page Add
Message(),
MapsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
       appBar: AppBar(
        title: Text('Carhabty', style: TextStyle(
    color: Colors.white,
    fontSize: 20, // Vous pouvez ajuster la taille du texte
    fontWeight: FontWeight.bold, // Ajout d'épaisseur au texte (optionnel)
  ),),
         automaticallyImplyLeading: false,
        backgroundColor:  Color.fromRGBO(52, 138, 199, .6),
        actions: <Widget>[
          // Menu déroulant avec l'image de profil
          PopupMenuButton<String>(
            
            icon: CircleAvatar(
              radius: 20,
              backgroundImage: _imageUrl != null
                  ? NetworkImage(_imageUrl!) :null// Utilise l'URL de l'image, // Image par défaut si aucune image n'est récupérée
            ),
            onSelected: (value) {
              if (value == 'profile') {
                // Action pour le profil
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              } else if (value == 'logout') {
                // Action pour la déconnexion
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text('Profil'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
       leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.menu), 
             color: Colors.white,// Icône pour le menu
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Ouvre le Drawer
            },
          );
        },
      ),
    ),
       drawer: SideMenu(), 
       body: SpinCircleBottomBarHolder(
          bottomNavigationBar: SCBottomBarDetails(
            circleColors: [Colors.white, Color.fromRGBO(52, 138, 199, .6), Color.fromARGB(255, 82, 194, 255)],
            iconTheme: IconThemeData(color: Colors.black45),
            activeIconTheme: IconThemeData(color:   Color.fromRGBO(52, 138, 199, .6)),
            backgroundColor: Colors.white,
            titleStyle: TextStyle(color: Colors.black45,fontSize: 12),
            activeTitleStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold),
            actionButtonDetails: SCActionButtonDetails(
              color: const Color.fromARGB(255, 82, 151, 255),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              elevation: 2
            ),
            elevation: 2.0,
            items: [
              // Suggested count : 4
              SCBottomBarItem(icon: Icons.home, title: "home", onPressed: () {
                  setState(() {
                selectedIndex = 0; // Sélectionne la page "Add"
              });

              }),
              SCBottomBarItem(icon: Icons.stacked_line_chart, title: "Stat", onPressed: () {  setState(() {
                selectedIndex = 1; // Sélectionne la page "Add"
              });}),
              SCBottomBarItem(icon: Icons.watch_later, title: "Rappels", onPressed: () {
                 setState(() {
                selectedIndex = 2; // Sélectionne la page "Add"
              });
              }),
              SCBottomBarItem(icon: Icons.map, title: "maps", onPressed: () {
                 setState(() {
                selectedIndex = 3; // Sélectionne la page "Add"
              });
              }),
            ],
            circleItems: [
              //Suggested Count: 3
              SCItem(icon: Icon(Icons.money), onPressed: () { 
                Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddExpensePage()),
      );
      }),
             
              SCItem(icon: Icon(Icons.local_gas_station), onPressed: () {

                        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddCarburantPage()),
      );
              }),


               SCItem(icon: Icon(Icons.build), onPressed: () {
 Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddentretienPage()),
      );

               }),
               SCItem(icon: Icon(Icons.watch_later), onPressed: () {

                 Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddrappelPage()),
      );
               }),
            ],
           
            bnbHeight: 80 // Suggested Height 80
          ),
          child: pages[selectedIndex],
        ),
      );
  }
}


class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool _isExpanded = false;
  int? vehiculeId = null;

    Future<void> requestPermissions() async {
    await Permission.storage.request();
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

Future<Map<String, dynamic>?> fetchVehicleData() async {
  final prefs = await SharedPreferences.getInstance();
  final vehicleId = prefs.getInt('selectedVehicleId');

  if (vehicleId == null) return null;
  final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
  final response = await http.get(
    
    Uri.parse("$url/vehicule/$vehicleId")
   
  );

  if (response.statusCode == 200) {
      print("la récupération des données succses: ${response.statusCode}");
    return json.decode(response.body);
  } else {
    print("Erreur lors de la récupération des données : ${response.statusCode}");
    return null;
  }
}



Future<void> generatePdf() async {
  print('pdf');
  await requestPermissions();  // Demande de permissions
  
  final pdf = pw.Document();
  final vehiculeData = await fetchVehicleData();

  if (vehiculeData != null) {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text("Rapport pour le véhicule ID: ${vehiculeData['id']}"),
              pw.SizedBox(height: 20),
              pw.Text("Dépenses:"),
              for (var depense in vehiculeData['depense'])
                pw.Text("- ${depense['remarque']}: ${depense['montant']}"),
              pw.SizedBox(height: 10),
              pw.Text("Carburant:"),
              for (var carburant in vehiculeData['carburant'])
                pw.Text("- ${carburant['remarque']}: ${carburant['montant']}"),
              pw.SizedBox(height: 10),
              pw.Text("Entretien:"),
              for (var entretien in vehiculeData['entretien'])
                pw.Text("- ${entretien['remarque']}: ${entretien['montant']}"),
              pw.SizedBox(height: 10),
              pw.Text("Rappels:"),
              for (var rappel in vehiculeData['rappel'])
                pw.Text("- ${rappel['type']}"),
            ],
          );
        },
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/rapport_vehicule_${vehiculeData['id']}.pdf");
    await file.writeAsBytes(await pdf.save());

    print("PDF saved at: ${file.path}");
  }
}

Future<void> generateExcel() async {
  print('excel');
  await requestPermissions();  // Demande de permissions
  
  final vehiculeData = await fetchVehicleData();

  if (vehiculeData != null) {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Rapport_${vehiculeData['id']}'];

    sheetObject.appendRow(["Section", "Données"]);
    sheetObject.appendRow(["Dépenses"]);
    for (var depense in vehiculeData['depense']) {
      sheetObject.appendRow(["", "${depense['remarque']}: ${depense['montant']}"]);
    }
    sheetObject.appendRow(["Carburant"]);
    for (var carburant in vehiculeData['carburant']) {
      sheetObject.appendRow(["", "${carburant['remarque']}: ${carburant['montant']}"]);
    }
    sheetObject.appendRow(["Entretien"]);
    for (var entretien in vehiculeData['entretien']) {
      sheetObject.appendRow(["", "${entretien['remarque']}: ${entretien['montant']}"]);
    }
    sheetObject.appendRow(["Rappels"]);
    for (var rappel in vehiculeData['rappel']) {
      sheetObject.appendRow(["", "${rappel['type']}"]);
    }

     final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/rapport_vehicule_${vehiculeData['id']}.xlsx");
    await file.writeAsBytes(excel.save() as List<int>);

    print("Excel saved at: ${file.path}");
  }
}

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _isExpanded ? 200 : 70,
      child: Drawer(
        child: Container(
        color:  Color.fromRGBO(52, 138, 199, .6),// Couleur de fond personnalisée
          child: Column(
            children: [
              // DrawerHeader ici si vous le souhaitez
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    SizedBox(height: 30),
                    ListTile(
                      leading: Icon(Icons.person, color: Colors.white,),
                      title: _isExpanded ? Text('Profil', style: TextStyle(
    color: Colors.white,

  ),) : null,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ));
                      },
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.car_crash,  color: Colors.white,),
                      title: _isExpanded ? Text('Vehicule', style: TextStyle(
    color: Colors.white,

  ),) : null,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EditVehiculePage(),
                        ));
                      },
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.settings,  color: Colors.white,),
                      title: _isExpanded ? Text('Type Entretien', style: TextStyle(
    color: Colors.white,

  ),) : null,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AfficherTypeEntretienPage(),
                        ));
                      },
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.money,  color: Colors.white,),
                      title: _isExpanded ? Text('Type Dépense', style: TextStyle(
    color: Colors.white,

  ),) : null,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AfficherTypeDepensePage(),
                        ));
                      },
                    ),

                     Divider(),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.picture_as_pdf,  color: Colors.white,),
                      title: _isExpanded ? Text('PDF', style: TextStyle(
    color: Colors.white,
),) : null,
                      onTap: ()async {
                        await generatePdf();
                      },
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.file_download,  color: Colors.white,),
                      title: _isExpanded ? Text('Excel', style: TextStyle(
    color: Colors.white,

  ),) : null,
                      onTap: () async {
                      await generateExcel();
                      },
                    ),
                  ],
                ),
              ),
              Divider(),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.exit_to_app,  color: Colors.white,),
                title: _isExpanded ? Text('Déconnexion', style: TextStyle(
    color: Colors.white,

  ),) : null,
                onTap: () => _logout(context),
              ),
              IconButton(
                icon: Icon(_isExpanded ? Icons.arrow_back : Icons.arrow_forward, color: Colors.white,),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
