class Dueno {
  int? id;
  String nombre;
  String telefono;

  Dueno({
    this.id,
    required this.nombre,
    required this.telefono,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
    };
  }

  factory Dueno.fromMap(Map<String, dynamic> map) {
    return Dueno(
      id: map['id'],
      nombre: map['nombre'],
      telefono: map['telefono'],
    );
  }
}