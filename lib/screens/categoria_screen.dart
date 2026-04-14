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

  Future<void> mostrarDialogoCategoria({Categoria? categoria}) async {
    final TextEditingController nombreController = TextEditingController(
      text: categoria?.nombre ?? '',
    );

    final bool esEdicion = categoria != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(esEdicion ? 'Editar categoría' : 'Nueva categoría'),
          content: TextField(
            controller: nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la categoría',
              border: OutlineInputBorder(),
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
              },
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
          title: const Text('Eliminar categoría'),
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
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await DBHelper.deleteCategoria(categoria.id!);
      cargarCategorias();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        centerTitle: true,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : categorias.isEmpty
              ? const Center(
                  child: Text(
                    'No hay categorías registradas',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = categorias[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.category),
                        ),
                        title: Text(categoria.nombre),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => mostrarDialogoCategoria(
                                categoria: categoria,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarCategoria(categoria),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarDialogoCategoria(),
        child: const Icon(Icons.add),
      ),
    );
  }
}