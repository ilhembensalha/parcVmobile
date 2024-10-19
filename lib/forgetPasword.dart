import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendResetPasswordLink() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.113:8000/api/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: '{"email": "${_emailController.text}"}',
    );

    if (response.statusCode == 200) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset link sent to your email.')),
 );
  // Attendez un peu pour permettre à l'utilisateur de voir le SnackBar avant de revenir en arrière
  Future.delayed(Duration(seconds: 2), () {
    Navigator.pop(context); // Retourner à la page précédente
  });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reset link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          
          children: [
              SizedBox(height: 20),


            TextField(
               obscureText: false,
              controller: _emailController,
              //decoration: InputDecoration(labelText: 'Enter your email'),
               decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter your email",
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 147, 147, 147)
                                  )
                                ),
              keyboardType: TextInputType.emailAddress,
            ),


            SizedBox(height: 20),
 FadeInUp(
  duration: const Duration(milliseconds: 1900),
  child: GestureDetector(
    onTap: _sendResetPasswordLink,
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
          Icon(Icons.email, color: Colors.white),
          SizedBox(width: 10),
          Text(
            "Send Reset Link",
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

           /* ElevatedButton(
              onPressed: ,
              child: Text(''),
            ),
*/


          ],
        ),
      ),
    );
  }
}
