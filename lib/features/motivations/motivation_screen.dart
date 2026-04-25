import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/motivation_provider.dart';
import '../../core/theme/theme_notifier.dart';

class MotivationScreen extends StatefulWidget {
  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final provider = context.read<MotivationProvider>();
    provider.fetchMotivations();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        provider.fetchMotivations();
      }
    });
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("dd MMM yyyy, HH:mm").format(parsed);
    } catch (e) {
      return date;
    }
  }

  // Daftar emoji obat-obatan untuk variasi tampilan
  final List<String> medicineEmojis = ['💊', '💉', '🩺', '🌿', '🧪', '📋', '🏥', '❤️'];

  void showGenerateDialog() {
    final themeController = TextEditingController();
    final totalController = TextEditingController();

    // Saran jenis obat
    final List<String> suggestions = [
      'Paracetamol', 'Amoksisilin', 'Vitamin C',
      'Obat Batuk OBH', 'Ibuprofen', 'Antalgin',
      'Cetirizine', 'Promag'
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<MotivationProvider>(
          builder: (context, provider, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Text("💊 "),
                  Text("Info Obat"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nama Obat",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 6),
                  TextField(
                    controller: themeController,
                    decoration: InputDecoration(
                      hintText: "Contoh: Paracetamol, Amoksisilin...",
                      prefixIcon: Icon(Icons.medication),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Chip saran obat
                  Wrap(
                    spacing: 6,
                    children: suggestions.map((s) => ActionChip(
                      label: Text(s, style: TextStyle(fontSize: 11)),
                      onPressed: () => themeController.text = s,
                    )).toList(),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Jumlah Informasi",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 6),
                  TextField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Contoh: 3 (maksimal 10)",
                      prefixIcon: Icon(Icons.format_list_numbered),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: provider.isGenerating
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: provider.isGenerating
                      ? null
                      : () async {
                    if (themeController.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text("Nama obat harus diisi"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    int total = int.tryParse(totalController.text) ?? 3;
                    if (total > 10) total = 10;
                    if (total < 1) total = 1;

                    await provider.generate(
                      themeController.text,
                      total,
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: provider.isGenerating
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text("Mencari..."),
                    ],
                  )
                      : Text("Cari Info Obat"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotivationProvider>();
    final themeNotifier = context.watch<ThemeNotifier>();
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A237E) : Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF283593) : Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Text("💊 "),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delcom Medicine",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "Informasi Obat Terpercaya",
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.dark_mode),
            onPressed: themeNotifier.toggleTheme,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: showGenerateDialog,
        icon: Icon(Icons.medication),
        label: Text("Info Obat"),
        backgroundColor: Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),

      body: Stack(
        children: [
          Column(
            children: [
              // Banner info
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isDark ? Color(0xFF283593) : Color(0xFFBBDEFB),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF2196F3), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Tap '💊 Info Obat' untuk mendapatkan informasi lengkap tentang obat",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List info obat
              Expanded(
                child: provider.motivations.isEmpty && !provider.isLoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("💊", style: TextStyle(fontSize: 64)),
                      SizedBox(height: 16),
                      Text(
                        "Belum ada informasi obat",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Color(0xFF1565C0),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tap tombol '💊 Info Obat' untuk mulai mencari",
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(top: 8, bottom: 120),
                  itemCount: provider.motivations.length + 1,
                  itemBuilder: (context, index) {
                    if (index < provider.motivations.length) {
                      final item = provider.motivations[index];
                      final number = index + 1;
                      final emoji = medicineEmojis[index % medicineEmojis.length];

                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark ? Color(0xFF283593) : Colors.white,
                          border: Border.all(
                            color: isDark
                                ? Color(0xFF2196F3).withValues(alpha: 0.3)
                                : Color(0xFF90CAF9),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(emoji,
                                          style: TextStyle(fontSize: 20)),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF2196F3)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "Info #$number",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2196F3),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    formatDate(item.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                item.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return provider.isLoading
                          ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF2196F3),
                            ),
                            SizedBox(height: 8),
                            Text("Memuat info obat..."),
                          ],
                        ),
                      )
                          : SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),

          // Overlay loading saat generate
          if (provider.isGenerating)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("💊", style: TextStyle(fontSize: 40)),
                      SizedBox(height: 12),
                      CircularProgressIndicator(color: Color(0xFF2196F3)),
                      SizedBox(height: 12),
                      Text(
                        "Mencari informasi obat...",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}