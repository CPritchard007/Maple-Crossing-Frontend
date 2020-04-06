import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maple_crossing_application/signinPage.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class Signup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return buildMaterial(child: Scaffold(
        appBar: AppBar(
          title: Text("Sign up"),
          backgroundColor: Color.fromRGBO(254, 95, 95, 1),
        ),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  child: Text(
                    "Create an account",
                    style: Theme.of(context).textTheme.title,
                  ),
                  alignment: Alignment.center,
                ),
              ),
              Padding(padding: const EdgeInsets.all(12.0), child: SignupForm()),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  TextEditingController _usernameCon,
      _firstNameCon,
      _lastNameCon,
      _emailCon,
      _passCon;

  final RegExp emailReg = new RegExp(
    r"([a-z,A-Z,0-9,.]+)@([a-z,A-Z]+)\.([a-z]+)",
    caseSensitive: false,
    multiLine: false,
  );

  @override
  void initState() {
    super.initState();
    _usernameCon = new TextEditingController();
    _firstNameCon = new TextEditingController();
    _lastNameCon = new TextEditingController();
    _emailCon = new TextEditingController();
    _passCon = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: "first name"),
            controller: _firstNameCon,
            maxLength: 30,
            validator: (value) {
              if (value.isEmpty) {
                return "a first name is required";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "last name"),
            controller: _lastNameCon,
            maxLength: 30,
            validator: (value) {
              if (value.isEmpty) {
                return "a last name is required";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "username"),
            controller: _usernameCon,
            maxLength: 30,
            validator: (value) {
              if (value.isEmpty) {
                return "a username is required";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "email"),
            controller: _emailCon,
            maxLength: 120,
            validator: (value) {
              if (value.isEmpty) {
                return "an email is required";
              } else if (!emailReg.hasMatch(value)) {
                return "this is not a valid email";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: "password",
            ),
            obscureText: true,
            controller: _passCon,
            maxLength: 60,
            validator: (value) {
              if (value.isEmpty) {
                return "a password is required";
              }
              return null;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                  onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignIn(),
                          ),
                        )
                      },
                  child: Text("I already have an account")),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  _formKey.currentState.validate();
                  if (_formKey.currentState.validate())
                    registerAccount(
                            _usernameCon.value.text,
                            _firstNameCon.value.text,
                            _lastNameCon.value.text,
                            _emailCon.value.text,
                            _passCon.value.text)
                        .then(
                      (val) => {
                        val
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignIn(),
                                ),
                              )
                            : null
                      },
                    );
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

Future<bool> registerAccount(String username, String firstName, String lastName,
    String email, String password) async {
  final response = await http
      .post("https://cpritchar.scweb.ca/mapleCrossing/api/register", headers: {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded"
  }, body: {
    "name": username,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "password": password
  });
  print("{ \n" +
      "\tusername: $username \n" +
      "\tfirst name: $firstName \n" +
      "\tlast name: $lastName \n" +
      "\temail: $email \n" +
      "\tpassword: $password \n" +
      "}\n" +
      "${response.body}");

  if (response.statusCode == 201) {
    print("success");
    return true;
  } else {
    print(response.statusCode);
    return false;
  }
}
