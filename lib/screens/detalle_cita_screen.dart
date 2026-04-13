import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/cita.dart';

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

  late String estatusSeleccionado;

  @override
  void initState() {
    super.initState();
    fechaController = TextEditingController(text: widget.cita.fecha);
    horaController = TextEditingController(text: widget.cita.hora);
    recordatorioController = TextEditingController(text: widget.cita.recordatorio);
    estatusSeleccionado = widget.cita.estatus;
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