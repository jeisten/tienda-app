import 'package:flutter/material.dart';
import '../models/propietario.dart';
import '../database/propietario_dao.dart';
import 'add_propietario_screen.dart';

class PropietariosScreen extends StatefulWidget {
  const PropietariosScreen({Key? key}) : super(key: key);

  @override
  State<PropietariosScreen> createState() => _PropietariosScreenState();
}

class _PropietariosScreenState extends State<PropietariosScreen> {
  final PropietarioDao _propietarioDao = PropietarioDao();
  List<Propietario> _propietarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPropietarios();
  }

  Future<void> _cargarPropietarios() async {
    setState(() {
      _cargando = true;
    });

    try {
      List<Propietario> propietarios = await _propietarioDao.getAll();
      setState(() {
        _propietarios = propietarios;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando propietarios: $e')),
      );
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _eliminarPropietario(String id) async {
    try {
      await _propietarioDao.delete(id);
      _cargarPropietarios();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Propietario eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error eliminando propietario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propietarios'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _propietarios.isEmpty
              ? const Center(
                  child: Text(
                    'No hay propietarios registrados',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _propietarios.length,
                  itemBuilder: (context, index) {
                    final propietario = _propietarios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: propietario.sincronizado
                              ? Colors.green
                              : Colors.orange,
                          child: Icon(
                            propietario.sincronizado
                                ? Icons.check
                                : Icons.sync_problem,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(propietario.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(propietario.direccion),
                            Text(propietario.telefono),
                            Text(
                              'Creado: ${propietario.createdAt.day}/${propietario.createdAt.month}/${propietario.createdAt.year}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'eliminar') {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmar eliminación'),
                                  content: Text(
                                    '¿Está seguro de eliminar a ${propietario.nombre}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _eliminarPropietario(propietario.id);
                                      },
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPropietarioScreen(),
            ),
          );
          if (resultado == true) {
            _cargarPropietarios();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
