import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../database/db_helper.dart';
import '../models/cita_completa.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final LinkedHashMap<DateTime, List<CitaCompleta>> _eventos =
      LinkedHashMap<DateTime, List<CitaCompleta>>(
    equals: isSameDay,
    hashCode: _getHashCode,
  );

  static int _getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();
    cargarEventos();
  }

  DateTime limpiarHora(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  Future<void> cargarEventos() async {
    final citas = await DBHelper.getCitasCompletas();

    _eventos.clear();

    for (final cita in citas) {
      final partes = cita.fecha.split('-');

      final fecha = limpiarHora(
        DateTime(
          int.parse(partes[0]),
          int.parse(partes[1]),
          int.parse(partes[2]),
        ),
      );

      if (_eventos[fecha] == null) {
        _eventos[fecha] = [];
      }

      _eventos[fecha]!.add(cita);
    }

    if (mounted) {
      setState(() {});
    }
  }

  List<CitaCompleta> obtenerEventosDelDia(DateTime dia) {
    return _eventos[limpiarHora(dia)] ?? [];
  }

  Color obtenerColor(String estatus) {
    switch (estatus.toLowerCase()) {
      case 'pendiente':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'completado':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  void mostrarEventosDelDia(DateTime dia) {
    final eventosDelDia = obtenerEventosDelDia(dia);

    showDialog(
      context: context,
      builder: (_) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Eventos del día'),
            ),
            body: eventosDelDia.isEmpty
                ? const Center(
                    child: Text(
                      'No hay eventos',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: eventosDelDia.length,
                    itemBuilder: (_, index) {
                      final cita = eventosDelDia[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: obtenerColor(cita.estatus),
                            child: const Icon(
                              Icons.pets,
                              color: Colors.black,
                            ),
                          ),
                          title: Text(cita.mascotaNombre),
                          subtitle: Text(
                            'Dueño: ${cita.duenoNombre}\n'
                            'Hora: ${cita.hora}\n'
                            'Estatus: ${cita.estatus}\n'
                            'Servicio(s): ${cita.servicios}\n'
                            'Total: \$${cita.total.toStringAsFixed(2)}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de citas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar<CitaCompleta>(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: obtenerEventosDelDia,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            mostrarEventosDelDia(selectedDay);
          },
          calendarStyle: const CalendarStyle(
            markersMaxCount: 3,
            outsideDaysVisible: false,
          ),
          calendarBuilders: CalendarBuilders<CitaCompleta>(
            markerBuilder: (context, day, eventosDelDia) {
              if (eventosDelDia.isEmpty) {
                return const SizedBox.shrink();
              }

              return Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: eventosDelDia.take(3).map((cita) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: obtenerColor(cita.estatus),
                        border: Border.all(color: Colors.black12),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}