import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

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
  List<AppointmentItem> _appointments = [];

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
        specialty: "Cardiologist",
        date: DateTime.now().add(const Duration(days: 3)),
        time: const TimeOfDay(hour: 10, minute: 30),
        isVirtual: false,
        notes: "Annual heart checkup",
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
                    label: const Text('Call Emergency Services (911)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5446D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // In a real app, this would actually call 911
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Emergency services would be called here'),
                          backgroundColor: Colors.red,
                        ),
                      );
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
                child: const Text('Confirm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3FD3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

  void _toggleHealthStat() {
    setState(() {
      _selectedHealthStat = _selectedHealthStat == 0 ? 1 : 0;
    });
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
              child: const Text('Save'),
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
              child: const Text('Done'),
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
                    _bloodPressure.currentValue = (125 + math.Random().nextInt(10)) as double;
                    _bloodPressure.secondaryValue = (80 + math.Random().nextInt(5)) as double?;
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
              child: const Text('OK'),
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
                  child: const Text('Add'),
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
                    });

                    // Sort medications by time
                    _medications.sort((a, b) {
                      final aMinutes = a.time.hour * 60 + a.time.minute;
                      final bMinutes = b.time.hour * 60 + b.time.minute;
                      return aMinutes.compareTo(bMinutes);
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
                  child: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    _deleteMedication(medication);
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Save'),
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
              child: const Text('Delete'),
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

  void _showAddAppointmentDialog() {
    final doctorNameController = TextEditingController();
    final specialtyController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();
    bool isVirtual = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Schedule Appointment'),
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
                  child: const Text('Schedule'),
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

                    final newAppointment = AppointmentItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      doctorName: doctorNameController.text,
                      specialty: specialtyController.text,
                      date: selectedDate,
                      time: selectedTime,
                      isVirtual: isVirtual,
                      notes: notesController.text,
                    );

                    setState(() {
                      _appointments.add(newAppointment);
                    });

                    // Sort appointments by date and time
                    _appointments.sort((a, b) {
                      int dateComparison = a.date.compareTo(b.date);
                      if (dateComparison != 0) return dateComparison;

                      final aMinutes = a.time.hour * 60 + a.time.minute;
                      final bMinutes = b.time.hour * 60 + b.time.minute;
                      return aMinutes.compareTo(bMinutes);
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
                  child: const Text('Delete'),
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
                  child: const Text('Save'),
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
              child: const Text('Save'),
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
                  child: const Text('Save'),
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
              child: const Text('Close'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section with Purple Background
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
                    "${_getGreeting()}, ${widget.user.displayName ?? 'User'}",
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
    value: _medications.where((med) => med.taken).length / _medications.length,
    backgroundColor: Colors.grey.shade200,
    color: const Color(0xFF5D3FD3),
    minHeight: 6,
    borderRadius: BorderRadius.circular(3),
    ),
    ),
    const SizedBox(height: 12),

    // Medication List (Next medication to take or most recent)
    if (_medications.isNotEmpty) ...[
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
      child: const Text("Take"),
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
                    onPressed: _showAddAppointmentDialog,
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
                    _showAddAppointmentDialog,
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
                  value: _medications.where((med) => med.taken).length / _medications.length,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF5D3FD3),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${_medications.where((med) => med.taken).length} of ${_medications.length}",
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
                  label: const Text("Add Medication"),
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
                          child: const Text("Take"),
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
                  _showAddAppointmentDialog,
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

          // Health Trends (placeholder for future implementation)
          Padding(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Health Trends",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButton<String>(
                        value: "Week",
                        onChanged: (_) {},
                        items: const [
                          DropdownMenuItem(
                            value: "Week",
                            child: Text("This Week"),
                          ),
                          DropdownMenuItem(
                            value: "Month",
                            child: Text("This Month"),
                          ),
                        ],
                        underline: const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Text("Health Trends Graph - Coming Soon"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
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
                    color: const Color(0xFF5D3FD3).withOpacity(0.1),
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
                      : const Icon(
                    Icons.person,
                    color: Color(0xFF5D3FD3),
                    size: 60,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user.displayName ?? "User",
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
                  widget.user.email ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Sign Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    // No actual sign out as we're using a mock user
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
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

  void _showCalendarView() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Calendar",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "Calendar View - Coming Soon",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D3FD3),
                  ),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSetReminderDialog() {
    TimeOfDay selectedTime = TimeOfDay.now();
    DateTime selectedDate = DateTime.now();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Set Reminder'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const Text("Reminder Type:"),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("Medication"),
                          selected: true,
                          onSelected: (_) {},
                        ),
                        ChoiceChip(
                          label: const Text("Appointment"),
                          selected: false,
                          onSelected: (_) {},
                        ),
                        ChoiceChip(
                          label: const Text("Custom"),
                          selected: false,
                          onSelected: (_) {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
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
                  child: const Text('Set Reminder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D3FD3),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reminder set successfully'),
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

class AppointmentItem {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final TimeOfDay time;
  final bool isVirtual;
  final String notes;

  AppointmentItem({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.isVirtual,
    required this.notes,
  });
}