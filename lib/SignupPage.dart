import 'package:flutter/material.dart';
import 'package:maple_crossing_application/main.dart';
import 'package:maple_crossing_application/signinPage.dart';

class Signup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Color.fromRGBO(254, 95, 95, 1)),
      home: Scaffold(
          appBar: AppBar(
            title: Text("Sign up"),
            backgroundColor: Color.fromRGBO(254, 95, 95, 1),
          ),
          body: ListView(
            children: <Widget>[
              Image(
                image: AssetImage("assets/icons/welcome_image.png"),
              ),
              Padding(padding: const EdgeInsets.all(12.0), child: SignupForm()),
            ],
          )),
    );
  }
}

class SignupForm extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final RegExp emailReg = new RegExp(
    r"([a-z,A-Z,0-9,.]+)@([a-z,A-Z]+)\.([a-z]+)",
    caseSensitive: false,
    multiLine: false,
  );

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
            validator: (value) {
              if (value.isEmpty) {
                return "a first name is required";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "last name"),
            validator: (value) {
              if (value.isEmpty) {
                return "a last name is required";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "username"),
            validator: (value) {
              if (value.isEmpty) {
                return "a username is required";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "email"),
            validator: (value) {
              if (value.isEmpty) {
                return "an email is required";
              } else if (!emailReg.hasMatch(value)){
                return "this is not a valid email";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "password"),
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Signin()))
                      },
                  child: Text("I already have an account")),
              IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    _formKey.currentState.validate();
                    if (_formKey.currentState.validate())
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyApp()));
                  })
            ],
          )
        ],
      ),
    );
  }

  void generateUsername(String username, String firstName, String lastName) {
    username = firstName[0] + lastName;
  }
}
