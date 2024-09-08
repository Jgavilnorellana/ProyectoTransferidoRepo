import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:proyectotransferido/presentaciones/app_bar.dart';
import 'package:proyectotransferido/screens/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String myAcessToken = dotenv.env['ACCESS_TOKEN']!;

class SubirCaso extends StatefulWidget {
  final XFile foto;

  const SubirCaso({super.key, required this.foto});

  @override
  State<SubirCaso> createState() => _SubirCasoState();
}

class _SubirCasoState extends State<SubirCaso> {
  bool mapa = true;

  final Location location = Location();

  FirebaseFirestore instancia = FirebaseFirestore.instance;


  final tipos = <String>[
    'Bache', 
    'Desnivel', 
    'Grieta', 
    'Hundimiento',
    'Zona no pavimentada',
    'Deterioro del pavimento',
    'Acumulación de agua',
    'Obstrucción en la vía',
  ];

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

  late LocationData ubicacion;
  double? latitud;
  double? longitud;

  Future<void> revisionPermisos() async {
    try {
      location.changeSettings(accuracy: LocationAccuracy.high);
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          // Manejar el caso en que el usuario no habilita la ubicación
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          // Manejar el caso en que el usuario no otorga permisos
          return;
        }
      }
      LocationData ubicacion = await location.getLocation();

      setState(() {
        ubicacion = ubicacion;
        latitud = ubicacion.latitude;
        longitud = ubicacion.longitude;
      });

    } catch (e) {
      if (context.mounted) {
        showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      }
    }

  }

  @override
  void initState() {
    super.initState();
    revisionPermisos();
  }

  String descripcion = '';
  String seleccion = 'Bache';


  @override
  Widget build(BuildContext context) {
    File fotoArchivo = File(widget.foto.path);

    return Scaffold(
      resizeToAvoidBottomInset : true,
      appBar: const MyAppBar(
        title: 'Subir nuevo caso',
      ),
      body: 
        SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            color: const Color(0x95454546),
            child: Column(
              children: [
                Container(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 400,
                      child: Stack(
                        children: <Widget>[
                          if (mapa && latitud != null && longitud != null)
                          FlutterMap(
                          options: MapOptions(
                            onPositionChanged: (MapCamera position, bool hasGesture) {
                              setState(() {
                                latitud = position.center.latitude;
                                longitud = position.center.longitude;
                              });
                            } ,
                            initialCenter: LatLng(latitud! ,longitud!),
                            initialZoom: 17, 
                            interactionOptions: 
                            const InteractionOptions(
                              flags: InteractiveFlag.drag
                            ),
                          ), 
                          children: [
                            TileLayer(
                              urlTemplate: 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                              additionalOptions: {
                                'accessToken': myAcessToken,
                                'id': 'mapbox/streets-v12'
                              },
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(latitud!, longitud!), 
                                  child: const Icon(Icons.my_location)
                                )
                              ]
                            )
                          ]
                        ),
                        if (!mapa)
                          Image.file(
                            fotoArchivo,
                            fit: BoxFit.cover,
                            width: 300,
                            height: 400,  
                          ),
                        Container(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                mapa = !mapa;
                              });
                            }, 
                            child: 
                              const Icon(Icons.change_circle)
                          ),
                        )
                      ]),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  isExpanded: false,
                  alignment: Alignment.center,
                  value: seleccion,
                  onChanged: (value) {
                    setState(() {
                      seleccion = value!;
                    });
                  },
                  items: tipos.map<DropdownMenuItem<String>>((String valor)  {
                    return DropdownMenuItem<String>(
                      alignment: Alignment.center,
                      value: valor,
                      child: Text(valor),
                    );
                  }).toList()
                  
                ),
                const SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        descripcion = value;
                      });
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                    maxLines: 4,
                    maxLength: 256,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  )
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () {
                    
                    
                    // ignore: unused_local_variable
                    Future<String> compressedFile = compressImageAndUpload(widget.foto);
                    compressedFile.toString();
                    guardarFoto(compressedFile, user!.uid, latitud!, longitud!, seleccion, DateTime.now(), descripcion);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Aviso'),
                          content: const Text('Fotografía subida con exito'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cerrar'),
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Home()),
                                  (route) => false,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }, 
                  child: const Text(
                    'Subir caso',
                    style: TextStyle(fontSize: 20),
                  )
                ),
              ],
              
            ),
          ),
        ),
    );
  }
}