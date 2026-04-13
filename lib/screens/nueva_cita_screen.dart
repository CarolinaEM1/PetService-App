import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/dueno.dart';
import '../models/mascota.dart';
import '../models/cita.dart';

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

  String estatusSeleccionado = 'pendiente';

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

  Future<void> guardarCita() async {
    if (!_formKey.currentState!.validate()) return;

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

      await DBHelper.insertCita(
        Cita(
          mascotaId: mascotaId,
          fecha: fechaController.text.trim(),
          hora: horaController.text.trim(),
          estatus: estatusSeleccionado,
          recordatorio: recordatorioController.text.trim(),
        ),
      );

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

  @override
  void dispose() {
    nombreDuenoController.dispose();
    telefonoController.dispose();
    nombreMascotaController.dispose();
    razaController.dispose();
    fechaController.dispose();
    horaController.dispose();
    recordatorioController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cita'),
        centerTitle: true,
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