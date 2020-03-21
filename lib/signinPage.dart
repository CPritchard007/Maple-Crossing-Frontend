import 'package:flutter/material.dart';
import 'package:maple_crossing_application/SignupPage.dart';
import 'package:maple_crossing_application/main.dart';

class Signin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primaryColor: Color.fromRGBO(254, 95, 95, 1)),
        home: Scaffold(
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
                    suffixIcon: IconButton(icon: _obscure?Icon(Icons.remove_red_eye): ImageIcon(AssetImage("assets/icons/eyeClosed.png")), onPressed: (){
                      setState(() {
                        _obscure = !_obscure;

                      });
                    })
                  ),
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
                          _formKey.currentState.validate();
                          if (_formKey.currentState.validate())
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LaunchScene()));
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
            )),
      ],
    );
  }
}
