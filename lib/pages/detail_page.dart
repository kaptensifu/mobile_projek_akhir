import 'package:flutter/material.dart';
import 'package:projek_akhir/models/circuit_model.dart';
import 'package:projek_akhir/models/team_model.dart';
import 'package:projek_akhir/models/driver_model.dart';
import 'package:projek_akhir/presenters/f1_presenter.dart';
import 'package:projek_akhir/services/database_helper.dart';
import 'package:projek_akhir/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final String id;
  final String endpoint;
  const DetailPage({super.key, required this.id, required this.endpoint});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> implements DriverView {
  late DriverPresenter _presenter;
  bool _isLoading = true;
  Driver? _driver;
  Circuit? _circuit;
  Team? _team;
  String? _errorMessage;
  
  // New variables for favorite driver feature
  bool _isFavorite = false;
  bool _isUpdatingFavorite = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _presenter = DriverPresenter(this);
    _loadDetailData();
    _loadCurrentUser();
  }

  void _loadDetailData() {
    if (widget.endpoint == 'current/drivers') {
      _presenter.loadDriverData(widget.endpoint);
    } else if (widget.endpoint == 'circuits') {
      _presenter.loadCircuitData(widget.endpoint);
    } else if (widget.endpoint == 'current/teams') {
      _presenter.loadTeamData(widget.endpoint);
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId != null) {
        final user = await DatabaseHelper().getUserById(userId);
        setState(() {
          _currentUser = user;
          if (widget.endpoint == 'current/drivers' && user?.favoriteDriverId == widget.id) {
            _isFavorite = true;
          }
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _toggleFavoriteDriver() async {
  if (_currentUser == null || _driver == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please login to set favorite driver')),
    );
    return;
  }

  setState(() {
    _isUpdatingFavorite = true;
  });

  try {
    final newFavoriteId = _isFavorite ? null : _driver!.driverId;
    final success = await DatabaseHelper().updateFavoriteDriver(
      _currentUser!.id!,
      newFavoriteId, // Remove the ?? '' part
    );

    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
        _currentUser = _currentUser!.copyWith(
          favoriteDriverId: newFavoriteId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite 
            ? 'Added ${_driver!.fullName} to favorites' 
            : 'Removed ${_driver!.fullName} from favorites'),
          backgroundColor: _isFavorite ? Colors.green : Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorite driver'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print('Error updating favorite driver: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error updating favorite driver'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isUpdatingFavorite = false;
    });
  }
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
      _driver = driverList.firstWhere(
        (driver) => driver.driverId == widget.id,
        orElse: () => driverList.first,
      );
      _errorMessage = null;
      
      // Check if this driver is favorite after loading
      if (_currentUser?.favoriteDriverId == _driver?.driverId) {
        _isFavorite = true;
      }
    });
  }

  @override
  void showCircuitList(List<Circuit> circuitList) {
    setState(() {
      _circuit = circuitList.firstWhere(
        (circuit) => circuit.circuitId == widget.id,
        orElse: () => circuitList.first,
      );
      _errorMessage = null;
    });
  }

  @override
  void showTeamList(List<Team> teamList) {
    setState(() {
      _team = teamList.firstWhere(
        (team) => team.teamId == widget.id,
        orElse: () => teamList.first,
      );
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.red[700], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverDetail() {
    if (_driver == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [Colors.red[700]!, Colors.red[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getFlagEmoji(_driver!.nationality),
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _driver!.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_driver!.number != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#${_driver!.number}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Favorite Button
          if (_currentUser != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdatingFavorite ? null : _toggleFavoriteDriver,
                icon: _isUpdatingFavorite
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text(_isFavorite ? 'Already Favorites' : 'Add to Favorites'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFavorite ? Colors.green[700] : Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Details Section
          Text(
            'Driver Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard('Nationality', _driver!.nationality, Icons.flag),
          _buildInfoCard('Birthday', _driver!.formattedBirthday, Icons.cake),
          _buildInfoCard('Age', '${_driver!.age} years old', Icons.person),
          if (_driver!.shortName != null)
            _buildInfoCard('Short Name', _driver!.shortName!, Icons.badge),
          
          const SizedBox(height: 20),
          
          // Wikipedia Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(_driver!.url),
              icon: const Icon(Icons.open_in_new),
              label: const Text('View on Wikipedia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircuitDetail() {
    if (_circuit == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _circuit!.circuitName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_circuit!.city}, ${_circuit!.country}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Details Section
          Text(
            'Circuit Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard('Country', _circuit!.country, Icons.public),
          _buildInfoCard('City', _circuit!.city, Icons.location_city),
          _buildInfoCard('Length', '${_circuit!.circuitLength}m', Icons.straighten),
          _buildInfoCard('Lap Record', _circuit!.lapRecord, Icons.timer),
          _buildInfoCard('First Year', _circuit!.firstParticipationYear.toString(), Icons.calendar_today),
          _buildInfoCard('Corners', _circuit!.numberOfCorners.toString(), Icons.turn_right),
          _buildInfoCard('Fastest Lap Year', _circuit!.fastestLapYear.toString(), Icons.speed),
          
          const SizedBox(height: 20),
          
          // Wikipedia Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(_circuit!.url),
              icon: const Icon(Icons.open_in_new),
              label: const Text('View on Wikipedia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamDetail() {
    if (_team == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [Colors.green[700]!, Colors.green[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.groups,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _team!.teamName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getFlagEmoji(_team!.teamNationality),
                    style: const TextStyle(fontSize: 32),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Details Section
          Text(
            'Team Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard('Nationality', _team!.teamNationality, Icons.flag),
          if (_team!.firstAppearance != null)
            _buildInfoCard('First Appearance', _team!.firstAppearance.toString(), Icons.calendar_today),
          if (_team!.constructorsChampionships != null)
            _buildInfoCard('Constructors Championships', _team!.constructorsChampionships.toString(), Icons.emoji_events),
          if (_team!.driversChampionships != null)
            _buildInfoCard('Drivers Championships', _team!.driversChampionships.toString(), Icons.military_tech),
          
          const SizedBox(height: 20),
          
          // Wikipedia Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(_team!.url),
              icon: const Icon(Icons.open_in_new),
              label: const Text('View on Wikipedia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (widget.endpoint) {
      case 'current/drivers':
        return 'Driver Details';
      case 'circuits':
        return 'Circuit Details';
      case 'current/teams':
        return 'Team Details';
      default:
        return 'Details';
    }
  }

  Color _getAppBarColor() {
    switch (widget.endpoint) {
      case 'current/drivers':
        return Colors.red[700]!;
      case 'circuits':
        return Colors.blue[700]!;
      case 'current/teams':
        return Colors.green[700]!;
      default:
        return Colors.red[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _getAppBarColor(),
        title: Text(
          _getTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadDetailData();
            },
          ),
        ],
      ),
      body: _isLoading
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
                          _loadDetailData();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : widget.endpoint == 'current/drivers'
                  ? _buildDriverDetail()
                  : widget.endpoint == 'circuits'
                      ? _buildCircuitDetail()
                      : widget.endpoint == 'current/teams'
                          ? _buildTeamDetail()
                          : const Center(
                              child: Text('Unknown endpoint'),
                            ),
    );
  }
}