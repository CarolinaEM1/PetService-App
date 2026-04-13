class Servicio {
  int? id;
  String nombre;
  double precio;
  int categoriaId;

  Servicio({
    this.id,
    required this.nombre,
    required this.precio,
    required this.categoriaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'categoria_id': categoriaId,
    };
  }

  factory Servicio.fromMap(Map<String, dynamic> map) {
    return Servicio(
      id: map['id'],
      nombre: map['nombre'],
      precio: map['precio'] is int
          ? (map['precio'] as int).toDouble()
          : map['precio'],
      categoriaId: map['categoria_id'],
    );
  }
}