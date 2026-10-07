import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../utils/formatters.dart';

class ConfirmationPage extends StatelessWidget {
  final String customerName;
  final int totalPaid;
  final String methodName;
  final String bookingCode; // dibuat di PaymentPage, jadi tidak berubah-ubah
  final List<CartItem> items; // salinan isi keranjang saat pembayaran

  const ConfirmationPage({
    super.key,
    required this.customerName,
    required this.totalPaid,
    required this.methodName,
    required this.bookingCode,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        // Center + SingleChildScrollView: tetap di tengah kalau isinya
        // sedikit, dan bisa di-scroll kalau reservasinya banyak.
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  'Terima kasih, $customerName. Reservasi lapangan padel Anda '
                      'sudah diterima.',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Kode Booking',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600)),
                            const SizedBox(height: 4),
                            Text(
                              bookingCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.5,
                                color: Colors.pink.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24),
                      const Text('Rincian Reservasi',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 10),
                      for (final item in items) ...[
                        Text(
                          item.court.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        Text(
                          '${item.fieldName} • ${formatDate(item.date)}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                        Text(
                          '${item.timeSlot} • ${item.duration}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                        if (item.addons.isNotEmpty)
                          Text(
                            'Add-on: ${item.addonsText}',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600),
                          ),
                        if (item.note.isNotEmpty)
                          Text(
                            'Catatan: ${item.note}',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600),
                          ),
                        if (item != items.last) const Divider(height: 18),
                      ],
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
                      backgroundColor: Colors.pink.shade300,
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
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}