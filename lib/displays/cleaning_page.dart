import 'package:flutter/material.dart';
import '../services/services.dart' as service;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CleaningPage extends StatefulWidget {
  const CleaningPage({super.key});

  @override
  State<CleaningPage> createState() => _CleaningPageState();
}

class _CleaningPageState extends State<CleaningPage> {
  List<Map<String, dynamic>> _tables = [];
  int idClean = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spartans Limpieza Mesas'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar Sesión'),
              ),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 2.0,
        ),
        itemCount: _tables.length,
        itemBuilder: (context, index) {
          var table = _tables[index];
          return FutureBuilder<Map<String, dynamic>>(
            future: _getTableDetails(table['status'], table['id_table']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error al obtener los detalles');
              } else if (snapshot.hasData) {
                // Extrayendo los datos del Map
                Color color = snapshot.data!['color'];
                Icon icon = snapshot.data!['icon'];

                return GestureDetector(
                  onTap: () =>
                      _showDialog(context, table['id_table'], table['status']),
                  child: Card(
                    color: color,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon,
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Mesa ${table['id_table']}\n ${table['customer_name']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const Text('No se encontraron detalles');
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _showDialog(
      BuildContext context, int idTable, int status) async {
    bool isClean = await service.getTablesCleaning(idClean, idTable);

    if (isClean) {
      if (status == 5) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Finalizar limpieza de la mesa'),
              content: const Text(
                  'Si presionas finalizar estas indicando que la mesa esta lista para su uso'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    String freeStatus = 'Libre';

                    service.updateTable(idTable, freeStatus, 1);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Finalizar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      } else {
        service.showInfoDialog(
            context,
            const Text('Mesa no necesita limpieza',
                style: TextStyle(color: Colors.white)),
            const Text(
                'Esta mesa esta en un proceso diferente al que intentas realizar',
                style: TextStyle(color: Colors.white)),
            Colors.red.shade900);
      }
    } else {
      service.showInfoDialog(
          context,
          const Text('Esta mesa no la tienes asignada',
              style: TextStyle(color: Colors.white)),
          const Text(
              'Esta mesa esta asignada a uno de tus compañeros y no puedes visualizar sus acciones',
              style: TextStyle(color: Colors.white)),
          Colors.red.shade900);
    }
  }

  void logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void initState() {
    super.initState();
    getTablesClean(context);
  }

  void getTablesClean(context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idClean = preferences.getInt('id_user')!;
    QuerySnapshot? tables = await service.getTables();

    // Verificamos que tables no sea nulo
    if (tables != null) {
      List<Map<String, dynamic>> tablesList = tables.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {
        _tables = tablesList;
      });
    } else {
      print('No se pudieron obtener las tablas.');
    }
  }

  Future<Map<String, dynamic>> _getTableDetails(int status, int idTable) async {
    Color color = await service.assignColor(status, idTable, idClean);
    Icon icon = await service.assignIcon(status, idTable, idClean);

    return {'color': color, 'icon': icon};
  }
}
