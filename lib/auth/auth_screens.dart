import 'package:carhabty/auth/forgetPasword.dart';
import 'package:flutter/material.dart';
import 'package:carhabty/Spincircle.dart';
import 'package:animate_do/animate_do.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import 'dart:convert'; // Pour convertir le mot de passe en bytes
import 'package:crypto/crypto.dart'; // Pour le hachage
import 'package:encrypt/encrypt.dart' as encrypt; // Utiliser un alias pour 'encrypt'


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final LocalAuthentication auth = LocalAuthentication();

  bool _canCheckBiometrics = false;
  bool _hasSavedCredentials = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _checkSavedCredentials();
  }

  // Vérifie si la biométrie est disponible
  void _checkBiometrics() async {
    bool canCheck = await auth.canCheckBiometrics;
    setState(() {
      _canCheckBiometrics = canCheck;
    });
  }

  // Vérifie si des identifiants sont enregistrés dans les SharedPreferences
  void _checkSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    setState(() {
      _hasSavedCredentials = email != null && password != null;
    });
  }
  //password crypté


Future<void> storeEncryptedPassword(String password) async {
  final prefs = await SharedPreferences.getInstance();
  final key = "Your16CharacterK"; // Clé de 16 caractères

  // Chiffrement du mot de passe
  encrypt.Encrypted encryptedPassword = encryptPassword(key, password);

  // Stocker le mot de passe chiffré (Base64) dans SharedPreferences
  await prefs.setString('password', encryptedPassword.base64);
}

Future<String> getDecryptedPassword() async {
  final prefs = await SharedPreferences.getInstance();
  final key = "Your16CharacterK"; // Clé de 16 caractères

  // Récupérer le mot de passe chiffré
  String? encryptedPasswordBase64 = prefs.getString('password');

  if (encryptedPasswordBase64 != null && encryptedPasswordBase64.isNotEmpty) {
    // Convertir la chaîne Base64 en objet Encrypted
    final encryptedPassword = encrypt.Encrypted.fromBase64(encryptedPasswordBase64);

    // Déchiffrement du mot de passe
    String decryptedPassword = decryptPassword(key, encryptedPassword);
    return decryptedPassword;
  }

  return ''; // Retourne une chaîne vide si aucun mot de passe n'est trouvé
}

String decryptPassword(String keyString, encrypt.Encrypted encryptedData) {
  final key = encrypt.Key.fromUtf8(keyString); // Utiliser 'encrypt.Key'
  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  final initVector = encrypt.IV.fromUtf8(keyString.substring(0, 16));
  return encrypter.decrypt(encryptedData, iv: initVector);
}

encrypt.Encrypted encryptPassword(String keyString, String plainText) {
  final key = encrypt.Key.fromUtf8(keyString); // Utiliser 'encrypt.Key'
  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  final initVector = encrypt.IV.fromUtf8(keyString.substring(0, 16));
  return encrypter.encrypt(plainText, iv: initVector);
}



  // Méthode pour vérifier l'empreinte digitale et auto-remplir les identifiants
  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      if (authenticated) {
        // Charger les identifiants sauvegardés
        SharedPreferences prefs = await SharedPreferences.getInstance();
          try {
    String decryptedPassword = await getDecryptedPassword();
    final token = await _apiService.login(
        prefs.getString('email') ?? '',
        //prefs.getString('password') ?? '',
         decryptedPassword,
      
    );
    if (token != null) {
      // Sauvegarde des identifiants dans les SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Spincircle()),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login successful"),
      ));

      // Mise à jour du bouton fingerprint après la première connexion
      _checkSavedCredentials();
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Login failed: $error'),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }
        prefs.getString('email') ?? '';
        prefs.getString('password') ?? '';
     
      }
    } catch (e) {
      print('Error using biometrics: $e');
    }
  }

void _login() async {
  try {
    final token = await _apiService.login(
      _emailController.text,
      _passwordController.text,
    );
     
    if (token != null) {
      // Sauvegarde des identifiants dans les SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _emailController.text);
     // await prefs.setString('password', _passwordController.text);
     await storeEncryptedPassword(_passwordController.text);
      // Vérifier si c'est la première connexion
      bool isFirstLogin = prefs.getBool('isFirstLogin') ?? true;
      print(isFirstLogin);
      if (isFirstLogin) {
        // Afficher le pop-up pour informer l'utilisateur de l'option de fingerprint
        _showFingerprintDialog();
        // Mettre à jour la préférence pour indiquer que l'utilisateur a été informé
        await prefs.setBool('isFirstLogin', false);
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Spincircle()),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login successful"),
      ));

      // Mise à jour du bouton fingerprint après la première connexion
      _checkSavedCredentials();
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Login failed: $error'),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }
}

// Fonction pour afficher le pop-up d'information sur l'empreinte digitale
void _showFingerprintDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Fingerprint Authentication'),
        content: const Text('You can now use your fingerprint to log in for future sessions.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le pop-up
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.fill
                  )
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1600),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 50),
                          child: const Center(
                            child: Text(
                              "Login", 
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 40, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1800),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromRGBO(242, 243, 248, 1)
                                  )
                                )
                              ),
                              child: TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email ",
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 147, 147, 147)
                                  )
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 147, 147, 147)
                                  )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: GestureDetector(
                        onTap: _login,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                               Color.fromRGBO(52, 138, 199, 1),
                              Color.fromRGBO(52, 138, 199, .6),
                              ],
                            ),
                             boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
                          ),
                          child: const Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Affiche le bouton Login with fingerprint uniquement si des identifiants sont enregistrés
                     if (_canCheckBiometrics && _hasSavedCredentials)
                  FadeInUp(
  duration: const Duration(milliseconds: 1900),
  child: GestureDetector(
    onTap: _authenticateWithBiometrics,
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(52, 138, 199, 1),
            Color.fromRGBO(52, 138, 199, .6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.fingerprint, color: Colors.white),
          SizedBox(width: 10),
          Text(
            "Login with fingerprint",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  ),
),
  const SizedBox(height: 20),
            FadeInUp(
              duration: const Duration(milliseconds: 2000),
              child: GestureDetector(
                onTap: () {
                  // Naviguer vers la page de mot de passe oublié
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordPage(), // Remplacez avec votre page de mot de passe oublié
                    ),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color:  Color.fromRGBO(52, 138, 199, .6),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
