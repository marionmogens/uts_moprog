import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class ConfirmationPage extends StatelessWidget {
  final String customerName;
  final int totalPaid;
  final String methodName;

  const ConfirmationPage({
    super.key,
    required this.customerName,
    required this.totalPaid,
    required this.methodName,
  });

  // Kode booking dummy: gabungan prefix tetap + waktu saat ini.
  // Cukup untuk kebutuhan UI mockup, tidak perlu backend sungguhan
  // untuk menjamin keunikan beneran.
  String get _bookingCode {
    final now = DateTime.now();
    final code = now.millisecondsSinceEpoch.toString().substring(7);
    return 'PDL-$code';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: Colors.green.shade600, size: 72),
              ),
              const SizedBox(height: 20),
              const Text(
                'Reservasi Berhasil!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Terima kasih, $customerName. Reservasi lapangan padel kamu '
                    'sudah kami terima.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text('Kode Booking',
                        style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text(
                      _bookingCode,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.5,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const Divider(height: 24),
                    _detailRow('Total Dibayar', formatRupiah(totalPaid)),
                    const SizedBox(height: 6),
                    _detailRow('Metode Pembayaran', methodName),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Kembali ke Home, bersihkan seluruh stack navigasi
                    // supaya tombol back tidak balik lagi ke halaman bayar.
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}