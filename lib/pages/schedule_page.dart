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
  final List<String> addons;
  final String note;
  final int pricePerSession;

  const SchedulePage({
    super.key,
    required this.court,
    required this.duration,
    required this.addons,
    required this.note,
    required this.pricePerSession,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String _selectedField = fieldOptions.first;
  DateTime? _selectedDate;
  int? _selectedSlotIndex;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      helpText: 'Pilih Tanggal Reservasi',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // reset slot yang sudah dipilih kalau ganti tanggal, supaya
        // tidak salah asumsi jam yang sama otomatis tersedia lagi.
        _selectedSlotIndex = null;
      });
    }
  }

  void _addToCart() {
    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      court: widget.court,
      fieldName: _selectedField,
      date: _selectedDate!,
      timeSlot:
      '${timeSlots[_selectedSlotIndex!]} - ${_nextHour(timeSlots[_selectedSlotIndex!])}',
      duration: widget.duration,
      addons: widget.addons,
      note: widget.note,
      pricePerUnit: widget.pricePerSession,
    );
    CartStore.add(cartItem);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
    );
  }

  String _nextHour(String hour) {
    final h = int.parse(hour.split(':')[0]) + 1;
    return '${h.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    // tombol "Lanjut" hanya aktif kalau tanggal DAN slot sudah dipilih
    final bool canContinue = _selectedDate != null && _selectedSlotIndex != null;

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
                '${widget.duration} • ${formatRupiah(widget.pricePerSession)}',
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
                        onTap: () => setState(() => _selectedField = field),
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
              child: Text(
                canContinue
                    ? 'Lanjut ke Keranjang'
                    : 'Pilih tanggal & jam dulu',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendDot(Colors.white, 'Tersedia', bordered: true),
        const SizedBox(width: 14),
        _legendDot(Colors.pink.shade300, 'Dipilih'),
        const SizedBox(width: 14),
        _legendDot(Colors.grey.shade300, 'Penuh'),
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(timeSlots.length, (index) {
        final isBooked = bookedSlotIndexes.contains(index);
        final isSelected = _selectedSlotIndex == index;

        Color backgroundColor;
        Color textColor;
        Color borderColor;
        if (isBooked) {
          backgroundColor = Colors.grey.shade200;
          textColor = Colors.grey.shade500;
          borderColor = Colors.grey.shade200;
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
          onTap: isBooked
              ? null // slot penuh tidak bisa ditekan sama sekali
              : () => setState(() => _selectedSlotIndex = index),
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