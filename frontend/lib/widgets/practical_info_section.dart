import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget réutilisable affichant les informations pratiques du restaurant "Les AL"
class PracticalInfoSection extends StatelessWidget {
  final bool showTitle;
  final EdgeInsets? padding;

  const PracticalInfoSection({
    Key? key,
    this.showTitle = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGrey,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppTheme.softBlack, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Informations pratiques',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          _buildInfoItem(
            Icons.access_time_rounded,
            'Ouvert 7j/7',
            '11h - 23h',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            Icons.location_on_rounded,
            'Adresse',
            '123 Rue de l\'ESGI, Lyon',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            Icons.phone_rounded,
            'Téléphone',
            '01 23 45 67 89',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.mediumGrey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mediumGrey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
