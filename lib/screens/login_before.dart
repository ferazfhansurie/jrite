import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jritev4/screens/login.dart';
import 'package:jritev4/screens/register.dart';

class ModeScreen extends StatefulWidget {
  const ModeScreen({super.key});

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
        Container(
          height: MediaQuery.of(context).size.height * 85/100,
          child: Stack(
            children: [
              Container(
                  
                  width: double.infinity,
                  child: Image.asset('assets/images/login-background.png',fit: BoxFit.cover,),
                ),
                Positioned(
                  top:445,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){
                            Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return RegistrationActivity(role: "Employer",);
                }));
                        },
                        child: Card(
                             color: Color.fromARGB(255, 208, 80, 21),
                          child: Stack(
                            children: [
                              Container(
                                height: 130,
                                 width: 155,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromARGB(255, 208, 80, 21),
                                ),
                              ),
                              Positioned(
                                top:101,
                                child: Container(
                                  height: 33,
                                   width: 155,
                                  decoration: BoxDecoration(
                                   borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(0),
                                                topLeft: Radius.circular(0),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                    color: Colors.white,
                                  ),
                                  child: Center(child: Text("Find a copywriter")),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                       SizedBox(width: 10,),
                       GestureDetector(
                        onTap: (){
                           Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return RegistrationActivity(role: "Freelancer",);
                }));
                        },
                         child: Card(
                          color: Color.fromARGB(255, 208, 80, 21),
                           child: Stack(
                            children: [
                              Container(
                                height: 130,
                                  width: 155,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromARGB(255, 208, 80, 21),
                                ),
                              ),
                              Positioned(
                                top:101,
                                child: Container(
                                   height: 32.5,
                                    width: 155,
                                  decoration: BoxDecoration(
                                    
                                   borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(0),
                                                topLeft: Radius.circular(0),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                    color: Colors.white,
                                  ),
                                   child: Center(child: Text("Become a copywriter")),
                                ),
                              ),
                            ],
                      ),
                         ),
                       ),
                      SizedBox(width: 10,),
                    ],
                  ),
                )
            ],
          ),
        ),
         GestureDetector(
          onTap: (){
             Navigator.of(context)
                        .push(CupertinoPageRoute(builder: (context) {
                      return LoginPage();
                    }));
          },
          child: Text('Sign In',style: TextStyle( color: Color.fromARGB(255, 208, 80, 21),fontSize: 18),)),
        
        ],
      ),
    );
  }
}
