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

  InputDecoration decorarCampo(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
    );
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    esEdicion ? Icons.edit : Icons.add_circle_outline,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(width: 8),
                  Text(esEdicion ? 'Editar servicio' : 'Nuevo servicio'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: decorarCampo(
                        'Nombre del servicio',
                        Icons.design_services,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: precioController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: decorarCampo(
                        'Precio',
                        Icons.attach_money,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: categoriaSeleccionada,
                      decoration: decorarCampo(
                        'Categoría',
                        Icons.category,
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

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          esEdicion
                              ? 'Servicio actualizado'
                              : 'Servicio guardado',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Eliminar servicio'),
            ],
          ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await DBHelper.deleteServicio(servicio.id!);
      await cargarDatos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servicio eliminado'),
        ),
      );
    }
  }

  Widget construirEncabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.orange.shade300,
            child: const Icon(
              Icons.design_services,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administra los servicios disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget construirListaServicios() {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categorias.isEmpty) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Primero debes registrar categorías',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ),
      );
    }

    if (servicios.isEmpty) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No hay servicios registrados',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: servicios.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final servicio = servicios[index];

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade200,
              child: const Icon(
                Icons.content_cut,
                color: Colors.black87,
              ),
            ),
            title: Text(
              servicio.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Precio: \$${servicio.precio.toStringAsFixed(2)}\n'
              'Categoría: ${obtenerNombreCategoria(servicio.categoriaId)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => mostrarDialogoServicio(
                    servicio: servicio,
                  ),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => eliminarServicio(servicio),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Servicios'),
        centerTitle: true,
      ),
      floatingActionButton: categorias.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => mostrarDialogoServicio(),
              backgroundColor: Colors.orange.shade400,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            construirEncabezado(),
            const SizedBox(height: 18),
            construirListaServicios(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}