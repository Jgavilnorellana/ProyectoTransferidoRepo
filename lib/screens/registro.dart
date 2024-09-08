import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0x90666666),
        title: const Text('Registrarse'),
      ),
      body: Container(
        color: const Color(0x951C1C1C),
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Column(
          children: [
            //SizedBox(height: 150,),
            Container(
              padding: const EdgeInsets.only(top: 80),
              child: const 
                UserAndPass()
              ),
          ],
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

class _UserAndPassState extends State<UserAndPass> {

  final TextEditingController usuario = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasenia = TextEditingController();
  final TextEditingController contraseniaRepetida = TextEditingController();
  String rellenaTodo = '';

  final Registrar registrar = Registrar(); 

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(rellenaTodo, style: const TextStyle(color: Color.fromARGB(255, 255, 247, 3), fontSize: 16),),
        TextField(
          controller: usuario,
          decoration: InputDecoration(
            icon: Icon(Icons.email, color: Colors.white.withOpacity(0.7)),
            labelText: 'Usuario',
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
          controller: correo,
          decoration: InputDecoration(
            icon: Icon(Icons.email, color: Colors.white.withOpacity(0.7)),
            labelText: 'Correo electrónico',
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
          obscureText: true,
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
        const SizedBox(height: 15,),
        TextField(
          controller: contraseniaRepetida,
          obscureText: true,
          decoration: InputDecoration(
            icon: Icon(Icons.password, color: Colors.white.withOpacity(0.7),),
            focusColor: Colors.red,
            labelText: 'Repetir contraseña',
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
        const SizedBox(height: 75,),
        ElevatedButton(
          onPressed: () {
            if (usuario.text.isEmpty || correo.text.isEmpty || contrasenia.text.isEmpty || contraseniaRepetida.text.isEmpty ){
              setState(() {
                rellenaTodo = 'Rellena todos los campos requeridos';
              });

            } if (contrasenia.text != contraseniaRepetida.text){
              setState(() {
                rellenaTodo = 'Las contraseñas no coinciden';
              });
            } if ( !(usuario.text.isEmpty || correo.text.isEmpty || contrasenia.text.isEmpty || contraseniaRepetida.text.isEmpty) && !(contrasenia.text != contraseniaRepetida.text)) {
              registrar.registrarCuenta(usuario.text, correo.text, contrasenia.text, contraseniaRepetida.text, context);
            
            }
            contrasenia.clear();
            FocusScope.of(context).unfocus();
          }, 
          child: const Text(
            'Crear cuenta',
            style: TextStyle(fontSize: 20),
          )
        ),
      ],
    );
  }
}

class Registrar {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  

  Future<void> registrarCuenta(String usuario, String correo, String contrasenia, String contraseniaRepetida, BuildContext context) async {
    final usuarioExistente = await db.collection('users').doc(usuario).get();

    if (usuarioExistente.exists) {
      if (context.mounted) {
        showDialog(
        context: context, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Usuario ya se encuentra en uso'),
            content: const Text('Por favor, use otro nombre de usuario'),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop, 
                child: const Text('Cerrar')
              )
            ],
          );
        }
      );
      }
      return;
    }

    try {
      UserCredential credencialUsuario = await auth.createUserWithEmailAndPassword(
        email: correo, 
        password: contrasenia,
      );

      await credencialUsuario.user?.sendEmailVerification();

      await db.collection('users').doc(credencialUsuario.user?.uid).set({
        'email': correo,
        'usuario': usuario,
        'fecha': DateTime.now().millisecondsSinceEpoch,
        'logged': false,
        'tokens': FieldValue.arrayUnion([]),
        'last': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (context.mounted) {
        showDialog(
        context: context, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Revise su correo'),
            content: const Text('En la bandeja de su correo estara el mail de verificación'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop;
                  Navigator.pushNamed(context, '/login');
                  },
                child: const Text('Cerrar')
              )
            ],
          );
        }
      );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ventanaEmergente(context, e);
      }
    }

  } //Future<void> registrar

  void ventanaEmergente(BuildContext context, FirebaseAuthException mensajeError) {
    // ignore: unused_local_variable
    String mensaje;

    switch (mensajeError.code) {
      case 'email-already-in-use':
        mensaje = 'El correo ya está en uso.';
        break;
      case 'invalid-email':
        mensaje = 'El correo no es válido.';
        break;
      case 'weak-password':
        mensaje = 'La contraseña es muy débil';
        break;
      default:
        mensaje = 'Ocurrió un error inesperado';
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
