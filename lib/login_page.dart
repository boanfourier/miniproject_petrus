import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:miniproject_petrus/home_page.dart';
import 'dart:convert';
import 'package:miniproject_petrus/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        shadowColor: Colors.black,
        elevation: 10,
        title: const Text('Chat Apps'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: NetworkImage('https://static.vecteezy.com/system/resources/thumbnails/011/976/274/small/stick-figures-welcome-free-vector.jpg')),
            SizedBox(height: 20,),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(username: usernameController.text)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}