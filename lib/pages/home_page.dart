import 'package:flutter/material.dart';
import '../data/dummy_courts.dart';
import '../models/padel_court.dart';
import '../widgets/court_card.dart';
import '../widgets/custom_bottom_nav.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PadelCourt> _courts = getDummyCourts();
  final List<String> _categories = const ['Semua', 'Indoor', 'Outdoor'];

  String _selectedCategory = 'Semua';
  int _navIndex = 0;
  String? _toastMessage;
  int _toastToken = 0;

  // Daftar lapangan setelah difilter sesuai kategori yang dipilih.
  List<PadelCourt> get _filteredCourts {
    if (_selectedCategory == 'Semua') return _courts;
    final wantIndoor = _selectedCategory == 'Indoor';
    return _courts.where((c) => c.isIndoor == wantIndoor).toList();
  }

  void _toggleFavorite(PadelCourt court) {
    setState(() {
      court.isFavorite = !court.isFavorite;
    });
    _showToast(
      court.isFavorite
          ? '${court.name} ditambahkan ke favorit'
          : '${court.name} dihapus dari favorit',
    );
  }

  // Notifikasi kecil di atas layar, dipicu dari double tap.
  // Pola token sama seperti di aplikasi sebelumnya, supaya pesan
  // tidak saling tertutup ketika beberapa card di-double tap beruntun.
  void _showToast(String message) {
    setState(() => _toastMessage = message);
    final myToken = ++_toastToken;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && myToken == _toastToken) {
        setState(() => _toastMessage = null);
      }
    });
  }

  // Dipicu dari long press: preview cepat lapangan tanpa pindah halaman dulu.
  void _showQuickPreview(PadelCourt court) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                court.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                court.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _openDetail(court);
                  },
                  child: const Text('Lihat Detail'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openDetail(PadelCourt court) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(court: court)),
    );
    // Refresh setelah kembali dari Detail, siapa tahu status
    // favorite-nya diubah dari sana (object yang sama, isFavorite mutable).
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Padel Point',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Temukan & reservasi lapangan terdekat',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSearchBar(),
                _buildCategoryChips(),
                const SizedBox(height: 4),
                Expanded(child: _buildCourtGrid()),
              ],
            ),
            if (_toastMessage != null)
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: _ToastBanner(message: _toastMessage!),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNav(
          currentIndex: _navIndex,
          onTap: (index) => setState(() => _navIndex = index),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari nama lapangan atau lokasi...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter kategori (Semua/Indoor/Outdoor). Menggunakan Wrap supaya chip
  // tidak overflow kalau daftar kategori bertambah atau layar sempit.
  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: _categories.map((category) {
          final isSelected = category == _selectedCategory;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            selectedColor: Colors.teal.shade700,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 12,
            ),
            onSelected: (_) => setState(() => _selectedCategory = category),
          );
        }).toList(),
      ),
    );
  }

  // Grid responsif: LayoutBuilder dipakai untuk menentukan jumlah kolom
  // berdasarkan lebar layar yang TERSEDIA (bukan lebar layar penuh),
  // jadi tetap akurat walau dipakai di dalam layout lain.
  Widget _buildCourtGrid() {
    final courts = _filteredCourts;
    if (courts.isEmpty) {
      return Center(
        child: Text(
          'Belum ada lapangan untuk kategori ini',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= 900) {
          crossAxisCount = 3; // desktop/tablet lanskap
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2; // tablet
        } else {
          crossAxisCount = 1; // mobile
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 1 ? 2.6 : 0.72,
          ),
          itemBuilder: (context, index) {
            final court = courts[index];
            return CourtCard(
              court: court,
              onTap: () => _openDetail(court),
              onDoubleTap: () => _toggleFavorite(court),
              onLongPress: () => _showQuickPreview(court),
              onToggleFavorite: () => _toggleFavorite(court),
            );
          },
        );
      },
    );
  }
}

class _ToastBanner extends StatelessWidget {
  final String message;
  const _ToastBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}