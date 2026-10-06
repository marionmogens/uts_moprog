import 'package:flutter/material.dart';
import '../data/booking_options.dart';
import '../data/cart_store.dart';
import '../models/cart_item.dart';
import '../models/padel_court.dart';
import '../utils/formatters.dart';
import 'cart_page.dart';

class SchedulePage extends StatefulWidget {
  final PadelCourt court;
  final String duration;
  final int durationHours; // jumlah slot 1 jam yang WAJIB dipilih
  final List<CartAddon> addons; // add-on terpilih (jumlah awal 1)
  final String note;
  final int courtPrice; // harga sewa lapangan untuk durasi ini
  // Diisi kalau sedang mengedit reservasi di Keranjang (bukan menambah baru).
  final CartItem? editItem;

  const SchedulePage({
    super.key,
    required this.court,
    required this.duration,
    required this.durationHours,
    required this.addons,
    required this.note,
    required this.courtPrice,
    this.editItem,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String _selectedField = fieldOptions.first;
  DateTime? _selectedDate;
  // Slot yang dipilih (bisa lebih dari satu, jumlahnya harus sama
  // dengan durationHours supaya reservasi valid).
  final Set<int> _selectedSlotIndexes = {};

  @override
  void initState() {
    super.initState();
    final item = widget.editItem;
    if (item != null) {
      // Mode edit: isi awal dari reservasi lama.
      _selectedField = item.fieldName;
      _selectedDate = item.date;
      // Slot lama hanya dipakai kalau jumlahnya masih cocok dengan durasi
      // baru (kalau durasi diganti, pengguna memilih jam lagi).
      if (item.slotIndexes.length == widget.durationHours) {
        _selectedSlotIndexes.addAll(item.slotIndexes);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      helpText: 'Pilih Tanggal Reservasi',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // reset slot yang sudah dipilih kalau ganti tanggal, supaya
        // tidak salah asumsi jam yang sama otomatis tersedia lagi.
        _selectedSlotIndexes.clear();
      });
    }
  }

  void _addToCart() {
    final sorted = _selectedSlotIndexes.toList();
    sorted.sort();
    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      court: widget.court,
      fieldName: _selectedField,
      date: _selectedDate!,
      timeSlot: _formatSlots(sorted),
      slotIndexes: sorted,
      duration: widget.duration,
      // salinan baru, supaya jumlah add-on tiap reservasi berdiri sendiri
      addons: widget.addons.map((a) => a.copy()).toList(),
      note: widget.note,
      courtPrice: widget.courtPrice,
    );
    final editItem = widget.editItem;
    if (editItem == null) {
      CartStore.add(cartItem);
    } else {
      // Mode edit: ganti reservasi lama dengan yang baru (posisi tetap).
      final index = CartStore.items.indexOf(editItem);
      if (index == -1) {
        CartStore.add(cartItem);
      } else {
        CartStore.items[index] = cartItem;
      }
    }

    // Ganti semua halaman di atas Home dengan Keranjang, supaya tombol
    // back dari Keranjang kembali ke Home (bukan ke Jadwal) dan Keranjang
    // selalu tampil dengan data terbaru.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
          (route) => route.isFirst,
    );
  }

  // Harga sesi = sewa lapangan + add-on terpilih (untuk ditampilkan di header).
  int get _sessionPrice =>
      widget.courtPrice +
          widget.addons.fold(0, (sum, a) => sum + a.subtotal);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Slot yang SUDAH ada di keranjang untuk venue + lapangan + tanggal
  // yang sedang dipilih. Slot ini tidak boleh dipesan lagi.
  Set<int> get _slotsInCart {
    final result = <int>{};
    if (_selectedDate == null) return result;
    for (final item in CartStore.items) {
      // slot milik reservasi yang sedang diedit tidak ikut dikunci
      if (item == widget.editItem) continue;
      final sameCourt = item.court.id == widget.court.id;
      final sameField = item.fieldName == _selectedField;
      if (sameCourt && sameField && _isSameDay(item.date, _selectedDate!)) {
        result.addAll(item.slotIndexes);
      }
    }
    return result;
  }

  // Pilih / lepas slot jam. Slot yang dipilih HARUS berurutan.
  // - Ketuk slot yang sudah dipilih: slot itu dilepas.
  // - Ketuk slot baru saat belum ada pilihan: langsung dipilih.
  // - Ketuk slot baru yang menempel di ujung pilihan (jam sebelum atau
  //   sesudahnya) dan jumlahnya masih kurang: ditambahkan.
  // - Selain itu (tidak menempel, atau jumlah sudah pas): pilihan lama
  //   diganti, mulai lagi dari slot yang baru diketuk.
  // Slot penuh tidak bisa diketuk, jadi pilihan tidak mungkin melewati slot penuh.
  void _toggleSlot(int index) {
    if (_selectedSlotIndexes.contains(index)) {
      setState(() => _selectedSlotIndexes.remove(index));
      return;
    }

    if (_selectedSlotIndexes.isEmpty) {
      setState(() => _selectedSlotIndexes.add(index));
      return;
    }

    final sorted = _selectedSlotIndexes.toList();
    sorted.sort();
    final isNextToSelection =
        index == sorted.first - 1 || index == sorted.last + 1;

    setState(() {
      if (isNextToSelection &&
          _selectedSlotIndexes.length < widget.durationHours) {
        _selectedSlotIndexes.add(index);
      } else {
        _selectedSlotIndexes.clear();
        _selectedSlotIndexes.add(index);
      }
    });
  }

  // Mengubah daftar index slot (sudah terurut) jadi teks jam.
  // Jam yang berurutan digabung: 18:00 + 19:00 jadi "18:00 - 20:00".
  String _formatSlots(List<int> sorted) {
    final parts = <String>[];
    int start = sorted.first;
    int prev = sorted.first;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == prev + 1) {
        prev = sorted[i];
      } else {
        parts.add('${timeSlots[start]} - ${_nextHour(timeSlots[prev])}');
        start = sorted[i];
        prev = sorted[i];
      }
    }
    parts.add('${timeSlots[start]} - ${_nextHour(timeSlots[prev])}');
    return parts.join(', ');
  }

  String get _buttonLabel {
    if (_selectedDate == null) return 'Pilih tanggal dulu';
    if (_selectedSlotIndexes.length < widget.durationHours) {
      return 'Pilih ${widget.durationHours} jam berurutan '
          '(${_selectedSlotIndexes.length}/${widget.durationHours})';
    }
    return widget.editItem == null ? 'Lanjut ke Keranjang' : 'Simpan Perubahan';
  }

  String _nextHour(String hour) {
    final h = int.parse(hour.split(':')[0]) + 1;
    return '${h.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    // tombol "Lanjut" hanya aktif kalau tanggal DAN slot sudah dipilih
    final bool canContinue = _selectedDate != null &&
        _selectedSlotIndexes.length == widget.durationHours;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade300,
        title: const Text('Pilih Jadwal',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.court.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                '${widget.duration} • ${formatRupiah(_sessionPrice)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 20),

              const _SectionTitle('Pilih Lapangan'),
              const SizedBox(height: 10),
              Row(
                children: fieldOptions.map((field) {
                  final isSelected = field == _selectedField;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: field == fieldOptions.last ? 0 : 8,
                      ),
                      child: InkWell(
                        onTap: () => setState(() {
                          _selectedField = field;
                          // slot yang sudah di keranjang beda tiap lapangan,
                          // jadi pilihan lama dikosongkan.
                          _selectedSlotIndexes.clear();
                        }),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.pink.shade300
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.pink.shade300
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            field,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              const _SectionTitle('Pilih Tanggal'),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 18, color: Colors.pink.shade300),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDate == null
                            ? 'Ketuk untuk memilih tanggal'
                            : formatDate(_selectedDate!),
                        style: TextStyle(
                          fontSize: 13,
                          color: _selectedDate == null
                              ? Colors.grey.shade500
                              : Colors.black87,
                          fontWeight: _selectedDate == null
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const _SectionTitle('Pilih Jam'),
              const SizedBox(height: 6),
              Text(
                'Wajib pilih ${widget.durationHours} jam berurutan (1 jam per slot) • '
                    'dipilih ${_selectedSlotIndexes.length}/${widget.durationHours}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              _buildLegend(),
              const SizedBox(height: 10),
              _buildTimeSlotGrid(),
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
              // "if" di sini yang nentuin tombol aktif/nonaktif:
              // kalau canContinue false, onPressed diisi null (disabled).
              onPressed: canContinue ? _addToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade300,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(_buttonLabel),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        _legendDot(Colors.white, 'Tersedia', bordered: true),
        _legendDot(Colors.pink.shade300, 'Dipilih'),
        _legendDot(Colors.grey.shade300, 'Penuh'),
        _legendDot(Colors.pink.shade100, 'Di keranjang'),
      ],
    );
  }

  Widget _legendDot(Color color, String label, {bool bordered = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: bordered ? Border.all(color: Colors.grey.shade400) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  // Grid slot jam: disusun manual pakai Wrap + "for" (lewat List.generate)
  // supaya tiap slot bisa dikasih warna berbeda sesuai 3 status:
  // tersedia (putih+border), dipilih (teal), penuh (abu+label "Penuh").
  Widget _buildTimeSlotGrid() {
    final slotsInCart = _slotsInCart;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(timeSlots.length, (index) {
        final isBooked = bookedSlotIndexes.contains(index);
        final isInCart = slotsInCart.contains(index);
        final isSelected = _selectedSlotIndexes.contains(index);

        Color backgroundColor;
        Color textColor;
        Color borderColor;
        if (isBooked) {
          backgroundColor = Colors.grey.shade200;
          textColor = Colors.grey.shade500;
          borderColor = Colors.grey.shade200;
        } else if (isInCart) {
          backgroundColor = Colors.pink.shade50;
          textColor = Colors.pink.shade200;
          borderColor = Colors.pink.shade100;
        } else if (isSelected) {
          backgroundColor = Colors.pink.shade300;
          textColor = Colors.white;
          borderColor = Colors.pink.shade300;
        } else {
          backgroundColor = Colors.white;
          textColor = Colors.black87;
          borderColor = Colors.grey.shade300;
        }

        return InkWell(
          onTap: (isBooked || isInCart)
              ? null // slot penuh / sudah di keranjang tidak bisa ditekan
              : () => _toggleSlot(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            // Stack dipakai supaya label "Penuh" bisa ditempel
            // sebagai badge kecil di atas teks jam, tanpa widget
            // tambahan di luar area slot ini.
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Text(
                  timeSlots[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (isBooked)
                  Positioned(
                    top: -16,
                    child: Text(
                      'Penuh',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isInCart)
                  Positioned(
                    top: -16,
                    child: Text(
                      'Di keranjang',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.pink.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
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