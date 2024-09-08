import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecuperarCuenta extends StatefulWidget {
  const RecuperarCuenta({super.key});

  @override
  State<RecuperarCuenta> createState() => _RecuperarCuentaState();
}

class _RecuperarCuentaState extends State<RecuperarCuenta> {
  late TextEditingController correo;

    @override
  void initState() {
    super.initState();
    correo = TextEditingController();
  }

  bool icono = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(190, 154, 160, 166),
        title: const Text('Recuperar contraseña'),
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
                controller: correo,
                decoration: InputDecoration(
                  icon: Icon(Icons.mail, color: Colors.white.withOpacity(0.7)),
                  labelText: '',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 20),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10,),
            const Text('Escribe el correo asociado a la cuenta que deseas recuperar'),
            const SizedBox(height: 20,),
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 35, 12))
              ),
              child: 
                const Text(
                  'Enviar correo',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              onPressed: () async {
                await FirebaseAuth.instance
                  .sendPasswordResetEmail(email: correo.text);

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setInt('auth_time', DateTime.now().millisecondsSinceEpoch);

                if (context.mounted) {
                  showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Revise su correo'),
                      content: const Text('Revise su bandeja de entrada. Si no hay ningún correo, asegurese que el correo está asociado a una cuenta existente.'),
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
              }, 
            )
          ],
        ),
      ),
    );
  }
}