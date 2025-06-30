// lib/pages/admin/content_list_page.dart

import 'package:flutter/material.dart';
import 'package:umkm_connect/models/content_model.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/pages/admin/content_detail_page.dart';
import 'package:umkm_connect/pages/admin/content_form_page.dart';

class ContentListPage extends StatefulWidget {
  const ContentListPage({super.key});

  @override
  State<ContentListPage> createState() => _ContentListPageState();
}

class _ContentListPageState extends State<ContentListPage> {
  late Future<List<ContentModel>> _contentsFuture;
  final APIStatic _api = APIStatic();

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    setState(() {
      _contentsFuture = _api.getAllContents();
    });
  }

  void _navigateAndRefresh(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    _loadContents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Konten")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(const ContentFormPage()),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadContents,
        child: FutureBuilder<List<ContentModel>>(
          future: _contentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Tidak ada konten."));
            }
            
            final contents = snapshot.data!;
            return ListView.builder(
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final content = contents[index];
                return ListTile(
                  leading: content.thumbnail != null
                      ? Image.network(content.thumbnail!, width: 100, fit: BoxFit.cover)
                      : const Icon(Icons.video_library),
                  title: Text(content.title),
                  subtitle: Text(content.creator),
                  onTap: () => _navigateAndRefresh(ContentDetailPage(contentId: content.id)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}