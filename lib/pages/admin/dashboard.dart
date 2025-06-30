// lib/pages/admin/admin_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:umkm_connect/pages/admin/shop_list_page.dart';
import 'package:umkm_connect/pages/admin/user_list_page.dart'; 
import 'package:umkm_connect/pages/admin/content_list_page.dart'; 
import 'package:umkm_connect/pages/admin/order_list_page.dart'; 

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Validasi Toko', 'icon': Icons.store_mall_directory, 'page': const ShopListPage()},
      {'title': 'Manajemen Pengguna', 'icon': Icons.people, 'page': const UserListPage()},
      {'title': 'Manajemen Konten', 'icon': Icons.article, 'page': const ContentListPage()},
      {'title': 'Semua Pesanan', 'icon': Icons.receipt_long, 'page': const OrderListPage()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.indigo,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => item['page']),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], size: 48, color: Colors.indigo),
                  const SizedBox(height: 12),
                  Text(item['title'], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}