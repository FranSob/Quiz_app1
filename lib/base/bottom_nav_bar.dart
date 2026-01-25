import 'package:flutter/material.dart';
import 'package:quiz_app1/screens/home_page.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    Center(child: Text('Statystyki', style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,)),),
    Center(child: Text("Profil", style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,)),),
    Center(child: Text("Wersja premium",style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,)),),
  ];

  void _onNavTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // tło aplikacji ustawione na kolor appki
      backgroundColor: const Color(0xFF0F0F14),
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        child: _PremiumBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

/// Premium floating gradient bottom nav bar (ciemniejszy, dopasowany do appki)
class _PremiumBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ciemniejszy gradient, bardziej stonowany
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF302B46), // ciemny fioletowy
        Color(0xFF1C1C28), // główne tło appki
      ],
    );

    return Container(
      height: 74,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _NavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Statystyki',
              index: 1,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              index: 2,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _NavItem(
              icon: Icons.star_rounded,
              label: 'Premium',
              index: 3,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pojedynczy element navbary z animacją i etykietą
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          // delikatne wyróżnienie aktywnego elementu
          color: isActive ? Colors.white.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: isActive ? 38 : 30,
              height: isActive ? 38 : 30,
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.06) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.white70,
                size: isActive ? 20 : 18,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: Colors.white.withOpacity(isActive ? 0.95 : 0.75),
                fontSize: isActive ? 12 : 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
