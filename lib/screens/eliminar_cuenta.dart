import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class EliminarCuenta extends StatefulWidget {
  const EliminarCuenta({super.key});

  @override
  State<EliminarCuenta> createState() => _EliminarCuentaState();
}

class _EliminarCuentaState extends State<EliminarCuenta> {

  Future<List<String>> eliminarDocumentos(String uid) async {
    final firestore = FirebaseFirestore.instance;

    final querySnapshot = await firestore.collection('fotos')
      .where('uidUser', isEqualTo: uid)
      .get();

    List<String> urls = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      if (data.containsKey('url')) {
        var url = data['url'];
        urls.add(url);
      }
      await doc.reference.delete();
    }
    return urls;
  }

  Future<void> eliminarImagenes(List<String> urls) async {
    final storage = FirebaseStorage.instance;

    for (var url in urls) {
      final ref = storage.refFromURL(url);
      await ref.delete();
    }
  }

  Future<void> eliminarCuenta(User user) async {
    //final auth = FirebaseAuth.instance;

    try {
      await user.delete();
    } catch (e) {
      //IMPLEMENTAR
      //print('no se pudo matar $e');
    }
  } 

  late TextEditingController nombre;

    @override
  void initState() {
    super.initState();
    nombre = TextEditingController();
  }

  bool icono = false;

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final nombreAEscribir = args['usuariox'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(190, 154, 160, 166),
        title: const Text('Eliminar cuenta'),
      ),
      body: Container(
        color: const Color(0x95454546),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 20,),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: TextField(
                controller: nombre,
                decoration: InputDecoration(
                  icon: Icon(Icons.person, color: Colors.white.withOpacity(0.7)),
                  labelText: '',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 20),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)
                  ),
                ),
                onChanged: (String texto) {
                  if (texto == nombreAEscribir) {
                    setState(() {
                      icono = true;
                    });
                  } else {
                    setState(() {
                      icono = false;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 10,),
            Text('Escribe ' "'$nombreAEscribir'" ' para poder eliminar tu cuenta'),
            const SizedBox(height: 20,),
            Visibility(
              visible: icono, /*Comienza en false*/ 
              child: ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 35, 12))
                ),
                child: 
                  const Text(
                    'Eliminar cuenta',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                onPressed: () async {
                  try {
                    final auth = FirebaseAuth.instance;
                    final user = auth.currentUser;

                    if (user==null) {
                      throw Exception('No hay usuario autenticado');
                    }

                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                      'tokens': FieldValue.delete(),
                    });

                    List<String> urls = await eliminarDocumentos(user.uid);

                    await eliminarImagenes(urls);

                    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

                    await eliminarCuenta(user);

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cuenta eliminada con éxito'))
                  );
                    if (context.mounted) {
                      Navigator.pushNamed(context, '/login');
                    }
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }, 
              ),
            )
          ],
        ),
      ),
    );
  }
}