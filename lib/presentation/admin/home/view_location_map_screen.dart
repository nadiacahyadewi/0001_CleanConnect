import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewLocationMap extends StatefulWidget {
  final String address;
  final String customerName;
  final String orderId;

  const ViewLocationMap({
    super.key,
    required this.address,
    required this.customerName,
    required this.orderId,
  });

  @override
  State<ViewLocationMap> createState() => _ViewLocationMapState();
}

class _ViewLocationMapState extends State<ViewLocationMap> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  CameraPosition? _initialCamera;
  Position? _currentPosition;
  LatLng? _destinationLocation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  Future<void> _setupMap() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current position
      await _getCurrentPosition();
      
      // Get destination coordinates from address
      await _getDestinationCoordinates();
      
      // Setup camera and markers
      _setupCameraAndMarkers();
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      // Check location service
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Location service tidak aktif';
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen';
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      // If location fails, use default Jakarta location
      _currentPosition = Position(
        latitude: -6.2088,
        longitude: 106.8456,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0, altitudeAccuracy: 0, headingAccuracy: 0,
      );
    }
  }

  Future<void> _getDestinationCoordinates() async {
    try {
      List<Location> locations = await locationFromAddress(widget.address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        _destinationLocation = LatLng(location.latitude, location.longitude);
      } else {
        throw 'Alamat tidak ditemukan';
      }
    } catch (e) {
      // If geocoding fails, use current position as fallback
      _destinationLocation = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }
  }

  void _setupCameraAndMarkers() {
    if (_destinationLocation != null && _currentPosition != null) {
      // Set camera to destination
      _initialCamera = CameraPosition(
        target: _destinationLocation!,
        zoom: 16.0,
      );

      // Add markers
      _markers = {
        // Current location marker
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Lokasi Anda',
            snippet: 'Posisi saat ini',
          ),
        ),
        // Destination marker
        Marker(
          markerId: const MarkerId('destination'),
          position: _destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: widget.customerName,
            snippet: 'Order #${widget.orderId}',
          ),
        ),
      };

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showBothLocations() async {
    if (_currentPosition != null && _destinationLocation != null) {
      final GoogleMapController controller = await _controller.future;
      
      // Calculate bounds to show both markers
      double minLat = _currentPosition!.latitude < _destinationLocation!.latitude
          ? _currentPosition!.latitude
          : _destinationLocation!.latitude;
      double maxLat = _currentPosition!.latitude > _destinationLocation!.latitude
          ? _currentPosition!.latitude
          : _destinationLocation!.latitude;
      double minLng = _currentPosition!.longitude < _destinationLocation!.longitude
          ? _currentPosition!.longitude
          : _destinationLocation!.longitude;
      double maxLng = _currentPosition!.longitude > _destinationLocation!.longitude
          ? _currentPosition!.longitude
          : _destinationLocation!.longitude;

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          100.0, // padding
        ),
      );
    }
  }

  Future<void> _goToDestination() async {
    if (_destinationLocation != null) {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(_destinationLocation!, 18.0),
      );
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentPosition != null) {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          18.0,
        ),
      );
    }
  }

  double _calculateDistance() {
    if (_currentPosition != null && _destinationLocation != null) {
      return Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _destinationLocation!.latitude,
        _destinationLocation!.longitude,
      );
    }
    return 0.0;
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toInt()} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lokasi ${widget.customerName}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade600,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat peta...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _setupMap,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: _initialCamera!,
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      zoomControlsEnabled: false,
                    ),
                    
                    // Info Card
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.blue.shade600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.receipt, color: Colors.orange.shade600),
                                  const SizedBox(width: 8),
                                  Text('Order #${widget.orderId}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.red.shade600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.address,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              if (_currentPosition != null && _destinationLocation != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.straighten, color: Colors.green.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Jarak: ${_formatDistance(_calculateDistance())}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'show_both',
            onPressed: _showBothLocations,
            backgroundColor: Colors.purple,
            child: const Icon(Icons.fullscreen, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'destination',
            onPressed: _goToDestination,
            backgroundColor: Colors.red,
            child: const Icon(Icons.location_on, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'current',
            onPressed: _goToCurrentLocation,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Open Google Maps for directions
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Membuka Google Maps untuk navigasi...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.directions, color: Colors.white),
                label: const Text(
                  'Navigasi',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Share location
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berbagi lokasi...'),
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Bagikan'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}