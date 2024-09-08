import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster_2/flutter_map_marker_cluster.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:proyectotransferido/presentaciones/drawer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart' as geo;

final String myAcessToken = dotenv.env['ACCESS_TOKEN']!;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Location location = Location();
  final MapController mapController = MapController();
  List<String> marcadoresVisibles = [];

  bool oculto = false;
  IconData icono = Icons.person_off;

  void ocultarMarcadorUsuario() {
    setState(() {
      oculto = !oculto;
      if (oculto) {
        icono = Icons.person;
      } else {
        icono = Icons.person_off;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    revisionPermisos();
    marcadoresVisibles = ['Bache', 'Desnivel', 'Grieta', 'Hundimiento', 'Zona no pavimentada', 'Deterioro del pavimento', 'Acumulación de agua', 'Obstrucción en la vía'];
  }

  void onFiltroChanged(List<String> nuevosMarcadoresVisibles) {
    setState(() {
      marcadoresVisibles = nuevosMarcadoresVisibles;
    });
  }



  Future<void> revisionPermisos() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(190, 154, 160, 166),
          title: const Text('Home'),
        ),
        drawer: const MyDrawer(),
        body: StreamBuilder<LocationData>(
          stream: location.onLocationChanged,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final locationData = snapshot.data!;
            double latitud1 = locationData.latitude!;
            double longitud1 = locationData.longitude!;

            return Stack(
              children: [
                MarcadoresYElMapa(
                  latitud: latitud1, 
                  longitud: longitud1, 
                  oculto: oculto, 
                  mapController: mapController, 
                  marcadoresVisibles: marcadoresVisibles,
                ),
                const AlertButton(),
                CentrarUsuario(
                  latitud: latitud1, 
                  longitud: longitud1, 
                  centrarCamara: () {
                    mapController.move(LatLng(latitud1, longitud1), 20.0);
                  }
                ),
                OcultarUsuario(botonPresionado: ocultarMarcadorUsuario, icono: icono),
                ApuntarAlNorte(
                  botonPresionado: () {
                    mapController.rotate(0);

                  }, 
                ),
                const ListaMarcadores(),
                Filtro(tiposMarcadores: const ['Bache', 'Desnivel', 'Grieta', 'Hundimiento', 'Zona no pavimentada', 'Deterioro del pavimento', 'Acumulación de agua', 'Obstrucción en la vía'], 
                      onFiltroChanged: onFiltroChanged,),
              ],
            );
          },
        ),
      ),
    );
  }
}
  
class AlertButton extends StatelessWidget {
  const AlertButton({super.key});


  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 25,
      child: 
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color.fromARGB(255, 249, 46, 32),
          child: IconButton(
            icon: const Icon(
              Icons.campaign,
              color: Color.fromARGB(255, 45, 44, 44),
              size: 50,
              opticalSize: 10),
            onPressed: () {
              Navigator.pushNamed(context, '/camara');
            },
          ),  
        )
    );
  }
}

class CentrarUsuario extends StatelessWidget {

  final double latitud;
  final double longitud;
  final VoidCallback centrarCamara;

  const CentrarUsuario({super.key, required this.latitud, required this.longitud, required this.centrarCamara});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      top: 25,
      child: 
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color.fromARGB(255, 188, 174, 173),
          child: IconButton(
            icon: const Icon(
              Icons.my_location,
              color: Color.fromARGB(255, 45, 44, 44),
              size: 27,
              opticalSize: 10),
            onPressed: centrarCamara,
          ),  
        )
    );
  }
}

class OcultarUsuario extends StatelessWidget {

  final VoidCallback botonPresionado;
  final IconData icono;
  
  const OcultarUsuario({super.key, required this.botonPresionado, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      top: 85,
      child: 
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color.fromARGB(255, 188, 174, 173),
          child: IconButton(
            icon: Icon(
              icono,
              color: const Color.fromARGB(255, 45, 44, 44),
              size: 27,
              opticalSize: 10),
            onPressed: botonPresionado,
          ),  
        )
    );
  }
}

class ApuntarAlNorte extends StatelessWidget {

  final VoidCallback botonPresionado;
  
  const ApuntarAlNorte({super.key, required this.botonPresionado});


  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      top: 145,
      child: 
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color.fromARGB(255, 188, 174, 173),
          child: Transform.rotate(
            angle: 0,
            child: IconButton(
              icon: const Icon(
                Icons.north,
                color: Color.fromARGB(255, 45, 44, 44),
                size: 27,
                opticalSize: 10),
              onPressed: botonPresionado,
            ),
          ),  
        )
    );
  }
}

class ListaMarcadores extends StatefulWidget {
  const ListaMarcadores({super.key});

  @override
  State<ListaMarcadores> createState() => _ListaMarcadoresState();
}

class _ListaMarcadoresState extends State<ListaMarcadores> {
  
  bool menuAbierto = false;
  Icon abrir = const Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.black,);
  Icon cerrar = const Icon(Icons.keyboard_arrow_up, size: 30, color: Colors.black,);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15,
      left: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: menuAbierto ? cerrar : abrir,
            onPressed: () {
              setState(() {
                menuAbierto = !menuAbierto;
              });
            },
          ),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            height: menuAbierto ? 160 : 0,
            curve: Curves.fastOutSlowIn,
            child: const IgnorePointer(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 15),
                        Text(' Bache'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.purple, size: 15),
                        Text(' Desnivel'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.black, size: 15),
                        Text(' Grieta'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green, size: 15,),
                        Text(' Hundimiento'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.yellow, size: 15,),
                        Text(' Zona no pavimentada'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.tealAccent, size: 15,),
                        Text(' Deterioro del pavimento'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.lightBlue, size: 15,),
                        Text(' Acumulación de agua'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.orange, size: 15,),
                        Text(' Obstrucción en la via'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Filtro extends StatefulWidget {
  final List<String> tiposMarcadores;
  final void Function(List<String>) onFiltroChanged;

  const Filtro({super.key, required this.tiposMarcadores, required this.onFiltroChanged});

  @override
  State<Filtro> createState() => _FiltroState();
}

class _FiltroState extends State<Filtro> {
  bool menuAbierto = false;
  Set<String> marcadoresSeleccionados = {};

  final Map<String, Color> colores = {
  'Bache': Colors.red,
  'Desnivel': Colors.purple,
  'Grieta': Colors.black,
  'Hundimiento': Colors.green,
  'Zona no pavimentada': Colors.yellow,
  'Deterioro del pavimento': Colors.tealAccent,
  'Acumulación de agua': Colors.lightBlue,
  'Obstrucción en la vía': Colors.orange,
};

  @override
  void initState() {
    super.initState();
    marcadoresSeleccionados = widget.tiposMarcadores.toSet();
  }

  void toggleFiltro(String tipo) {
    setState(() {
      if (marcadoresSeleccionados.contains(tipo)) {
        marcadoresSeleccionados.remove(tipo);
      } else {
        marcadoresSeleccionados.add(tipo);
      }
    });
    widget.onFiltroChanged(marcadoresSeleccionados.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15,
      left: 65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.filter_list, size: 23, color: Colors.black,),
            onPressed: () {
              setState(() {
                menuAbierto = !menuAbierto;
              });
              if (context.mounted) {
                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          title: const Text('Filtrar'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: widget.tiposMarcadores.map((tipo) {
                                return CheckboxListTile(
                                  title: Text(tipo),
                                  value: marcadoresSeleccionados.contains(tipo), 
                                  secondary: Icon(
                                    Icons.location_on,
                                    color: colores[tipo],),
                                  controlAffinity: ListTileControlAffinity.platform,
                                  onChanged: (bool? checked) {
                                    if (checked != null) {
                                      setState(() {
                                        toggleFiltro(tipo);
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ),
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
                  },
                );
              }
            },
          ),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            height: menuAbierto ? 160 : 0,
            curve: Curves.fastOutSlowIn,
            child: const IgnorePointer(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FiltroMarcadores extends StatefulWidget {
  final void Function(List<String>) onFiltroChanged;

  const FiltroMarcadores({super.key, required this.onFiltroChanged});

  @override
  State<FiltroMarcadores> createState() => _FiltroMarcadoresState();
}

class _FiltroMarcadoresState extends State<FiltroMarcadores> {
  List<String> tiposSeleccionados = [];

  final Map<String, IconData> iconos = {
  'Bache': Icons.location_on,
  'Desnivel': Icons.location_on,
  'Grieta': Icons.location_on,
  'Hundimiento': Icons.location_on,
  'Zona no pavimentada': Icons.location_on,
  'Deterioro del pavimento': Icons.location_on,
  'Acumulación de agua': Icons.location_on,
  'Obstrucción en la vía': Icons.location_on,
};

final Map<String, Color> colores = {
  'Bache': Colors.red,
  'Desnivel': Colors.purple,
  'Grieta': Colors.black,
  'Hundimiento': Colors.green,
  'Zona no pavimentada': Colors.yellow,
  'Deterioro del pavimento': Colors.tealAccent,
  'Acumulación de agua': Colors.lightBlue,
  'Obstrucción en la vía': Colors.orange,
};

  void _toggleTipo(String tipo) {
    setState(() {
      if (tiposSeleccionados.contains(tipo)) {
        tiposSeleccionados.remove(tipo);
      } else {
        tiposSeleccionados.add(tipo);
      }
    });
    widget.onFiltroChanged(tiposSeleccionados);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...['Bachex', 'Desnivel', 'Grieta', 'Hundimiento', 'Zona no pavimentada', 'Deterioro del pavimento', 'Acumulación de agua', 'Obstrucción en la vía'].map((tipo) {
          return CheckboxListTile(
            secondary: Icon(
              Icons.location_on,
              color: colores[tipo],
            ),
            value: tiposSeleccionados.contains(tipo),
            onChanged: (bool? checked) {
              if (checked != null) {
                _toggleTipo(tipo);
              }
            },
          );
        })
      ],
    );
  }
}

class MarcadoresYElMapa extends StatelessWidget {
  final double latitud;
  final double longitud;
  final bool oculto;
  final MapController mapController;
  final List<String> marcadoresVisibles;

  const MarcadoresYElMapa({super.key, required this.latitud, required this.longitud, required this.oculto, required this.mapController, required this.marcadoresVisibles});
    
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

    Map<String, dynamic> iconosColor = {
      'Bache': const Icon(Icons.location_on, color: Colors.red,),
      'Desnivel': const Icon(Icons.location_on, color: Colors.purple,),
      'Grieta': const Icon(Icons.location_on, color: Colors.black,),
      'Hundimiento': const Icon(Icons.location_on, color: Colors.green,),
      'Zona no pavimentada': const Icon(Icons.location_on, color: Colors.yellow,),
      'Deterioro del pavimento': const Icon(Icons.location_on, color: Colors.tealAccent,),
      'Acumulación de agua': const Icon(Icons.location_on, color: Colors.lightBlue,),
      'Obstrucción en la vía': const Icon(Icons.location_on, color: Colors.orange,)
    };

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('fotos').snapshots(), 
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        var fotos = snapshot.data!.docs.map((doc) => doc.data() as Map<String,dynamic>).toList();
        
        var filtrados = fotos.where((foto) {
          var tipoMarcador = foto['tipo'];
          return marcadoresVisibles.contains(tipoMarcador);
        }).toList();

        var markers = filtrados.map((foto) {
          var tipoMarcador = foto['tipo'];
          var icon = iconosColor[tipoMarcador] ?? const Icon(Icons.location_on, color: Colors.black,);

          return Marker(
            width: 80,
            height: 80,
            point: LatLng(foto['latitud'], foto['longitud']),
            child: InkWell(
              onTap: () async {
                String direccion = await direccionConLatLong(foto['latitud'], foto['longitud']);
                if (context.mounted) {
                  showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: IntrinsicHeight(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network('https://firebasestorage.googleapis.com/v0/b/proyecto-de-titulo-87230.appspot.com/o/uploads%2F1716400024876V33T.jpg?alt=media&token=a7b43a72-b4ac-46d5-844b-d38f10a5363d',
                                  height: 300,
                                  width: 120,),
                                Text(foto['tipo']),
                                Text(DateFormat('dd-MM-yyyy h:mm a').format(foto['fecha'].toDate())),
                                Text('latitud: $latitud'),
                                Text('longitud: $longitud'),
                                Text('Dirección: $direccion'),
                                Text(foto['descripcion'], textAlign: TextAlign.center,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
                }
              },
              child: icon,
            ),
          );
        }).toList();

        Marker markerUsuario = Marker(
            height: 80,
            width: 80,
            point: LatLng(latitud, longitud), 
            child: const Icon(Icons.person_rounded, size: 35, color: Colors.blueAccent,),
          );

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(latitud,longitud),
            initialZoom: 20,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
              additionalOptions: {
                'accessToken': myAcessToken,
                'id': 'mapbox/streets-v12',
              },
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 120,
                size: const Size(40, 40),
                padding: const EdgeInsets.all(50),
                markers: markers,
                polygonOptions: const  PolygonOptions(
                    borderColor: Colors.blueAccent,
                    color: Colors.black12,
                    borderStrokeWidth: 3
                ),
                builder: (context, markers) {
                  return FloatingActionButton(
                    enableFeedback: false,
                    onPressed: () {},
                    child: Text(markers.length.toString()),
                    //child: Text('${mapController.camera.rotation}'),
                  );
                },
              ),
            ),

            //Aca pongo este nuevo marcador del usuario por separado, asi el ClusterLayer no le afecta
            Visibility(
              visible: !oculto,
              child: MarkerLayer(
                markers: [markerUsuario]),
            )
          ],
        );
      }
    );
  }
}