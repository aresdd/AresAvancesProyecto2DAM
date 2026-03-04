import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../providers/home_tab_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../dashboard/dashboard_screen.dart';
import '../dishes/dishes_screen.dart';
import '../profile/profile_screen.dart';
import '../search/food_search_screen.dart';
import '../stats/stats_screen.dart';

/// Home container with bottom navigation.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  Widget build(BuildContext context) {
    final index = ref.watch(homeTabIndexProvider);
    final user = ref.watch(userProvider);
    final titles = [
      user == null ? 'Inicio' : 'Hola, ${user.name}',
      'Buscar alimentos',
      'Platos',
      'Estadísticas',
      'Perfil',
    ];

    final pages = const [
      DashboardScreen(),
      FoodSearchScreen(),
      DishesScreen(),
      StatsScreen(),
      ProfileScreen(),
    ];

    return AppScaffold(
      title: titles[index],
      actions: [
        if (index == 0)
          IconButton(
            tooltip: 'Añadir comida',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addMeal),
            icon: const Icon(Icons.add_circle_outline),
          ),
      ],
      body: IndexedStack(index: index, children: pages),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addMeal),
              icon: const Icon(Icons.add),
              label: const Text('Añadir comida'),
            )
          : null,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: index,
        onChanged: (i) => ref.read(homeTabIndexProvider.notifier).state = i,
      ),
    );
  }
}

