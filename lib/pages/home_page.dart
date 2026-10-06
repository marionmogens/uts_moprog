import 'package:flutter/material.dart';
import '../data/dummy_courts.dart';
import '../data/cart_store.dart';
import '../models/padel_court.dart';
import '../widgets/court_card.dart';
import '../widgets/custom_bottom_nav.dart';
import 'detail_page.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PadelCourt> _courts = getDummyCourts();
  final List<String> _categories = const ['Lapangan', 'Kelas'];

  String _selectedCategory = 'Lapangan';
  int _navIndex = 0;
  String? _toastMessage;
  int _toastToken = 0;

  // Controller + teks pencarian untuk search bar di Home.
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Setiap isi keranjang berubah (di halaman mana pun), Home ikut
    // di-refresh supaya angka badge keranjang selalu sesuai.
    CartStore.onChanged = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  void dispose() {
    CartStore.onChanged = null;
    _searchController.dispose();
    super.dispose();
  }

  // Daftar layanan setelah difilter sesuai kategori yang dipilih
  // (Lapangan / Kelas), memakai field category di PadelCourt.
  // Selain kategori, daftar juga difilter oleh kata kunci pencarian
  // (cocokkan dengan nama atau lokasi, tidak peduli huruf besar/kecil).
  List<PadelCourt> get _filteredCourts {
    final query = _searchQuery.trim().toLowerCase();
    return _courts.where((c) {
      final matchCategory = c.category == _selectedCategory;
      final matchSearch = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.location.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  // Daftar layanan yang sudah ditandai favorit (hati merah), dari kategori mana pun.
  List<PadelCourt> get _favoriteCourts {
    return _courts.where((c) => c.isFavorite).toList();
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
                    backgroundColor: Colors.pink.shade300,
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

  Future<void> _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
    );
    // Refresh badge setelah kembali dari Keranjang, karena isi
    // CartStore mungkin berubah (item dihapus atau jumlahnya diubah)
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade300,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text(
          'PadelBook',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [_buildCartButton()],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _buildTabContent(),
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

  // Isi body sesuai tab bottom nav yang sedang aktif:
  // 0 = Beranda, 1 = Favorit, 2 = Riwayat, 3 = Akun.
  Widget _buildTabContent() {
    if (_navIndex == 1) {
      return _buildFavoritesView();
    }
    if (_navIndex == 2) {
      return _buildComingSoon(
        Icons.history,
        'Riwayat Reservasi',
        'Reservasi yang sudah kamu bayar akan muncul di sini.',
      );
    }
    if (_navIndex == 3) {
      return _buildComingSoon(
        Icons.person_outline,
        'Akun Saya',
        'Pengaturan profil akan hadir di versi berikutnya.',
      );
    }
    return Column(
      children: [
        _buildGreeting(),
        _buildSearchBar(),
        _buildCategoryChips(),
        const SizedBox(height: 4),
        Expanded(child: _buildCourtGrid()),
      ],
    );
  }

  // Tampilan sementara untuk tab yang belum punya halaman sungguhan
  // (sesuai ketentuan UTS: cukup rancangan tampilan).
  Widget _buildComingSoon(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.pink.shade200),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
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
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
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

  Widget _buildGreeting() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Welcome to PadelBook!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 2),
              Text(
                'Silakan pilih layanan yang Anda butuhkan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        )
    );
  }

// Ikon keranjang di AppBar + badge jumlah item. Stack + Positioned
// dipakai supaya badge bisa "menempel" di pojok kanan atas ikon.
// Badge hanya muncul kalau keranjang tidak kosong.
  Widget _buildCartButton() {
    final count = CartStore.totalItemCount;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: _openCart,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              if (count > 0)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Filter kategori (Lapangan/Kelas). Menggunakan Wrap supaya chip
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
            selectedColor: Colors.pink.shade300,
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

  // Menghitung childAspectRatio supaya tinggi sel grid pas dengan isi card.
  // Tinggi card = tinggi gambar (lebar / 1.6, sesuai AspectRatio 16/10)
  // + bagian teks (sekitar 92 px). Dengan begini tidak ada ruang kosong
  // di bawah card, berapa pun lebar layarnya.
  double _cardAspectRatio(double gridWidth, int columns) {
    const sidePadding = 16.0 * 2; // padding kiri-kanan grid
    const spacing = 12.0; // jarak antar kolom
    final cellWidth = (gridWidth - sidePadding - spacing * (columns - 1)) / columns;
    final cellHeight = cellWidth / 1.6 + 92;
    return cellWidth / cellHeight;
  }

  // Grid responsif: LayoutBuilder dipakai untuk menentukan jumlah kolom
  // berdasarkan lebar layar yang TERSEDIA (bukan lebar layar penuh),
  // jadi tetap akurat walau dipakai di dalam layout lain.
  Widget _buildCourtGrid() {
    final courts = _filteredCourts;
    if (courts.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.trim().isEmpty
              ? 'Belum ada lapangan untuk kategori ini'
              : 'Tidak ada hasil untuk "${_searchQuery.trim()}"',
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
            childAspectRatio: _cardAspectRatio(constraints.maxWidth, crossAxisCount),
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

  // Tampilan tab Favorit: grid 2 kolom supaya kartunya tidak terlalu
  // melebar. Memakai CourtCard yang sama dengan Home, jadi gesture-nya
  // (tap, double tap, long press, ikon hati) tetap bekerja.
  Widget _buildFavoritesView() {
    final favorites = _favoriteCourts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'My Favorites',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Expanded(
          child: favorites.isEmpty
              ? _buildEmptyFavorites()
              : LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: _cardAspectRatio(constraints.maxWidth, 2),
                ),
                itemBuilder: (context, index) {
                  final court = favorites[index];
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
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('Belum ada favorit',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(
              'Ketuk ikon hati atau ketuk dua kali pada layanan untuk menyimpannya di favorit',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
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