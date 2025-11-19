import 'package:flutter/material.dart';
import 'package:ty_cafe/features/home/presentation/pages/home_page.dart';
import 'package:ty_cafe/features/home/presentation/widgets/app_bottom_navigation.dart';
import 'package:ty_cafe/features/cart/presentation/pages/cart_page.dart';
import 'package:ty_cafe/features/favorite/presentation/pages/favorite_page.dart';
import 'package:ty_cafe/features/profile/presentation/pages/profile_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [HomePage(), CartPage(), FavoritePage(), ProfilePage()];
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _pages.map((p) {
                return HeroMode(enabled: true, child: p);
              }).toList(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
