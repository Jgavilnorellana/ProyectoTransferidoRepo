import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
//import 'package:proyecto_memoria/screens/detalles_casos.dart';

class MisCasos extends StatefulWidget {
  const MisCasos({super.key});

  @override
  State<MisCasos> createState() => _MisCasosState();
}

class _MisCasosState extends State<MisCasos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0x90666666),
          title: const Text('Mis Casos'),
        ),
        body: Container(
          color: const Color(0x95454546),
          height: double.infinity,
          width: double.infinity,
          child: const SingleChildScrollView(
            
            //width: double.maxFinite,
            child: ListaCasos(),
          ),
        ));
  }
}

class ListaCasos extends StatefulWidget {
  const ListaCasos({super.key});

  @override
  State<ListaCasos> createState() => _ListaCasosState();
}

class _ListaCasosState extends State<ListaCasos> {
  FirebaseFirestore instancia = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  Future<String> direccionConLatLong(double lat, double long) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        geo.Placemark placemark = placemarks.first;
        return '${placemark.street ?? ''}, ${placemark.locality ?? ''}';
      }  
      return 'No se encontró la dirección';
    } catch (e) {
      return 'Error al obtener la dirección';
    } 
  } 

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 30, right: 15),
        //color: Colors.blue,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder(
              stream: instancia
                  .collection('fotos')
                  .where('uidUser', isEqualTo: user!.uid)
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Ha habido un error cargando la lista de casos');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                return Column(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    
                    double latitud = data['latitud'];
                    double longitud = data['longitud'];
                    
                    return Column(
                      children: [
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Icon(
                                Icons.fiber_manual_record,
                                size: 10,
                              ),
                            ),
                            const SizedBox(
                              height: 80,
                              width: 20,
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                //splashColor: Colors.grey,
                                splashColor: Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                radius: 40,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context, 
                                    '/detalles_caso',
                                    arguments: {
                                      'descripcion': document['descripcion'],
                                      'tipo': document['tipo'], 
                                      'latitud': document['latitud'], 
                                      'longitud': document['longitud'], 
                                      'url': document['url'],
                                    }
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          // ignore: prefer_interpolation_to_compose_strings
                                          'CASO ' + DateFormat('dd-MM-yyyy h:mm a').format(data['fecha'].toDate()) ,
                                          style: GoogleFonts.openSans(
                                              textStyle: const TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.w200,
                                          )),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward,
                                          size: 35,
                                        ),
                                      ],
                                    ),
                                    FutureBuilder<String>(
                                      future: direccionConLatLong(latitud, longitud),
                                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Obteniendo dirección...');
                                        } else if (snapshot.hasError) {
                                          return const Text('Error obteniendo la dirección');
                                        } else {
                                          return SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.6,
                                            child: Text(
                                            snapshot.data!,
                                            ),
                                        );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Color(0x99454546),
                          thickness: 2,
                        ),
                      ],
                    );
                  }).toList(),
                );
              })
        ]
      )
    );
  }
}

