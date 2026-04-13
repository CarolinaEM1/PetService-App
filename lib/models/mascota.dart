class Mascota {
  int? id;
  String nombre;
  String raza;
  int duenoId;

  Mascota({
    this.id,
    required this.nombre,
    required this.raza,
    required this.duenoId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'raza': raza,
      'dueno_id': duenoId,
    };
  }

  factory Mascota.fromMap(Map<String, dynamic> map) {
    return Mascota(
      id: map['id'],
      nombre: map['nombre'],
      raza: map['raza'],
      duenoId: map['dueno_id'],
    );
  }
}