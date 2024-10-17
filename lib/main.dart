import 'package:flutter/material.dart';
import 'package:carhabty/home.dart'; // Page après la connexion.
import 'auth_screens.dart'; // Écran de connexion.
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
  int? vehicleId = prefs.getInt('selectedVehicleId');

  // Vérifiez si vehicleId n'est pas nul avant de continuer
  if (vehicleId == null) {
    print('Aucun véhicule sélectionné');
    return; // Sortir de la fonction si aucun véhicule n'est sélectionné
  }

  // Appel à l'API pour récupérer les rappels d'un véhicule spécifique
  final response = await http.get(
    Uri.parse('http://192.168.1.113:8000/api/rappels/$vehicleId'),
  );

  if (response.statusCode == 200) {
    List rappels = json.decode(response.body);
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print('Rappels récupérés : ${response.body}');

    bool notificationSent = false; // Pour vérifier si une notification a été envoyée

    // Parcourt les rappels pour vérifier si la date correspond à aujourd'hui
    for (var rappel in rappels) {
      if (rappel['date'] == today) {
        if (!notificationSent) {
          showNotification('Rappel de véhicule', 'Vérifiez le rappel ou le kilométrage de votre véhicule.');
          print('Notification envoyée pour le rappel: ${rappel['date']}');
          notificationSent = true; // Mettez à jour pour éviter d'envoyer plusieurs notifications
        }
      }
    }

    if (!notificationSent) {
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
                             
// Fonction pour planifier les rappels
void scheduleReminder() async {
  await Workmanager().registerPeriodicTask(
    "checkRappelsTask", // Un identifiant unique pour la tâche
    "checkRappels", // Nom de la tâche
    frequency: const Duration(days: 1), // Intervalle minimum 15 minutes avec WorkManager
    initialDelay: const Duration(seconds: 5), // Démarrer après 5 secondes
    inputData: {}, // Données en entrée si nécessaire
    constraints: Constraints(
      networkType: NetworkType.connected, // Peut être configuré pour limiter à certains cas
      requiresBatteryNotLow: false, // Peut être configuré selon les besoins
      requiresCharging: false,
    ),
  );
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

  // Planifier la tâche récurrente toutes les 15 minutes
  scheduleReminder();
  
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