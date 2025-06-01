import 'package:flutter/material.dart';
import 'package:projek_akhir/models/circuit_model.dart';
import 'package:projek_akhir/models/driver_model.dart';
import 'package:projek_akhir/models/team_model.dart';
import 'package:projek_akhir/services/database_helper.dart';
import 'package:projek_akhir/presenters/f1_presenter.dart';

class AddCompetitionPage extends StatefulWidget {
  final int currentUserId;
  
  const AddCompetitionPage({
    super.key,
    required this.currentUserId,
  });

  @override
  State<AddCompetitionPage> createState() => _AddCompetitionPageState();
}

class _AddCompetitionPageState extends State<AddCompetitionPage> implements DriverView {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late DriverPresenter _presenter;
  List<Circuit> _circuits = [];
  Circuit? _selectedCircuit;
  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 1));
  bool _isLoadingCircuits = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _presenter = DriverPresenter(this);
    _presenter.loadCircuitData('circuits');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // DriverView implementation
  @override
  void hideLoading() {
    setState(() {
      _isLoadingCircuits = false;
    });
  }

  @override
  void showCircuitList(List<Circuit> circuitList) {
    setState(() {
      _circuits = circuitList;
    });
  }

  @override
  void showDriverList(List<Driver> driverList) {
    // Not used in this page
  }

  @override
  void showTeamList(List<Team> teamList) {
    // Not used in this page
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error loading circuits: $message'),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      _isLoadingCircuits = false;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _isLoadingCircuits = true;
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveCompetition() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCircuit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a circuit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final competition = await _databaseHelper.createCompetition(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        circuitId: _selectedCircuit!.circuitId,
        circuitName: _selectedCircuit!.circuitName,
        startTime: _selectedDateTime,
        createdBy: widget.currentUserId,
      );

      if (competition != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Competition created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create competition'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error creating competition: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error creating competition'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: const Text(
          'Add Competition',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingCircuits
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Competition Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.trim().length < 3) {
                          return 'Title must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Circuit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Circuit>(
                          value: _selectedCircuit,
                          hint: const Text('Choose a circuit'),
                          isExpanded: true,
                          items: _circuits.map((circuit) {
                            return DropdownMenuItem<Circuit>(
                              value: circuit,
                              child: Text(
                                '${circuit.circuitName} - ${circuit.city}, ${circuit.country}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (Circuit? circuit) {
                            setState(() {
                              _selectedCircuit = circuit;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Competition Date & Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateTime,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Text(
                              _formatDateTime(_selectedDateTime),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveCompetition,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Create Competition',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}