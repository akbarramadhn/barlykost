import 'package:flutter/material.dart';

class KostCard extends StatelessWidget {
  final String namaKost;
  final String lokasi;
  final num harga;
  final double rating;
  final String? imageUrl;
  final bool tersedia;
  final String? availableText;
  final bool isHorizontal;
  final bool showStatusBadge;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double? width;

  const KostCard({
    super.key,
    required this.namaKost,
    required this.lokasi,
    required this.harga,
    required this.rating,
    this.imageUrl,
    this.tersedia = true,
    this.availableText,
    this.isHorizontal = false,
    this.showStatusBadge = true,
    this.onTap,
    this.margin,
    this.width,
  });

  static const Color primaryDark = Color(0xFF10776F);
  static const Color primaryLight = Color(0xFF5CE7D1);
  static const Color buttonColor = Color(0xFF003B63);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGrey = Color(0xFF777777);
  static const Color locationBlue = Color(0xFF6AB8FF);
  static const Color starColor = Color(0xFFFFB000);

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return buildHorizontalCard();
    }

    return buildVerticalCard();
  }

  Widget buildHorizontalCard() {
    return Container(
      width: width ?? double.infinity,
      height: 168,
      margin: margin,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: buildImage(
                  width: 116,
                  height: 148,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaKost,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildHorizontalInfoRow(
                        icon: Icons.location_on_outlined,
                        iconColor: locationBlue,
                        text: lokasi,
                      ),
                      const SizedBox(height: 7),
                      buildHorizontalInfoRow(
                        icon: Icons.star_rounded,
                        iconColor: starColor,
                        text: '${formatRating(rating)} (reviewers)',
                      ),
                      const SizedBox(height: 7),
                      buildHorizontalInfoRow(
                        icon: Icons.meeting_room_outlined,
                        iconColor: buttonColor,
                        text: availableText ?? (tersedia ? 'Kamar tersedia' : 'Kamar penuh'),
                      ),
                      const Spacer(),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: formatRupiah(harga),
                              style: const TextStyle(
                                color: Color(0xFF2D3438),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const TextSpan(
                              text: ' /Perbulan',
                              style: TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVerticalCard() {
    return Container(
      width: width,
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildVerticalImage(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTitleAndRating(),
                    const SizedBox(height: 8),
                    buildVerticalLocation(),
                    const SizedBox(height: 12),
                    buildVerticalPrice(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVerticalImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(22),
      ),
      child: Stack(
        children: [
          buildImage(
            width: double.infinity,
            height: 145,
          ),
          if (showStatusBadge)
            Positioned(
              top: 12,
              right: 12,
              child: buildAvailabilityBadge(),
            ),
        ],
      ),
    );
  }

  Widget buildImage({
    required double width,
    required double height,
  }) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    if (!hasImage) {
      return buildImagePlaceholder(
        width: width,
        height: height,
      );
    }

    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return buildImagePlaceholder(
          width: width,
          height: height,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          width: width,
          height: height,
          color: primaryLight.withValues(alpha: 0.18),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: primaryDark,
            ),
          ),
        );
      },
    );
  }

  Widget buildImagePlaceholder({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      color: primaryLight.withValues(alpha: 0.18),
      child: const Center(
        child: Icon(
          Icons.home_rounded,
          size: 42,
          color: primaryDark,
        ),
      ),
    );
  }

  Widget buildAvailabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tersedia
            ? primaryDark.withValues(alpha: 0.95)
            : Colors.redAccent.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tersedia ? 'Tersedia' : 'Penuh',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget buildTitleAndRating() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            namaKost,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6DD),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 15,
                color: starColor,
              ),
              const SizedBox(width: 3),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildVerticalLocation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on_rounded,
          size: 18,
          color: primaryDark,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            lokasi,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildVerticalPrice() {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: formatRupiah(harga),
            style: const TextStyle(
              color: buttonColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const TextSpan(
            text: ' / bulan',
            style: TextStyle(
              color: textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHorizontalInfoRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF303030),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  String formatRupiah(num value) {
    final raw = value.round().toString();
    String result = '';
    int counter = 0;

    for (int i = raw.length - 1; i >= 0; i--) {
      result = raw[i] + result;
      counter++;

      if (counter % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }

    return 'Rp $result';
  }

  String formatRating(double value) {
    return '${value.toStringAsFixed(1).replaceAll('.', ',')}/5';
  }
}