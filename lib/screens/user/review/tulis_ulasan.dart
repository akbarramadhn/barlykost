import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/penyewa/review_service.dart';

class TulisUlasanScreen extends StatefulWidget {
  final String bookingId;
  final String kostId;
  final String kostName;

  const TulisUlasanScreen({
    super.key,
    required this.bookingId,
    required this.kostId,
    required this.kostName,
  });

  @override
  State<TulisUlasanScreen> createState() => _TulisUlasanScreenState();
}

class _TulisUlasanScreenState extends State<TulisUlasanScreen> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();

  int _selectedRating = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitReview() async {
    FocusScope.of(context).unfocus();

    if (_selectedRating == 0) {
      _showMessage('Pilih rating terlebih dahulu');
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      _showMessage('Tulis komentar terlebih dahulu');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _reviewService.createReview(
        bookingId: widget.bookingId,
        kostId: widget.kostId,
        rating: _selectedRating,
        comment: _commentController.text,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Ulasan berhasil dikirim');

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on ReviewServiceException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal mengirim ulasan: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 48, 18, 16),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.05,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _isSaving
                ? null
                : () {
                    Navigator.pop(context);
                  },
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeApp.textDark,
                size: 23,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Tulis Ulasan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeApp.textDark,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      children: List<Widget>.generate(5, (int index) {
        final int rating = index + 1;

        return Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _isSaving
                ? null
                : () {
                    setState(() {
                      _selectedRating = rating;
                    });
                  },
            child: SizedBox(
              height: 52,
              child: Center(
                child: Icon(
                  rating <= _selectedRating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: ThemeApp.starColor,
                  size: 38,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 42),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: ThemeApp.white,
            borderRadius: ThemeApp.radius(24),
            boxShadow: [
              ThemeApp.softShadow(
                alpha: 0.08,
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bagaimana pengalamanmu?',
                style: TextStyle(
                  color: ThemeApp.textDark,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.kostName.isEmpty
                    ? 'Berikan penilaian untuk kost ini.'
                    : 'Berikan penilaian untuk ${widget.kostName}.',
                style: const TextStyle(
                  color: ThemeApp.textGrey,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              _buildRatingSelector(),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _selectedRating == 0
                      ? 'Pilih rating'
                      : '$_selectedRating dari 5',
                  style: const TextStyle(
                    color: ThemeApp.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Komentar',
                style: TextStyle(
                  color: ThemeApp.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                enabled: !_isSaving,
                minLines: 5,
                maxLines: 7,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  color: ThemeApp.textDark,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Ceritakan pengalamanmu selama tinggal di kost ini',
                  hintStyle: const TextStyle(
                    color: ThemeApp.textGrey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  filled: true,
                  fillColor: ThemeApp.white,
                  border: OutlineInputBorder(
                    borderRadius: ThemeApp.radius(18),
                    borderSide: const BorderSide(color: ThemeApp.borderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ThemeApp.radius(18),
                    borderSide: const BorderSide(color: ThemeApp.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: ThemeApp.radius(18),
                    borderSide: const BorderSide(
                      color: ThemeApp.primaryDark,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeApp.buttonColor,
                    foregroundColor: ThemeApp.white,
                    disabledBackgroundColor: ThemeApp.lightGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: ThemeApp.radius(28),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            color: ThemeApp.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Kirim Ulasan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        backgroundColor: ThemeApp.primaryDark,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: ThemeApp.backgroundGradient,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
