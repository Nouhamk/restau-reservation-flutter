import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../services/place_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AdminPlacesScreen extends StatefulWidget {
  const AdminPlacesScreen({Key? key}) : super(key: key);

  @override
  State<AdminPlacesScreen> createState() => _AdminPlacesScreenState();
}

class _AdminPlacesScreenState extends State<AdminPlacesScreen> {
  final _placeService = PlaceService();
  final _authService = AuthService();
  
  List<Place> _places = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _placeService.getAllPlaces();

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _places = result['places'] as List<Place>;
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  Future<void> _showAddEditDialog({Place? place}) async {
    final nameController = TextEditingController(text: place?.name ?? '');
    final addressController = TextEditingController(text: place?.address ?? '');
    final phoneController = TextEditingController(text: place?.phone ?? '');
    final capacityController = TextEditingController(
      text: place?.capacity?.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.accentGold.withOpacity(0.3), width: 2),
        ),
        title: Row(
          children: [
            Icon(
              place == null ? Icons.add_location : Icons.edit_location,
              color: AppTheme.accentGold,
            ),
            const SizedBox(width: 12),
            Text(
              place == null ? 'Nouveau Restaurant' : 'Modifier Restaurant',
              style: const TextStyle(color: AppTheme.accentGold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: AppTheme.creamWhite),
                  decoration: const InputDecoration(
                    labelText: 'Nom du restaurant *',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  style: const TextStyle(color: AppTheme.creamWhite),
                  decoration: const InputDecoration(
                    labelText: 'Adresse *',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'adresse est requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  style: const TextStyle(color: AppTheme.creamWhite),
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: capacityController,
                  style: const TextStyle(color: AppTheme.creamWhite),
                  decoration: const InputDecoration(
                    labelText: 'Capacité',
                    prefixIcon: Icon(Icons.people),
                    suffixText: 'personnes',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final capacity = int.tryParse(value);
                      if (capacity == null || capacity <= 0) {
                        return 'Capacité invalide';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                await _savePlace(
                  place: place,
                  name: nameController.text,
                  address: addressController.text,
                  phone: phoneController.text.isEmpty ? null : phoneController.text,
                  capacity: capacityController.text.isEmpty
                      ? null
                      : int.parse(capacityController.text),
                );
              }
            },
            child: Text(place == null ? 'Créer' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlace({
    Place? place,
    required String name,
    required String address,
    String? phone,
    int? capacity,
  }) async {
    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
          ),
          child: const CircularProgressIndicator(color: AppTheme.accentGold),
        ),
      ),
    );

    final token = await _authService.getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showErrorSnackBar('Token manquant - veuillez vous reconnecter');
      return;
    }

    final result = place == null
        ? await _placeService.createPlace(
            token: token,
            name: name,
            address: address,
            phone: phone,
            capacity: capacity,
          )
        : await _placeService.updatePlace(
            token: token,
            id: place.id!,
            name: name,
            address: address,
            phone: phone,
            capacity: capacity,
          );

    if (!mounted) return;
    Navigator.of(context).pop(); // Fermer le loader

    if (result['success']) {
      _showSuccessSnackBar(result['message']);
      await _loadPlaces(); // Recharger la liste
    } else {
      _showErrorSnackBar(result['message']);
    }
  }

  Future<void> _confirmDelete(Place place) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.warmRed.withOpacity(0.5), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppTheme.warmRed),
            const SizedBox(width: 12),
            const Text(
              'Confirmer la suppression',
              style: TextStyle(color: AppTheme.warmRed),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer ce restaurant ?',
              style: TextStyle(color: AppTheme.creamWhite.withOpacity(0.9)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.address,
                    style: TextStyle(
                      color: AppTheme.creamWhite.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ Cette action est irréversible.',
              style: TextStyle(
                color: AppTheme.warmRed.withOpacity(0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warmRed,
            ),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deletePlace(place);
    }
  }

  Future<void> _deletePlace(Place place) async {
    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
          ),
          child: const CircularProgressIndicator(color: AppTheme.accentGold),
        ),
      ),
    );

    final token = await _authService.getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showErrorSnackBar('Token manquant - veuillez vous reconnecter');
      return;
    }

    final result = await _placeService.deletePlace(
      token: token,
      id: place.id!,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // Fermer le loader

    if (result['success']) {
      _showSuccessSnackBar(result['message']);
      await _loadPlaces(); // Recharger la liste
    } else {
      _showErrorSnackBar(result['message']);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.deepGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.warmRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.goldGradient
              .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: const Text(
            'GESTION DES RESTAURANTS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accentGold),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.warmRed.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppTheme.creamWhite.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadPlaces,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : _places.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 64,
                              color: AppTheme.accentGold.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun restaurant enregistré',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.creamWhite.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajoutez votre premier restaurant',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.creamWhite.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPlaces,
                        color: AppTheme.accentGold,
                        backgroundColor: AppTheme.backgroundDark,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _places.length,
                          itemBuilder: (context, index) {
                            final place = _places[index];
                            return _buildPlaceCard(place);
                          },
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.accentGold,
        icon: const Icon(Icons.add_location, color: AppTheme.primaryDark),
        label: const Text(
          'AJOUTER',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundDark,
            AppTheme.backgroundDark.withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: AppTheme.leatherShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showAddEditDialog(place: place),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec nom et actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGold.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: AppTheme.primaryDark,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Bouton modifier
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.accentGold),
                      onPressed: () => _showAddEditDialog(place: place),
                      tooltip: 'Modifier',
                    ),
                    // Bouton supprimer
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.warmRed),
                      onPressed: () => _confirmDelete(place),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Divider
                Divider(
                  color: AppTheme.accentGold.withOpacity(0.2),
                  height: 1,
                ),
                const SizedBox(height: 16),

                // Adresse
                _buildInfoRow(
                  Icons.location_on,
                  'Adresse',
                  place.address,
                ),

                // Téléphone
                if (place.phone != null && place.phone!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.phone,
                    'Téléphone',
                    place.phone!,
                  ),
                ],

                // Capacité
                if (place.capacity != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.people,
                    'Capacité',
                    '${place.capacity} personnes',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.accentGold.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.creamWhite.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.creamWhite,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
