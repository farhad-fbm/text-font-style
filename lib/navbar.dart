import 'package:flutter/material.dart';
import 'snippet_2.dart';
import 'snippet_1.dart';

class ScrollableBottomNav extends StatefulWidget {
  const ScrollableBottomNav({super.key});

  @override
  State<ScrollableBottomNav> createState() => _ScrollableBottomNavState();
}

class _ScrollableBottomNavState extends State<ScrollableBottomNav> {
  int _selectedIndex = 0;

  final List<Map<dynamic, dynamic>> _navItems = [
    {Widget: Snippet1(), 'label': 'Snippet1', 'icon': Icons.snippet_folder},
    {
      Widget: Snippet2(),
      'label': 'Snippet2',
      'icon': Icons.snippet_folder_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scrollable Bottom Nav")),
      body: Center(child: _navItems[_selectedIndex][Widget]),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navItems.length, (index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.blue.shade100 : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _navItems[index]['icon'],
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      Text(
                        _navItems[index]['label'],
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
