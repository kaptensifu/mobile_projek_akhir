import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projek_akhir/models/circuit_model.dart';
import 'package:projek_akhir/models/driver_model.dart';
import 'package:projek_akhir/models/team_model.dart';
import 'package:projek_akhir/presenters/f1_presenter.dart';
import 'package:projek_akhir/services/circuit_coordinate.dart';

class SimpleMapsPage extends StatefulWidget {
  final String? circuitId;
  
  const SimpleMapsPage({super.key, this.circuitId});

  @override
  State<SimpleMapsPage> createState() => _SimpleMapsPageState();
}

class _SimpleMapsPageState extends State<SimpleMapsPage> implements DriverView {
  late DriverPresenter _presenter;
  final MapController _mapController = MapController();
  
  bool _isLoading = false;
  List<Circuit> _circuitList = [];
  List<Marker> _markers = [];
  String? _errorMessage;
  
  // Default center position
  static const LatLng _defaultCenter = LatLng(48.8566, 2.3522); // Paris
  
  @override
  void initState() {
    super.initState();
    _presenter = DriverPresenter(this);
    _loadCircuitData();
  }

  void _loadCircuitData() {
    _presenter.loadCircuitData('circuits');
  }

  void _createMarkers() {
    _markers.clear();
    
    for (Circuit circuit in _circuitList) {
      final coordinates = CircuitCoordinates.getCoordinates(circuit.circuitId);
      if (coordinates != null) {
        _markers.add(
          Marker(
            point: LatLng(coordinates.latitude, coordinates.longitude),
            width: 60,
            height: 60,
            child: GestureDetector(
              onTap: () => _showCircuitInfo(circuit),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.circuitId == circuit.circuitId 
                      ? Colors.red 
                      : Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        );
      }
    }
    
    setState(() {});
  }

  void _showCircuitInfo(Circuit circuit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red[700], size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    circuit.circuitName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.place, 'Location', '${circuit.city}, ${circuit.country}'),
            _buildInfoRow(Icons.straighten, 'Length', '${circuit.circuitLength}m'),
            _buildInfoRow(Icons.calendar_today, 'First Start', '${circuit.firstParticipationYear}'),
            _buildInfoRow(Icons.turn_right, 'Corners', '${circuit.numberOfCorners}'),
            if (circuit.lapRecord.isNotEmpty)
              _buildInfoRow(Icons.timer, 'Lap Record', circuit.lapRecord),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _focusOnCircuit(circuit.circuitId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Focus on Map'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _focusOnCircuit(String circuitId) {
    final coordinates = CircuitCoordinates.getCoordinates(circuitId);
    if (coordinates != null) {
      _mapController.move(
        LatLng(coordinates.latitude, coordinates.longitude),
        13.0,
      );
    }
  }

  void _showCircuitList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.map, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'F1 Circuits',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_circuitList.where((c) => CircuitCoordinates.hasCoordinates(c.circuitId)).length} circuits',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _circuitList.length,
                itemBuilder: (context, index) {
                  final circuit = _circuitList[index];
                  final hasCoordinates = CircuitCoordinates.hasCoordinates(circuit.circuitId);
                  final region = CircuitCoordinates.getRegion(circuit.circuitId);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: hasCoordinates ? Colors.red[100] : Colors.grey[200],
                        child: Icon(
                          hasCoordinates ? Icons.location_on : Icons.location_off,
                          color: hasCoordinates ? Colors.red[700] : Colors.grey,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        circuit.circuitName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${circuit.city}, ${circuit.country}'),
                          if (hasCoordinates) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                region,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: hasCoordinates 
                          ? const Icon(Icons.visibility, color: Colors.blue)
                          : const Icon(Icons.visibility_off, color: Colors.grey),
                      onTap: hasCoordinates 
                          ? () {
                              Navigator.pop(context);
                              _focusOnCircuit(circuit.circuitId);
                            }
                          : null,
                      enabled: hasCoordinates,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: const Text(
          'F1 Circuit Maps',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: _showCircuitList,
            tooltip: 'Circuit List',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCircuitData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading circuit data...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Error: $_errorMessage",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCircuitData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _defaultCenter,
                        initialZoom: 4.0,
                        minZoom: 2.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.f1_app',
                        ),
                        MarkerLayer(markers: _markers),
                      ],
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap circuit markers for details • ${_markers.length} circuits mapped',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "circuit_list",
            onPressed: _showCircuitList,
            backgroundColor: Colors.red[700],
            child: const Icon(Icons.list, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            onPressed: () {
              _mapController.move(_defaultCenter, 4.0);
            },
            backgroundColor: Colors.blue[700],
            child: const Icon(Icons.zoom_out_map, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Implementasi DriverView methods
  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  @override
  void showCircuitList(List<Circuit> circuitList) {
    setState(() {
      _circuitList = circuitList;
      _errorMessage = null;
    });
    _createMarkers();
    
    // Auto focus jika ada circuitId yang dipilih
    if (widget.circuitId != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _focusOnCircuit(widget.circuitId!);
      });
    }
  }

  @override
  void showDriverList(List<Driver> driverList) {
    // Not used
  }

  @override
  void showTeamList(List<Team> teamList) {
    // Not used
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }
}