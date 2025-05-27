import 'package:delipan/config/styles.dart';
import 'package:delipan/models/pickup_point.dart';
import 'package:delipan/services/geocoding_service.dart';
import 'package:delipan/services/pickup_service.dart';
import 'package:delipan/features/admin/add_edit_pickup_point_page.dart';
import 'package:flutter/material.dart';

class AdminPickupPointsPage extends StatefulWidget {
  const AdminPickupPointsPage({super.key});

  @override
  State<AdminPickupPointsPage> createState() => _AdminPickupPointsPageState();
}

class _AdminPickupPointsPageState extends State<AdminPickupPointsPage> {
  final PickupService _pickupService = PickupService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: AppStyles.lightBrown,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: AppStyles.primaryBrown),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppStyles.primaryBrown,
                    radius: 16,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Image.asset(
                        'assets/Logo_delipan.png',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Gestión de Puntos',
                    style: AppStyles.appTitle.copyWith(fontSize: 24),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add, color: AppStyles.primaryBrown),
                    onPressed: () => _showAddEditDialog(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: StreamBuilder<List<PickupPoint>>(
                stream: _pickupService.getAllPickupPointsForAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryBrown),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Error al cargar los puntos de recogida',
                            style: AppStyles.bodyText,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final puntos = snapshot.data ?? [];

                  if (puntos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off, size: 64, color: AppStyles.darkGrey),
                          SizedBox(height: 16),
                          Text(
                            'No hay puntos de recogida registrados',
                            style: AppStyles.bodyText,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _showAddEditDialog(context),
                            style: AppStyles.primaryButtonStyle,
                            child: Text('Agregar Primer Punto'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: puntos.length,
                    itemBuilder: (context, index) {
                      final punto = puntos[index];
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: punto.isActive 
                                      ? AppStyles.primaryBrown.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.store,
                                    color: punto.isActive 
                                      ? AppStyles.primaryBrown 
                                      : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        punto.nombre,
                                        style: AppStyles.cardTitle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        punto.direccion,
                                        style: AppStyles.cardText.copyWith(
                                          color: AppStyles.darkGrey.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        _showAddEditDialog(context, punto: punto);
                                        break;
                                      case 'toggle':
                                        _toggleActiveStatus(punto);
                                        break;
                                      case 'delete':
                                        _showDeleteConfirmation(punto);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: AppStyles.primaryBrown),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'toggle',
                                      child: Row(
                                        children: [
                                          Icon(
                                            punto.isActive ? Icons.visibility_off : Icons.visibility,
                                            color: punto.isActive ? Colors.orange : Colors.green,
                                          ),
                                          SizedBox(width: 8),
                                          Text(punto.isActive ? 'Desactivar' : 'Activar'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Eliminar'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoChip(
                                    icon: Icons.schedule,
                                    label: punto.horario,
                                  ),
                                ),
                                SizedBox(width: 8),
                                _buildInfoChip(
                                  icon: Icons.location_on,
                                  label: punto.distanciaString,
                                ),
                              ],
                            ),
                            if (punto.hasCoordinates) ...[
                              SizedBox(height: 8),
                              _buildInfoChip(
                                icon: Icons.map,
                                label: 'Coordenadas: ${punto.latitude!.toStringAsFixed(4)}, ${punto.longitude!.toStringAsFixed(4)}',
                              ),
                            ],
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: punto.isActive 
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    punto.isActive ? 'Activo' : 'Inactivo',
                                    style: AppStyles.cardText.copyWith(
                                      color: punto.isActive ? Colors.green : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Creado: ${_formatDate(punto.createdAt)}',
                                  style: AppStyles.cardText.copyWith(
                                    fontSize: 10,
                                    color: AppStyles.darkGrey.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppStyles.lightBrown,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppStyles.primaryBrown),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppStyles.cardText.copyWith(
                fontSize: 11,
                color: AppStyles.primaryBrown,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddEditDialog(BuildContext context, {PickupPoint? punto}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPickupPointPage(pickupPoint: punto),
      ),
    );
  }

  void _toggleActiveStatus(PickupPoint punto) async {
    final updatedPoint = punto.copyWith(
      isActive: !punto.isActive,
      updatedAt: DateTime.now(),
    );

    final success = await _pickupService.updatePickupPoint(punto.id!, updatedPoint);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            punto.isActive 
              ? 'Punto de recogida desactivado'
              : 'Punto de recogida activado',
          ),
          backgroundColor: AppStyles.primaryBrown,
        ),
      );
    }
  }

  void _showDeleteConfirmation(PickupPoint punto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Punto de Recogida'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${punto.nombre}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _pickupService.deletePickupPoint(punto.id!);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Punto de recogida eliminado'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class AddEditPickupPointPage extends StatefulWidget {
  final PickupPoint? pickupPoint;

  const AddEditPickupPointPage({super.key, this.pickupPoint});

  @override
  State<AddEditPickupPointPage> createState() => _AddEditPickupPointPageState();
}

class _AddEditPickupPointPageState extends State<AddEditPickupPointPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _horarioController = TextEditingController();
  final _distanciaController = TextEditingController();
  final PickupService _pickupService = PickupService();
  
  bool _isLoading = false;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    if (widget.pickupPoint != null) {
      _nombreController.text = widget.pickupPoint!.nombre;
      _direccionController.text = widget.pickupPoint!.direccion;
      _horarioController.text = widget.pickupPoint!.horario;
      _distanciaController.text = widget.pickupPoint!.distancia.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pickupPoint != null;

    return Scaffold(
      backgroundColor: AppStyles.lightBrown,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: AppStyles.lightBrown,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: AppStyles.primaryBrown),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppStyles.primaryBrown,
                    radius: 16,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Image.asset(
                        'assets/Logo_delipan.png',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    isEditing ? 'Editar Punto' : 'Nuevo Punto',
                    style: AppStyles.appTitle.copyWith(fontSize: 24),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        controller: _nombreController,
                        label: 'Nombre del punto',
                        hint: 'Ej: DeliPan Centro',
                        icon: Icons.store,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      _buildFormField(
                        controller: _direccionController,
                        label: 'Dirección',
                        hint: 'Ej: Av. Principal 123, Centro',
                        icon: Icons.location_on,
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La dirección es requerida';
                          }
                          return null;
                        },
                        suffixIcon: _isGeocoding
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: Icon(Icons.search, color: AppStyles.primaryBrown),
                              onPressed: _geocodeAddress,
                            ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      _buildFormField(
                        controller: _horarioController,
                        label: 'Horario',
                        hint: 'Ej: Lun-Vie: 7:00-20:00, Sáb-Dom: 8:00-18:00',
                        icon: Icons.schedule,
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El horario es requerido';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      _buildFormField(
                        controller: _distanciaController,
                        label: 'Distancia (km)',
                        hint: 'Ej: 1.5',
                        icon: Icons.straighten,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La distancia es requerida';
                          }
                          final distance = double.tryParse(value);
                          if (distance == null || distance <= 0) {
                            return 'Ingresa una distancia válida';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _savePickupPoint,
                          style: AppStyles.primaryButtonStyle.copyWith(
                            padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isEditing ? 'ACTUALIZAR' : 'GUARDAR',
                                style: AppStyles.buttonText.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.cardTitle.copyWith(
            color: AppStyles.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppStyles.primaryBrown),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppStyles.mediumBrown),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppStyles.primaryBrown, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _geocodeAddress() async {
    final address = _direccionController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingresa una dirección primero')),
      );
      return;
    }

    setState(() {
      _isGeocoding = true;
    });

    try {
      final coordinates = await GeocodingService.getCoordinatesFromAddress(address);
      
      if (coordinates != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Coordenadas encontradas: ${coordinates['latitude']!.toStringAsFixed(4)}, ${coordinates['longitude']!.toStringAsFixed(4)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudieron encontrar las coordenadas para esta dirección'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar coordenadas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  void _savePickupPoint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final distance = double.parse(_distanciaController.text);
      
      // Obtener coordenadas de la dirección
      Map<String, double>? coordinates;
      try {
        coordinates = await GeocodingService.getCoordinatesFromAddress(
          _direccionController.text.trim(),
        );
      } catch (e) {
        print('Error obteniendo coordenadas: $e');
      }

      final pickupPoint = PickupPoint(
        id: widget.pickupPoint?.id,
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        horario: _horarioController.text.trim(),
        distancia: distance,
        latitude: coordinates?['latitude'],
        longitude: coordinates?['longitude'],
        isActive: widget.pickupPoint?.isActive ?? true,
        createdAt: widget.pickupPoint?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.pickupPoint != null) {
        success = await _pickupService.updatePickupPoint(widget.pickupPoint!.id!, pickupPoint);
      } else {
        final id = await _pickupService.addPickupPoint(pickupPoint);
        success = id != null;
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.pickupPoint != null 
                ? 'Punto de recogida actualizado'
                : 'Punto de recogida agregado',
            ),
            backgroundColor: AppStyles.primaryBrown,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el punto de recogida'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _horarioController.dispose();
    _distanciaController.dispose();
    super.dispose();
  }
}
