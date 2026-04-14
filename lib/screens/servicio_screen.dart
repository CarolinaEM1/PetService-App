import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/categoria.dart';
import '../models/servicio.dart';

class ServicioScreen extends StatefulWidget {
  const ServicioScreen({super.key});

  @override
  State<ServicioScreen> createState() => _ServicioScreenState();
}

class _ServicioScreenState extends State<ServicioScreen> {
  List<Servicio> servicios = [];
  List<Categoria> categorias = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() {
      cargando = true;
    });

    final resultadoServicios = await DBHelper.getServicios();
    final resultadoCategorias = await DBHelper.getCategorias();

    setState(() {
      servicios = resultadoServicios;
      categorias = resultadoCategorias;
      cargando = false;
    });
  }

  String obtenerNombreCategoria(int categoriaId) {
    try {
      return categorias.firstWhere((c) => c.id == categoriaId).nombre;
    } catch (e) {
      return 'Sin categoría';
    }
  }

  Future<void> mostrarDialogoServicio({Servicio? servicio}) async {
    final TextEditingController nombreController = TextEditingController(
      text: servicio?.nombre ?? '',
    );

    final TextEditingController precioController = TextEditingController(
      text: servicio != null ? servicio.precio.toString() : '',
    );

    int? categoriaSeleccionada = servicio?.categoriaId;

    final bool esEdicion = servicio != null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(esEdicion ? 'Editar servicio' : 'Nuevo servicio'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del servicio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: precioController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: categoriaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items: categorias.map((categoria) {
                        return DropdownMenuItem<int>(
                          value: categoria.id,
                          child: Text(categoria.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          categoriaSeleccionada = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nombre = nombreController.text.trim();
                    final precioTexto = precioController.text.trim();

                    if (nombre.isEmpty ||
                        precioTexto.isEmpty ||
                        categoriaSeleccionada == null) {
                      return;
                    }

                    final precio = double.tryParse(precioTexto);
                    if (precio == null) return;

                    if (esEdicion) {
                      await DBHelper.updateServicio(
                        Servicio(
                          id: servicio.id,
                          nombre: nombre,
                          precio: precio,
                          categoriaId: categoriaSeleccionada!,
                        ),
                      );
                    } else {
                      await DBHelper.insertServicio(
                        Servicio(
                          nombre: nombre,
                          precio: precio,
                          categoriaId: categoriaSeleccionada!,
                        ),
                      );
                    }

                    if (!mounted) return;
                    Navigator.pop(context);
                    cargarDatos();
                  },
                  child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> eliminarServicio(Servicio servicio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar servicio'),
          content: Text(
            '¿Seguro que deseas eliminar el servicio "${servicio.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await DBHelper.deleteServicio(servicio.id!);
      cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        centerTitle: true,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : categorias.isEmpty
              ? const Center(
                  child: Text(
                    'Primero debes registrar categorías',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : servicios.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay servicios registrados',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: servicios.length,
                      itemBuilder: (context, index) {
                        final servicio = servicios[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.content_cut),
                            ),
                            title: Text(servicio.nombre),
                            subtitle: Text(
                              'Precio: \$${servicio.precio.toStringAsFixed(2)}\n'
                              'Categoría: ${obtenerNombreCategoria(servicio.categoriaId)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => mostrarDialogoServicio(
                                    servicio: servicio,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => eliminarServicio(servicio),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: categorias.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => mostrarDialogoServicio(),
              child: const Icon(Icons.add),
            ),
    );
  }
}