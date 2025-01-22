import 'package:flutter/material.dart';
import 'video_player_widget.dart';

class VideoCategory extends StatefulWidget {
  final String title;
  final List<VideoItem> videos;
  final bool isExpanded;
  final Function(bool) onExpansionChanged;
  final ExpansionTileController controller;
  final String originalTitle;

  const VideoCategory({
    Key? key,
    required this.title,
    required this.videos,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.controller,
    required this.originalTitle,
  }) : super(key: key);

  @override
  _VideoCategoryState createState() => _VideoCategoryState();
}

class _VideoCategoryState extends State<VideoCategory> {
  final List<GlobalKey<CustomVideoPlayerState>> _videoKeys = [];

  @override
  void initState() {
    super.initState();
    _videoKeys.addAll(
      List.generate(
        widget.videos.length,
        (_) => GlobalKey<CustomVideoPlayerState>(),
      ),
    );
  }

  void _stopOtherVideos(int currentIndex) {
    for (int i = 0; i < _videoKeys.length; i++) {
      if (i != currentIndex) {
        _videoKeys[i].currentState?.stopVideo();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.grey[900] 
          : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          controller: widget.controller,
          initiallyExpanded: widget.isExpanded,
          maintainState: false,
          onExpansionChanged: widget.onExpansionChanged,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Container(
            height: 60, // Fixed height for category header
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF5EFF8B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: Color(0xFF5EFF8B),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5EFF8B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: widget.videos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final video = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < widget.videos.length - 1 ? 16 : 0),
                    child: CustomVideoPlayer(
                      key: _videoKeys[index],
                      videoPath: video.path,
                      title: video.title,
                      description: video.description,
                      thumbnail: Image.asset(
                        video.thumbnailPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[300],
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 50,
                              color: Color(0xFF5EFF8B),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.originalTitle) {
      case 'basicLifeSupport':
        return Icons.favorite_border;
      case 'advancedCardiacLifeSupport':
        return Icons.monitor_heart;
      case 'pediatricLifeSupport':
        return Icons.child_care;
      default:
        return Icons.play_circle_outline;
    }
  }
}

class VideoItem {
  final String path;
  final String title;
  final String description;
  final String thumbnailPath;

  VideoItem({
    required this.path,
    required this.title,
    required this.description,
    required this.thumbnailPath,
  });
} 