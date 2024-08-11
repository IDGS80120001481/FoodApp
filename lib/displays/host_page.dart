import 'package:flutter/material.dart';
import '../services/services.dart' as service;
import 'package:cloud_firestore/cloud_firestore.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  final TextEditingController _controllerName = TextEditingController();
  List<Map<String, dynamic>> _tables = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Maasai Food Restaurante',
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                logout();
              } else if (value == 'day') {
                service.closeDay();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar Sesión'),
              ),
              const PopupMenuItem(
                value: 'day',
                child: Text('Cerrar Dia'),
              )
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
            future: _getTableDetails(table['status']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error al obtener los detalles');
              } else if (snapshot.hasData) {
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
    if (status == 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Nombre del cliente: '),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controllerName,
                  decoration: const InputDecoration(
                    hintText: 'Ingresa el nombre del cliente: ',
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  String nameClient = _controllerName.text;

                  service.updateTable(idTable, nameClient, 2);
                  service.countCommand();
                  Navigator.of(context).pop();
                },
                child: const Text('Enviar'),
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
          const Text('Mesa ocupada', style: TextStyle(color: Colors.white)),
          const Text('No se puede asignar esta mesa por que no esta disponible',
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
    getTablesHost(context);
  }

  void getTablesHost(context) async {
    QuerySnapshot? tables = await service.getTables();

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

  Future<Map<String, dynamic>> _getTableDetails(int status) async {
    Color color = await service.assignColorHost(status);
    Icon icon = await service.assignIconHost(status);

    return {'color': color, 'icon': icon};
  }
}
