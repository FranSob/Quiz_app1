import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app1/base/widgets/fiszki_data.dart';
import 'package:quiz_app1/base/pages/quiz_fiszki_page.dart';

class FiszkiPage extends StatefulWidget {
  const FiszkiPage({super.key});

  @override
  State<FiszkiPage> createState() => _FiszkiPageState();
}

class _FiszkiPageState extends State<FiszkiPage> {
  Map<String, List<Fiszka>> folderyFiszki = {};
  Map<String, int> folderFinishCounts = {};
  List<Fiszka> roboczeFiszki = [];
  bool inAddingMode = false;
  
  // --- nowa zmienna dla wyszukiwania ---
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadFoldery();
    loadFinishCounts();
  }

  // --- STORAGE ---
  Future<void> loadFoldery() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('folderyFiszki');
    if (data != null) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      final Map<String, List<Fiszka>> loaded = {};
      decoded.forEach((key, value) {
        loaded[key] = (value as List)
            .map((e) => Fiszka.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      setState(() => folderyFiszki = loaded);
    } else {
      setState(() => folderyFiszki = {});
    }
  }

  Future<void> persistFoldery() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(folderyFiszki.map(
      (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
    ));
    await prefs.setString('folderyFiszki', encoded);
  }

  // --- FINISH COUNTS STORAGE ---
  Future<void> loadFinishCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('folderFinishCounts');
    if (data != null) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      setState(() {
        folderFinishCounts = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      });
    } else {
      setState(() {
        folderFinishCounts = {};
      });
    }
  }

  // --- DIALOG: dodaj fiszkę do roboczych (podczas tworzenia nowego folderu) ---
  void showAddFiszkaDialog() {
    String q = '';
    String a = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dodaj fiszkę'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Pytanie'),
                onChanged: (v) => q = v,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(hintText: 'Odpowiedź'),
                onChanged: (v) => a = v,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
            ElevatedButton(
              onPressed: () {
                if (q.trim().isEmpty || a.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wypełnij pytanie i odpowiedź')),
                  );
                  return;
                }
                setState(() {
                  roboczeFiszki.add(Fiszka(question: q.trim(), answer: a.trim()));
                });
                Navigator.pop(context);
              },
              child: const Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }

  // --- DIALOG: dodaj fiszkę do istniejącego folderu ---
  void showAddFiszkaToFolderDialog(String folderName) {
    String q = '';
    String a = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Dodaj fiszkę do "$folderName"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Pytanie'),
                onChanged: (v) => q = v,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(hintText: 'Odpowiedź'),
                onChanged: (v) => a = v,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
            ElevatedButton(
              onPressed: () async {
                if (q.trim().isEmpty || a.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wypełnij pytanie i odpowiedź')),
                  );
                  return;
                }
                setState(() {
                  folderyFiszki[folderName] ??= [];
                  folderyFiszki[folderName]!.add(Fiszka(question: q.trim(), answer: a.trim()));
                });
                await persistFoldery();
                Navigator.pop(context);
              },
              child: const Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }

  // --- ZAKOŃCZ DODAWANIE: zapytaj o nazwę folderu i zapisz robocze fiszki ---
  void finishAddingAndSaveFolder() {
    if (roboczeFiszki.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodaj przynajmniej jedną fiszkę przed zakończeniem')),
      );
      return;
    }

    String folderName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zapisz folder'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Nazwa folderu'),
            onChanged: (v) => folderName = v,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
            ElevatedButton(
              onPressed: () async {
                final name = folderName.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Podaj nazwę folderu')),
                  );
                  return;
                }
                if (folderyFiszki.containsKey(name)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Folder o takiej nazwie już istnieje')),
                  );
                  return;
                }
                setState(() {
                  folderyFiszki[name] = List<Fiszka>.from(roboczeFiszki);
                  roboczeFiszki = [];
                  inAddingMode = false;
                });
                await persistFoldery();
                Navigator.pop(context);
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }

  // --- USUŃ FOLDER (z potwierdzeniem) ---
  void confirmAndDeleteFolder(String folderName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usuń folder'),
          content: Text('Czy na pewno chcesz usunąć folder "$folderName"? Ta operacja jest nieodwracalna.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                setState(() {
                  folderyFiszki.remove(folderName);
                });
                await persistFoldery();
                Navigator.pop(context);
              },
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );
  }

  // --- UI helper: 3D-stylizowany przycisk (używany do przycisków dodawania) ---
  Widget build3DButton({
    required String text,
    required VoidCallback onPressed,
    required EdgeInsetsGeometry margin,
    Color color = Colors.deepPurple,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(4, 4), blurRadius: 6),
            BoxShadow(color: Colors.white.withOpacity(0.06), offset: const Offset(-4, -4), blurRadius: 6),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // --- PAGE: open folder content (podgląd). Po powrocie odświeżamy listę folderów i liczniki
  Future<void> openFolderContent(String folderName, List<Fiszka> fiszki) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderContentPage(folderName: folderName, fiszki: fiszki),
      ),
    );
    await loadFoldery(); // odśwież po powrocie (by widzieć zmiany)
    await loadFinishCounts(); // odśwież liczniki
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      // --- AppBar z widoczną strzałką wstecz ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        foregroundColor: Colors.white, // wymusza biały kolor ikon i tekstu
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fiszki',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: inAddingMode
                  ? _buildAddingView()
                  : Column(
                      children: [
                        // --- SEARCH BAR ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C28),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.white54),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      hintText: 'Szukaj folderu...',
                                      hintStyle: TextStyle(color: Colors.white38),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                  ),
                                ),
                                if (searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () => setState(() => searchQuery = ''),
                                    child: const Icon(Icons.close, color: Colors.white54),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // --- LISTA FOLDERÓW ---
                        Expanded(child: _buildFoldersView()),
                      ],
                    ),
            ),
          ),

          // ------ DOLNY PANEL PRZYCISKÓW ------
          SafeArea(
            minimum: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
            child: inAddingMode
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // czerwony ZAKOŃCZ DODAWANIE (na górze)
                      build3DButton(
                        text: 'ZAKOŃCZ DODAWANIE',
                        onPressed: finishAddingAndSaveFolder,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 10),
                      // przycisk DODAJ FISZKĘ (pod czerwonym)
                      build3DButton(
                        text: 'DODAJ FISZKĘ',
                        onPressed: showAddFiszkaDialog,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ],
                  )
                : build3DButton(
                    text: 'DODAJ FISZKI',
                    onPressed: () {
                      setState(() {
                        inAddingMode = true;
                        roboczeFiszki = [];
                      });
                    },
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
          ),
        ],
      ),
    );
  }

  // Widok listy folderów (z filtrowaniem po searchQuery)
  Widget _buildFoldersView() {
    if (folderyFiszki.isEmpty) {
      return const Center(
        child: Text('Brak folderów', style: TextStyle(color: Colors.white70, fontSize: 18)),
      );
    }
    // filtruj po nazwie (case-insensitive)
    final filteredEntries = folderyFiszki.entries
        .where((e) => e.key.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (filteredEntries.isEmpty) {
      return const Center(
        child: Text('Brak pasujących folderów', style: TextStyle(color: Colors.white70, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filteredEntries.length,
      itemBuilder: (context, index) {
        final name = filteredEntries[index].key;
        final fiszki = filteredEntries[index].value;
        final timesFinished = folderFinishCounts[name] ?? 0;
        return Card(
          color: const Color(0xFF1C1C28),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 18)),
            subtitle: Text(
              '${fiszki.length} fiszek · Zakończono: $timesFinished razy',
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: PopupMenuButton<String>(
              color: const Color(0xFF1C1C28),
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onSelected: (value) {
                if (value == 'add') {
                  showAddFiszkaToFolderDialog(name);
                } else if (value == 'delete') {
                  confirmAndDeleteFolder(name);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'add', child: Text('Dodaj fiszkę', style: TextStyle(color: Colors.white),)),
                const PopupMenuItem(value: 'delete', child:  Text(
  'Usuń folder',
  style: TextStyle(color: Colors.white),
),
)
              ],
            ),
            onTap: () => openFolderContent(name, fiszki),
          ),
        );
      },
    );
  }

  // Widok podczas tworzenia nowych fiszek (robocze)
  Widget _buildAddingView() {
    if (roboczeFiszki.isEmpty) {
      return const Center(
        child: Text(
          'Brak dodanych fiszek. Kliknij DODAJ FISZKĘ, aby dodać pierwszą.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: roboczeFiszki.length,
      itemBuilder: (context, index) {
        final f = roboczeFiszki[index];
        return Card(
          color: const Color(0xFF1C1C28),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(f.question, style: const TextStyle(color: Colors.white)),
            subtitle: Text(f.answer, style: const TextStyle(color: Colors.white54)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  roboczeFiszki.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }
}

// ---------- FolderContentPage (STATEFUL) ----------
class FolderContentPage extends StatefulWidget {
  final String folderName;
  final List<Fiszka> fiszki;

  const FolderContentPage({super.key, required this.folderName, required this.fiszki});

  @override
  State<FolderContentPage> createState() => _FolderContentPageState();
}

class _FolderContentPageState extends State<FolderContentPage> {
  late List<Fiszka> _fiszki;

  @override
  void initState() {
    super.initState();
    _fiszki = List<Fiszka>.from(widget.fiszki);
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('folderyFiszki');
    Map<String, dynamic> decoded = {};
    if (data != null) {
      decoded = jsonDecode(data) as Map<String, dynamic>;
    }
    decoded[widget.folderName] = _fiszki.map((e) => e.toJson()).toList();
    await prefs.setString('folderyFiszki', jsonEncode(decoded));
  }

  // --- inkrementacja licznika zakończeń dla tego folderu ---
  Future<void> _incrementFinishCount() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'folderFinishCounts';
    final String? data = prefs.getString(key);
    Map<String, int> counts = {};
    if (data != null) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      decoded.forEach((k, v) => counts[k] = (v as num).toInt());
    }
    counts[widget.folderName] = (counts[widget.folderName] ?? 0) + 1;
    await prefs.setString(key, jsonEncode(counts));
  }

  void _showAddFiszkaDialog() {
    String q = '';
    String a = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dodaj fiszkę do "${widget.folderName}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Pytanie'),
              onChanged: (v) => q = v,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(hintText: 'Odpowiedź'),
              onChanged: (v) => a = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
          ElevatedButton(
            onPressed: () async {
              if (q.trim().isEmpty || a.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wypełnij pytanie i odpowiedź')),
                );
                return;
              }
              setState(() => _fiszki.add(Fiszka(question: q.trim(), answer: a.trim())));
              await _saveChanges();
              Navigator.pop(context);
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }

  void _confirmAndDeleteFiszka(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń fiszkę'),
        content: const Text('Czy chcesz usunąć tę fiszkę?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              setState(() => _fiszki.removeAt(index));
              await _saveChanges();
              Navigator.pop(context);
            },
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
  }

  Widget build3DButton({
    required String text,
    required VoidCallback onPressed,
    required EdgeInsetsGeometry margin,
    Color color = Colors.deepPurple,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.35), offset: const Offset(3, 3), blurRadius: 6),
            BoxShadow(color: Colors.white.withOpacity(0.04), offset: const Offset(-3, -3), blurRadius: 6),
          ],
        ),
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        foregroundColor: Colors.white,
        title: Text(widget.folderName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _fiszki.isEmpty
                ? const Center(child: Text('Folder pusty', style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 12),
                    itemCount: _fiszki.length,
                    itemBuilder: (context, index) {
                      final f = _fiszki[index];
                      return Card(
                        color: const Color(0xFF1C1C28),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(f.question, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(f.answer, style: const TextStyle(color: Colors.white54)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _confirmAndDeleteFiszka(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          SafeArea(
            minimum: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                build3DButton(
  text: 'START QUIZ',
  color: Colors.green,
  margin: const EdgeInsets.symmetric(horizontal: 16),
  onPressed: () async {
    if (_fiszki.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder jest pusty')),
      );
      return;
    }

    // 👇 Tutaj wstaw Navigator.push z folderName
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizFiszkiPage(
          fiszki: _fiszki,
          folderName: widget.folderName, // nazwa folderu przekazana do quizu
        ),
      ),
    );

    if (result == true) {
      await _incrementFinishCount();
    }
  },
),


                const SizedBox(height: 10),
                build3DButton(
                  text: 'DODAJ FISZKĘ',
                  onPressed: _showAddFiszkaDialog,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
