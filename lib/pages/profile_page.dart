import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:projek_akhir/models/user_model.dart';
import 'package:projek_akhir/models/circuit_model.dart';
import 'package:projek_akhir/models/team_model.dart';
import 'package:projek_akhir/models/driver_model.dart';
import 'package:projek_akhir/services/database_helper.dart';
import 'package:projek_akhir/presenters/f1_presenter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> implements DriverView {
  User? _currentUser;
  Driver? _favoriteDriver;
  bool _isLoading = true;
  bool _isUpdatingProfile = false;
  String? _errorMessage;
  File? _selectedImage;
  late DriverPresenter _presenter;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _presenter = DriverPresenter(this);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId != null) {
        final user = await DatabaseHelper().getUserById(userId);
        if (user != null) {
          setState(() {
            _currentUser = user;
            _usernameController.text = user.username;
            _emailController.text = user.email;
          });

          // Load favorite driver if exists
          if (user.favoriteDriverId != null && user.favoriteDriverId!.isNotEmpty) {
            _presenter.loadDriverData('current/drivers');
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = 'User not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Not logged in';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void showDriverList(List<Driver> driverList) {
    if (_currentUser?.favoriteDriverId != null) {
      try {
        final favoriteDriver = driverList.firstWhere(
          (driver) => driver.driverId == _currentUser!.favoriteDriverId,
        );
        setState(() {
          _favoriteDriver = favoriteDriver;
        });
      } catch (e) {
        print('Favorite driver not found in list');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showCircuitList(List<Circuit> circuitList) {
    // Not used in profile page
  }

  @override
  void showTeamList(List<Team> teamList) {
    // Not used in profile page
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
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
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      String? imagePath;
      if (_selectedImage != null) {
        // In a real app, you'd save this to a permanent location
        // For now, we'll just use the temporary path
        imagePath = _selectedImage!.path;
      }

      final success = await DatabaseHelper().updateUserProfile(
        userId: _currentUser!.id!,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        profileImage: imagePath ?? _currentUser!.profileImage,
      );

      if (success) {
        // Reload user data
        final updatedUser = await DatabaseHelper().getUserById(_currentUser!.id!);
        if (updatedUser != null) {
          setState(() {
            _currentUser = updatedUser;
            _selectedImage = null; // Clear selected image after successful update
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdatingProfile = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_id');
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
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

  Widget _buildProfileHeader() {
    return Card(
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
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : _currentUser?.profileImage != null
                              ? Image.file(
                                  File(_currentUser!.profileImage!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentUser?.username ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentUser?.email ?? 'No email',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteDriverCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Favorite Driver',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_favoriteDriver != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Center(
                        child: Text(
                          _getFlagEmoji(_favoriteDriver!.nationality),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _favoriteDriver!.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _favoriteDriver!.nationality,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_favoriteDriver!.number != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[700],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#${_favoriteDriver!.number}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'No favorite driver selected. Go to driver details to select your favorite!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
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
    );
  }

  Widget _buildEditForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdatingProfile ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isUpdatingProfile
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Update Profile',
                        style: TextStyle(fontSize: 16),
                      ),
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
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
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
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 16),
                        _buildFavoriteDriverCard(),
                        const SizedBox(height: 16),
                        _buildEditForm(),
                      ],
                    ),
                  ),
                ),
    );
  }
}