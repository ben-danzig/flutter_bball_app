import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_configuration.dart';

class TeamConfigurationService {
  static final TeamConfigurationService instance = TeamConfigurationService._();
  final CollectionReference _configsRef = FirebaseFirestore.instance.collection('team_configurations');

  TeamConfigurationService._();

  Future<void> saveConfiguration(TeamConfiguration config) async {
    await _configsRef.doc(config.id).set(config.toJson());
  }

  Future<List<TeamConfiguration>> getConfigurations() async {
    final snapshot = await _configsRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => TeamConfiguration.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> updateConfigurationName(String id, String newName) async {
    await _configsRef.doc(id).update({'name': newName});
  }
} 