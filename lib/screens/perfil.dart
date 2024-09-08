import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyectotransferido/presentaciones/drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyectotransferido/screens/login.dart';

class DatosUsuario {
  User? user = FirebaseAuth.instance.currentUser;

  String correo = '';
  String nombre = '';

  Future<void> cargarDatos() async {
    var documento = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .get();

    correo = documento['email'];
    nombre = documento['usuario'];
  }
}

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    final datosUsuario = DatosUsuario();
    return FutureBuilder(
      future: datosUsuario.cargarDatos(), 
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
          ),
          );
        } else if (snapshot.hasError) {
          return const Text('Error al cargar los datos del usuario');
        } else {
          return Material(
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0x90666666),
                title: const Text('Mi perfil'),
              ),
              drawer: const MyDrawer(),
              body: SafeArea(
                child: Container(
                  width: double.maxFinite,
                  //color: Theme.of(context).colorScheme.background,
                  color: const Color(0x95454546),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 60),
                      //TextoMiPerfil(),
                      const SizedBox(height: 10),
                      const CircleAvatar(
                        radius: 70,
                        backgroundImage: 
                          AssetImage('assets/jolounai.jpg'),
                      ),
                      const SizedBox(height: 15),
                      Textox(textox: datosUsuario.nombre, applyFontWeight: false,),
                      Textox(textox: datosUsuario.correo, applyFontWeight: true,),
                      const SizedBox(height: 20),
                      const MisCasosButton(),
                      //SizedBox(height: 20,),
                      CambiarConfiguracionCuenta(usuario: datosUsuario.nombre, correo: datosUsuario.correo),
                      const LogoutButton(),
                      
                    ],
                  ),
                ),
              ),
            ),
          );
        }

      });

  }
}

class NombreUser extends StatelessWidget {
  final String nombre;

  const NombreUser({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) {
    final datos = DatosUsuario();
    datos.cargarDatos();
    return Column(
      children: [
        Text(
          textAlign: TextAlign.center,
          nombre,
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              color: Colors.white.withOpacity(1),
              fontSize: 25,
            )
          ),
        ),
      ],
    );
  }
}

class Textox extends StatelessWidget {

  final String textox;
  final bool applyFontWeight;

  const Textox({super.key, required this.textox, this.applyFontWeight = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          textAlign: TextAlign.center,
          textox,
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              color: Colors.white.withOpacity(1),
              fontSize: 25,
              fontWeight: applyFontWeight ? FontWeight.w200 : FontWeight.normal,
            ),
          )
        ),
      ],
    );
  }
}

class TextoMiPerfil extends StatelessWidget {
  const TextoMiPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Mi perfil', 
      style: 
      TextStyle(
        fontSize: 60,
        color: Colors.black.withOpacity(0.7),
      ),
    );
  }
}

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        ElevatedButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 35, 12))
          ),
          child: 
            const Text(
              'Cerrar sesion',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          onPressed: () async {
            try {
              User? user = FirebaseAuth.instance.currentUser;
              DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);

              await userDoc.update({'logged': false});


              String? token = await user.getIdToken();
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                'tokens': FieldValue.arrayRemove([token]),
              });
              await auth.signOut();
              setState(() {});
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            } catch (e) {
              if (context.mounted) {
                ventanaEmergente(context, e.toString());
              }
            }
          }, 
        ),
      ],
    );
  }

void ventanaEmergente(BuildContext context, String error) {
    // ignore: unused_local_variable
    String mensaje;

    if (context.mounted) {
      showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              child: 
                const Text('Cerrar')
            )
          ],
        );
      }
    );
    }
  }
}

class MisCasosButton extends StatelessWidget {
  const MisCasosButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Container(
          padding: const EdgeInsets.all(8.5),
          width: double.infinity,
          child: 
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/mis_casos');
            }, 
            child: Row(
              children: [
                const Icon(Icons.map, color: Colors.black87,),
                Text(
                  'Mis casos',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 30,
                      fontWeight: FontWeight.w400
                    ), 
                  ) 
                )
              ]
            )
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class CambiarConfiguracionCuenta extends StatelessWidget {

  final String usuario;
  final String correo;
  const CambiarConfiguracionCuenta({super.key, required this.usuario, required this.correo});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.5),
          width: double.infinity,
          child: 
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context, 
                '/configurar_cuenta',
                arguments: {'usuario': usuario, 'correo': correo},
              );
            }, 
            child: Row(
              children: [
                const Icon(Icons.settings, color: Colors.black87,),
                Text(
                  'Configurar cuenta',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 30,
                      fontWeight: FontWeight.w400
                    ), 
                  ) 
                )
              ]
            )
          ),
        ),
        const Divider(),
      ],
    );
  }
}