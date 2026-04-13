class CitaCompleta {
  int id;
  String mascotaNombre;
  String duenoNombre;
  String fecha;
  String hora;
  String estatus;

  CitaCompleta({
    required this.id,
    required this.mascotaNombre,
    required this.duenoNombre,
    required this.fecha,
    required this.hora,
    required this.estatus,
  });

  factory CitaCompleta.fromMap(Map<String, dynamic> map) {
    return CitaCompleta(
      id: map['id'],
      mascotaNombre: map['mascota_nombre'],
      duenoNombre: map['dueno_nombre'],
      fecha: map['fecha'],
      hora: map['hora'],
      estatus: map['estatus'],
    );
  }
}