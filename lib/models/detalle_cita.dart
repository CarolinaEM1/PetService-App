class DetalleCita {
  int? id;
  int citaId;
  int servicioId;
  int cantidad;

  DetalleCita({
    this.id,
    required this.citaId,
    required this.servicioId,
    required this.cantidad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cita_id': citaId,
      'servicio_id': servicioId,
      'cantidad': cantidad,
    };
  }

  factory DetalleCita.fromMap(Map<String, dynamic> map) {
    return DetalleCita(
      id: map['id'],
      citaId: map['cita_id'],
      servicioId: map['servicio_id'],
      cantidad: map['cantidad'],
    );
  }
}