import 'package:flutter/material.dart';
import 'package:proyectotransferido/screens/home.dart';
import 'package:proyectotransferido/screens/perfil.dart';
//import 'package:proyecto_de_titulo/presentaciones/app_bar.dart';
import 'package:provider/provider.dart';


class MyAccessBarState extends ChangeNotifier{

  var mySelectedIndex = 0;
  bool visibilidadActual = false;

  void navigationIndex(int index) {
    mySelectedIndex = index;
    notifyListeners();
  }

  void cambiarVisibilidad(bool nuevaVisibilidad){
    visibilidadActual = nuevaVisibilidad;
    notifyListeners();
  }

}

class AccessBar extends StatefulWidget {
  const AccessBar({super.key});

  static final pages = [
    const Home(), 
    const Home(),
    const Perfil(),
  ];

  @override
  State<AccessBar> createState() => _AccessBarState();
}

class _AccessBarState extends State<AccessBar> {

  bool visibilidad = MyAccessBarState().visibilidadActual;

  @override
  Widget build(BuildContext context) {

    //var AccessBarState = context.watch<MyAccessBarState>();

    return Scaffold(
      body: Consumer<MyAccessBarState>(
        builder: (context, value, child) {
          return Stack(
            children: [
              Row(
                children: [
                  if (visibilidad)
                  SafeArea(
                    child: NavigationRail(
                      extended: false,
                      backgroundColor: const Color.fromARGB(255, 10, 147, 245),
                      selectedIndex: value.mySelectedIndex,
                      onDestinationSelected: (index) {
                        if (index == 0){
                          setState(() {
                            visibilidad = !visibilidad;
                          });
                        } else {
                          value.navigationIndex(index);
                        }
                      }, 
   
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.menu, size: 35, color: Colors.black54) ,
                          label: Text('Menu'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.home, size: 35, color: Colors.black54), 
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.account_circle, size: 35, color: Colors.black54),
                          label: Text('Perfil'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.map, size: 35, color: Colors.black54), 
                          label: Text('Mi mapa')
                        )
                      ],
                    ),
                  ),
                                
                  Expanded(
                    child: AccessBar.pages[value.mySelectedIndex],
                  ),
                ],
                
              ),
              SafeArea(
                child: IconButton(
                  padding: const EdgeInsets.only(left: 22.5, top: 14),
                  icon: const Icon(Icons.menu, size: 35,),
                  onPressed: () {
                    setState(() {
                      visibilidad = !visibilidad;
                    });
                  },
                ),
              )
            ], 
          );
        }
      )
    );
  }
}


