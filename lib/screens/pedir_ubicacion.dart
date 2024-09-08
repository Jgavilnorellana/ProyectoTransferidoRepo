import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:proyectotransferido/screens/login.dart';

class PedirPermisos extends StatefulWidget {
  const PedirPermisos({super.key});

  @override
  State<PedirPermisos> createState() => _PedirPermisosState();
}

class _PedirPermisosState extends State<PedirPermisos> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      final permiso = await Permission.location.request();
      
      if (permiso.isGranted && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          '/login', 
          (Route<dynamic> route) => false,
        );
      } else {
        if (context.mounted) {
          _mostrarDialogoPermisos();
        }

        if (permiso.isPermanentlyDenied && context.mounted) {
          _mostrarDialogoPermisosDenegados();
        }
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Ocurrió un error al solicitar permisos: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _mostrarDialogoPermisos() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: const Text('Por favor asegúrate de dar los permisos pertinentes para utilizar esta aplicación'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoPermisosDenegados() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: const Text('Permisos denegados, asegúrate de activarlos para tener todas las funcionalidades'),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text('Ir a ajustes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
