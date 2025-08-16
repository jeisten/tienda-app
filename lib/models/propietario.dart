class Propietario {
  final String id;
  final String nombre;
  final String direccion;
  final String telefono;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool sincronizado;

  Propietario({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.createdAt,
    required this.updatedAt,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sincronizado': sincronizado ? 1 : 0,
    };
  }

  factory Propietario.fromMap(Map<String, dynamic> map) {
    return Propietario(
      id: map['id'],
      nombre: map['nombre'],
      direccion: map['direccion'],
      telefono: map['telefono'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      sincronizado: map['sincronizado'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
    };
  }

  Propietario copyWith({
    String? id,
    String? nombre,
    String? direccion,
    String? telefono,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? sincronizado,
  }) {
    return Propietario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }
}
