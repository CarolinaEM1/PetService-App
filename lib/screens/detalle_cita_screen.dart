import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/categoria.dart';
import '../models/cita.dart';
import '../models/servicio.dart';

class DetalleCitaScreen extends StatefulWidget {
  final Cita cita;

  const DetalleCitaScreen({super.key, required this.cita});

  @override
  State<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends State<DetalleCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fechaController;
  late TextEditingController horaController;
  late TextEditingController recordatorioController;
  final TextEditingController cantidadController = TextEditingController(text: '1');

  late String estatusSeleccionado;

  List<Map<String, dynamic>> detalleServicios = [];
  bool cargandoDetalle = true;

  List<Categoria> categorias = [];
  List<Servicio> servicios = [];
  int? categoriaSeleccionadaId;
  Servicio? servicioSeleccionado;

  double totalCita = 0.0;

  @override
  void initState() {
    super.initState();
    fechaController = TextEditingController(text: widget.cita.fecha);
    horaController = TextEditingController(text: widget.cita.hora);
    recordatorioController = TextEditingController(text: widget.cita.recordatorio);
    estatusSeleccionado = widget.cita.estatus;

    cargarTodo();
  }

  Future<void> cargarTodo() async {
    await Future.wait([
      cargarDetalleServicios(),
      cargarCategorias(),
      cargarTotal(),
    ]);
  }

  Future<void> cargarDetalleServicios() async {
    final resultado = await DBHelper.getDetalleCompletoCita(widget.cita.id!);

    setState(() {
      detalleServicios = resultado;
      cargandoDetalle = false;
    });
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

  Future<void> cargarTotal() async {
    final total = await DBHelper.getTotalCita(widget.cita.id!);
    setState(() {
      totalCita = total;
    });
  }

  Future<void> seleccionarFecha() async {
    final partes = fechaController.text.split('-');
    DateTime fechaInicial = DateTime.now();

    if (partes.length == 3) {
      fechaInicial = DateTime(
        int.parse(partes[0]),
        int.parse(partes[1]),
        int.parse(partes[2]),
      );
    }

    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
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
    final partes = horaController.text.split(':');
    TimeOfDay horaInicial = TimeOfDay.now();

    if (partes.length == 2) {
      horaInicial = TimeOfDay(
        hour: int.parse(partes[0]),
        minute: int.parse(partes[1]),
      );
    }

    TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: horaInicial,
    );

    if (hora != null) {
      horaController.text =
          "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> actualizarCita() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final citaActualizada = Cita(
        id: widget.cita.id,
        mascotaId: widget.cita.mascotaId,
        fecha: fechaController.text.trim(),
        hora: horaController.text.trim(),
        estatus: estatusSeleccionado,
        recordatorio: recordatorioController.text.trim(),
      );

      await DBHelper.updateCita(citaActualizada);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita actualizada correctamente')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  Future<void> eliminarCita() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar cita'),
          content: const Text('¿Seguro que deseas eliminar esta cita?'),
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
      try {
        await DBHelper.deleteCita(widget.cita.id!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita eliminada correctamente')),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  Future<void> eliminarServicioDetalle(int detalleId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar servicio'),
          content: const Text('¿Deseas eliminar este servicio de la cita?'),
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
      await DBHelper.deleteDetallePorId(detalleId);
      await cargarDetalleServicios();
      await cargarTotal();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio eliminado de la cita')),
      );
    }
  }

  Future<void> agregarServicioACita() async {
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

    await DBHelper.insertDetalleSiNoExiste(
      citaId: widget.cita.id!,
      servicioId: servicioSeleccionado!.id!,
      cantidad: cantidad,
    );

    cantidadController.text = '1';

    await cargarDetalleServicios();
    await cargarTotal();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicio agregado a la cita')),
    );
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
        title: const Text('Detalle de Cita'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: eliminarCita,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar cita de la mascota ID: ${widget.cita.mascotaId}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
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
                  'Recordatorio',
                  Icons.notifications,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Agregar servicio a la cita',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                  onPressed: agregarServicioACita,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar servicio'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Servicios de la cita',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              cargandoDetalle
                  ? const Center(child: CircularProgressIndicator())
                  : detalleServicios.isEmpty
                      ? const Text('No hay servicios asociados a esta cita')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: detalleServicios.length,
                          itemBuilder: (context, index) {
                            final item = detalleServicios[index];
                            final double precio =
                                (item['servicio_precio'] as num).toDouble();
                            final int cantidad = item['cantidad'] as int;
                            final double subtotal = precio * cantidad;

                            return Card(
                              child: ListTile(
                                title: Text(item['servicio_nombre']),
                                subtitle: Text(
                                  'Cantidad: $cantidad\n'
                                  'Precio: \$${precio.toStringAsFixed(2)}\n'
                                  'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      eliminarServicioDetalle(item['id'] as int),
                                ),
                              ),
                            );
                          },
                        ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Total de la cita: \$${totalCita.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: actualizarCita,
                  child: const Text(
                    'Actualizar cita',
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