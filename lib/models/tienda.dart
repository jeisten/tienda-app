class Tienda {
  final String id;
  final String propietarioId;
  final DateTime fechaPermiso;
  final String? fotoUrl;
  final String? certificadoBomberos;
  final String? saycoAcinpro;
  final double? latitud;
  final double? longitud;
  final String direccionTienda;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool sincronizado;

  Tienda({
    required this.id,
    required this.propietarioId,
    required this.fechaPermiso,
    this.fotoUrl,
    this.certificadoBomberos,
    this.saycoAcinpro,
    this.latitud,
    this.longitud,
    required this.direccionTienda,
    required this.createdAt,
    required this.updatedAt,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propietario_id': propietarioId,
      'fecha_permiso': fechaPermiso.toIso8601String().split('T')[0],
      'foto_url': fotoUrl,
      'certificado_bomberos': certificadoBomberos,
      'sayco_acinpro': saycoAcinpro,
      'latitud': latitud,
      'longitud': longitud,
      'direccion_tienda': direccionTienda,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sincronizado': sincronizado ? 1 : 0,
    };
  }

  factory Tienda.fromMap(Map<String, dynamic> map) {
    return Tienda(
      id: map['id'],
      propietarioId: map['propietario_id'],
      fechaPermiso: DateTime.parse(map['fecha_permiso']),
      fotoUrl: map['foto_url'],
      certificadoBomberos: map['certificado_bomberos'],
      saycoAcinpro: map['sayco_acinpro'],
      latitud: map['latitud']?.toDouble(),
      longitud: map['longitud']?.toDouble(),
      direccionTienda: map['direccion_tienda'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      sincronizado: map['sincronizado'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propietario_id': propietarioId,
      'fecha_permiso': fechaPermiso.toIso8601String().split('T')[0],
      'foto_url': fotoUrl,
      'certificado_bomberos': certificadoBomberos,
      'sayco_acinpro': saycoAcinpro,
      'latitud': latitud,
      'longitud': longitud,
      'direccion_tienda': direccionTienda,
    };
  }

  Tienda copyWith({
    String? id,
    String? propietarioId,
    DateTime? fechaPermiso,
    String? fotoUrl,
    String? certificadoBomberos,
    String? saycoAcinpro,
    double? latitud,
    double? longitud,
    String? direccionTienda,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? sincronizado,
  }) {
    return Tienda(
      id: id ?? this.id,
      propietarioId: propietarioId ?? this.propietarioId,
      fechaPermiso: fechaPermiso ?? this.fechaPermiso,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      certificadoBomberos: certificadoBomberos ?? this.certificadoBomberos,
      saycoAcinpro: saycoAcinpro ?? this.saycoAcinpro,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccionTienda: direccionTienda ?? this.direccionTienda,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }
}
