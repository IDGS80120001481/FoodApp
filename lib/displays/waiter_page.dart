import 'package:flutter/material.dart';
import '../services/services.dart' as service;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaiterPage extends StatefulWidget {
  const WaiterPage({super.key});

  @override
  State<WaiterPage> createState() => _WaiterPageState();
}

class _WaiterPageState extends State<WaiterPage> {
  List<Map<String, dynamic>> _tables = [];
  List<Map<String, dynamic>> _menu = [];
  int idWaiter = 0;
  TextEditingController _controllerQuantity = TextEditingController();
  TextEditingController _controllerOption = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spartans Meseros'),
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
                            'Mesa ${table['id_table']}\n ${table['customer_name']} \n Comanda: ${table['command_number']}',
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
    bool isWaiter = await service.getTablesWaiter(idWaiter, idTable);

    if (isWaiter) {
      if (status == 2) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Menu'),
              content: Container(
                width: double.maxFinite,
                height: 300.0,
                child: ListView.builder(
                  itemCount: _menu.length,
                  itemBuilder: (context, index) {
                    var item = _menu[index];
                    return ListTile(
                      leading: const Icon(Icons.label),
                      title: Text('${item['nombre']}  ${item['precio']} MXN'),
                      subtitle: Text(
                        '${item['descripcion']} Opciones: ${item['opciones']}',
                      ),
                      onTap: () {
                        service.showAddOrder(context, item, _controllerQuantity,
                            _controllerOption, idTable);
                      },
                    );
                  },
                ),
              ),
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
      } else {
        service.showInfoDialog(
            context,
            const Text('Mesa no disponible para tomar pedido',
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
    getTablesWaiters(context);
  }

  void getTablesWaiters(context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idWaiter = preferences.getInt('id_user')!;
    QuerySnapshot? tables = await service.getTables();
    QuerySnapshot? products = await service.getMenu();

    if (tables != null) {
      List<Map<String, dynamic>> tablesList = tables.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {
        _tables = tablesList;
      });
    } else {
      print('No se pudo obtener la tabla de mesas.');
    }

    if (products != null) {
      List<Map<String, dynamic>> productsList = products.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {
        _menu = productsList;
      });
    } else {
      print('No se pudo obtener la tabla de productos.');
    }
  }

  Future<Map<String, dynamic>> _getTableDetails(int status, int idTable) async {
    Color color = await service.assignColorWaiter(status, idTable, idWaiter);
    Icon icon = await service.assignIconWaiter(status, idTable, idWaiter);

    return {'color': color, 'icon': icon};
  }
}
