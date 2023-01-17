import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:photomanager/authentification.dart";

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Authentication().signInwithEmailAndPass(
          email: _controllerEmail.text, password: _controllerPassword.text);
    }on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Authentication().createUserWithEmailAndPass(
          email: _controllerEmail.text, password: _controllerPassword.text);
    }
    on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return Text('Authentication');
  }
  Widget _logo(){
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 70),
      child: FlutterLogo(
        size: 180,
      ),
    );
  }

  Widget _entryField_mail(TextEditingController controller,) {
    //return (TextField(
    //  controller: controller, decoration: InputDecoration(labelText: title,),));
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(90.0),
          ),
          labelText: 'Email',
        ),
      ),
    );
  }

  Widget _entryField_pwd(TextEditingController controller,) {
    //return (TextField(
    //  controller: controller, decoration: InputDecoration(labelText: title,),));
    return  Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(90.0),
          ),
          labelText: 'Password',
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Hum? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(onPressed: () =>
    isLogin
        ? signInWithEmailAndPassword()
        : createUserWithEmailAndPassword(),
        child: Text(isLogin ? 'Login' : 'Register'));
  }

  Widget _loginOrRegisterButton() {
    return TextButton(onPressed: () {
      setState(() {
        isLogin = !isLogin;
      });
    }, child: Text(isLogin ? 'Register instead ' : 'Login instead'));
  }

  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: _title(),),
        body: Container(
            height: double.infinity,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _logo(),
                _entryField_mail(_controllerEmail),
                _entryField_pwd(_controllerPassword),
                _errorMessage(),
                _submitButton(),
                _loginOrRegisterButton(),
              ],)));
  }
}