import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:proyectotransferido/screens/camara.dart';
import 'package:proyectotransferido/screens/configurar_cuenta.dart';
import 'package:proyectotransferido/screens/detalles_casos.dart';
import 'package:proyectotransferido/screens/eliminar_cuenta.dart';
import 'package:proyectotransferido/screens/home.dart';
import 'package:proyectotransferido/screens/login.dart';
import 'package:proyectotransferido/screens/mis_casos.dart';
import 'package:proyectotransferido/screens/perfil.dart';
import 'package:proyectotransferido/screens/recuperar_contrasena.dart';
import 'package:proyectotransferido/screens/registro.dart';
import 'package:proyectotransferido/screens/subir_caso.dart';

class Routes extends StatelessWidget {
  const Routes({super.key});
  
Future<bool> estaLogeado(BuildContext context) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No hay usuario autenticado, redirige a la pantalla de inicio de sesión
      return false;
    }

    // Verifica si el token es válido o ha expirado
    if (!await _verificarToken(user, context)) {
      // Si _verificarToken retorna false, estaLogeado también retorna false inmediatamente
      return false;
    }

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> _verificarToken(User user, BuildContext context) async {
  try {
    // Intenta obtener un nuevo token
    await user.getIdToken(true);
    return true;  // Si el token es válido, retorna true
  } catch (e) {
    // Siempre cierra sesión sin importar el tipo de excepción
    await FirebaseAuth.instance.signOut();

    // Mostrar mensaje usando Fluttertoast
    Fluttertoast.showToast(
      msg: "Sesión inválida, por favor inicie sesión nuevamente",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,  // Puedes cambiar la posición
    );

    // Retorna false en todos los casos
    return false;
  }
}

    /* final uid = user.uid;
    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    //Verificar si el documento existe y si tiene tokens válidos
    if (!docSnapshot.exists || docSnapshot.data()?['tokens'] == null || (docSnapshot.data()?['tokens'] as List).isEmpty) {
      // Si el documento no existe o la lista de tokens está vacía, cerrar sesión
      await FirebaseAuth.instance.signOut();
      return false;
    } */
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: estaLogeado(context),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final bool estaLogeadoResultado = snapshot.data ?? false;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
              ),
              title: 'Proyecto titulo',
              /* home: Scaffold(
                body: estaLogeadoResultado ? const Home() : const Login(),
              ), */
              initialRoute: estaLogeadoResultado ? '/home' : '/login',
              routes: {
                '/home': (context) => const Home(),
                '/login': (context) => const Login(),
                '/mis_casos': (context) => const MisCasos(),
                '/perfil': (context) => const Perfil(),
                '/camara': (context) => const Camara(),
                '/configurar_cuenta': (context) => const ConfigurarCuenta(),
                '/registrar': (context) => const Registro(),
                '/recuperar_contrasena': (context) => const RecuperarCuenta(),
                '/subir_caso': (context) {
                    final XFile? foto = ModalRoute.of(context)?.settings.arguments as XFile?;
                    return SubirCaso(foto: foto!);
                },
                '/eliminar_cuenta': (context) => const EliminarCuenta(),
              },
                //'detalles_caso': (context) => const DetallesCaso(index: , caso: caso),
              onGenerateRoute: (settings) {
              if (settings.name == '/detalles_caso') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) {
                    return DetallesCaso(
                      descripcion: args['descripcion'],
                      tipo: args['tipo'], 
                      latitud: args['latitud'], 
                      longitud: args['longitud'], 
                      url: args['url'],
                      
                    );
                  },
                );
              }
              return null;
              }
            );
          }
        }
      }
    ); 
  }
}