import 'package:flutter/material.dart';
import '../data/cart_store.dart';
import '../models/cart_item.dart';
import '../utils/formatters.dart';
import 'detail_page.dart';
import 'summary_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Getter yang pakai fold -- sama konsepnya dengan totalPrice di
  // aplikasi Shopping Cart sebelumnya. totalPrice tiap item sudah
  // menghitung sewa lapangan + semua add-on beserta jumlahnya.
  int get _totalPrice =>
      CartStore.items.fold(0, (sum, item) => sum + item.totalPrice);

  int get _totalItems => CartStore.items.length;

  // Tambah jumlah add-on (+).
  void _incrementAddon(CartAddon addon) {
    setState(() => addon.quantity++);
  }

  // Kurangi jumlah add-on (-). Kalau tinggal 1, add-on dihapus dari item.
  void _decrementAddon(CartItem item, CartAddon addon) {
    setState(() {
      if (addon.quantity > 1) {
        addon.quantity--;
      } else {
        item.addons.remove(addon);
      }
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
          // ---------- Info reservasi + tombol hapus ----------
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
          const Divider(height: 20),

          // ---------- Sewa lapangan (tanpa + / -, selalu 1) ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sewa lapangan', style: TextStyle(fontSize: 12)),
              Text(formatRupiah(item.courtPrice),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),

          // ---------- Subcart tambahan (hanya muncul kalau ada add-on) ----------
          if (item.addons.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tambahan',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade300)),
                  for (final addon in item.addons)
                    _buildAddonRow(item, addon),
                ],
              ),
            ),
          ],

          // ---------- Catatan untuk penyedia (ketuk untuk tambah / ubah) ----------
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _editNote(item),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Catatan untuk penyedia',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700)),
                        const SizedBox(height: 2),
                        Text(
                          item.note.isEmpty
                              ? 'Ketuk untuk menambah catatan'
                              : item.note,
                          style: TextStyle(
                            fontSize: 12,
                            color: item.note.isEmpty
                                ? Colors.grey.shade500
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined,
                      size: 14, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),

          const Divider(height: 24),

          // ---------- Total item + tombol tambah jadwal ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total reservasi',
                      style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  Text(
                    formatRupiah(item.totalPrice),
                    style: TextStyle(
                      color: Colors.pink.shade300,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEditButton(item),
                  const SizedBox(width: 8),
                  _buildAddScheduleButton(item),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog untuk menambah / mengubah catatan untuk penyedia.
  void _editNote(CartItem item) {
    final controller = TextEditingController(text: item.note);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Catatan untuk Penyedia'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Contoh: tolong siapkan net cadangan',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() => item.note = controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Satu baris add-on di subcart: nama, harga x jumlah, dan stepper + / -.
  Widget _buildAddonRow(CartItem item, CartAddon addon) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(addon.name,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                Text(
                  '${formatRupiah(addon.price)} x ${addon.quantity} = '
                      '${formatRupiah(addon.subtotal)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          _buildStepper(
            quantity: addon.quantity,
            onMinus: () => _decrementAddon(item, addon),
            onPlus: () => _incrementAddon(addon),
          ),
        ],
      ),
    );
  }

  // Stepper +/- jumlah, pola sama dengan aplikasi Shopping Cart sebelumnya.
  // Kalau jumlah tinggal 1, ikon "-" berubah jadi tong sampah (hapus add-on).
  Widget _buildStepper({
    required int quantity,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepperButton(
          icon: quantity == 1 ? Icons.delete_outline : Icons.remove,
          background: Colors.white,
          iconColor: quantity == 1 ? Colors.redAccent : Colors.black87,
          onTap: onMinus,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        _stepperButton(
          icon: Icons.add,
          background: Colors.pink.shade300,
          iconColor: Colors.white,
          onTap: onPlus,
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

  // Tombol "Edit": membuka Detail dalam mode edit (durasi, add-on, catatan
  // sudah terisi), lalu lanjut ke Jadwal untuk mengganti tanggal / jam.
  // Reservasi baru menggantikan yang lama setelah "Simpan Perubahan".
  Widget _buildEditButton(CartItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailPage(court: item.court, editItem: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 14, color: Colors.pink.shade300),
            const SizedBox(width: 4),
            Text(
              'Edit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.pink.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tombol "Tambah jadwal": membuka halaman Detail dari lapangan yang sama,
  // jadi pengguna bisa memilih ulang durasi, add-on, dan catatan, lalu
  // lanjut Pilih Jadwal. Satu slot jam tidak boleh dipesan dua kali, jadi
  // slot yang sudah di keranjang otomatis terkunci di halaman Jadwal.
  Widget _buildAddScheduleButton(CartItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(court: item.court),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.pink.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: Colors.pink.shade300),
            const SizedBox(width: 4),
            Text(
              'Tambah jadwal',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.pink.shade300,
              ),
            ),
          ],
        ),
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
                Text('Total ($_totalItems reservasi)',
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