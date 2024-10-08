import 'package:flutter/material.dart';
import 'package:carhabty/home.dart';
import 'api_service.dart';
import 'package:animate_do/animate_do.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
//  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

void _login() async {
 // if (_formKey.currentState != null && _formKey.currentState!.validate()) {
    try {
      final token = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );
      // ignore: unnecessary_null_comparison
      if (token != null ){
     
       print(token);
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => Spincircle()));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("login successful"),
    ));
    }
      print('Login successful!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Login failed!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $error'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
  
  }
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
	                    child: FadeInUp(duration: const Duration(milliseconds: 1600), child: Container(
	                      margin: const EdgeInsets.only(top: 50),
	                      child: const Center(
	                        child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),),
	                      ),
	                    )),
	                  )
	                ],
	              ),
	            ),
	            Padding(
	              padding: const EdgeInsets.all(30.0),
	              child: Column(
	                children: <Widget>[
	                  FadeInUp(duration: const Duration(milliseconds: 1800), child: Container(
	                    padding: const EdgeInsets.all(5),
	                   
	                    child: Column(
	                      children: <Widget>[
	                        Container(
	                          padding: const EdgeInsets.all(8.0),
	                          decoration: const BoxDecoration(
	                            border: Border(bottom: BorderSide(color:  Color.fromRGBO(242, 243, 248, 1)))
	                          ),
	                          child: TextField(
                              controller: _emailController,
	                            decoration: const InputDecoration(
	                              border: InputBorder.none,
	                              hintText: "Email ",
	                              hintStyle: TextStyle(color: Color.fromARGB(255, 147, 147, 147))
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
	                              hintStyle: TextStyle(color: Color.fromARGB(255, 147, 147, 147))
	                            ),
	                          ),
	                        )
	                      ],
	                    ),
	                  )),
	                  const SizedBox(height: 30,),
                  /*   ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
                
              ),*/
	                 FadeInUp(
  duration: Duration(milliseconds: 1900),
  child: GestureDetector( // Utilisation de GestureDetector
    onTap: _login, // Appel de la méthode _login lors du clic
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(143, 148, 251, 1),
            Color.fromRGBO(143, 148, 251, .6),
          ],
        ),
      ),
      child: Center(
        child: Text(
          "Login",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ),
),

	                  const SizedBox(height: 70,),
	                  FadeInUp(duration: const Duration(milliseconds: 2000), child: const Text("Forgot Password?", style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),)),
	                ],
	              ),
	            )
	          ],
	        ),
	      ),
      )
    );
  }
}
  /*    body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
