import 'dart:convert';
import 'package:maple_crossing_application/profile.dart';

import 'Const.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:maple_crossing_application/SignupPage.dart';
import 'package:http/http.dart' as http;

Future<bool> fetchProfile(String user, String pass) async {
  //build api link
  final response = await http
      .post("https://cpritchar.scweb.ca/mapleCrossing/oauth/token", headers: {
    HttpHeaders.acceptHeader: "application/json",  
  }, body: {
    'grant_type': "password",
    'client_id': Const.CLIENT_ID,
    'client_secret': Const.CLIENT_SECRET,
    'username': user,
    'password': pass
  });

  if (response.statusCode == 200) {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final responseJson = json.decode(response.body);
    pref.setString('access_token',
        "${responseJson['token_type']} ${responseJson['access_token']}");
    pref.setString('refresh_token',
        "${responseJson['refresh_token']}");
    pref.setInt("expires_in", responseJson['expires_in']);

    User user = await getUser();
    
    pref.setInt("user_id", user.id);
    print("\n\n\n\n\n\n\n${user.id}\n\n\n\n\n\n\n\n\n");

    return true;
  } else {
    print('status code ${response.statusCode}: {\n' +
        'username: $user\n' +
        'password: $pass\n' +
        'id:       ${Const.CLIENT_ID}:${Const.CLIENT_SECRET}');

    return false;
  }
}

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return buildSignInPage();
  }
}

  MaterialApp buildSignInPage() {
    return buildMaterial(child: Scaffold(
        appBar: AppBar(
          title: Text("Sign In"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 500,
            child: Textfields(),
          ),
        ),
      ));
  }


class Textfields extends StatefulWidget {
  @override
  _TextfieldsState createState() => _TextfieldsState();
}

class _TextfieldsState extends State<Textfields> {
  TextEditingController _emailCon;
  TextEditingController _passwordCon;

  bool passwordIsVisable = true;
  final RegExp emailReg = new RegExp(
    r"([a-z,A-Z,0-9,.]+)@([a-z,A-Z]+)\.([a-z]+)",
    caseSensitive: false,
    multiLine: false,
  );
  var _obscure = true;

  @override
  void initState() {
    _emailCon = new TextEditingController();
    _passwordCon = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return ListView(
      children: <Widget>[
        Image(
          image: AssetImage("assets/icons/welcome_image.png"),
        ),
        Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "an email is required";
                    } else if (!emailReg.hasMatch(value)) {
                      return "the email you entered is not valid";
                    }
                    return null;
                  },
                  controller: _emailCon,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                          icon: _obscure
                              ? Icon(Icons.remove_red_eye)
                              : ImageIcon(
                                  AssetImage("assets/icons/eyeClosed.png")),
                          onPressed: () {
                            setState(() {
                              _obscure = !_obscure;
                            });
                          })),
                  controller: _passwordCon,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "a password is required";
                    }
                    return null;
                  },
                  obscureText: _obscure,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Signup()))
                            },
                        child: Text("I dont have an account")),
                    IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          String email = _emailCon.value.text;
                          String pass = _passwordCon.value.text;
                          if(_formKey.currentState.validate())
                          fetchProfile(email, pass).then( (val) => val ?  
                          Navigator.push(context,MaterialPageRoute(builder: (context) =>  LoadScreen())) : null);
                        })
                  ],
                ),
                Align(
                  child: FlatButton(
                    child: Text("Forgot Password?"),
                    onPressed: () => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Signup()))
                    },
                  ),
                  alignment: Alignment.centerLeft,
                )
              ],
            ),
          ),
      ],
    );
  }
}
