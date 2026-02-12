import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../post/create_post_screen.dart';
import '../video/video_upload_screen.dart';

/// Hub screen that switches between Track Upload and Music Video Upload.
class UploadHubScreen extends StatefulWidget {
  const UploadHubScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<UploadHubScreen> createState() => _UploadHubScreenState();
}

class _UploadHubScreenState extends State<UploadHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: MoltColors.backgroundGradient),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
              decoration: BoxDecoration(
                color: MoltColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: MoltColors.purple.withValues(alpha: 0.2)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: MoltColors.purplePinkGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                labelColor: Colors.white,
                unselectedLabelColor: MoltColors.textMuted,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: '🎵 Track / Album'),
                  Tab(text: '🎬 Music Video'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CreatePostScreen(services: widget.services),
                VideoUploadScreen(services: widget.services),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
