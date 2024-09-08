import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return  Material(
      child: SizedBox(
        //width: MediaQuery.of(context).size.width * 0.30,
        child: Drawer(
          backgroundColor: const Color.fromARGB(190, 154, 160, 166),
          surfaceTintColor: Colors.red,
          child: Builder(
            builder: (context) {
              return ListView(
                children: <Widget>[
                   const SizedBox(
                    height: 100,
                    child: DrawerHeader(
                      curve: Curves.bounceIn,
                      duration: Duration(seconds: 2),
                      child: 
                        Text(
                          'Menu'
                        )
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home, size: 50,),
                    title: Text(
                      'Home',
                      style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          fontSize: 20
                        )
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/home');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person, size: 50,),
                    title: Text(
                      'Mi perfil',
                      style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          fontSize: 20
                        )
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/perfil');
                    },
                  ),
                ],
              );
            }
          )
        ),
      ),
    );
  }
}