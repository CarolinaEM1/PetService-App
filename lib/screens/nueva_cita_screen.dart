import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

import '../database/db_helper.dart';
import '../models/dueno.dart';
import '../models/mascota.dart';
import '../models/cita.dart';
import '../models/categoria.dart';
import '../models/servicio.dart';
import '../models/detalle_cita.dart';
import '../models/item_servicio.dart';
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
  final TextEditingController cantidadController =
      TextEditingController(text: '1');

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
      horaController.text =
          "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";
    }
  }

  void agregarServicio() {
    if (servicioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un servicio')),
      );
      return;
    }

    final cantidad = int.tryParse(cantidadController.text.trim()) ?? 0;

    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad debe ser mayor a 0')),
      );
      return;
    }

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicio agregado')),
    );
  }

  double calcularTotalEstimado() {
    double total = 0;
    for (final item in itemsSeleccionados) {
      total += item.servicio.precio * item.cantidad;
    }
    return total;
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
    final totalEstimado = calcularTotalEstimado();

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
      backgroundColor: Colors.orange.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              construirSeccion(
                titulo: 'Datos del dueño',
                icono: Icons.person,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nombreDuenoController,
                      decoration:
                          decorarCampo('Nombre del dueño', Icons.person),
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
                  ],
                ),
              ),
              construirSeccion(
                titulo: 'Datos de la mascota',
                icono: Icons.pets,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nombreMascotaController,
                      decoration:
                          decorarCampo('Nombre de la mascota', Icons.pets),
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
                  ],
                ),
              ),
              construirSeccion(
                titulo: 'Información de la cita',
                icono: Icons.calendar_month,
                child: Column(
                  children: [
                    TextFormField(
                      controller: fechaController,
                      readOnly: true,
                      onTap: seleccionarFecha,
                      decoration:
                          decorarCampo('Fecha', Icons.calendar_month),
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
                  ],
                ),
              ),
              construirSeccion(
                titulo: 'Agregar servicios',
                icono: Icons.design_services,
                child: Column(
                  children: [
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
                      decoration:
                          decorarCampo('Servicio', Icons.design_services),
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
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: agregarServicio,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Agregar servicio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      'Total estimado: \$${totalEstimado.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: guardarCita,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Guardar cita',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}