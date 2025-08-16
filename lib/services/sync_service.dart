import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/propietario_dao.dart';
import '../database/tienda_dao.dart';
import '../models/propietario.dart';
import '../models/tienda.dart';
import '../config/api_config.dart';

class SyncService {
  final PropietarioDao _propietarioDao = PropietarioDao();
  final TiendaDao _tiendaDao = TiendaDao();

  Future<Map<String, dynamic>> sincronizarTodo(String token) async {
    List<String> errores = [];
    int propietariosSincronizados = 0;
    int tiendasSincronizadas = 0;

    try {
      // Sincronizar propietarios
      List<Propietario> propietariosPendientes = await _propietarioDao.getPendientesSincronizacion();
      
      for (Propietario propietario in propietariosPendientes) {
        try {
          bool exito = await _sincronizarPropietario(propietario, token);
          if (exito) {
            propietariosSincronizados++;
          } else {
            errores.add('Error sincronizando propietario: ${propietario.nombre}');
          }
        } catch (e) {
          errores.add('Error sincronizando propietario ${propietario.nombre}: $e');
        }
      }

      // Sincronizar tiendas
      List<Tienda> tiendasPendientes = await _tiendaDao.getPendientesSincronizacion();
      
      for (Tienda tienda in tiendasPendientes) {
        try {
          bool exito = await _sincronizarTienda(tienda, token);
          if (exito) {
            tiendasSincronizadas++;
          } else {
            errores.add('Error sincronizando tienda: ${tienda.direccionTienda}');
          }
        } catch (e) {
          errores.add('Error sincronizando tienda ${tienda.direccionTienda}: $e');
        }
      }

      return {
        'exito': errores.isEmpty,
        'propietarios_sincronizados': propietariosSincronizados,
        'tiendas_sincronizadas': tiendasSincronizadas,
        'errores': errores,
      };
    } catch (e) {
      return {
        'exito': false,
        'propietarios_sincronizados': propietariosSincronizados,
        'tiendas_sincronizadas': tiendasSincronizadas,
        'errores': ['Error general en sincronización: $e'],
      };
    }
  }

  Future<bool> _sincronizarPropietario(Propietario propietario, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/propietarios'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': propietario.id,
          'nombre': propietario.nombre,
          'direccion': propietario.direccion,
          'telefono': propietario.telefono,
          'created_at': propietario.createdAt.toIso8601String(),
          'updated_at': propietario.updatedAt.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Marcar como sincronizado
        Propietario propietarioActualizado = propietario.copyWith(
          sincronizado: true,
          updatedAt: DateTime.now(),
        );
        await _propietarioDao.update(propietarioActualizado);
        return true;
      } else {
        print('Error sincronizando propietario: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en _sincronizarPropietario: $e');
      return false;
    }
  }

  Future<bool> _sincronizarTienda(Tienda tienda, String token) async {
    try {
      Map<String, dynamic> data = {
        'id': tienda.id,
        'propietario_id': tienda.propietarioId,
        'fecha_permiso': tienda.fechaPermiso.toIso8601String().split('T')[0],
        'direccion_tienda': tienda.direccionTienda,
        'created_at': tienda.createdAt.toIso8601String(),
        'updated_at': tienda.updatedAt.toIso8601String(),
      };

      // Agregar campos opcionales solo si no son null
      if (tienda.certificadoBomberos != null) {
        data['certificado_bomberos'] = tienda.certificadoBomberos;
      }
      if (tienda.saycoAcinpro != null) {
        data['sayco_acinpro'] = tienda.saycoAcinpro;
      }
      if (tienda.latitud != null) {
        data['latitud'] = tienda.latitud;
      }
      if (tienda.longitud != null) {
        data['longitud'] = tienda.longitud;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/tiendas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Marcar como sincronizado
        Tienda tiendaActualizada = tienda.copyWith(
          sincronizado: true,
          updatedAt: DateTime.now(),
        );
        await _tiendaDao.update(tiendaActualizada);
        
        // Si hay foto, sincronizarla por separado
        if (tienda.fotoUrl != null) {
          await _sincronizarFoto(tienda.id, tienda.fotoUrl!, token);
        }
        
        return true;
      } else {
        print('Error sincronizando tienda: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en _sincronizarTienda: $e');
      return false;
    }
  }

  Future<bool> _sincronizarFoto(String tiendaId, String fotoPath, String token) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/tiendas/$tiendaId/foto'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('foto', fotoPath));

      var response = await request.send();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error sincronizando foto: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error en _sincronizarFoto: $e');
      return false;
    }
  }

  Future<int> obtenerPendientesSincronizacion() async {
    try {
      // Obtener propietarios pendientes de sincronización
      List<Propietario> propietariosPendientes = await _propietarioDao.getPendientesSincronizacion();
      
      // Obtener tiendas pendientes de sincronización
      List<Tienda> tiendasPendientes = await _tiendaDao.getPendientesSincronizacion();
      
      // Retornar el total de elementos pendientes
      return propietariosPendientes.length + tiendasPendientes.length;
    } catch (e) {
      print('Error al obtener pendientes de sincronización: $e');
      return 0;
    }
  }
}

class ApiConfig {
  static get baseUrl => null;
}
