import 'package:flutter/material.dart';
import '../data/cart_store.dart';
import '../models/cart_item.dart';
import '../utils/formatters.dart';
import 'summary_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Getter yang pakai fold -- sama konsepnya dengan totalPrice di
  // aplikasi Shopping Cart sebelumnya, hanya sumber datanya sekarang
  // dari CartStore (shared antar halaman), bukan List lokal di State.
  int get _totalPrice =>
      CartStore.items.fold(0, (sum, item) => sum + item.totalPrice);

  int get _totalItems =>
      CartStore.items.fold(0, (sum, item) => sum + item.quantity);

  void _incrementQuantity(CartItem item) {
    setState(() => item.quantity++);
  }

  void _decrementQuantity(CartItem item) {
    setState(() {
      if (item.quantity > 1) item.quantity--;
    });
  }

  void _confirmRemove(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Hapus Item'),
        content: Text(
          'Hapus reservasi ${CartStore.items[index].court.name} dari keranjang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() => CartStore.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = CartStore.items;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade300,
        title: const Text('Keranjang',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: items.isEmpty ? _buildEmptyState() : _buildCartList(items),
      ),
      bottomNavigationBar: SafeArea(top: false, child: _buildCheckoutBar()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text('Keranjang masih kosong',
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildCartList(List<CartItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildCartCard(items[index], index),
    );
  }

  Widget _buildCartCard(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.court.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      '${item.fieldName} • ${formatDate(item.date)}',
                      style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    Text(
                      '${item.timeSlot} • ${item.duration}',
                      style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    if (item.addons.isNotEmpty)
                      Text(
                        'Add-on: ${item.addons.join(', ')}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _confirmRemove(index),
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatRupiah(item.totalPrice),
                style: TextStyle(
                  color: Colors.pink.shade300,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              _buildStepper(item),
            ],
          ),
        ],
      ),
    );
  }

  // Stepper +/- jumlah, pola sama persis dengan aplikasi Shopping Cart
  // sebelumnya (dipisah jadi widget kecil biar tidak duplikasi tombol -/+).
  Widget _buildStepper(CartItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepperButton(
          icon: Icons.remove,
          background: Colors.grey.shade200,
          iconColor: Colors.black87,
          onTap: () => _decrementQuantity(item),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '${item.quantity}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        _stepperButton(
          icon: Icons.add,
          background: Colors.pink.shade300,
          iconColor: Colors.white,
          onTap: () => _incrementQuantity(item),
        ),
      ],
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required Color background,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: iconColor),
      ),
    );
  }

  Widget _buildCheckoutBar() {
    final hasItems = CartStore.items.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total ($_totalItems item)',
                    style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                Text(
                  formatRupiah(_totalPrice),
                  style: TextStyle(
                    color: Colors.pink.shade300,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: hasItems
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SummaryPage()),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade300,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}