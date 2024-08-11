import 'package:flutter/material.dart';
import '../services/services.dart' as service;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  List<Map<String, dynamic>> _tables = [];
  List<Map<String, dynamic>> _orders = [];
  int idWaiter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spartans Cocina'),
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
    QuerySnapshot? orders = await service.getOrders(idTable);

    if (orders != null) {
      List<Map<String, dynamic>> ordersList = orders.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {
        _orders = ordersList;
      });
    } else {
      print('No se pudo obtener la tabla de productos.');
    }

    if (status == 3 || status == 4) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Menu'),
            content: Container(
              width: double.maxFinite,
              height: 300.0,
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  var item = _orders[index];
                  return ListTile(
                    leading: const Icon(Icons.label),
                    title: Text('${item['food']}'),
                    subtitle: Text(
                      'Opción: ${item['opcion']} Cantidad:  ${item['cantidad']}',
                    ),
                    onTap: () {
                      service.showOrderKitchen(context, idTable, item);
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
              TextButton(
                onPressed: () {
                  service.updateTable(idTable, '', 4);
                  Navigator.of(context).pop();
                },
                child: const Text('Finalizar Pedido'),
              ),
            ],
          );
        },
      );
    } else {
      service.showInfoDialog(
          context,
          const Text('Esta mesa no ha realizado ningun pedido',
              style: TextStyle(color: Colors.white)),
          const Text(
              'Esta mesa esta en un proceso diferente al que intentas realizar',
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
    getTablesKitchen(context);
  }

  void getTablesKitchen(context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idWaiter = preferences.getInt('id_user')!;
    QuerySnapshot? tables = await service.getTables();

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
  }

  Future<Map<String, dynamic>> _getTableDetails(int status, int idTable) async {
    Color color = await service.assignColorHost(status);
    Icon icon = await service.assignIconHost(status);

    return {'color': color, 'icon': icon};
  }
}
