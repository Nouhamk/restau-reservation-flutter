import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../services/menu_item_service.dart';

class MenuPage extends StatefulWidget {
  final User? currentUser;

  const MenuPage({super.key, this.currentUser});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _selectedCategory = 'all';
  final _authService = AuthService();

  List<MenuItemModel> _allItems = [];
  bool _isLoading = false;
  String? _error;

  bool get _isAdmin => widget.currentUser?.role == 'admin';

  // Catégories, avec une catégorie supplémentaire pour les plats indisponibles côté admin
  List<Map<String, String>> get _categories => [
    {'key': 'all', 'label': 'Tous'},
    {'key': 'starter', 'label': 'Entrées'},
    {'key': 'main', 'label': 'Plats'},
    {'key': 'dessert', 'label': 'Desserts'},
    {'key': 'drink', 'label': 'Boissons'},
    if (_isAdmin) {'key': 'unavailable', 'label': 'Indisponibles'},
  ];

  List<MenuItemModel> get _filteredItems {
    if (_isAdmin) {
      if (_selectedCategory == 'all') {
        return _allItems;
      }
      if (_selectedCategory == 'unavailable') {
        return _allItems.where((m) => !m.available).toList();
      }
      return _allItems
          .where((m) => m.category == _selectedCategory)
          .toList();
    }

    // Comportement inchangé pour un utilisateur non admin
    if (_selectedCategory == 'all') {
      return _allItems.where((m) => m.available).toList();
    }
    return _allItems
        .where((m) => m.available && m.category == _selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = _isAdmin
          ? await MenuItemService.getAllMenuItems()
          : await MenuItemService.getAvailableMenu();

      _allItems = data
          .map(
            (json) => MenuItemModel.fromJson(json as Map<String, dynamic>),
      )
          .toList();
    } catch (e, st) {
      // ignore: avoid_print
      print('Erreur _fetchMenu: $e');
      // ignore: avoid_print
      print(st);
      _error = 'Impossible de charger le menu.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: AppTheme.lightSurface,
        foregroundColor: Colors.white,
        actions: [
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () => _showItemForm(),
                icon: const Icon(Icons.add, color: AppTheme.roseGold),
                label: const Text(
                  'Ajouter un plat',
                  style: TextStyle(
                    color: AppTheme.roseGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.roseGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            _buildCategoryBar(),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildContent(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.roseGold,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Text(
          'Aucun plat disponible.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return GridView.builder(
      itemCount: _filteredItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.80,
      ),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildCard(item, theme);
      },
    );
  }

  Widget _buildCategoryBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final isSelected = cat['key'] == _selectedCategory;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat['key']!;
                });
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.roseGoldGradient : null,
                  color: isSelected ? null : AppTheme.lightBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? AppTheme.cardShadow : [],
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.roseGold
                        : AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    cat['label']!,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.lightSurface
                          : AppTheme.darkText,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(MenuItemModel item, ThemeData theme) {
    return Card(
      color: AppTheme.lightBackground,
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.roseGold.withOpacity(0.25),
          width: 1,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? Image.network(
              item.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              color: AppTheme.deepNavy,
              child: const Center(
                child: Icon(
                  Icons.restaurant,
                  size: 40,
                  color: AppTheme.roseGold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
            child: Text(
              item.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                color: AppTheme.deepNavy,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: AppTheme.secondaryGray,
              ),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              '${item.price.toStringAsFixed(2)} €',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.roseGold,
              ),
            ),
          ),
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => _showItemForm(item: item),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.roseGold,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    child: const Text('Éditer'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _confirmDelete(item),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.elegantBurgundy,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showItemForm({MenuItemModel? item}) async {
    final isEdit = item != null;

    final nameController = TextEditingController(text: item?.name ?? '');
    final descriptionController =
    TextEditingController(text: item?.description ?? '');
    final priceController =
    TextEditingController(text: item != null ? item.price.toString() : '');
    final imageUrlController =
    TextEditingController(text: item?.imageUrl ?? '');
    String category = item?.category ?? 'starter';
    bool available = item?.available ?? true;

    await showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.lightBackground,
              title: Text(
                isEdit ? 'Modifier un plat' : 'Ajouter un plat',
                style: theme.textTheme.titleLarge,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Prix (€)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'starter',
                          child: Text('Entrée'),
                        ),
                        DropdownMenuItem(
                          value: 'main',
                          child: Text('Plat'),
                        ),
                        DropdownMenuItem(
                          value: 'dessert',
                          child: Text('Dessert'),
                        ),
                        DropdownMenuItem(
                          value: 'drink',
                          child: Text('Boisson'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          category = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL de l’image',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: available,
                      activeColor: AppTheme.roseGold,
                      title: const Text('Disponible'),
                      onChanged: (val) {
                        setModalState(() {
                          available = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final priceText =
                    priceController.text.trim().replaceAll(',', '.');

                    if (name.isEmpty || priceText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nom et prix sont obligatoires'),
                        ),
                      );
                      return;
                    }

                    final price = double.tryParse(priceText);
                    if (price == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Prix invalide'),
                        ),
                      );
                      return;
                    }

                    final body = {
                      'name': name,
                      'description': descriptionController.text.trim(),
                      'price': price,
                      'category': category,
                      'image_url': imageUrlController.text.trim().isEmpty
                          ? null
                          : imageUrlController.text.trim(),
                      'available': available,
                    };

                    try {
                      if (isEdit) {
                        await MenuItemService.updateMenuItem(item!.id, body);
                      } else {
                        await MenuItemService.createMenuItem(body);
                      }

                      if (!mounted) return;
                      Navigator.of(context).pop();
                      await _fetchMenu();
                    } catch (e) {
                      if (!mounted) return;
                      // ignore: avoid_print
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Erreur lors de l\'enregistrement du plat: $e'),
                        ),
                      );
                    }
                  },
                  child: Text(isEdit ? 'Enregistrer' : 'Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(MenuItemModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: AppTheme.lightBackground,
          title: Text(
            'Supprimer ce plat ?',
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            'Cette action est définitive.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.elegantBurgundy,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    ) ??
        false;

    if (!confirm) return;

    try {
      await MenuItemService.deleteMenuItem(item.id);
      await _fetchMenu();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression du plat'),
        ),
      );
    }
  }
}
