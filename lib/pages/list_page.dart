import 'package:flutter/material.dart';
import 'package:projek_akhir/models/circuit_model.dart';
import 'package:projek_akhir/models/team_model.dart';
import 'package:projek_akhir/models/driver_model.dart';
import 'package:projek_akhir/presenters/f1_presenter.dart';
import 'package:projek_akhir/pages/detail_page.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> implements DriverView {
  late DriverPresenter _presenter;
  bool _isLoading = false;
  List<Driver> _driverList = [];
  List<Circuit> _circuitList = [];
  List<Team> _teamList = [];
  String? _errorMessage;
  String _currentEndpoint = 'current/drivers';

  @override
  void initState() {
    super.initState();
    _presenter = DriverPresenter(this);
    _presenter.loadDriverData(_currentEndpoint);
    _presenter.loadTeamData(_currentEndpoint);
    _presenter.loadCircuitData(_currentEndpoint);
  }

  void _fetchData(String endpoint) {
    setState(() {
      _currentEndpoint = endpoint;
      if (endpoint == 'current/drivers') {
        _presenter.loadDriverData(endpoint);
      } else if (endpoint == 'current/teams') {
        _presenter.loadTeamData(endpoint);
      } else if (endpoint == 'circuits') {
        _presenter.loadCircuitData(endpoint);
      }
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showDriverList(List<Driver> driverList) {
    setState(() {
      _driverList = driverList;
      _errorMessage = null;
    });
  }

  @override
  void showCircuitList(List<Circuit> circuitList) {
    setState(() {
      _circuitList = circuitList;
      _errorMessage = null;
    });
  }

  @override
  void showTeamList(List<Team> teamList) {
    setState(() {
      _teamList = teamList;
      _errorMessage = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  String _getFlagEmoji(String nationality) {
    final flagMap = {
      'Great Britain': '🇬🇧',
      'Germany': '🇩🇪',
      'Spain': '🇪🇸',
      'France': '🇫🇷',
      'Italian': '🇮🇹',
      'Netherlands': '🇳🇱',
      'Canada': '🇨🇦',
      'American': '🇺🇸',
      'Brazil': '🇧🇷',
      'Mexican': '🇲🇽',
      'Australia': '🇦🇺',
      'Japan': '🇯🇵',
      'Thailand': '🇹🇭',
      'Argentine': '🇦🇷',
      'New Zealander': '🇳🇿',
      'Monaco': '🇲🇨',
    };
    return flagMap[nationality] ?? '🏁';
  }

  Widget _buildFilterButton(String label, String endpoint) {
    final isSelected = _currentEndpoint == endpoint;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          _fetchData(endpoint);
        },
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: const Text(
          'F1 Drivers',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _fetchData(_currentEndpoint);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildFilterButton('Drivers', 'current/drivers'),
                _buildFilterButton('Teams', 'current/teams'),
                _buildFilterButton('Circuits', 'circuits'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[700]!, Colors.red[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              'Data-data F1',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
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
                            onPressed: () {
                              _fetchData(_currentEndpoint);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount:
                          _currentEndpoint == 'current/drivers'
                              ? _driverList.length
                              : _currentEndpoint == 'circuits'
                              ? _circuitList.length
                              : _currentEndpoint == 'current/teams'
                              ? _teamList.length
                              : 0,
                      itemBuilder: (context, index) {
                        if (_currentEndpoint == 'current/drivers') {
                          final driver = _driverList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DetailPage(
                                          id: driver.driverId,
                                          endpoint: _currentEndpoint,
                                        ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.red[100],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            _getFlagEmoji(driver.nationality),
                                            style: const TextStyle(
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              driver.fullName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.flag,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  driver.nationality,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.cake,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${driver.formattedBirthday} ',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (driver.number != null) ...[
                                              const SizedBox(height: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red[700],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '#${driver.number}',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else if (_currentEndpoint == 'circuits') {
                          final circuit = _circuitList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DetailPage(
                                          id: circuit.circuitId, // Adjust ID property for circuit
                                          endpoint: _currentEndpoint,
                                        ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 40,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          circuit.circuitName, // Adjust property for circuit name
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else if (_currentEndpoint == 'current/teams') {
                          final team = _teamList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  team.teamName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        // Default return to avoid nullable return type error
                        return const SizedBox.shrink();
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
