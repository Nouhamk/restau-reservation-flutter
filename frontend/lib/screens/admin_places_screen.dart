import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/place_service.dart';

class AdminPlacesScreen extends StatefulWidget {
  const AdminPlacesScreen({Key? key}) : super(key: key);

  @override
  State<AdminPlacesScreen> createState() => _AdminPlacesScreenState();
}

class _AdminPlacesScreenState extends State<AdminPlacesScreen> {
  final _service = PlaceService();
  bool _loading = true;
  List<dynamic> _places = [];

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() => _loading = true);
    try {
      final items = await _service.listPlaces();
      setState(() {
        _places = items;
      });
    } catch (e) {
      // simple error feedback
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur chargement lieux')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _showPlaceForm({Map<String, dynamic>? place}) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController(text: place?['name'] ?? '');
        final addressCtrl =
            TextEditingController(text: place?['address'] ?? '');
        final phoneCtrl = TextEditingController(text: place?['phone'] ?? '');
        final capacityCtrl =
            TextEditingController(text: place?['capacity']?.toString() ?? '50');

        return AlertDialog(
          backgroundColor: AppTheme.lightSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(place == null ? 'Ajouter un lieu' : 'Modifier le lieu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nom')),
                const SizedBox(height: 8),
                TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Adresse')),
                const SizedBox(height: 8),
                TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Téléphone')),
                const SizedBox(height: 8),
                TextField(
                    controller: capacityCtrl,
                    decoration: const InputDecoration(labelText: 'Capacité'),
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final payload = {
                  'name': nameCtrl.text.trim(),
                  'address': addressCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'capacity': int.tryParse(capacityCtrl.text.trim()) ?? 50,
                };
                Navigator.of(context).pop(payload);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppTheme.deepNavy),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    try {
      if (place == null) {
        await _service.createPlace(result);
      } else {
        await _service.updatePlace(place['id'] as int, result);
      }
      await _loadPlaces();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Opération réussie')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightSurface,
        title: const Text('Supprimer le lieu'),
        content: const Text('Voulez-vous vraiment supprimer ce lieu ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.elegantBurgundy),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _service.deletePlace(id);
      await _loadPlaces();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lieu supprimé')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur suppression: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.deepNavy,
        title: const Text('Gérer les Restaurants'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPlaces,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _places.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                              child: Text('Aucun lieu trouvé',
                                  style:
                                      TextStyle(color: AppTheme.mediumGrey))),
                        ],
                      )
                    : ListView.separated(
                        itemCount: _places.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final p = _places[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.lightSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.lightGrey),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.store,
                                    color: AppTheme.deepNavy, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p['name'] ?? '—',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.darkText)),
                                      const SizedBox(height: 4),
                                      Text(p['address'] ?? '',
                                          style: TextStyle(
                                              color: AppTheme.mediumGrey)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                              'Capacité: ${p['capacity'] ?? '—'}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.mediumGrey)),
                                          const SizedBox(width: 12),
                                          Text(p['phone'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.mediumGrey)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded),
                                      color: AppTheme.champagne,
                                      onPressed: () => _showPlaceForm(place: p),
                                      tooltip: 'Modifier',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: AppTheme.elegantBurgundy,
                                      onPressed: () =>
                                          _confirmDelete(p['id'] as int),
                                      tooltip: 'Supprimer',
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.roseGold,
        child: const Icon(Icons.add),
        onPressed: () => _showPlaceForm(),
        tooltip: 'Ajouter un lieu',
      ),
    );
  }
}
