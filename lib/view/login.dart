import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sabang/view/Admin.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController email = new TextEditingController();
  final TextEditingController password = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future signIn() async {
    try {
      if (_formKey.currentState.validate()) {
        AuthResult result = await auth.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );

        if (result.user != null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) {
            return Admin();
          }));
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green[100],
            Colors.green[50],
            Colors.white,
            Colors.green[50],
            Colors.green[100],
          ],
        )),
        child: Form(
          key: _formKey,
          child: Column(
            verticalDirection: VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "LOGIN",
                style: TextStyle(
                    fontSize: 32,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: email,
                validator: (val) => val.isEmpty ? "Masukkan Email" : null,
                decoration: InputDecoration(
                  fillColor: Colors.green,
                  focusColor: Colors.green,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: "Email",
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: password,
                validator: (val) => val.isEmpty ? "Masukkan Password" : null,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: "Password",
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              SizedBox(height: 10),
              Material(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: MaterialButton(
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: signIn,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
