// Modelos completos basados en el schema OpenAPI real del backend

// ============== USUARIOS ==============
class User {
  final int? id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isStaff;
  final bool isActive;

  User({
    this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.isStaff = false,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      isStaff: json['is_staff'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_staff': isStaff,
      'is_active': isActive,
    };
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

// Modelo para respuesta de login
class LoginResponse {
  final String token;
  final User? user;

  LoginResponse({required this.token, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

// Modelo para registro
class UserRegistration {
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final bool? esResidente;

  UserRegistration({
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.esResidente,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'es_residente': esResidente,
    };
  }
}

// Residente con información completa
class ResidenteRead {
  final int id;
  final User usuario;
  final Propiedad? propiedad;
  final String rol;
  final String? telefono;
  final DateTime fechaRegistro;

  ResidenteRead({
    required this.id,
    required this.usuario,
    this.propiedad,
    required this.rol,
    this.telefono,
    required this.fechaRegistro,
  });

  factory ResidenteRead.fromJson(Map<String, dynamic> json) {
    return ResidenteRead(
      id: json['id'],
      usuario: User.fromJson(json['usuario']),
      propiedad: json['propiedad'] != null
          ? Propiedad.fromJson(json['propiedad'])
          : null,
      rol: json['rol'],
      telefono: json['telefono'],
      fechaRegistro: DateTime.parse(json['fecha_registro']),
    );
  }
}

// ============== CONDOMINIO ==============
class Propiedad {
  final int id;
  final String numero;
  final int? numeroCasa;
  final int? bloque;
  final String? torre;
  final double? metrosCuadrados;
  final int propietarioId;
  final String? observaciones;

  Propiedad({
    required this.id,
    required this.numero,
    this.numeroCasa,
    this.bloque,
    this.torre,
    this.metrosCuadrados,
    required this.propietarioId,
    this.observaciones,
  });

  factory Propiedad.fromJson(Map<String, dynamic> json) {
    return Propiedad(
      id: json['id'],
      numero: json['numero'],
      numeroCasa: json['numero_casa'],
      bloque: json['bloque'],
      torre: json['torre'],
      metrosCuadrados: json['metros_cuadrados']?.toDouble(),
      propietarioId: json['propietario_id'],
      observaciones: json['observaciones'],
    );
  }
}

class AreaComun {
  final int id;
  final String nombre;
  final String? descripcion;
  final int? capacidad;
  final double? costoReserva;
  final bool disponible;
  final String? horariosDisponibles;
  final String? reglas;

  AreaComun({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.capacidad,
    this.costoReserva,
    this.disponible = true,
    this.horariosDisponibles,
    this.reglas,
  });

  factory AreaComun.fromJson(Map<String, dynamic> json) {
    return AreaComun(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      capacidad: json['capacidad'],
      costoReserva: json['costo_reserva']?.toDouble(),
      disponible: json['disponible'] ?? true,
      horariosDisponibles: json['horarios_disponibles'],
      reglas: json['reglas'],
    );
  }
}

class Aviso {
  final int id;
  final String titulo;
  final String contenido;
  final DateTime fechaPublicacion;
  final DateTime? fechaExpiracion;
  final String? prioridad;
  final bool activo;

  Aviso({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.fechaPublicacion,
    this.fechaExpiracion,
    this.prioridad,
    this.activo = true,
  });

  factory Aviso.fromJson(Map<String, dynamic> json) {
    return Aviso(
      id: json['id'],
      titulo: json['titulo'],
      contenido: json['contenido'],
      fechaPublicacion: DateTime.parse(json['fecha_publicacion']),
      fechaExpiracion: json['fecha_expiracion'] != null
          ? DateTime.parse(json['fecha_expiracion'])
          : null,
      prioridad: json['prioridad'],
      activo: json['activo'] ?? true,
    );
  }
}

class Regla {
  final int id;
  final String titulo;
  final String contenido;
  final String categoria;
  final DateTime fechaCreacion;

  Regla({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.categoria,
    required this.fechaCreacion,
  });

  factory Regla.fromJson(Map<String, dynamic> json) {
    return Regla(
      id: json['id'],
      titulo: json['titulo'],
      contenido: json['contenido'],
      categoria: json['categoria'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );
  }
}
