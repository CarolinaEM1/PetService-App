class CitaCompleta {
  int id;
  String mascotaNombre;
  String duenoNombre;
  String fecha;
  String hora;
  String estatus;
  String servicios;
  double total;

  CitaCompleta({
    required this.id,
    required this.mascotaNombre,
    required this.duenoNombre,
    required this.fecha,
    required this.hora,
    required this.estatus,
    required this.servicios,
    required this.total,
  });

  factory CitaCompleta.fromMap(Map<String, dynamic> map) {
    return CitaCompleta(
      id: map['id'],
      mascotaNombre: map['mascota_nombre'],
      duenoNombre: map['dueno_nombre'],
      fecha: map['fecha'],
      hora: map['hora'],
      estatus: map['estatus'],
      servicios: map['servicios'] ?? 'Sin servicios',
      total: map['total'] == null ? 0.0 : (map['total'] as num).toDouble(),
    );
  }
}