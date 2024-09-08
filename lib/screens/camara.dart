import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';

class Camara extends StatefulWidget {
  const Camara({super.key});

  @override
  State<Camara> createState() => _CamaraState();
}



class _CamaraState extends State<Camara> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  bool sacandoFoto = true;
  bool isFlashOn = false;

  void ventanaEmergente(BuildContext context, String mensajeError) {
    // ignore: unused_local_variable
    String mensaje;

    if (context.mounted) {
      showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(mensajeError),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
                openAppSettings();
              }, 
              child: 
                const Text('Ir a ajustes')
            )
          ],
        );
      });
    }
  }

  @override
  void initState() {
    startCamera();
    super.initState();
  }

  void startCamera() async {

    cameras = await availableCameras();
    PermissionStatus permisosCamaras = await Permission.camera.status;

    cameraController = CameraController(
      cameras[0], 
      ResolutionPreset.high,
      enableAudio: false,
    );

    if (mounted) {
      await cameraController.initialize().then((value) {
      if(!mounted) {
        return;
      }
      setState(() {});
    }).catchError((e) {
      if (permisosCamaras.isPermanentlyDenied && context.mounted){
        // ignore: use_build_context_synchronously
        ventanaEmergente(context, 'Habilita los permisos de la camara en las configuraciones de tu dispositivo');
      } else if (context.mounted){
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/home');
      }
    });
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

    //Aca hare las instancias del storage y firestore donde guardare todo lo necesario

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> guardarFoto(Future<String> futureUrl, String uid, num lat, num lon, String tipo, DateTime fecha, String descripcion) async {
    try {
      String url = await futureUrl;

      await firestore.collection('fotos').add({
        'descripcion': descripcion,
        'fecha': fecha,
        'latitud': lat,
        'longitud': lon,
        'tipo': tipo,
        'uidUser': uid,
        'url': url,
      });
    } catch (e) {
      //print(e);


      //hay que implementar



    }
  }

  FirebaseStorage storage = FirebaseStorage.instance;
  Future<String> compressImageAndUpload(XFile file) async {
    final inPath = file.path;
    final outPath = inPath.replaceFirst(RegExp(r'.jpg'), '_compreso.jpg');
  
    final imagenComprimida = await FlutterImageCompress.compressAndGetFile(
      inPath, 
      outPath,
      quality: 50,
      minHeight: 400,
      minWidth: 300,
    );
    


    String imageID = DateTime.now().millisecondsSinceEpoch.toString() + user!.uid.toString().substring(0,4);

    try {
      TaskSnapshot snapshot = await storage.ref('/uploads/$imageID.jpg').putFile(File(imagenComprimida!.path));
    
      String url = await snapshot.ref.getDownloadURL();
    
      return url;
    } on FirebaseException catch (e) {
      //print(e);



      //Hay que implementaaaar




      return 'Error al subir la foto $e';
    }
  }


  @override
  Widget build(BuildContext context) {
    try{
      return Scaffold(
        backgroundColor: const Color(0x998c8c8c),
        body: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    color: const Color(0x008c8c8c),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: CameraPreview(cameraController)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pop(context);
                        }, 
                        icon: const Icon(Icons.arrow_back,),
                      ),
                      IconButton(
                        iconSize: 40,
                        onPressed: () {
                          setState(() {
                            isFlashOn = !isFlashOn;
                          });
                          if (isFlashOn) {
                            cameraController.setFlashMode(FlashMode.always);
                            
                          } else {
                            cameraController.setFlashMode(FlashMode.off);
                          }
                        }, 
                        icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
                      ),
                    ],
                  )
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(45),
                          onTap: sacandoFoto ? () async {
                            setState(() {
                              sacandoFoto = !sacandoFoto;
                            });
                            try {
                              // ignore: unused_local_variable
                              XFile? file = await cameraController.takePicture();
                              if (context.mounted) {
                                Navigator.pushNamed(
                                  context, 
                                  '/subir_caso',
                                  arguments: file,
                                  );
                              }

                            } on Exception catch (e) {
                              if (context.mounted) {
                                ventanaEmergente(context, e as String);
                              }
                            } finally {
                              setState(() {
                                sacandoFoto = !sacandoFoto;
                              });
                            }
                          } : null,
                      child: const CircleAvatar(
                        radius: 50,
                        child: Icon(
                          Icons.photo_camera, 
                          color: Color(0x998c8c8c),
                          size: 50,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    } catch (e) {
      return Container(

      );
    }
  }
}