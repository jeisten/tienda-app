import 'package:flutter/material.dart';
import '../models/tienda.dart';
import '../models/propietario.dart';
import '../database/tienda_dao.dart';
import '../database/propietario_dao.dart';
import 'add_tienda_screen.dart';

class TiendasScreen extends StatefulWidget {
  const TiendasScreen({Key? key}) : super(key: key);

  @override
  State<TiendasScreen> createState() => _TiendasScreenState();
}

class _TiendasScreenState extends State<TiendasScreen> {
  final TiendaDao _tiendaDao = TiendaDao();
  final PropietarioDao _propietarioDao = PropietarioDao();
  List<Tienda> _tiendas = [];
  Map<String, Propietario> _propietarios = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
    });

    try {
      // Cargar tiendas
      List<Tienda> tiendas = await _tiendaDao.getAll();
      
      // Cargar propietarios para mostrar nombres
      List<Propietario> propietarios = await _propietarioDao.getAll();
      Map<String, Propietario> mapaProps = {};
      for (var prop in propietarios) {
        mapaProps[prop.id] = prop;
      }

      setState(() {
        _tiendas = tiendas;
        _propietarios = mapaProps;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando tiendas: $e')),
      );
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _eliminarTienda(String id) async {
    try {
      await _tiendaDao.delete(id);
      _cargarDatos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tienda eliminada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error eliminando tienda: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiendas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _tiendas.isEmpty
              ? const Center(
                  child: Text(
                    'No hay tiendas registradas',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _tiendas.length,
                  itemBuilder: (context, index) {
                    final tienda = _tiendas[index];
                    final propietario = _propietarios[tienda.propietarioId];
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: tienda.sincronizado
                              ? Colors.green
                              : Colors.orange,
                          child: Icon(
                            tienda.sincronizado
                                ? Icons.check
                                : Icons.sync_problem,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(propietario?.nombre ?? 'Propietario desconocido'),
                        subtitle: Text(tienda.direccionTienda),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Fecha permiso:', 
                                  '${tienda.fechaPermiso.day}/${tienda.fechaPermiso.month}/${tienda.fechaPermiso.year}'),
                                if (tienda.certificadoBomberos != null)
                                  _buildInfoRow('Cert. Bomberos:', tienda.certificadoBomberos!),
                                if (tienda.saycoAcinpro != null)
                                  _buildInfoRow('SAYCO/ACINPRO:', tienda.saycoAcinpro!),
                                if (tienda.latitud != null && tienda.longitud != null)
                                  _buildInfoRow('Coordenadas:', 
                                    '${tienda.latitud!.toStringAsFixed(6)}, ${tienda.longitud!.toStringAsFixed(6)}'),
                                _buildInfoRow('Creado:', 
                                  '${tienda.createdAt.day}/${tienda.createdAt.month}/${tienda.createdAt.year}'),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmar eliminación'),
                                            content: const Text(
                                              '¿Está seguro de eliminar esta tienda?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _eliminarTienda(tienda.id);
                                                },
                                                child: const Text('Eliminar'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      label: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTiendaScreen(),
            ),
          );
          if (resultado == true) {
            _cargarDatos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
