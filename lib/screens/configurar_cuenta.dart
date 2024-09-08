import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatosUsuario {

  void ventanaEmergente(BuildContext context, String error) {
    // ignore: unused_local_variable
    String mensaje;

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

  Future<void> cambiarNombre(BuildContext context, nuevoNombre) async {
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'usuario': nuevoNombre});
    } catch (e) {
      if (context.mounted) {
        ventanaEmergente(context, e.toString());
      }
    }
  }
}

class ConfigurarCuenta extends StatefulWidget {
  const ConfigurarCuenta({super.key});

  @override
  State<ConfigurarCuenta> createState() => _ConfigurarCuentaState();
}

class _ConfigurarCuentaState extends State<ConfigurarCuenta> {

  late TextEditingController nuevoUsuariox;
  late String usuarioxActual;
  late DatosUsuario datosUsuario;

  @override
  void initState() {
    super.initState();
    nuevoUsuariox = TextEditingController();
    datosUsuario = DatosUsuario();
    datosUsuario.cargarDatos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String usuariox = args['usuario'];
    usuarioxActual = usuariox;
    
    setState(() {
      nuevoUsuariox.text = usuariox;
    });
  }

  @override
  void dispose() {
    nuevoUsuariox.dispose();
    super.dispose();
  }

  bool icono = false;

  @override
  Widget build(BuildContext context) {

    return Material(
    child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0x90666666),
          title: const Text('Configuración Cuenta'),
        ),
        body: SafeArea(
          child: Container(
            width: double.maxFinite,
            //color: Theme.of(context).colorScheme.background,
            color: const Color(0x95454546),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 70),
                const CircleAvatar(
                  radius: 70,
                  backgroundImage: 
                    AssetImage('assets/jolounai.jpg'),
                ),
                const SizedBox(height: 15,),
                const Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(color: Color.fromARGB(255, 64, 57, 250), fontSize: 22),
                ),
                const SizedBox(height: 20),

                Column(
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.9,
                      child: Row(
                        children: [
                          Expanded(
                            child: FractionallySizedBox(
                              widthFactor: 0.9,
                              child: TextField(
                                controller: nuevoUsuariox,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.email, color: Colors.white.withOpacity(0.7)),
                                  labelText: 'Nuevo nombre',
                                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 20),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white,),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white)
                                  )
                                  ),
                                  onChanged: (value) {
                                    if (value == usuarioxActual) {
                                      setState(() {
                                        icono = false;
                                      });
                                    } else{
                                      setState(() {
                                        icono = true;
                                      });
                                    }
                                  },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: icono, /*Comienza en false*/ 
                            child: IconButton(
                              onPressed: () async {
                                try{
                                  await datosUsuario.cambiarNombre(context, nuevoUsuariox.text);
                                  setState(() {
                                    usuarioxActual = nuevoUsuariox.text;
                                    icono = false;
                                  });
                                } catch (e) {
                                  if (context.mounted) {
                                    ventanaEmergente(context, e.toString());
                                  }
                                }
                                if (context.mounted) {
                                  Navigator.pushNamed(context, '/perfil');
                                }
                            }, 
                            icon: const Icon(
                              Icons.update,
                              size: 35,
                              weight: 100,
                              color: Color.fromARGB(255, 64, 57, 250),
                              )
                            ),
                          )
                        ]
                      ),
                    ),
                     
                    const SizedBox(height: 45),
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 35, 12))
                      ),
                      child: 
                        const Text(
                          'Eliminar cuenta',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      onPressed: () {
                        Navigator.pushNamed(
                        context, 
                        '/eliminar_cuenta',
                        arguments: {'usuariox': usuarioxActual,},
                      );
                      }, 
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
    void ventanaEmergente(BuildContext context, String error) {
    // ignore: unused_local_variable
    String mensaje;

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
