import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tienda.dart';
import '../models/propietario.dart';
import '../database/tienda_dao.dart';
import '../database/propietario_dao.dart';
import '../services/location_service.dart';

class AddTiendaScreen extends StatefulWidget {
  const AddTiendaScreen({Key? key}) : super(key: key);

  @override
  State<AddTiendaScreen> createState() => _AddTiendaScreenState();
}

class _AddTiendaScreenState extends State<AddTiendaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionController = TextEditingController();
  final _certificadoBomberosController = TextEditingController();
  final _saycoAcinproController = TextEditingController();
  
  final TiendaDao _tiendaDao = TiendaDao();
  final PropietarioDao _propietarioDao = PropietarioDao();
  final LocationService _locationService = LocationService();
  final ImagePicker _imagePicker = ImagePicker();

  List<Propietario> _propietarios = [];
  Propietario? _propietarioSeleccionado;
  DateTime _fechaPermiso = DateTime.now();
  String? _fotoUrl;
  double? _latitud;
  double? _longitud;
  bool _guardando = false;
  bool _obteniendoUbicacion = false;

  @override
  void initState() {
    super.initState();
    _cargarPropietarios();
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _certificadoBomberosController.dispose();
    _saycoAcinproController.dispose();
    super.dispose();
  }

  Future<void> _cargarPropietarios() async {
    try {
      List<Propietario> propietarios = await _propietarioDao.getAll();
      setState(() {
        _propietarios = propietarios;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando propietarios: $e')),
      );
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaPermiso,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (fecha != null) {
      setState(() {
        _fechaPermiso = fecha;
      });
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (imagen != null) {
        setState(() {
          _fotoUrl = imagen.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error tomando foto: $e')),
      );
    }
  }

  Future<void> _obtenerUbicacion() async {
    setState(() {
      _obteniendoUbicacion = true;
    });

    try {
      Map<String, double>? coordenadas = await _locationService.obtenerCoordenadas();
      if (coordenadas != null) {
        setState(() {
          _latitud = coordenadas['latitud'];
          _longitud = coordenadas['longitud'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación obtenida exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la ubicación')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error obteniendo ubicación: $e')),
      );
    } finally {
      setState(() {
        _obteniendoUbicacion = false;
      });
    }
  }

  Future<void> _guardarTienda() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_propietarioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un propietario')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final tienda = Tienda(
        id: const Uuid().v4(),
        propietarioId: _propietarioSeleccionado!.id,
        fechaPermiso: _fechaPermiso,
        fotoUrl: _fotoUrl,
        certificadoBomberos: _certificadoBomberosController.text.trim().isEmpty 
            ? null : _certificadoBomberosController.text.trim(),
        saycoAcinpro: _saycoAcinproController.text.trim().isEmpty 
            ? null : _saycoAcinproController.text.trim(),
        latitud: _latitud,
        longitud: _longitud,
        direccionTienda: _direccionController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sincronizado: false,
      );

      await _tiendaDao.insert(tienda);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tienda guardada exitosamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando tienda: $e')),
        );
      }
    } finally {
      setState(() {
        _guardando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Tienda'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Selección de propietario
                DropdownButtonFormField<Propietario>(
                  value: _propietarioSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Propietario',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: _propietarios.map((propietario) {
                    return DropdownMenuItem(
                      value: propietario,
                      child: Text(propietario.nombre),
                    );
                  }).toList(),
                  onChanged: (propietario) {
                    setState(() {
                      _propietarioSeleccionado = propietario;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Seleccione un propietario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Fecha del permiso
                InkWell(
                  onTap: _seleccionarFecha,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha del permiso',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_fechaPermiso.day}/${_fechaPermiso.month}/${_fechaPermiso.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dirección de la tienda
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección de la tienda',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La dirección es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Certificado de bomberos
                TextFormField(
                  controller: _certificadoBomberosController,
                  decoration: const InputDecoration(
                    labelText: 'Certificado de bomberos (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_fire_department),
                  ),
                ),
                const SizedBox(height: 16),

                // SAYCO/ACINPRO
                TextFormField(
                  controller: _saycoAcinproController,
                  decoration: const InputDecoration(
                    labelText: 'SAYCO/ACINPRO (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.music_note),
                  ),
                ),
                const SizedBox(height: 16),

                // Foto
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.camera_alt),
                            const SizedBox(width: 8),
                            const Text('Foto de la tienda'),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _tomarFoto,
                              child: const Text('Tomar foto'),
                            ),
                          ],
                        ),
                        if (_fotoUrl != null) ...[
                          const SizedBox(height: 8),
                          const Text('✓ Foto capturada'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ubicación
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.gps_fixed),
                            const SizedBox(width: 8),
                            const Text('Ubicación GPS'),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _obteniendoUbicacion ? null : _obtenerUbicacion,
                              child: _obteniendoUbicacion
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Obtener ubicación'),
                            ),
                          ],
                        ),
                        if (_latitud != null && _longitud != null) ...[                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${_latitud!.toStringAsFixed(6)}, Lng: ${_longitud!.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardarTienda,
                    child: _guardando
                        ? const CircularProgressIndicator()
                        : const Text('Guardar Tienda'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

                          
