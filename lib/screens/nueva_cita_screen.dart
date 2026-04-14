import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/dueno.dart';
import '../models/mascota.dart';
import '../models/cita.dart';
import '../models/categoria.dart';
import '../models/servicio.dart';
import '../models/detalle_cita.dart';
import '../models/item_servicio.dart';
import 'package:badges/badges.dart' as badges;
import 'bienes_agregados_screen.dart';

class NuevaCitaScreen extends StatefulWidget {
  const NuevaCitaScreen({super.key});

  @override
  State<NuevaCitaScreen> createState() => _NuevaCitaScreenState();
}

class _NuevaCitaScreenState extends State<NuevaCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreDuenoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController nombreMascotaController = TextEditingController();
  final TextEditingController razaController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();
  final TextEditingController recordatorioController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController(text: '1');

  String estatusSeleccionado = 'pendiente';

  List<Categoria> categorias = [];
  List<Servicio> servicios = [];
  List<ItemServicio> itemsSeleccionados = [];

  int? categoriaSeleccionadaId;
  Servicio? servicioSeleccionado;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    final resultado = await DBHelper.getCategorias();
    setState(() {
      categorias = resultado;
    });
  }

  Future<void> abrirBienesAgregados() async {
  final resultado = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BienesAgregadosScreen(
        itemsSeleccionados: itemsSeleccionados,
      ),
    ),
  );

  if (resultado != null && resultado is List<ItemServicio>) {
    setState(() {
      itemsSeleccionados = resultado;
    });
  }
}

  Future<void> cargarServiciosPorCategoria(int categoriaId) async {
    final resultado = await DBHelper.getServiciosPorCategoria(categoriaId);
    setState(() {
      servicios = resultado;
      servicioSeleccionado = null;
    });
  }

  Future<void> seleccionarFecha() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (fecha != null) {
      fechaController.text =
          "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";

      DateTime fechaRecordatorio = fecha.subtract(const Duration(days: 2));
      recordatorioController.text =
          "${fechaRecordatorio.year.toString().padLeft(4, '0')}-${fechaRecordatorio.month.toString().padLeft(2, '0')}-${fechaRecordatorio.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> seleccionarHora() async {
    TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      final horaFormateada =
          "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";
      horaController.text = horaFormateada;
    }
  }

  void agregarServicio() {
    if (servicioSeleccionado == null) return;

    final cantidad = int.tryParse(cantidadController.text.trim()) ?? 0;
    if (cantidad <= 0) return;

    final indexExistente = itemsSeleccionados.indexWhere(
      (item) => item.servicio.id == servicioSeleccionado!.id,
    );

    setState(() {
      if (indexExistente >= 0) {
        itemsSeleccionados[indexExistente].cantidad += cantidad;
      } else {
        itemsSeleccionados.add(
          ItemServicio(
            servicio: servicioSeleccionado!,
            cantidad: cantidad,
          ),
        );
      }

      cantidadController.text = '1';
    });
  }

  void eliminarItemServicio(int index) {
    setState(() {
      itemsSeleccionados.removeAt(index);
    });
  }

  Future<void> guardarCita() async {
    if (!_formKey.currentState!.validate()) return;

    if (itemsSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un servicio')),
      );
      return;
    }

    try {
      int duenoId = await DBHelper.insertDueno(
        Dueno(
          nombre: nombreDuenoController.text.trim(),
          telefono: telefonoController.text.trim(),
        ),
      );

      int mascotaId = await DBHelper.insertMascota(
        Mascota(
          nombre: nombreMascotaController.text.trim(),
          raza: razaController.text.trim(),
          duenoId: duenoId,
        ),
      );

      int citaId = await DBHelper.insertCita(
        Cita(
          mascotaId: mascotaId,
          fecha: fechaController.text.trim(),
          hora: horaController.text.trim(),
          estatus: estatusSeleccionado,
          recordatorio: recordatorioController.text.trim(),
        ),
      );

      for (final item in itemsSeleccionados) {
        await DBHelper.insertDetalleCita(
          DetalleCita(
            citaId: citaId,
            servicioId: item.servicio.id!,
            cantidad: item.cantidad,
          ),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita guardada correctamente')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar cita: $e')),
      );
    }
  }

  InputDecoration decorarCampo(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void dispose() {
    nombreDuenoController.dispose();
    telefonoController.dispose();
    nombreMascotaController.dispose();
    razaController.dispose();
    fechaController.dispose();
    horaController.dispose();
    recordatorioController.dispose();
    cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text('Nueva Cita'),
  centerTitle: true,
  actions: [
    IconButton(
      onPressed: abrirBienesAgregados,
      icon: badges.Badge(
        showBadge: itemsSeleccionados.isNotEmpty,
        badgeContent: Text(
          itemsSeleccionados.length.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        child: const Icon(Icons.shopping_cart),
      ),
    ),
  ],
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreDuenoController,
                decoration: decorarCampo('Nombre del dueño', Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre del dueño';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                decoration: decorarCampo('Teléfono', Icons.phone),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nombreMascotaController,
                decoration: decorarCampo('Nombre de la mascota', Icons.pets),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre de la mascota';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: razaController,
                decoration: decorarCampo('Raza', Icons.content_cut),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la raza';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: fechaController,
                readOnly: true,
                onTap: seleccionarFecha,
                decoration: decorarCampo('Fecha', Icons.calendar_month),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione la fecha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: horaController,
                readOnly: true,
                onTap: seleccionarHora,
                decoration: decorarCampo('Hora', Icons.access_time),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione la hora';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: estatusSeleccionado,
                decoration: decorarCampo('Estatus', Icons.flag),
                items: const [
                  DropdownMenuItem(
                    value: 'pendiente',
                    child: Text('Pendiente'),
                  ),
                  DropdownMenuItem(
                    value: 'completado',
                    child: Text('Completado'),
                  ),
                  DropdownMenuItem(
                    value: 'cancelado',
                    child: Text('Cancelado'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    estatusSeleccionado = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: recordatorioController,
                readOnly: true,
                decoration: decorarCampo(
                  'Recordatorio (2 días antes)',
                  Icons.notifications,
                ),
              ),
              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Agregar servicios',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                value: categoriaSeleccionadaId,
                decoration: decorarCampo('Categoría', Icons.category),
                items: categorias.map((categoria) {
                  return DropdownMenuItem<int>(
                    value: categoria.id,
                    child: Text(categoria.nombre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    categoriaSeleccionadaId = value;
                  });
                  if (value != null) {
                    cargarServiciosPorCategoria(value);
                  }
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<Servicio>(
                value: servicioSeleccionado,
                decoration: decorarCampo('Servicio', Icons.design_services),
                items: servicios.map((servicio) {
                  return DropdownMenuItem<Servicio>(
                    value: servicio,
                    child: Text(
                      '${servicio.nombre} - \$${servicio.precio.toStringAsFixed(2)}',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    servicioSeleccionado = value;
                  });
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: decorarCampo('Cantidad', Icons.numbers),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: agregarServicio,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Agregar servicio'),
                ),
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Servicios agregados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              if (itemsSeleccionados.isEmpty)
                const Text('No has agregado servicios todavía'),

              if (itemsSeleccionados.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemsSeleccionados.length,
                  itemBuilder: (context, index) {
                    final item = itemsSeleccionados[index];
                    final subtotal = item.servicio.precio * item.cantidad;

                    return Card(
                      child: ListTile(
                        title: Text(item.servicio.nombre),
                        subtitle: Text(
                          'Cantidad: ${item.cantidad}\n'
                          'Precio: \$${item.servicio.precio.toStringAsFixed(2)}\n'
                          'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => eliminarItemServicio(index),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: guardarCita,
                  child: const Text(
                    'Guardar cita',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}