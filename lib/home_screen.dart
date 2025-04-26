import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<MedicationItem> _medications = [];
  late HealthStats _heartRate;
  late HealthStats _bloodPressure;
  int _selectedHealthStat = 0; // 0 for heart rate, 1 for blood pressure
  int _selectedTabIndex = 0;
  final List<AppointmentItem> _appointments = [];
  final List<ReminderItem> _reminders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _initializeMockData();
  }

  void _initializeMockData() {
    // Demo medications
    _medications.add(
      MedicationItem(
        id: "1",
        name: "Lisinopril",
        dosage: "10mg",
        time: const TimeOfDay(hour: 8, minute: 0),
        taken: true,
        color: Colors.pink.shade400,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        frequency: "Daily",
        instructions: "Take with food",
      ),
    );
    _medications.add(
      MedicationItem(
        id: "2",
        name: "Metformin",
        dosage: "500mg",
        time: const TimeOfDay(hour: 13, minute: 0),
        taken: false,
        color: Colors.purple.shade400,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 45)),
        frequency: "Daily",
        instructions: "Take after lunch",
      ),
    );
    _medications.add(
      MedicationItem(
        id: "3",
        name: "Simvastatin",
        dosage: "20mg",
        time: const TimeOfDay(hour: 20, minute: 0),
        taken: false,
        color: Colors.blue.shade400,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().add(const Duration(days: 305)),
        frequency: "Daily",
        instructions: "Take in the evening",
      ),
    );

    // Sort medications by time
    _medications.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });

    // Demo health stats
    _heartRate = HealthStats(
      currentValue: 72,
      minValue: 65,
      maxValue: 85,
      unit: "BPM",
      icon: Icons.favorite,
      color: Colors.red.shade400,
      status: HealthStatus.normal,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    );

    _bloodPressure = HealthStats(
      currentValue: 128,
      secondaryValue: 82,
      minValue: 110,
      maxValue: 140,
      unit: "mmHg",
      icon: Icons.monitor_heart_outlined,
      color: Colors.green.shade400,
      status: HealthStatus.normal,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
    );

    // Demo appointments
    _appointments.add(
      AppointmentItem(
        id: "1",
        doctorName: "Dr. Sarah Chen",
        specialty: "Oncologist",
        date: DateTime.now().add(const Duration(days: 3)),
        time: const TimeOfDay(hour: 10, minute: 30),
        isVirtual: false,
        notes: "Annual cancer checkup",
        reason: "Stage 1 Cancer Consultation",
      ),
    );

    _appointments.add(
      AppointmentItem(
        id: "2",
        doctorName: "Dr. Michael Rodriguez",
        specialty: "Primary Care",
        date: DateTime.now().add(const Duration(days: 7)),
        time: const TimeOfDay(hour: 14, minute: 0),
        isVirtual: true,
        notes: "Follow-up on medication adjustment",
        reason: "Medication Review",
      ),
    );

    // Demo reminders
    _reminders.add(
      ReminderItem(
        id: "1",
        title: "Take Lisinopril",
        date: DateTime.now(),
        time: const TimeOfDay(hour: 8, minute: 0),
        type: ReminderType.medication,
        notes: "Remember to take with food",
      ),
    );

    _reminders.add(
      ReminderItem(
        id: "2",
        title: "Oncologist Appointment",
        date: DateTime.now().add(const Duration(days: 3)),
        time: const TimeOfDay(hour: 10, minute: 30),
        type: ReminderType.appointment,
        notes: "Bring latest test results",
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Emergency Assistance'),
          content: const Text('Do you need immediate medical help?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.phone),
                    label: const Text(
                      'Call Emergency Services (911)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5446D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // Actually call 911 using phone dialer
                      _callEmergencyNumber();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        );
      },
    );
  }

  Future<void> _callEmergencyNumber() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '911');
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      // Show an error if unable to launch the dialer
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to make call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning";
    } else if (hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  String _getDisplayName() {
    final displayName = widget.user.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      // If there's a full name, try to get just the first name
      final nameParts = displayName.split(' ');
      if (nameParts.isNotEmpty) {
        return nameParts[0];
      }
      return displayName;
    }
    // Fallback to email if no name
    return widget.user.email?.split('@')[0] ?? 'User';
  }

  void _toggleMedicationStatus(int index) {
    final medication = _medications[index];

    if (medication.taken) {
      // If medicine was already taken, confirm before undoing
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Undo Medication?'),
            content: Text('Are you sure you want to mark ${medication.name} as not taken? This will update your medication tracking.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3FD3),
                ),
                onPressed: () {
                  setState(() {
                    _medications[index].taken = false;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${medication.name} marked as not taken'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } else {
      // If medicine wasn't taken, mark it as taken
      setState(() {
        _medications[index].taken = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medication.name} marked as taken'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _updateHealthStatus(HealthStats healthStats) {
    if (healthStats == _heartRate) {
      if (_heartRate.currentValue < 60 || _heartRate.currentValue > 100) {
        _heartRate.status = HealthStatus.warning;
      } else {
        _heartRate.status = HealthStatus.normal;
      }
    } else {
      if (_bloodPressure.currentValue > 140 || (_bloodPressure.secondaryValue != null && _bloodPressure.secondaryValue! > 90)) {
        _bloodPressure.status = HealthStatus.warning;
      } else if (_bloodPressure.currentValue < 90 || (_bloodPressure.secondaryValue != null && _bloodPressure.secondaryValue! < 60)) {
        _bloodPressure.status = HealthStatus.warning;
      } else {
        _bloodPressure.status = HealthStatus.normal;
      }
    }
  }

  void _editHealthData(HealthStats healthStats) {
    TextEditingController valueController = TextEditingController(
        text: healthStats.currentValue.toStringAsFixed(0));
    TextEditingController secondaryController = healthStats.secondaryValue != null
        ? TextEditingController(text: healthStats.secondaryValue!.toStringAsFixed(0))
        : TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update ${healthStats == _heartRate ? 'Heart Rate' : 'Blood Pressure'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option to connect to device
              ListTile(
                leading: const Icon(Icons.watch),
                title: const Text('Connect to Smart Device'),
                subtitle: const Text('Automatically sync with your wearable device'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showSmartDeviceConnection(healthStats);
                },
              ),
              const Divider(),
              const Text('Or enter values manually:'),
              const SizedBox(height: 8),

              // Manual entry fields
              if (healthStats == _heartRate) ...[
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Heart Rate (BPM)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: valueController,
                        decoration: const InputDecoration(
                          labelText: 'Systolic',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: secondaryController,
                        decoration: const InputDecoration(
                          labelText: 'Diastolic',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D3FD3),
              ),
              onPressed: () {
                setState(() {
                  if (healthStats == _heartRate) {
                    _heartRate.currentValue = double.tryParse(valueController.text) ?? _heartRate.currentValue;
                    _heartRate.lastUpdated = DateTime.now();
                    _updateHealthStatus(_heartRate);
                  } else {
                    _bloodPressure.currentValue = double.tryParse(valueController.text) ?? _bloodPressure.currentValue;
                    _bloodPressure.secondaryValue = double.tryParse(secondaryController.text) ?? _bloodPressure.secondaryValue;
                    _bloodPressure.lastUpdated = DateTime.now();
                    _updateHealthStatus(_bloodPressure);
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSmartDeviceConnection(HealthStats healthStats) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connect to Smart Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Searching for nearby devices...'),
              const SizedBox(height: 24),
              const Text('Please make sure your device is:'),
              const SizedBox(height: 8),
              const Text('• Turned on and within range'),
              const Text('• Bluetooth is enabled on your phone'),
              const Text('• The device is properly worn'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Simulate finding a device after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showDeviceFound(healthStats);
    });
  }

  void _showDeviceFound(HealthStats healthStats) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Device Found!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text('Successfully connected to:'),
              const SizedBox(height: 8),
              const Text('Smart Health Watch',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Data synced successfully!'),
            ],
          ),
          actions: [
            ElevatedButton(
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D3FD3),
              ),
              onPressed: () {
                // Update with "new" data from the device
                setState(() {
                  if (healthStats == _heartRate) {
                    _heartRate.currentValue = (73 + math.Random().nextInt(5)) as double;
                    _heartRate.lastUpdated = DateTime.now();
                    _updateHealthStatus(_heartRate);
                  } else {
                    _bloodPressure.currentValue = 125 + math.Random().nextInt(10) as double;
                    _bloodPressure.secondaryValue = 80 + math.Random().nextInt(5)as double;
                    _bloodPressure.lastUpdated = DateTime.now();
                    _updateHealthStatus(_bloodPressure);
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showHealthStatusInfo(HealthStats healthStats, bool isPositive) {
    final String title = isPositive ? 'Normal Range' : 'Attention Needed';
    final String content = isPositive
        ? healthStats == _heartRate
        ? 'Your heart rate is within the normal range of 60-100 BPM for adults at rest.'
        : 'Your blood pressure is within the normal range (below 120/80 mmHg).'
        : healthStats == _heartRate
        ? 'Your heart rate is outside the normal range of 60-100 BPM for adults at rest. Consider consulting your doctor if this persists.'
        : 'Your blood pressure reading suggests ${_bloodPressure.currentValue > 120 ? 'elevated blood pressure' : 'low blood pressure'}. Consider monitoring more frequently and consulting your doctor.';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D3FD3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final instructionsController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    String frequency = 'Daily';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Medication'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosage (e.g., 10mg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Time: '),
                        TextButton(
                          onPressed: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                          child: Text(
                            selectedTime.format(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Frequency: '),
                        DropdownButton<String>(
                          value: frequency,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                frequency = newValue;
                              });
                            }
                          },
                          items: <String>[
                            'Daily',
                            'Twice Daily',
                            'As Needed',
                            'Weekly'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Start Date: '),
                        TextButton(
                          onPressed: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                startDate = date;
                              });
                            }
                          },
                          child: Text(
                            DateFormat('MMM d, yyyy').format(startDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('End Date: '),
                        TextButton(
                          onPressed: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            );
                            if (date != null) {
                              setState(() {
                                endDate = date;
                              });
                            }
                          },
                          child: Text(
                            DateFormat('MMM d, yyyy').format(endDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Instructions',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D3FD3),
                  ),
                  onPressed: () {
                    if (nameController.text.isEmpty || dosageController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill out all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newMed = MedicationItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      dosage: dosageController.text,
                      time: selectedTime,
                      taken: false,
                      color: Colors.primaries[math.Random().nextInt(Colors.primaries.length)],
                      startDate: startDate,
                      endDate: endDate,
                      frequency: frequency,
                      instructions: instructionsController.text,
                    );

                    setState(() {
                      _medications.add(newMed);
                      // Sort medications by time
                      _medications.sort((a, b) {
                        final aMinutes = a.time.hour * 60 + a.time.minute;
                        final bMinutes = b.time.hour * 60 + b.time.minute;
                        return aMinutes.compareTo(bMinutes);
                      });
                    });

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteMedication(MedicationItem medication) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Medication'),
          content: Text('Are you sure you want to delete ${medication.name}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  _medications.removeWhere((med) => med.id == medication.id);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${medication.name} deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _editMedication(MedicationItem medication) {
    final nameController = TextEditingController(text: medication.name);
    final dosageController = TextEditingController(text: medication.dosage);
    final instructionsController = TextEditingController(text: medication.instructions);
    TimeOfDay selectedTime = medication.time;
    DateTime startDate = medication.startDate;
    DateTime endDate = medication.endDate;
    String frequency = medication.frequency;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Medication'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosage (e.g., 10mg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Time: '),
                        TextButton(
                          onPressed: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                          child: Text(
                            selectedTime.format(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Frequency: '),
                        DropdownButton<String>(
                          value: frequency,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                frequency = newValue;
                              });
                            }
                          },
                          items: <String>[
                            'Daily',
                            'Twice Daily',
                            'As Needed',
                            'Weekly'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Start Date: '),
                        TextButton(
                          onPressed: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                startDate = date;
                              });
                            }
                          },
                          child: Text(
                            DateFormat('MMM d, yyyy').format(startDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('End Date: '),
                        TextButton(
                          onPressed: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            );
                            if (date != null) {
                              setState(() {
                                endDate = date;
                              });
                            }
                          },
                          child: Text(
                            DateFormat('MMM d, yyyy').format(endDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Instructions',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    _deleteMedication(medication);
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D3FD3),
                  ),
                  onPressed: () {
                    if (nameController.text.isEmpty || dosageController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill out all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      final index = _medications.indexWhere((med) => med.id == medication.id);
                      if (index != -1) {
                        _medications[index] = MedicationItem(
                          id: medication.id,
                          name: nameController.text,
                          dosage: dosageController.text,
                          time: selectedTime,
                          taken: medication.taken,
                          color: medication.color,
                          startDate: startDate,
                          endDate: endDate,
                          frequency: frequency,
                          instructions: instructionsController.text,
                        );

                        // Sort medications by time
                        _medications.sort((a, b) {
                          final aMinutes = a.time.hour * 60 + a.time.minute;
                          final bMinutes = b.time.hour * 60 + b.time.minute;
                          return aMinutes.compareTo(bMinutes);
                        });
                      }
                    });

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBookConsultationScreen() {
    // Variables to track user selections
    String consultationType = "Video Call"; // Default: Video Call
    String selectedSpecialist = "";
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 11, minute: 0);
    String reason = "";
    final reasonController = TextEditingController();

    // Specialists list
    final specialists = [
      {"name": "Dr. Sarah Chen", "specialty": "Oncologist"},
      {"name": "Dr. Michael Rodriguez", "specialty": "Primary Care"},
      {"name": "Dr. Emily Johnson", "specialty": "Cardiologist"},
      {"name": "Dr. David Lee", "specialty": "Neurologist"},
    ];

    // Available time slots
    final timeSlots = [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 13, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
    ];

    // Show the booking screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFF5D3FD3),
                title: const Text(
                  'Book Consultation',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Text(
                        selectedSpecialist.isEmpty
                            ? "Cancer Treatment Consultation"
                            : "$selectedSpecialist Consultation",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Consultation Type
                      const Text(
                        "Consultation Type",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D3FD3),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Consultation Type Selection
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  consultationType = "Video Call";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: consultationType == "Video Call"
                                      ? const Color(0xFF4DA1FF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: consultationType == "Video Call"
                                        ? const Color(0xFF4DA1FF)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.videocam,
                                      color: consultationType == "Video Call"
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Video Call",
                                      style: TextStyle(
                                        color: consultationType == "Video Call"
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  consultationType = "In-Person";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: consultationType == "In-Person"
                                        ? const Color(0xFF5D3FD3)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: consultationType == "In-Person"
                                          ? const Color(0xFF5D3FD3)
                                          : Colors.grey.shade600,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "In-Person",
                                      style: TextStyle(
                                        color: consultationType == "In-Person"
                                            ? const Color(0xFF5D3FD3)
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Specialist Selection
                      const Text(
                        "Select Specialist",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D3FD3),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Specialists List
                      ...specialists.map((specialist) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedSpecialist == specialist["name"]
                                  ? const Color(0xFF5D3FD3)
                                  : Colors.grey.shade300,
                              width: selectedSpecialist == specialist["name"] ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            title: Text(
                              specialist["name"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(specialist["specialty"]!),
                            onTap: () {
                              setState(() {
                                selectedSpecialist = specialist["name"]!;
                              });
                            },
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 24),

                      // Date and Time Selection
                      Row(
                        children: [
                          for (int i = 2; i <= 6; i++)
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    "$i",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Time Selection
                      const Text(
                        "Select Time",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D3FD3),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time Slots
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: timeSlots.map((time) {
                          final isSelected = selectedTime.hour == time.hour && selectedTime.minute == time.minute;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTime = time;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF5D3FD3) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF5D3FD3) : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                _formatTimeOfDay(time),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Reason
                      const Text(
                        "Reason for Visit",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D3FD3),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reason Input
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: reasonController,
                              decoration: const InputDecoration(
                                hintText: "Stage 1 Cancer Consultation",
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                reason = value;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              icon: Icon(
                                Icons.add,
                                color: const Color(0xFF5D3FD3).withOpacity(0.8),
                                size: 16,
                              ),
                              label: Text(
                                "Add more details",
                                style: TextStyle(
                                  color: const Color(0xFF5D3FD3).withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                // Show a dialog for additional details
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Book Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedSpecialist.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a specialist'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Create a new appointment
                            String specialtyValue = "";
                            for (var specialist in specialists) {
                              if (specialist["name"] == selectedSpecialist) {
                                specialtyValue = specialist["specialty"] ?? "";
                                break;
                              }
                            }

                            final newAppointment = AppointmentItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              doctorName: selectedSpecialist,
                              specialty: specialtyValue,
                              date: selectedDate,
                              time: selectedTime,
                              isVirtual: consultationType == "Video Call",
                              notes: "",
                              reason: reasonController.text.isNotEmpty
                                  ? reasonController.text
                                  : "Consultation",
                            );

                            setState(() {
                              _appointments.add(newAppointment);
                            });

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Appointment booked successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D3FD3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Book Appointment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Help text
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Show help dialog
                          },
                          child: const Text(
                            "Need help? Call support",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final period = time.hour >= 12 ? "PM" : "AM";
    return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
  }

  void _viewAppointmentDetails(AppointmentItem appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment with ${appointment.doctorName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Specialty: ${appointment.specialty}'),
              const SizedBox(height: 8),
              Text('Date: ${DateFormat('EEEE, MMM d, yyyy').format(appointment.date)}'),
              const SizedBox(height: 4),
              Text('Time: ${appointment.time.format(context)}'),
              const SizedBox(height: 8),
              Text('Type: ${appointment.isVirtual ? 'Virtual' : 'In-Person'}'),
              const SizedBox(height: 8),
              Text('Reason: ${appointment.reason}'),
              if (appointment.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Notes:'),
                const SizedBox(height: 4),
                Text(appointment.notes),
              ],
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reschedule'),
              onPressed: () {
                Navigator.of(context).pop();
                _editAppointment(appointment);
              },
            ),
          ],
        );
      },
    );
  }

  void _editAppointment(AppointmentItem appointment) {
    final doctorNameController = TextEditingController(text: appointment.doctorName);
    final specialtyController = TextEditingController(text: appointment.specialty);
    final notesController = TextEditingController(text: appointment.notes);
    final reasonController = TextEditingController(text: appointment.reason);
    DateTime selectedDate = appointment.date;
    TimeOfDay selectedTime = appointment.time;
    bool isVirtual = appointment.isVirtual;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Appointment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: doctorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Doctor Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: specialtyController,
                      decoration: const InputDecoration(
                        labelText: 'Specialty',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Visit',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Date: '),
                        TextButton(
                          onPressed: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          child: Text(
                            DateFormat('MMM d, yyyy').format(selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Time: '),
                        TextButton(
                          onPressed: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                          child: Text(
                            selectedTime.format(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Appointment Type: '),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('In-Person'),
                          selected: !isVirtual,
                          onSelected: (selected) {
                            setState(() {
                              isVirtual = !selected;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Virtual'),
                          selected: isVirtual,
                          onSelected: (selected) {
                            setState(() {
                              isVirtual = selected;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _appointments.removeWhere((apt) => apt.id == appointment.id);
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment cancelled'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D3FD3),
                  ),
                  onPressed: () {
                    if (doctorNameController.text.isEmpty || specialtyController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill out all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      final index = _appointments.indexWhere((apt) => apt.id == appointment.id);
                      if (index != -1) {
                        _appointments[index] = AppointmentItem(
                          id: appointment.id,
                          doctorName: doctorNameController.text,
                          specialty: specialtyController.text,
                          date: selectedDate,
                          time: selectedTime,
                          isVirtual: isVirtual,
                          notes: notesController.text,
                          reason: reasonController.text,
                        );

                        // Sort appointments by date and time
                        _appointments.sort((a, b) {
                          int dateComparison = a.date.compareTo(b.date);
                          if (dateComparison != 0) return dateComparison;

                          final aMinutes = a.time.hour * 60 + a.time.minute;
                          final bMinutes = b.time.hour * 60 + b.time.minute;
                          return aMinutes.compareTo(bMinutes);
                        });
                      }
                    });

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment updated'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPersonalInfoDialog() {
    final nameController = TextEditingController(text: widget.user.displayName);
    final emailController = TextEditingController(text: widget.user.email);
    final ageController = TextEditingController(text: "68");
    final phoneController = TextEditingController(text: "(555) 123-4567");
    final emergencyContactController = TextEditingController(text: "John Smith (555) 987-6543");

    showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
          title: const Text('Personal Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emergencyContactController,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
      TextButton(
      child: const Text('Cancel'),
    onPressed: () {
    Navigator.of(context).pop();
    },
    ),
    ElevatedButton(
    child: const Text(
    'Save',
    style: TextStyle(
    color: Colors.white,fontWeight: FontWeight.bold,
    ),
    ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5D3FD3),
      ),
      onPressed: () {
        // In a real app, save profile info to backend/database
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal information updated'),
            backgroundColor: Colors.green,
          ),
        );
      },
    ),
          ],
      );
        },
    );
  }

  void _showNotificationSettings() {
    bool allowMedicationReminders = true;
    bool allowAppointmentReminders = true;
    bool allowHealthAlerts = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Notification Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Medication Reminders'),
                    subtitle: const Text('Get alerts when it\'s time to take your medications'),
                    value: allowMedicationReminders,
                    onChanged: (value) {
                      setState(() {
                        allowMedicationReminders = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Appointment Reminders'),
                    subtitle: const Text('Get alerts for upcoming appointments'),
                    value: allowAppointmentReminders,
                    onChanged: (value) {
                      setState(() {
                        allowAppointmentReminders = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Health Alerts'),
                    subtitle: const Text('Get alerts for abnormal health readings'),
                    value: allowHealthAlerts,
                    onChanged: (value) {
                      setState(() {
                        allowHealthAlerts = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D3FD3),
                  ),
                  onPressed: () {
                    // In a real app, save notification settings
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification settings updated'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About GuardianCare'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GuardianCare is your complete health companion app designed specifically to meet the needs of seniors. Our mission is to make health management simpler, more accessible, and more effective.',
                ),
                SizedBox(height: 16),
                Text(
                  'Key Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Medication tracking with reminders'),
                Text('• Health vitals monitoring'),
                Text('• Doctor appointment scheduling'),
                Text('• Emergency assistance'),
                Text('• Secure health data storage'),
                SizedBox(height: 16),
                Text(
                  'Version: 1.0.0',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(
                  '© 2025 GuardianCare',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D3FD3),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSetReminderDialog() {
    TimeOfDay selectedTime = TimeOfDay.now();
    DateTime selectedDate = DateTime.now();
    final noteController = TextEditingController();
    ReminderType reminderType = ReminderType.medication;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set Reminder',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Date:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          child: Text(
                            DateFormat('MMM d, yyyy').format(selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D3FD3),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Time row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Time:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                          child: Text(
                            selectedTime.format(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D3FD3),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      "Reminder Type:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Reminder type selector
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                reminderType = ReminderType.medication;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: reminderType == ReminderType.medication
                                    ? const Color(0xFF5D3FD3).withOpacity(0.2)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: reminderType == ReminderType.medication
                                      ? const Color(0xFF5D3FD3)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (reminderType == ReminderType.medication)
                                      const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Color(0xFF5D3FD3),
                                      ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Medication",
                                      style: TextStyle(
                                        color: reminderType == ReminderType.medication
                                            ? const Color(0xFF5D3FD3)
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                reminderType = ReminderType.appointment;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: reminderType == ReminderType.appointment
                                    ? const Color(0xFF5D3FD3).withOpacity(0.2)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: reminderType == ReminderType.appointment
                                      ? const Color(0xFF5D3FD3)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Appointment",
                                  style: TextStyle(
                                    color: reminderType == ReminderType.appointment
                                        ? const Color(0xFF5D3FD3)
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                reminderType = ReminderType.custom;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: reminderType == ReminderType.custom
                                    ? const Color(0xFF5D3FD3).withOpacity(0.2)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: reminderType == ReminderType.custom
                                      ? const Color(0xFF5D3FD3)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Custom",
                                  style: TextStyle(
                                    color: reminderType == ReminderType.custom
                                        ? const Color(0xFF5D3FD3)
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Note field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          hintText: "Note",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                        maxLines: 3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Add the reminder
                            final newReminder = ReminderItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: reminderType == ReminderType.medication
                                  ? "Take medication"
                                  : reminderType == ReminderType.appointment
                                  ? "Appointment reminder"
                                  : "Custom reminder",
                              date: selectedDate,
                              time: selectedTime,
                              type: reminderType,
                              notes: noteController.text,
                            );

                            setState(() {
                              _reminders.add(newReminder);
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder set successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D3FD3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            "Set Reminder",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCalendarView() {
    // Create a map of events for the calendar
    final Map<DateTime, List<dynamic>> events = {};

    // Add medications to events
    for (final med in _medications) {
      final DateTime today = DateTime.now();
      final DateTime endDateCheck = med.endDate.isAfter(today.add(const Duration(days: 31)))
          ? today.add(const Duration(days: 31))
          : med.endDate;

      // Only show medications that are active
      if (med.startDate.isBefore(endDateCheck)) {
        DateTime currentDate = med.startDate.isAfter(today) ? med.startDate : today;

        while (currentDate.isBefore(endDateCheck)) {
          final eventDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
          if (events[eventDate] == null) {
            events[eventDate] = [];
          }
          events[eventDate]!.add({
            'type': 'medication',
            'name': med.name,
            'time': med.time,
            'icon': Icons.medication
          });

          // Increment based on frequency
          if (med.frequency == 'Daily') {
            currentDate = currentDate.add(const Duration(days: 1));
          } else if (med.frequency == 'Weekly') {
            currentDate = currentDate.add(const Duration(days: 7));
          } else {
            // For other frequencies, just advance one day for demonstration
            currentDate = currentDate.add(const Duration(days: 1));
          }
        }
      }
    }

    // Add appointments to events
    for (final apt in _appointments) {
      final eventDate = DateTime(apt.date.year, apt.date.month, apt.date.day);
      if (events[eventDate] == null) {
        events[eventDate] = [];
      }
      events[eventDate]!.add({
        'type': 'appointment',
        'name': apt.doctorName,
        'time': apt.time,
        'icon': apt.isVirtual ? Icons.videocam : Icons.meeting_room
      });
    }

    // Calendar State
    DateTime focusedDay = DateTime.now();
    DateTime? selectedDay = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Text(
                            "Calendar",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showAddCalendarItemDialog();
                          },
                        ),
                      ],
                    ),
                    TableCalendar(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2026, 12, 31),
                      focusedDay: focusedDay,
                      calendarFormat: CalendarFormat.month,
                      eventLoader: (day) {
                        final eventDate = DateTime(day.year, day.month, day.day);
                        return events[eventDate] ?? [];
                      },
                      selectedDayPredicate: (day) {
                        return isSameDay(selectedDay, day);
                      },
                      onDaySelected: (selected, focused) {
                        setState(() {
                          selectedDay = selected;
                          focusedDay = focused;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        markerDecoration: const BoxDecoration(
                          color: Color(0xFF5D3FD3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF5D3FD3),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF5D3FD3).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: _buildEventsForSelectedDay(selectedDay!, events),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D3FD3),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventsForSelectedDay(DateTime day, Map<DateTime, List<dynamic>> events) {
    final eventDate = DateTime(day.year, day.month, day.day);
    final dayEvents = events[eventDate] ?? [];

    if (dayEvents.isEmpty) {
      return const Center(
        child: Text(
          'No events for this day',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        final time = event['time'] as TimeOfDay;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: event['type'] == 'medication'
                ? Colors.blue.shade100
                : Colors.green.shade100,
            child: Icon(
              event['icon'] as IconData,
              color: event['type'] == 'medication'
                  ? Colors.blue.shade700
                  : Colors.green.shade700,
              size: 20,
            ),
          ),
          title: Text(event['name']),
          subtitle: Text(
            '${_formatTimeOfDay(time)} - ${event['type'] == 'medication' ? 'Medication' : 'Appointment'}',
          ),
          trailing: event['type'] == 'medication'
              ? const Icon(Icons.check_circle_outline)
              : const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Handle event tap
            if (event['type'] == 'appointment') {
              AppointmentItem? apt;
              for (var a in _appointments) {
                if (a.doctorName == event['name'] &&
                    a.time.hour == time.hour &&
                    a.time.minute == time.minute &&
                    isSameDay(a.date, day)) {
                  apt = a;
                  break;
                }
              }
              if (apt != null) {
                Navigator.of(context).pop();
                _viewAppointmentDetails(apt);
              }
            } else {
              MedicationItem? med;
              for (var m in _medications) {
                if (m.name == event['name'] &&
                    m.time.hour == time.hour &&
                    m.time.minute == time.minute) {
                  med = m;
                  break;
                }
              }
              if (med != null) {
                Navigator.of(context).pop();
                _editMedication(med);
              }
            }
          },
        );
      },
    );
  }

  void _showAddCalendarItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to Calendar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.medication),
                title: const Text('Add Medication'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddMedicationDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Book Appointment'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showBookConsultationScreen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Set Reminder'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showSetReminderDialog();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } else if (difference.inHours > 0) {
      return "${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago";
    } else {
      return "Just now";
    }
  }

  Widget _buildHealthChart() {
    if (_selectedHealthStat == 0) {
      // Heart rate chart
      final List<FlSpot> spots = [
        const FlSpot(0, 68),
        const FlSpot(1, 72),
        const FlSpot(2, 70),
        const FlSpot(3, 74),
        const FlSpot(4, 71),
        const FlSpot(5, 73),
        FlSpot(6, _heartRate.currentValue.toDouble()),
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 5,
            )],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Heart Rate History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: "Week",
                    onChanged: (_) {},
                    items: const [
                      DropdownMenuItem(value: "Week", child: Text("This Week")),
                      DropdownMenuItem(value: "Month", child: Text("This Month")),
                    ],
                    underline: const SizedBox(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 10,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            final index = value.toInt();
                            if (index >= 0 && index < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  days[index],
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 10,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.red.shade400,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.red.shade400.withOpacity(0.1),
                        ),
                      ),
                    ],
                    minY: 60,
                    maxY: 100,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.black.withOpacity(0.8),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            return LineTooltipItem(
                              '${touchedSpot.y.toInt()} BPM',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Blood pressure chart
      final List<FlSpot> systolicSpots = [
        const FlSpot(0, 118),
        const FlSpot(1, 122),
        const FlSpot(2, 125),
        const FlSpot(3, 130),
        const FlSpot(4, 126),
        const FlSpot(5, 124),
        FlSpot(6, _bloodPressure.currentValue.toDouble()),
      ];

      final List<FlSpot> diastolicSpots = [
        const FlSpot(0, 78),
        const FlSpot(1, 80),
        const FlSpot(2, 82),
        const FlSpot(3, 84),
        const FlSpot(4, 81),
        const FlSpot(5, 80),
        FlSpot(6, _bloodPressure.secondaryValue!.toDouble()),
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 5,
            )],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Blood Pressure History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: "Week",
                    onChanged: (_) {},
                    items: const [
                      DropdownMenuItem(value: "Week", child: Text("This Week")),
                      DropdownMenuItem(value: "Month", child: Text("This Month")),
                    ],
                    underline: const SizedBox(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Systolic",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Diastolic",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            final index = value.toInt();
                            if (index >= 0 && index < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  days[index],
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Systolic line (top)
                      LineChartBarData(
                        spots: systolicSpots,
                        isCurved: true,
                        color: Colors.red.shade400,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: Colors.red.shade400,
                              strokeWidth: 0,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: false,
                        ),
                      ),
                      // Diastolic line (bottom)
                      LineChartBarData(
                        spots: diastolicSpots,
                        isCurved: true,
                        color: Colors.blue.shade400,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: Colors.blue.shade400,
                              strokeWidth: 0,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: false,
                        ),
                      ),
                    ],
                    minY: 60,
                    maxY: 140,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.black.withOpacity(0.8),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            final String text = touchedSpot.barIndex == 0
                                ? 'Systolic: ${touchedSpot.y.toInt()} mmHg'
                                : 'Diastolic: ${touchedSpot.y.toInt()} mmHg';
                            return LineTooltipItem(
                              text,
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section with Purple Background - Only show on Home tab
            if (_selectedTabIndex != 3) // Don't show on profile tab
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF5D3FD3),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_getGreeting()}, ${_getDisplayName()}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "How are you feeling today?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Emergency Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.warning_rounded),
                  label: const Text("Emergency Assistance"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5446D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _showEmergencyDialog,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tab content depends on which tab is selected
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: [
                  // Home Tab - Summary of all sections
                  _buildHomeSummaryTab(),

                  // Medications Tab
                  _buildMedicationsTab(),

                  // Health Tab
                  _buildHealthTab(),

                  // Profile Tab
                  _buildProfileTab(),
                ],
              ),
            ),

            // Bottom Navigation
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF5D3FD3),
                labelColor: const Color(0xFF5D3FD3),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.home),
                    text: "Home",
                  ),
                  Tab(
                    icon: Icon(Icons.medication),
                    text: "Medications",
                  ),
                  Tab(
                    icon: Icon(Icons.favorite_border),
                    text: "Health",
                  ),
                  Tab(
                    icon: Icon(Icons.person),
                    text: "Profile",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTabIndex == 1 ? FloatingActionButton(
        onPressed: _showAddMedicationDialog,
        backgroundColor: const Color(0xFF5D3FD3),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildHomeSummaryTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medications Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Medications",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  "${_medications.where((med) => med.taken).length} of ${_medications.length} taken",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Medication Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: _medications.isEmpty ? 0 : _medications.where((med) => med.taken).length / _medications.length,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF5D3FD3),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),

          // Medication List (Next medication to take or most recent)
          if (_medications.isEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "No medications added yet",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ] else ...[
            ListView.builder(
              itemCount: _medications.length > 2 ? 2 : _medications.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final medication = _medications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Medication Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: medication.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.medication_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Medication Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medication.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "${medication.dosage} ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  Text(
                                    " ${medication.formattedTime}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Take Button or Checkmark
                        medication.taken
                            ? GestureDetector(
                          onTap: () => _toggleMedicationStatus(index),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.green.shade700,
                            ),
                          ),
                        )
                            : ElevatedButton(
                          onPressed: () => _toggleMedicationStatus(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D3FD3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(70, 36),
                          ),
                          child: const Text(
                            "Take",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_medications.length > 2) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton(
                  onPressed: () {
                    _tabController.animateTo(1); // Switch to Medications tab
                  },
                  child: const Text("View All Medications"),
                ),
              ),
            ],
          ],

          const Divider(height: 32),

          // Health Stats Summary Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Health Stats",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _tabController.animateTo(2); // Switch to Health tab
                  },
                  child: const Text("View Details"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Health Cards in a row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Heart Rate Card
                Expanded(
                  child: _buildMiniHealthCard(
                    title: "Heart Rate",
                    value: "${_heartRate.currentValue.toInt()}",
                    unit: _heartRate.unit,
                    icon: Icons.favorite,
                    color: Colors.red.shade400,
                    status: _heartRate.status,
                  ),
                ),
                const SizedBox(width: 16),
                // Blood Pressure Card
                Expanded(
                  child: _buildMiniHealthCard(
                    title: "Blood Pressure",
                    value: "${_bloodPressure.currentValue.toInt()}/${_bloodPressure.secondaryValue!.toInt()}",
                    unit: _bloodPressure.unit,
                    icon: Icons.monitor_heart_outlined,
                    color: Colors.green.shade400,
                    status: _bloodPressure.status,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Upcoming Appointments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upcoming Appointments",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                TextButton(
                  onPressed: _showBookConsultationScreen,
                  child: const Text("+ Add"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Appointment List
          if (_appointments.isEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "No upcoming appointments",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ] else ...[
            ListView.builder(
              itemCount: _appointments.length > 2 ? 2 : _appointments.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                return GestureDetector(
                  onTap: () => _viewAppointmentDetails(appointment),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Appointment Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: appointment.isVirtual ? Colors.blue.shade400 : Colors.orange.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              appointment.isVirtual ? Icons.videocam : Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Appointment Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.doctorName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appointment.specialty,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    Text(
                                      " ${DateFormat('MMM d').format(appointment.date)}, ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    Text(
                                      " ${appointment.time.format(context)}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Type indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: appointment.isVirtual ? Colors.blue.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              appointment.isVirtual ? "Virtual" : "In-person",
                              style: TextStyle(
                                fontSize: 12,
                                color: appointment.isVirtual ? Colors.blue.shade700 : Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          const Divider(height: 32),

          // Quick Access Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Quick Access",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Quick Access Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickAccessButtonWithAction(
                  Icons.medication,
                  Colors.pink.shade400,
                      () => _tabController.animateTo(1), // Go to Medications tab
                ),
                _buildQuickAccessButtonWithAction(
                  Icons.calendar_today,
                  Colors.orange.shade400,
                  _showCalendarView,
                ),
                _buildQuickAccessButtonWithAction(
                  Icons.videocam,
                  Colors.green.shade400,
                  _showBookConsultationScreen,
                ),
                _buildQuickAccessButtonWithAction(
                  Icons.timer,
                  Colors.blue.shade400,
                  _showSetReminderDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMiniHealthCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required HealthStatus status,
  }) {
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(2); // Switch to Health tab
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  status == HealthStatus.normal ? Icons.arrow_upward : Icons.arrow_downward,
                  color: status == HealthStatus.normal ? Colors.green : Colors.red,
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsTab() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    // Medications Header
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text(
    "Your Medications",
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF333333),
    ),
    ),
    IconButton(
    icon: const Icon(Icons.add_circle),
    color: const Color(0xFF5D3FD3),
    onPressed: _showAddMedicationDialog,
    ),
    ],
    ),
    ),
    const SizedBox(height: 8),

    // Medication Progress
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
    children: [
    Expanded(
    child: LinearProgressIndicator(
    value: _medications.isEmpty ? 0 : _medications.where((med) => med.taken).length / _medications.length,
      backgroundColor: Colors.grey.shade200,
      color: const Color(0xFF5D3FD3),
      minHeight: 6,
      borderRadius: BorderRadius.circular(3),
    ),
    ),
      const SizedBox(width: 8),
      Text(
        _medications.isEmpty ? "0 of 0" : "${_medications.where((med) => med.taken).length} of ${_medications.length}",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
    ],
    ),
    ),
          const SizedBox(height: 16),

          // Filter Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Chip(
                    label: const Text("All"),
                    backgroundColor: const Color(0xFF5D3FD3).withOpacity(0.1),
                    side: BorderSide.none,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text("Morning"),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text("Afternoon"),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text("Evening"),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Medication List with Edit options
          Expanded(
            child: _medications.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No medications added yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddMedicationDialog,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Add Medication",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D3FD3),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _medications.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final medication = _medications[index];
                return GestureDetector(
                  onTap: () => _editMedication(medication),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Medication Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: medication.color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.medication_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Medication Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medication.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      "${medication.dosage} ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    Text(
                                      " ${medication.formattedTime}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  medication.instructions,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Take Button or Checkmark
                          medication.taken
                              ? GestureDetector(
                            onTap: () => _toggleMedicationStatus(index),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.green.shade700,
                              ),
                            ),
                          )
                              : ElevatedButton(
                            onPressed: () => _toggleMedicationStatus(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5D3FD3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(70, 36),
                            ),
                            child: const Text(
                              "Take",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Health Stats Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Health Stats",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Health Stat Cards
          _selectedHealthStat == 0
              ? _buildHeartRateCard()
              : _buildBloodPressureCard(),

          const SizedBox(height: 16),

          // Health Stat Toggle Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatButton(0, Icons.favorite, Colors.red.shade400),
                _buildStatButton(1, Icons.monitor_heart_outlined, Colors.green.shade400),
                GestureDetector(
                  onTap: () => _showHealthStatusInfo(_selectedHealthStat == 0 ? _heartRate : _bloodPressure, true),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      color: (_selectedHealthStat == 0 ? _heartRate.status : _bloodPressure.status) == HealthStatus.normal
                          ? Colors.green
                          : Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showHealthStatusInfo(_selectedHealthStat == 0 ? _heartRate : _bloodPressure, false),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_downward,
                      color: (_selectedHealthStat == 0 ? _heartRate.status : _bloodPressure.status) == HealthStatus.warning
                          ? Colors.red
                          : Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Last Updated
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Last updated: ${_formatLastUpdated(_selectedHealthStat == 0 ? _heartRate.lastUpdated : _bloodPressure.lastUpdated)}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _editHealthData(_selectedHealthStat == 0 ? _heartRate : _bloodPressure),
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text("Update"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5D3FD3),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Dynamic Chart Section
          _buildHealthChart(),

          const SizedBox(height: 24),

          // Quick Access Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Quick Access",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Quick Access Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickAccessButtonWithAction(
                  Icons.medication,
                  Colors.pink.shade400,
                      () => _tabController.animateTo(1), // Go to Medications tab
                ),
                _buildQuickAccessButtonWithAction(
                  Icons.calendar_today,
                  Colors.orange.shade400,
                  _showCalendarView,
                ),
                _buildQuickAccessButtonWithAction(
                  Icons.videocam,
                  Colors.green.shade400,
                  _showBookConsultationScreen,
                ),
                _buildQuickAccessButtonWithAction(
                  Icons.timer,
                  Colors.blue.shade400,
                  _showSetReminderDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D3FD3).withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF5D3FD3),
                      width: 2,
                    ),
                  ),
                  child: widget.user.photoURL != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      widget.user.photoURL!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Center(
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF5D3FD3),
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getDisplayName(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Age: 68",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.user.email ?? "rudra@example.com",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      // No actual sign out as we're using a mock user
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Settings List
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsItem(
                  Icons.person,
                  "Personal Information",
                  _showPersonalInfoDialog,
                ),
                _buildDivider(),
                _buildSettingsItem(
                  Icons.notifications,
                  "Notifications",
                  _showNotificationSettings,
                ),
                _buildDivider(),
                _buildSettingsItem(
                  Icons.privacy_tip,
                  "Privacy Settings",
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy settings coming soon'),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  Icons.help,
                  "Help & Support",
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help and support coming soon'),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  Icons.info,
                  "About GuardianCare",
                  _showAboutApp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Heart Rate",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_heartRate.currentValue.toInt()} BPM",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editHealthData(_heartRate),
                  color: const Color(0xFF5D3FD3),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Min",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_heartRate.minValue.toInt()} BPM",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Max",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_heartRate.maxValue.toInt()} BPM",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _heartRate.status == HealthStatus.normal
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _heartRate.status == HealthStatus.normal
                        ? Icons.check_circle
                        : Icons.warning,
                    color: _heartRate.status == HealthStatus.normal
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _heartRate.status == HealthStatus.normal
                        ? "Normal"
                        : "Attention Needed",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _heartRate.status == HealthStatus.normal
                          ? Colors.green.shade700
                          : Colors.red.shade700,
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

  Widget _buildBloodPressureCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.monitor_heart_outlined,
                    color: Colors.green.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Blood Pressure",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_bloodPressure.currentValue.toInt()}/${_bloodPressure.secondaryValue!.toInt()}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editHealthData(_bloodPressure),
                  color: const Color(0xFF5D3FD3),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Systolic",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_bloodPressure.currentValue.toInt()} mmHg",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Diastolic",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_bloodPressure.secondaryValue!.toInt()} mmHg",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _bloodPressure.status == HealthStatus.normal
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _bloodPressure.status == HealthStatus.normal
                        ? Icons.check_circle
                        : Icons.warning,
                    color: _bloodPressure.status == HealthStatus.normal
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _bloodPressure.status == HealthStatus.normal
                        ? "Normal"
                        : "Attention Needed",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _bloodPressure.status == HealthStatus.normal
                          ? Colors.green.shade700
                          : Colors.red.shade700,
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

  Widget _buildStatButton(int index, IconData icon, Color color) {
    final isSelected = _selectedHealthStat == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHealthStat = index;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : color,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildQuickAccessButtonWithAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5D3FD3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF5D3FD3),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 56,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Model classes for the app
class MedicationItem {
  final String id;
  final String name;
  final String dosage;
  final TimeOfDay time;
  bool taken;
  final Color color;
  final DateTime startDate;
  final DateTime endDate;
  final String frequency;
  final String instructions;

  MedicationItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.taken,
    required this.color,
    required this.startDate,
    required this.endDate,
    required this.frequency,
    required this.instructions,
  });

  String get formattedTime {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final period = time.hour >= 12 ? "PM" : "AM";
    return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
  }
}

enum HealthStatus {
  normal,
  warning,
}

class HealthStats {
  double currentValue;
  double? secondaryValue;
  final double minValue;
  final double maxValue;
  final String unit;
  final IconData icon;
  final Color color;
  HealthStatus status;
  DateTime lastUpdated;

  HealthStats({
    required this.currentValue,
    this.secondaryValue,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    required this.icon,
    required this.color,
    required this.status,
    required this.lastUpdated,
  });
}

enum ReminderType {
  medication,
  appointment,
  custom,
}

class ReminderItem {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final ReminderType type;
  final String notes;

  ReminderItem({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.type,
    required this.notes,
  });
}

class AppointmentItem {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final TimeOfDay time;
  final bool isVirtual;
  final String notes;
  final String reason;

  AppointmentItem({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.isVirtual,
    required this.notes,
    required this.reason,
  });
}