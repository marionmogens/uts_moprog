import 'package:flutter/material.dart';
import '../data/booking_options.dart';
import '../data/cart_store.dart';
import '../utils/formatters.dart';
import '../widgets/selectable_option.dart';
import 'confirmation_page.dart';

class PaymentPage extends StatefulWidget {
  final String customerName;
  final String customerPhone;

  const PaymentPage({
    super.key,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int? _selectedMethodIndex;

  void _confirmPayment() {
    final method = paymentMethods[_selectedMethodIndex!];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Konfirmasi Pembayaran'),
        content: Text(
          'Bayar ${formatRupiah(CartStore.totalPrice)} menggunakan '
              '${method.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog dulu
              final total = CartStore.totalPrice;
              // Salin isi keranjang DULU sebelum dikosongkan, supaya
              // halaman Konfirmasi masih bisa menampilkan rinciannya.
              final paidItems = [...CartStore.items];
              // Kode booking dibuat sekali di sini lalu dikirim ke
              // Konfirmasi, jadi nilainya tidak berubah-ubah.
              final bookingCode =
                  'PDL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
              CartStore.clear(); // "pembayaran berhasil" -> keranjang dikosongkan
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmationPage(
                    customerName: widget.customerName,
                    totalPaid: total,
                    methodName: method.name,
                    bookingCode: bookingCode,
                    items: paidItems,
                  ),
                ),
                    (route) => route.isFirst, // bersihkan stack sampai Home saja
              );
            },
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade300,
        title: const Text('Pembayaran',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Pembayaran',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      formatRupiah(CartStore.totalPrice),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'a.n. ${widget.customerName} • ${widget.customerPhone}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Pilih Metode Pembayaran'),
              const SizedBox(height: 12),
              // 3 card metode pembayaran, masing-masing SelectableOption
              // (Container+InkWell) dengan border pink saat terpilih.
              ...List.generate(paymentMethods.length, (index) {
                final method = paymentMethods[index];
                final isSelected = _selectedMethodIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SelectableOption(
                    selected: isSelected,
                    onTap: () => setState(() => _selectedMethodIndex = index),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(method.icon,
                            color: isSelected
                                ? Colors.pink.shade300
                                : Colors.grey.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(method.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              Text(
                                method.subtitle,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: Colors.pink.shade300, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMethodIndex != null ? _confirmPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade300,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Bayar Sekarang'),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }
}