import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyectotransferido/presentaciones/app_bar.dart';

final String myAcessToken = dotenv.env['ACCESS_TOKEN']!;


class DetallesCaso extends StatefulWidget {
  final String descripcion;
  final String tipo;
  final double latitud;
  final double longitud;
  final String url;


  const DetallesCaso({super.key, required this.descripcion, required this.tipo, required this.latitud, required this.longitud, required this.url});

  @override
  State<DetallesCaso> createState() => _DetallesCasoState();
}

class _DetallesCasoState extends State<DetallesCaso> {

  bool mapa = true;

  FirebaseFirestore instancia = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: widget.tipo,
      ),
      body: 
        Container(
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
                        if (mapa)
                        FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(widget.latitud,widget.longitud),
                          initialZoom: 17, 
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.pinchZoom),
                        ), 
                        children: [
                          TileLayer(
                            urlTemplate: 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                            additionalOptions: {
                              'accessToken': myAcessToken,
                              'id': 'mapbox/streets-v12'
                          })
                        ]
                      ),
                      if (!mapa)
                        Image.network(
                          widget.url,
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
              Text(
                'Tipo de falla: ${widget.tipo}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800
                ),  
              ),
              const SizedBox(height: 10,),
              Container(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                child:  Text(
                  textAlign: TextAlign.justify,
                  widget.descripcion,
                  style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400
                    ),
                  ) 
                )
              )
            ],
          ),
        ),
    );
  }
}
