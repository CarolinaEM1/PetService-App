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

  Color obtenerColorTextoEstatus(String estatus) {
    switch (estatus.toLowerCase()) {
      case 'pendiente':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'completado':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  Widget construirFilaDetalle(
    IconData icono,
    String titulo,
    String valor, {
    Color? valorColor,
    bool boldValue = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 18, color: Colors.orange.shade500),
        const SizedBox(width: 8),
        Text(
          '$titulo: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: TextStyle(
              color: valorColor,
              fontWeight: boldValue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget construirLeyendaItem(Color color, String texto, {bool borde = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: borde ? Border.all(color: Colors.black26) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  void mostrarEventosDelDia(DateTime dia) {
    final eventosDelDia = obtenerEventosDelDia(dia);
    final fechaTexto =
        '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}/${dia.year}';

    showDialog(
      context: context,
      builder: (_) {
        return Dialog.fullscreen(
          child: Scaffold(
            backgroundColor: Colors.orange.shade50,
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Eventos del día'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: eventosDelDia.isEmpty
                  ? Center(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No hay eventos para este día',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade300,
                                Colors.deepOrange.shade300,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.shade100,
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.event_available,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Citas del $fechaTexto',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${eventosDelDia.length} evento(s) programado(s)',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.92),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: eventosDelDia.length,
                            itemBuilder: (_, index) {
                              final cita = eventosDelDia[index];
                              final color = obtenerColor(cita.estatus);

                              return Card(
                                elevation: 4,
                                shadowColor: Colors.black12,
                                margin: const EdgeInsets.only(bottom: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: color,
                                            child: const Icon(
                                              Icons.pets,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cita.mascotaNombre,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Dueño: ${cita.duenoNombre}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                            color: Colors.orange.shade100,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            construirFilaDetalle(
                                              Icons.access_time,
                                              'Hora',
                                              cita.hora,
                                            ),
                                            const SizedBox(height: 10),
                                            construirFilaDetalle(
                                              Icons.flag,
                                              'Estatus',
                                              cita.estatus,
                                              valorColor:
                                                  obtenerColorTextoEstatus(
                                                      cita.estatus),
                                              boldValue: true,
                                            ),
                                            const SizedBox(height: 10),
                                            construirFilaDetalle(
                                              Icons.content_cut,
                                              'Servicio(s)',
                                              cita.servicios,
                                            ),
                                            const SizedBox(height: 10),
                                            construirFilaDetalle(
                                              Icons.attach_money,
                                              'Total',
                                              '\$${cita.total.toStringAsFixed(2)}',
                                              boldValue: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: Colors.orange,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: Colors.orange,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    markersMaxCount: 3,
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: Colors.orange.shade200,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.orange.shade500,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                    defaultTextStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    weekendStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
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
                              width: 7,
                              height: 7,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
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
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leyenda de estatus',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    children: [
                      construirLeyendaItem(Colors.green, 'Pendiente'),
                      construirLeyendaItem(Colors.red, 'Cancelado'),
                      construirLeyendaItem(
                        Colors.white,
                        'Completado',
                        borde: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}