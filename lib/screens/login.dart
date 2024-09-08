import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0x90666666),
          title: const Text('          Iniciar sesión'),
        ),
        body: Container(
          color: const Color(0x951C1C1C),
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            children: [
              const SizedBox(height: 130,),
              const UserAndPass(),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/recuperar_contrasena');
                },
                child: const  Text(
                  'Recuperar contraseña',
                  style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 195, 222, 224)),
                ),
              ),
              const SizedBox(height: 200,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes cuenta? ',
                    style: TextStyle(fontSize: 20),
                    ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/registrar');
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 25, 0, 255)),
                    ),
      
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class UserAndPass extends StatefulWidget {
  const UserAndPass({super.key});

  @override
  State<UserAndPass> createState() => _UserAndPassState();
}

final auth = FirebaseAuth.instance;

class _UserAndPassState extends State<UserAndPass> {

  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasenia = TextEditingController();

  @override
  void initState(){
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final permiso = await Permission.location.request();

    if (permiso.isGranted) {
      return;

    } else if (permiso.isDenied){
      if (context.mounted) {
        showDialog(
          barrierDismissible: false,
          // ignore: use_build_context_synchronously
          context: context, 
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Aviso'),
              content: const Text('Por favor asegurate de dar los permisos pertinentes para utilizar esta aplicación al abrirla'),
              actions: [
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  }, 
                  child: 
                    const Text('Cerrar aplicación')
                )
              ],
            );
          }
        );
      }
    }

    if (permiso.isPermanentlyDenied) {
      if (context.mounted) {
        showDialog(
          barrierDismissible: false,
          // ignore: use_build_context_synchronously
          context: context, 
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Aviso'),
              content: const Text('Permisos denegados, asegurese de activarlos para tener todas las funcionalidades'),
              actions: [
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  }, 
                  child: 
                    const Text('Ir a ajustes')
                )
              ],
            );
          }
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: correo,
          decoration: InputDecoration(
            icon: Icon(Icons.email, color: Colors.white.withOpacity(0.7)),
            labelText: 'Correo',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 20),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white
              )
            )
            ),
        ),
        const SizedBox(height: 15,),
        TextField(
          controller: contrasenia,
          decoration: InputDecoration(
            icon: Icon(Icons.password, color: Colors.white.withOpacity(0.7),),
            focusColor: Colors.red,
            labelText: 'Contraseña',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 20),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white
              )
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white
              )
            )
          ),
        ),
        //const SizedBox(height: 30,),
        //const Text('Recuperar cuenta'),
        const SizedBox(height: 100,),
        ElevatedButton(
          style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(250, 60))),
          onPressed: () async {
            try {
              // ignore: unused_local_variable
              UserCredential credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(email: correo.text, password: contrasenia.text);
              // ignore: await_only_futures
              User? user = await credencial.user;
              DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
              if (credencial.user != null && context.mounted) {
                if ((user.emailVerified == false) && context.mounted) {
                  throw FirebaseAuthException(code: 'email-not-verified'); 
                }

                await userDoc.update({
                  'last': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              }
              

              } on FirebaseAuthException catch (e) {
              if (context.mounted) {
                ventanaEmergente(context, e);
              }
            }
            contrasenia.clear();
            if (context.mounted) {
              FocusScope.of(context).unfocus();
            }
          }, 
          child: const Text(
            'Iniciar sesión',
            style: TextStyle(fontSize: 25),
          )
        ),
        const SizedBox(height:30),
      ],
    );
  }

  Future aviso(String titulo, String contenido) {
    return showDialog(
        context: context, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titulo),
            content: Text(contenido),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  },
                child: const Text('Cerrar')
              )
            ],
          );
        }
      );
  }

  void ventanaEmergente(BuildContext context, FirebaseAuthException mensajeError) {
    // ignore: unused_local_variable
    String mensaje;

    switch (mensajeError.code) {
      case 'user-not-found':
        mensaje = 'El correo ya está en uso.';
        break;
      case 'wrong-password':
        mensaje = 'La contraseña no es válido.';
        break;
      case 'email-not-verified':
      mensaje = 'El correo no ha sido verificado';
        break;
      default:
        mensaje = 'Correo o contraseña incorrecta';
    }

    if (context.mounted) {
      showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(mensaje),
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