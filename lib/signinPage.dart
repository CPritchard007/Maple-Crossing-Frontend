import 'package:flutter/material.dart';

class Signin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(254, 95, 95, 1)
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Sign In"),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
              Navigator.pop(context);
          }, ),
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
    bool passwordIsVisable = true;

  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image(image: AssetImage("assets/icons/welcome_image.png"),),
                TextField(
              obscureText: false,
              decoration: InputDecoration(
              labelText: 'Email',
                  ),
                ),TextField(
              obscureText: passwordIsVisable,
              decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(color: Color.fromRGBO(160 , 160, 160, 1),
              icon: (passwordIsVisable)? Icon( Icons.remove_red_eye ) : Image.asset("assets/icons/eyeClosed.png", color: Color.fromRGBO(160 , 160, 160, 1) ,),
              onPressed: () => setState((){passwordIsVisable = !passwordIsVisable;}), padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              )
           ),
         ),
         Align(alignment: Alignment.centerRight,
         child: IconButton(icon: Icon(Icons.arrow_forward), onPressed: ()=>{
                  setState((){
                    //TODO: ADD API PUSH
                  })
                }))
       ],
    );
  }
}