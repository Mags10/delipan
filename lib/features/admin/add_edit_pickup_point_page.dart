import 'package:flutter/material.dart';
import 'package:delipan/config/styles.dart';
import 'package:delipan/models/pickup_point.dart';
import 'package:delipan/services/pickup_service.dart';
import 'package:delipan/services/geocoding_service.dart';

class AddEditPickupPointPage extends StatefulWidget {
  final PickupPoint? pickupPoint;

  const AddEditPickupPointPage({
    super.key,
    this.pickupPoint,
  });

  @override
  State<AddEditPickupPointPage> createState() => _AddEditPickupPointPageState();
}

class _AddEditPickupPointPageState extends State<AddEditPickupPointPage> {
  final _formKey = GlobalKey<FormState>();  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController();
  
  final PickupService _pickupService = PickupService();
  final GeocodingService _geocodingService = GeocodingService();
  
  bool _isLoading = false;
  bool _isGeocodingLoading = false;
  double? _latitude;
  double? _longitude;
  String? _geocodingError;

  @override
  void initState() {
    super.initState();
    if (widget.pickupPoint != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final point = widget.pickupPoint!;    _nameController.text = point.nombre;
    _addressController.text = point.direccion;
    _hoursController.text = point.horario;
    _latitude = point.latitude;
    _longitude = point.longitude;
  }
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _geocodeAddress() async {
    if (_addressController.text.trim().isEmpty) {
      setState(() {
        _geocodingError = 'Ingresa una dirección válida';
      });
      return;
    }

    setState(() {
      _isGeocodingLoading = true;
      _geocodingError = null;
    });

    try {
      final coordinates = await GeocodingService.getCoordinatesFromAddress(
        _addressController.text.trim(),
      );

      if (coordinates != null) {
        setState(() {
          _latitude = coordinates['latitude'];
          _longitude = coordinates['longitude'];
          _geocodingError = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coordenadas obtenidas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _geocodingError = 'No se pudieron obtener las coordenadas para esta dirección';
        });
      }
    } catch (e) {
      setState(() {
        _geocodingError = 'Error al obtener coordenadas: $e';
      });
    } finally {
      setState(() {
        _isGeocodingLoading = false;
      });
    }
  }

  Future<void> _savePickupPoint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, obtén las coordenadas de la dirección primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {      final pickupPoint = PickupPoint(
        id: widget.pickupPoint?.id,
        nombre: _nameController.text.trim(),
        direccion: _addressController.text.trim(),
        horario: _hoursController.text.trim(),
        distancia: 0.0, // Se calculará automáticamente
        latitude: _latitude,
        longitude: _longitude,
      );

      if (widget.pickupPoint != null) {        // Editar punto existente
        await _pickupService.updatePickupPoint(widget.pickupPoint!.id!, pickupPoint);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Punto de recogida actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Crear nuevo punto
        await _pickupService.addPickupPoint(pickupPoint);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Punto de recogida creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                    isEditing ? 'Editar Punto de Recogida' : 'Nuevo Punto de Recogida',
                    style: AppStyles.appTitle.copyWith(fontSize: 24),
                  ),
                  Spacer(),
                  Icon(
                    isEditing ? Icons.edit_location : Icons.add_location,
                    color: AppStyles.primaryBrown,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Información básica
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información Básica',
                              style: TextStyle(
                                fontSize: AppStyles.cardTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppStyles.primaryBrown,
                              ),
                            ),
                            SizedBox(height: 20),
                            // Nombre
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Nombre del punto de recogida',
                                labelStyle: TextStyle(color: AppStyles.primaryBrown),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppStyles.primaryBrown),
                                ),
                                prefixIcon: Icon(Icons.store, color: AppStyles.primaryBrown),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa un nombre';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            // Dirección
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Dirección completa',
                                labelStyle: TextStyle(color: AppStyles.primaryBrown),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppStyles.primaryBrown),
                                ),
                                prefixIcon: Icon(Icons.location_on, color: AppStyles.primaryBrown),
                              ),
                              maxLines: 2,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa una dirección';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            // Botón para obtener coordenadas
                            Container(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isGeocodingLoading ? null : _geocodeAddress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: _isGeocodingLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(Icons.my_location),
                                label: Text(
                                  _isGeocodingLoading
                                      ? 'Obteniendo coordenadas...'
                                      : 'Obtener Coordenadas',
                                  style: TextStyle(fontSize: AppStyles.buttonFontSize),
                                ),
                              ),
                            ),
                            // Estado de las coordenadas
                            if (_latitude != null && _longitude != null) ...[
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Coordenadas: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: AppStyles.cardTextFontSize,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (_geocodingError != null) ...[
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _geocodingError!,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: AppStyles.cardTextFontSize,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Información adicional
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información Adicional',
                              style: TextStyle(
                                fontSize: AppStyles.cardTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppStyles.primaryBrown,
                              ),                            ),
                            SizedBox(height: 20),
                            // Horarios
                            TextFormField(
                              controller: _hoursController,
                              decoration: InputDecoration(
                                labelText: 'Horarios de atención (opcional)',
                                labelStyle: TextStyle(color: AppStyles.primaryBrown),
                                hintText: 'Ej: Lun-Vie 9:00-18:00, Sáb 9:00-14:00',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppStyles.primaryBrown),
                                ),
                                prefixIcon: Icon(Icons.access_time, color: AppStyles.primaryBrown),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      // Botón guardar
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _savePickupPoint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryBrown,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Guardando...',
                                      style: TextStyle(fontSize: AppStyles.buttonFontSize),
                                    ),
                                  ],
                                )
                              : Text(
                                  isEditing ? 'Actualizar Punto de Recogida' : 'Crear Punto de Recogida',
                                  style: TextStyle(fontSize: AppStyles.buttonFontSize),
                                ),
                        ),
                      ),
                      SizedBox(height: 16),
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
}
