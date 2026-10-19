import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
      title: 'Rezo+ CSU - Cartographie & Commandement',
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
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final MapController _mapController = MapController();
  
  Map<String, dynamic> _units = {};
  bool _hasSosAlert = false;
  
  // Position par défaut de la carte (Secteur Fresnes / Île-de-France)
  final LatLng _defaultCenter = const LatLng(48.7538, 2.3218);

  @override
  void initState() {
    super.initState();
    _listenToDatabase();
  }

  void _listenToDatabase() {
    _dbRef.onValue.listen((event) {
      final rawData = event.snapshot.value;
      if (rawData != null && rawData is Map) {
        Map<dynamic, dynamic>? unitsMap;
        if (rawData.containsKey('units') && rawData['units'] is Map) {
          unitsMap = rawData['units'] as Map<dynamic, dynamic>;
        } else {
          unitsMap = rawData;
        }

        Map<String, dynamic> parsedUnits = {};
        bool sosDetected = false;

        unitsMap.forEach((key, value) {
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
        });
      } else {
        setState(() {
          _units = {};
          _hasSosAlert = false;
        });
      }
    });
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'SOS_ACTIF':
        return Colors.red;
      case 'EN_INTERVENTION':
        return Colors.orange;
      case 'TRANSPORT':
        return Colors.blue;
      case 'RETOUR_POSTE':
        return Colors.purple;
      case 'EN_PATROUILLE':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
                _dbRef.child("units/$unitId/active_mission").set({
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
    _dbRef.child("units/$unitId/active_mission").remove();
  }

  @override
  Widget build(BuildContext context) {
    // Génération des marqueurs cartographiques pour chaque équipage ayant un signal GPS valide
    List<Marker> markers = [];
    _units.forEach((unitId, data) {
      if (data is Map && data['latitude'] != null && data['longitude'] != null) {
        double lat = (data['latitude'] as num).toDouble();
        double lng = (data['longitude'] as num).toDouble();
        String status = data['status'] ?? 'INCONNU';

        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Équipage sélectionné : $unitId ($status)')),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _getStatusColor(status)),
                    ),
                    child: Text(
                      unitId,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Icon(
                    Icons.local_police,
                    color: _getStatusColor(status),
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('REZO+ // CSU Cartographie & Commandement [Unités : ${_units.length}]'),
        backgroundColor: _hasSosAlert ? Colors.red.shade900 : const Color(0xFF1a1a2e),
      ),
      body: Row(
        children: [
          // 1. CARTE INTERACTIVE (OpenStreetMap)
          Expanded(
            flex: 3,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 13.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.rezoplus.csu',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),

          // 2. PANNEAU LATÉRAL : LISTE ET GESTION DES ÉQUIPAGES
          Container(
            width: 380,
            color: const Color(0xFF12121a),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasSosAlert)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🚨 ALERTE SOS ACTIF EN COURS !',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Text(
                  'Équipages en service :',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: _units.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune unité connectée.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _units.length,
                          itemBuilder: (context, index) {
                            String unitId = _units.keys.elementAt(index);
                            Map<String, dynamic> data = Map<String, dynamic>.from(_units[unitId] ?? {});
                            String status = data['status'] ?? 'INCONNU';
                            Map<dynamic, dynamic>? mission = data['active_mission'];
                            dynamic lat = data['latitude'];
                            dynamic lng = data['longitude'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: _getStatusColor(status), width: 1.5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(unitId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Chip(
                                          label: Text(status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                                          backgroundColor: _getStatusColor(status),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('GPS : ${lat != null ? "$lat, $lng" : "En attente..."}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    
                                    if (lat != null && lng != null)
                                      TextButton.icon(
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                                        onPressed: () {
                                          _mapController.move(LatLng((lat as num).toDouble(), (lng as num).toDouble()), 16.0);
                                        },
                                        icon: const Icon(Icons.my_location, size: 14, color: Colors.blueAccent),
                                        label: const Text('Centrer sur la carte', style: TextStyle(fontSize: 11, color: Colors.blueAccent)),
                                      ),

                                    if (mission != null)
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(color: Colors.orange.shade900.withOpacity(0.4), borderRadius: BorderRadius.circular(4)),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Mission: ${mission['title']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                  Text('Lieu: ${mission['location']}', style: const TextStyle(fontSize: 10)),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, size: 14),
                                              onPressed: () => _clearMission(unitId),
                                            ),
                                          ],
                                        ),
                                      ),

                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 32,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2a2a3d)),
                                        onPressed: () => _sendMissionDialog(unitId),
                                        child: const Text('Envoyer une mission', style: TextStyle(fontSize: 11)),
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
        ],
      ),
    );
  }
}
