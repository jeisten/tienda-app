import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../widgets/sync_button.dart';
import 'propietarios_screen.dart';
import 'tiendas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SyncService _syncService = SyncService();
  int _pendientesSincronizacion = 0;

  @override
  void initState() {
    super.initState();
    _cargarPendientes();
  }

  Future<void> _cargarPendientes() async {
    int pendientes = await _syncService.obtenerPendientesSincronizacion();
    setState(() {
      _pendientesSincronizacion = pendientes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiendas App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          SyncButton(
            onSyncComplete: _cargarPendientes,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Estado de sincronización
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _pendientesSincronizacion > 0 
                        ? Icons.sync_problem 
                        : Icons.check_circle,
                      color: _pendientesSincronizacion > 0 
                        ? Colors.orange 
                        : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _pendientesSincronizacion > 0
                        ? '$_pendientesSincronizacion elementos pendientes de sincronizar'
                        : 'Todo sincronizado',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botones de navegación
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'Propietarios',
                    Icons.person,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PropietariosScreen(),
                      ),
                    ).then((_) => _cargarPendientes()),
                  ),
                  _buildMenuCard(
                    context,
                    'Tiendas',
                    Icons.store,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TiendasScreen(),
                      ),
                    ).then((_) => _cargarPendientes()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
