import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('El snapshot.haserror paso');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                return Column(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
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
                                    Text(
                                      style: const TextStyle(fontSize: 15),
                                      '${data['latitud']} , ${data['longitud']}'
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

