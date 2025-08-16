import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/propietario.dart';
import '../models/tienda.dart';

class ApiService {
  static const String baseUrl = 'http://api-tienda.nacerparavivir.org/api'; // Cambia por tu URL
  
  // Headers básicos
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Propietarios
  Future<bool> crearPropietario(Propietario propietario) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/propietarios'),
        headers: _headers,
        body: jsonEncode(propietario.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creando propietario: $e');
      return false;
    }
  }

  Future<List<Propietario>> obtenerPropietarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/propietarios'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => Propietario.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo propietarios: $e');
      return [];
    }
  }

  // Tiendas
  Future<bool> crearTienda(Tienda tienda) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tiendas'),
        headers: _headers,
        body: jsonEncode(tienda.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creando tienda: $e');
      return false;
    }
  }

  Future<List<Tienda>> obtenerTiendas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tiendas'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => Tienda.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo tiendas: $e');
      return [];
    }
  }

  // Verificar conectividad
  Future<bool> verificarConectividad() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
