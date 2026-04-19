import 'package:flutter/material.dart';
import '../models/item_servicio.dart';

class BienesAgregadosScreen extends StatefulWidget {
  final List<ItemServicio> itemsSeleccionados;

  const BienesAgregadosScreen({
    super.key,
    required this.itemsSeleccionados,
  });

  @override
  State<BienesAgregadosScreen> createState() => _BienesAgregadosScreenState();
}

class _BienesAgregadosScreenState extends State<BienesAgregadosScreen> {
  late List<ItemServicio> items;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.itemsSeleccionados);
  }

  double calcularTotal() {
    double total = 0;
    for (final item in items) {
      total += item.servicio.precio * item.cantidad;
    }
    return total;
  }

  void eliminarItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Widget construirSeccion({
    required String titulo,
    required IconData icono,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: Colors.orange.shade400),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Servicios agregados'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: items.isEmpty
            ? construirSeccion(
                titulo: 'Servicios agregados',
                icono: Icons.shopping_bag,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No has agregado servicios todavía',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: construirSeccion(
                        titulo: 'Servicios agregados',
                        icono: Icons.shopping_bag,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final subtotal =
                                item.servicio.precio * item.cantidad;

                            return Card(
                              color: Colors.orange.shade50,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.shade200,
                                  child: const Icon(
                                    Icons.content_cut,
                                    color: Colors.black87,
                                  ),
                                ),
                                title: Text(item.servicio.nombre),
                                subtitle: Text(
                                  'Cantidad: ${item.cantidad}\n'
                                  'Precio: \$${item.servicio.precio.toStringAsFixed(2)}\n'
                                  'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => eliminarItem(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      'Total estimado: \$${calcularTotal().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, items);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirmar cambios',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}