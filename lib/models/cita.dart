class Cita {
  int? id;
  int mascotaId;
  String fecha;
  String hora;
  String estatus;
  String recordatorio;

  Cita({
    this.id,
    required this.mascotaId,
    required this.fecha,
    required this.hora,
    required this.estatus,
    required this.recordatorio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mascota_id': mascotaId,
      'fecha': fecha,
      'hora': hora,
      'estatus': estatus,
      'recordatorio': recordatorio,
    };
  }

  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map['id'],
      mascotaId: map['mascota_id'],
      fecha: map['fecha'],
      hora: map['hora'],
      estatus: map['estatus'],
      recordatorio: map['recordatorio'],
    );
  }
}