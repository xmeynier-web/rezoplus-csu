import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCu0BK4h2hhaGV4C46C9y65rBJlnLftq3A",
      appId: "1:561209004165:web:4c19c7b505bf7ad7df19ec",
      messagingSenderId: "561209004165",
      projectId: "rezoplus-police",
      databaseURL: "https://rezoplus-police-default-rtdb.europe-west1.firebasedatabase.app",
      storageBucket: "rezoplus-police.firebasestorage.app",
    ),
  );
  
  runApp(const RezoPlusDispatchApp());
}

class RezoPlusDispatchApp extends StatelessWidget {
  const RezoPlusDispatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rezo+ CSU - Commandement',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF12121a),
        cardColor: const Color(0xFF1e1e2d),
      ),
      home: const DispatchDashboard(),
    );
  }
}

class DispatchDashboard extends StatefulWidget {
  const DispatchDashboard({super.key});

  @override
  State<DispatchDashboard> createState() => _DispatchDashboardState();
}

class _DispatchDashboardState extends State<DispatchDashboard> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("units");
  Map<String, dynamic> _units = {};
  bool _hasSosAlert = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToUnits();
  }

  void _listenToUnits() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        Map<String, dynamic> parsedUnits = {};
        bool sosDetected = false;

        data.forEach((key, value) {
          if (value != null && value is Map) {
            final unitMap = Map<String, dynamic>.from(value);
            parsedUnits[key.toString()] = unitMap;
            if (unitMap['status'] == 'SOS_ACTIF') {
              sosDetected = true;
            }
          }
        });

        setState(() {
          _units = parsedUnits;
          _hasSosAlert = sosDetected;
          _isLoading = false;
        });
      } else {
        setState(() {
          _units = {};
          _hasSosAlert = false;
          _isLoading = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _sendMissionDialog(String unitId) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transmettre une mission : $unitId'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Objet de la mission'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Lieu / Adresse'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              if (titleController.text.isNotEmpty && locationController.text.isNotEmpty) {
                _dbRef.child("$unitId/active_mission").set({
                  "title": titleController.text.trim(),
                  "location": locationController.text.trim(),
                  "timestamp": ServerValue.timestamp,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _clearMission(String unitId) {
    _dbRef.child("$unitId/active_mission").remove();
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'SOS_ACTIF':
        return Colors.red;
      case 'EN_INTERVENTION':
        return Colors.orange;
      case 'TRANSPORT':
        return Colors.blue;
      case 'EN_PATROUILLE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REZO+ // CSU Commandement'),
        backgroundColor: _hasSosAlert ? Colors.red.shade900 : const Color(0xFF1a1a2e),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasSosAlert)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 36, color: Colors.white),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '🚨 ALERTE SOS DÉCLENCHÉE SUR LE TERRAIN !',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            const Text(
              'Équipages connectés en temps réel :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _units.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun équipage connecté pour le moment.\n\nAssurez-vous que l\'application Android est ouverte et qu\'un équipage a démarré sa prise de service.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            mainAxisExtent: 280,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _units.length,
                          itemBuilder: (context, index) {
                            String unitId = _units.keys.elementAt(index);
                            Map<String, dynamic> data = _units[unitId];
                            String status = data['status'] ?? 'INCONNU';
                            Map<dynamic, dynamic>? mission = data['active_mission'];
                            dynamic lat = data['latitude'];
                            dynamic lng = data['longitude'];

                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: _getStatusColor(status), width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          unitId,
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        Chip(
                                          label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          backgroundColor: _getStatusColor(status),
                                        ),
                                      ],
                                    ),
                                    const Divider(color: Colors.grey),
                                    Text(
                                      'GPS : ${lat != null ? "$lat, $lng" : "En attente de signal..."}',
                                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                                    ),
                                    const SizedBox(height: 8),
                                    if (mission != null)
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade900.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Mission : ${mission['title']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                  Text('Lieu : ${mission['location']}', style: const TextStyle(fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, size: 18, color: Colors.white),
                                              onPressed: () => _clearMission(unitId),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      const Text('Aucune mission active', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    
                                    const Spacer(),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2a2a3d)),
                                        onPressed: () => _sendMissionDialog(unitId),
                                        icon: const Icon(Icons.send, size: 16),
                                        label: const Text('Envoyer une mission'),
                                      ),
                                    ),
                                  ],
                                ),
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
}
