import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../config/auth_config.dart'; // Asumiendo que tienes un archivo de configuración para el token
class SyncButton extends StatefulWidget {
  final VoidCallback? onSyncComplete;

  const SyncButton({Key? key, this.onSyncComplete}) : super(key: key);

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  final SyncService _syncService = SyncService();
  bool _sincronizando = false;

  Future<void> _sincronizar() async {
    setState(() {
      _sincronizando = true;
    });

    try {
      // Obtener el token de una configuración estática o de un servicio
      String? token = AuthConfig.apiToken; // Asumiendo que tienes una clase AuthConfig con un token estático
      
      Map<String, dynamic> resultado = await _syncService.sincronizarTodo(token!);
      
      if (mounted) {
        String mensaje;
        if (resultado['exito']) {
          mensaje = 'Sincronización exitosa!\n'
                   'Propietarios: ${resultado['propietarios_sincronizados']}\n'
                   'Tiendas: ${resultado['tiendas_sincronizadas']}';
        } else {
          mensaje = 'Errores en sincronización:\n'
                   '${resultado['errores'].join('\n')}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: resultado['exito'] ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        if (widget.onSyncComplete != null) {
          widget.onSyncComplete!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error durante la sincronización: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _sincronizando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _sincronizando ? null : _sincronizar,
      icon: _sincronizando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
      tooltip: 'Sincronizar',
    );
  }
}

class AuthConfig {
  static String? get apiToken => null;
}
