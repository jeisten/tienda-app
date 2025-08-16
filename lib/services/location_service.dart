import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<bool> solicitarPermisos() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  Future<Position?> obtenerUbicacionActual() async {
    try {
      bool permisosConcedidos = await solicitarPermisos();
      if (!permisosConcedidos) {
        return null;
      }

      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return position;
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  Future<Map<String, double>?> obtenerCoordenadas() async {
    Position? position = await obtenerUbicacionActual();
    if (position != null) {
      return {
        'latitud': position.latitude,
        'longitud': position.longitude,
      };
    }
    return null;
  }
}
