import 'package:flutter/material.dart';
import 'package:projek_akhir/models/competition_model.dart';
import 'package:projek_akhir/services/database_helper.dart';
import 'package:projek_akhir/pages/add_competition_page.dart';
import 'package:projek_akhir/pages/edit_competition_page.dart';

class CompetitionPage extends StatefulWidget {
  final int currentUserId;
  
  const CompetitionPage({
    super.key,
    required this.currentUserId,
  });

  @override
  State<CompetitionPage> createState() => _CompetitionPageState();
}

class _CompetitionPageState extends State<CompetitionPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Competition> _competitions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompetitions();
  }

  Future<void> _loadCompetitions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final competitions = await _databaseHelper.getAllCompetitions();
      setState(() {
        _competitions = competitions;
      });
    } catch (e) {
      print('Error loading competitions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading competitions'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCompetition(Competition competition) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Competition'),
        content: Text('Are you sure you want to delete "${competition.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _databaseHelper.deleteCompetition(competition.id!);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Competition deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadCompetitions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete competition'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error deleting competition: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting competition'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCompetitionCard(Competition competition) {
    final isUserCreated = competition.createdBy == widget.currentUserId;
    final now = DateTime.now();
    final isUpcoming = competition.startTime.isAfter(now);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    competition.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isUserCreated) ...[
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCompetitionPage(
                              competition: competition,
                            ),
                          ),
                        ).then((_) => _loadCompetitions());
                      } else if (value == 'delete') {
                        _deleteCompetition(competition);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    competition.circuitName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: isUpcoming ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  competition.formattedStartTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: isUpcoming ? Colors.green[700] : Colors.grey[700],
                    fontWeight: isUpcoming ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isUpcoming ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUpcoming ? 'Upcoming' : 'Past',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (competition.description != null && competition.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                competition.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
          'Competitions',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCompetitions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _competitions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_motorsports,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No competitions yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first competition!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _competitions.length,
                  itemBuilder: (context, index) {
                    return _buildCompetitionCard(_competitions[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCompetitionPage(
                currentUserId: widget.currentUserId,
              ),
            ),
          ).then((_) => _loadCompetitions());
        },
        backgroundColor: Colors.red[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}