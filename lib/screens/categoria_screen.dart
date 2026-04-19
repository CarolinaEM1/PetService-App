import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/categoria.dart';

class CategoriaScreen extends StatefulWidget {
  const CategoriaScreen({super.key});

  @override
  State<CategoriaScreen> createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  List<Categoria> categorias = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    setState(() {
      cargando = true;
    });

    final resultado = await DBHelper.getCategorias();

    setState(() {
      categorias = resultado;
      cargando = false;
    });
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

  Future<void> mostrarDialogoCategoria({Categoria? categoria}) async {
    final TextEditingController nombreController = TextEditingController(
      text: categoria?.nombre ?? '',
    );

    final bool esEdicion = categoria != null;

    await showDialog(
      context: context,
      builder: (context) {
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
              Text(esEdicion ? 'Editar categoría' : 'Nueva categoría'),
            ],
          ),
          content: TextField(
            controller: nombreController,
            decoration: decorarCampo(
              'Nombre de la categoría',
              Icons.category,
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

                if (nombre.isEmpty) return;

                if (esEdicion) {
                  await DBHelper.updateCategoria(
                    Categoria(
                      id: categoria.id,
                      nombre: nombre,
                    ),
                  );
                } else {
                  await DBHelper.insertCategoria(
                    Categoria(nombre: nombre),
                  );
                }

                if (!mounted) return;
                Navigator.pop(context);
                cargarCategorias();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esEdicion
                          ? 'Categoría actualizada'
                          : 'Categoría guardada',
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
  }

  Future<void> eliminarCategoria(Categoria categoria) async {
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
              Text('Eliminar categoría'),
            ],
          ),
          content: Text(
            '¿Seguro que deseas eliminar la categoría "${categoria.nombre}"?',
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
      await DBHelper.deleteCategoria(categoria.id!);
      await cargarCategorias();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoría eliminada'),
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
              Icons.category,
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
                  'Administra las categorías de servicios',
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

  Widget construirListaCategorias() {
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
              'No hay categorías registradas',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: categorias.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final categoria = categorias[index];

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
                Icons.folder_open,
                color: Colors.black87,
              ),
            ),
            title: Text(
              categoria.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: const Text('Categoría disponible'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => mostrarDialogoCategoria(
                    categoria: categoria,
                  ),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => eliminarCategoria(categoria),
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
        title: const Text('Categorías'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarDialogoCategoria(),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            construirEncabezado(),
            const SizedBox(height: 18),
            construirListaCategorias(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}