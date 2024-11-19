import 'package:carhabty/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:carhabty/Spincircle.dart'; // Page après la connexion.
import 'auth/auth_screens.dart'; // Écran de connexion.
import 'package:firebase_core/firebase_core.dart'; // Initialisation Firebase
import 'package:firebase_messaging/firebase_messaging.dart'; // Notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart'; // Formatage des dates
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart'; // Ajoutez cette ligne

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Initialiser Firebase
  print('Handling a background message: ${message.messageId}');
}

void showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('rappel_channel', 'Rappels',
          channelDescription: 'Notifications de rappels de véhicule',
          importance: Importance.max,
          priority: Priority.high);
         
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
      0, title, body, platformChannelSpecifics);
}





Future<void> checkRappels() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
    final ApiService _apiService = ApiService();
      final url= _apiService.baseUrl;
      print(url);
  // Appel à l'API pour récupérer les rappels d'un véhicule spécifique
  final response = await http.get(
    Uri.parse('$url/rappels'),
  );

  if (response.statusCode == 200) {
    List rappels = json.decode(response.body);
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print('Rappels récupérés : ${response.body}');

    // Parcourt les rappels pour vérifier si la date correspond à aujourd'hui
    for (var rappel in rappels) {
      if (rappel['date'] == today) {
        String message;
        
        // Vérifier le type et formater le message en conséquence
        if (rappel['type'] == 'entretien') {
          message = 'Vous avez un entretien de ${rappel['type_entretien_name'] ?? 'N/A'}.';
        } else if (rappel['type'] == 'depense') {
          message = 'Vous avez une dépense de ${rappel['typeEntretien_name'] ?? 'N/A'}.';
        } else {
          message = 'Rappel inconnu.';
        }

        // Envoyer la notification avec le message formaté
        showNotification(
          'Rappel de véhicule ${rappel['vehicule']?? 'N/A'}',
          message,
        );
        print('Notification envoyée pour le rappel: ${rappel['date']}');
      }
    }

    // Si aucune notification n'a été envoyée, afficher un message dans la console
    if (rappels.where((rappel) => rappel['date'] == today).isEmpty) {
      print('Aucun rappel à notifier pour aujourd\'hui.');
    }
  } else {
    print('Erreur lors de la récupération des rappels : ${response.statusCode}');
  }
}


void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Tâche en arrière-plan : $task"); // Pour le debug
    // Exécute la vérification des rappels
    await checkRappels();
      print('hello ...');
     return Future.value(true);
  });
}
                             

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Initialise les fuseaux horaires

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  
  await AndroidAlarmManager.initialize(); // Initialise l'Alarm Manager

  await Firebase.initializeApp(); // Initialiser Firebase

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Écouter les messages en premier plan
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    if (message.notification != null) {
      showNotification(message.notification!.title!, message.notification!.body!);
      print('Message also contained a notification: ${message.notification}');
    }
  });

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("Token: $token");

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
  



  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask("checkRappels", "checkRappels",frequency: Duration(minutes: 60));
  
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    setState(() {
      _isLoggedIn = token != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn ? Spincircle() : LoginScreen(),
    );
  }
}