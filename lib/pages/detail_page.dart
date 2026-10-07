import 'package:flutter/material.dart';
import '../data/booking_options.dart';
import '../models/cart_item.dart';
import '../models/padel_court.dart';
import '../utils/formatters.dart';
import '../widgets/facility_chip.dart';
import '../widgets/selectable_option.dart';
import 'schedule_page.dart';

class DetailPage extends StatefulWidget {
  final PadelCourt court;
  // Diisi kalau halaman ini dibuka lewat tombol "Edit" di Keranjang.
  // Pilihan durasi, add-on, dan catatan akan terisi dari reservasi tsb.
  final CartItem? editItem;
  const DetailPage({super.key, required this.court, this.editItem});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // index durasi terpilih (default: durasi pertama, 1 Jam)
  int _selectedDurationIndex = 0;

  // nama add-on yang sedang dipilih (bisa lebih dari satu)
  final Set<String> _selectedAddons = {};

  final TextEditingController _noteController = TextEditingController();

  // Jumlah add-on dari reservasi yang sedang diedit (supaya jumlahnya
  // tidak kembali ke 1 saat pengguna hanya ingin menambah add-on lain).
  final Map<String, int> _addonQuantities = {};

  @override
  void initState() {
    super.initState();
    final item = widget.editItem;
    if (item != null) {
      final durationIndex =
      durationOptions.indexWhere((d) => d.label == item.duration);
      if (durationIndex != -1) {
        _selectedDurationIndex = durationIndex;
      }
      for (final addon in item.addons) {
        _selectedAddons.add(addon.name);
        _addonQuantities[addon.name] = addon.quantity;
      }
      _noteController.text = item.note;
    }
    // Kelas selalu 2 jam, jadi durasinya tidak dipilih pengguna.
    if (widget.court.category == 'Kelas') {
      final twoHours = durationOptions.indexWhere((d) => d.label == '2 Jam');
      if (twoHours != -1) _selectedDurationIndex = twoHours;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      widget.court.isFavorite = !widget.court.isFavorite;
    });
  }

  void _onImageLongPress() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            widget.court.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Icon(Icons.sports_tennis,
                  color: Colors.grey, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  // Getter _addons
  List<AddonOption> get _addons => addonsFor(widget.court.category);

  // Total harga dihitung ulang setiap build() dipanggil -> karena
  // dipanggil dari dalam setState (lewat pilih durasi/add-on), hasilnya
  // selalu "realtime" mengikuti state terbaru tanpa perlu logic tambahan.
  int get _totalPrice {
    final duration = durationOptions[_selectedDurationIndex];
    final base = (widget.court.pricePerHour * duration.multiplier).round();
    final addonsPrice = _addons
        .where((addon) => _selectedAddons.contains(addon.name))
        .fold(0, (sum, addon) => sum + addon.price * (_addonQuantities[addon.name] ?? 1));
    return base + addonsPrice;
  }

  // Harga sewa lapangan saja (tanpa add-on) untuk durasi yang dipilih.
  int get _courtPrice {
    final duration = durationOptions[_selectedDurationIndex];
    return (widget.court.pricePerHour * duration.multiplier).round();
  }

  void _goToSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchedulePage(
          court: widget.court,
          duration: durationOptions[_selectedDurationIndex].label,
          durationHours: durationOptions[_selectedDurationIndex].hours,
          addons: _addons
              .where((addon) => _selectedAddons.contains(addon.name))
              .map((addon) => CartAddon(
            name: addon.name,
            price: addon.price,
            quantity: _addonQuantities[addon.name] ?? 1,
          ))
              .toList(),
          note: _noteController.text.trim(),
          courtPrice: _courtPrice,
          editItem: widget.editItem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final court = widget.court;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade300,
        title: Text(widget.editItem == null ? court.name : 'Edit: ${court.name}',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              court.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: court.isFavorite ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(court),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo(court),
                    const Divider(height: 28),
                    const _SectionTitle('Tentang Lapangan'),
                    const SizedBox(height: 6),
                    Text(
                      court.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle('Fasilitas'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: court.facilities
                          .map((facility) => FacilityChip(label: facility))
                          .toList(),
                    ),
                    if (widget.court.category != 'Kelas') ...[
                      const SizedBox(height: 20),
                      const _SectionTitle('Pilih Durasi'),
                      const SizedBox(height: 10),
                      _buildDurationPicker(),
                    ],
                    const SizedBox(height: 20),
                    const _SectionTitle('Tambahan (Opsional)'),
                    if (widget.court.category == 'Kelas') ...[
                      const SizedBox(height: 4),
                      Text(
                        'Sudah termasuk pelatih, raket dan bola untuk 2 orang. '
                            'Silakan menambah raket atau bola apabila diperlukan.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                    const SizedBox(height: 10),
                    _buildAddonPicker(),
                    const SizedBox(height: 20),
                    const _SectionTitle('Catatan untuk Penyedia'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Contoh: tolong siapkan net cadangan',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(top: false, child: _buildBottomBar(court)),
    );
  }

  Widget _buildImage(PadelCourt court) {
    // Stack: gambar lapangan + label status ("Tersedia"/"Penuh") di atasnya
    return GestureDetector(
      onDoubleTap: _toggleFavorite,
      onLongPress: _onImageLongPress,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              court.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Icon(Icons.sports_tennis,
                    color: Colors.grey, size: 48),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: court.isAvailable ? Colors.green : Colors.redAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                court.isAvailable ? 'Tersedia' : 'Penuh',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(PadelCourt court) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          court.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                court.location,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.orange),
            const SizedBox(width: 4),
            Text('${court.rating}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Text('(${court.reviewCount} ulasan)',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              court.category == 'Kelas'
                  ? '${formatRupiah(court.pricePerHour)}/jam • Durasi 2 jam per sesi'
                  : '${formatRupiah(court.pricePerHour)}/jam',
              style: TextStyle(
                color: Colors.pink.shade300,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              court.isIndoor ? Icons.home_work_outlined : Icons.park_outlined,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              court.isIndoor ? 'Indoor' : 'Outdoor',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // Pilihan durasi dalam bentuk Row dari SelectableOption. Pakai
  // Expanded supaya ketiga pilihan melebar rata, bukan lebar seadanya.
  Widget _buildDurationPicker() {
    return Row(
      children: List.generate(durationOptions.length, (index) {
        final option = durationOptions[index];
        final isSelected = _selectedDurationIndex == index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == durationOptions.length - 1 ? 0 : 8,
            ),
            child: SelectableOption(
              selected: isSelected,
              onTap: () => setState(() => _selectedDurationIndex = index),
              child: Text(
                option.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isSelected ? Colors.pink.shade300 : Colors.black87,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Pilihan add-on: multi-select, pakai Wrap supaya tidak overflow
  // kalau layar sempit atau nama add-on panjang.
  Widget _buildAddonPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _addons.map((addon) {
        final isSelected = _selectedAddons.contains(addon.name);
        return SelectableOption(
          selected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAddons.remove(addon.name);
              } else {
                _selectedAddons.add(addon.name);
              }
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.add_circle_outline,
                size: 16,
                color: isSelected ? Colors.pink.shade300 : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                '${addon.name} (+${formatRupiah(addon.price)})',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(PadelCourt court) {
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
                Text('Total',
                    style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                // _totalPrice recomputed tiap build -> langsung berubah
                // begitu user pilih durasi/add-on berbeda (realtime).
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
            onPressed: court.isAvailable ? _goToSchedule : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade300,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(court.isAvailable ? 'Pilih Jadwal' : 'Tidak Tersedia'),
          ),
        ],
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