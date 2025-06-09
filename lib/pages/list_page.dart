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
  
  // Filtered lists for search functionality
  List<Driver> _filteredDriverList = [];
  List<Circuit> _filteredCircuitList = [];
  List<Team> _filteredTeamList = [];
  
  String? _errorMessage;
  String _currentEndpoint = 'current/drivers';
  
  // Search controller and state
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _presenter = DriverPresenter(this);
    _presenter.loadDriverData(_currentEndpoint);
    _presenter.loadTeamData(_currentEndpoint);
    _presenter.loadCircuitData(_currentEndpoint);
    
    // Listen to search input changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (_currentEndpoint == 'current/drivers') {
        _filteredDriverList = _driverList.where((driver) {
          return driver.fullName.toLowerCase().contains(query);
        }).toList();
      } else if (_currentEndpoint == 'circuits') {
        _filteredCircuitList = _circuitList.where((circuit) {
          return circuit.circuitName.toLowerCase().contains(query);
        }).toList();
      } else if (_currentEndpoint == 'current/teams') {
        _filteredTeamList = _teamList.where((team) {
          return team.teamName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _fetchData(String endpoint) {
    setState(() {
      _currentEndpoint = endpoint;
      _searchController.clear(); // Clear search when switching endpoints
      if (endpoint == 'current/drivers') {
        _presenter.loadDriverData(endpoint);
      } else if (endpoint == 'current/teams') {
        _presenter.loadTeamData(endpoint);
      } else if (endpoint == 'circuits') {
        _presenter.loadCircuitData(endpoint);
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
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
      _filteredDriverList = driverList; // Initialize filtered list
      _errorMessage = null;
    });
  }

  @override
  void showCircuitList(List<Circuit> circuitList) {
    setState(() {
      _circuitList = circuitList;
      _filteredCircuitList = circuitList; // Initialize filtered list
      _errorMessage = null;
    });
  }

  @override
  void showTeamList(List<Team> teamList) {
    setState(() {
      _teamList = teamList;
      _filteredTeamList = teamList; // Initialize filtered list
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: _getSearchHint(),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  String _getSearchHint() {
    switch (_currentEndpoint) {
      case 'current/drivers':
        return 'Search drivers by name...';
      case 'circuits':
        return 'Search circuits by name...';
      case 'current/teams':
        return 'Search teams by name...';
      default:
        return 'Search...';
    }
  }

  int _getFilteredItemCount() {
    switch (_currentEndpoint) {
      case 'current/drivers':
        return _filteredDriverList.length;
      case 'circuits':
        return _filteredCircuitList.length;
      case 'current/teams':
        return _filteredTeamList.length;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: const Text(
          'Formula 1',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search,
                color: Colors.white),
            onPressed: _toggleSearch,
          ),
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
          // Search bar - only show when _isSearchVisible is true
          if (_isSearchVisible) _buildSearchBar(),
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
              'Data-data F1${_searchController.text.isNotEmpty ? " (${_getFilteredItemCount()} hasil)" : ""}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _isLoading
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
                    : _getFilteredItemCount() == 0 && _searchController.text.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found for "${_searchController.text}"',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search terms',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _getFilteredItemCount(),
                            itemBuilder: (context, index) {
                              if (_currentEndpoint == 'current/drivers') {
                                final driver = _filteredDriverList[index];
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
                                          builder: (context) => DetailPage(
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
                                final circuit = _filteredCircuitList[index];
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
                                          builder: (context) => DetailPage(
                                            id: circuit.circuitId,
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
                                                circuit.circuitName,
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
                                final team = _filteredTeamList[index];
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
                                          builder: (context) => DetailPage(
                                            id: team.teamId,
                                            endpoint: _currentEndpoint,
                                          ),
                                        ),
                                      );
                                    },
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
                                              Icons.group,
                                              size: 40,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                team.teamName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                              }
                              return const SizedBox.shrink();
                            },
                          ),
          ),
        ],
      ),
    );
  }
}