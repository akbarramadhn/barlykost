import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../../../models/admin/kost.dart';

class AdminKostCard extends StatelessWidget {
  final Kost kost;
  final VoidCallback? onTap;

  const AdminKostCard({
    super.key,
    required this.kost,
    this.onTap,
  });

  String _formatRupiah(int number) {
    final String value = number.toString();
    final StringBuffer result = StringBuffer();

    for (int index = 0; index < value.length; index++) {
      if (index > 0 && (value.length - index) % 3 == 0) {
        result.write('.');
      }

      result.write(value[index]);
    }

    return result.toString();
  }

  Widget _buildImage() {
    final String? imageUrl = kost.coverImageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: ThemeApp.softBackground,
        alignment: Alignment.center,
        child: const Icon(
          Icons.home_work_outlined,
          size: 42,
          color: ThemeApp.buttonColor,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: ThemeApp.softBackground,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: ThemeApp.primaryDark,
            ),
          ),
        );
      },
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return Container(
          color: ThemeApp.softBackground,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: ThemeApp.buttonColor,
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: isAvailable
            ? ThemeApp.adminSoftGreen
            : ThemeApp.adminSoftRed,
        borderRadius: ThemeApp.radius(13),
      ),
      child: Text(
        isAvailable ? 'Tersedia' : 'Penuh',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: isAvailable
              ? ThemeApp.successGreen
              : ThemeApp.cancelledRed,
        ),
      ),
    );
  }

  Widget _buildKostName() {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          kost.namaKost,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 18,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: ThemeApp.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.location_on_outlined,
            size: 22,
            color: ThemeApp.locationBlue,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            kost.lokasi,
            softWrap: true,
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: ThemeApp.textGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return SizedBox(
      width: double.infinity,
      height: 28,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Rp ${_formatRupiah(kost.harga)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ThemeApp.priceDark,
                ),
              ),
              const TextSpan(
                text: ' /Perbulan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ThemeApp.textGrey,
                ),
              ),
            ],
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = kost.isAvailable;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: ThemeApp.radius(24),
        child: Ink(
          decoration: BoxDecoration(
            color: ThemeApp.white,
            borderRadius: ThemeApp.radius(24),
            border: Border.all(
              color: ThemeApp.adminCardBorder,
              width: 0.7,
            ),
            boxShadow: [
              ThemeApp.softShadow(
                alpha: 0.06,
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: ThemeApp.radius(19),
                  child: SizedBox(
                    width: 120,
                    height: 136,
                    child: _buildImage(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 136,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKostName(),
                        const SizedBox(height: 9),
                        _buildLocation(),
                        const SizedBox(height: 12),
                        _buildPrice(),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildStatusBadge(isAvailable),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}