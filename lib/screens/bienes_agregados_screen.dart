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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios agregados'),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'No hay servicios agregados',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final subtotal = item.servicio.precio * item.cantidad;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.design_services),
                          ),
                          title: Text(item.servicio.nombre),
                          subtitle: Text(
                            'Cantidad: ${item.cantidad}\n'
                            'Precio: \$${item.servicio.precio.toStringAsFixed(2)}\n'
                            'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => eliminarItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total: \$${calcularTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, items);
                          },
                          child: const Text('Confirmar cambios'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}