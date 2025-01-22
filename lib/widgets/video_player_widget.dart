import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import '../providers/volume_provider.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoPath;
  final String title;
  final String? description;
  final Widget? thumbnail;

  const CustomVideoPlayer({
    Key? key,
    required this.videoPath,
    required this.title,
    this.description,
    this.thumbnail,
  }) : super(key: key);

  @override
  CustomVideoPlayerState createState() => CustomVideoPlayerState();
}

class CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showThumbnail = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.asset(widget.videoPath);
      await _videoPlayerController.initialize();

      // Get volume from provider
      final volumeProvider = Provider.of<VolumeProvider>(context, listen: false);
      await _videoPlayerController.setVolume(volumeProvider.volume);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.green,
          handleColor: Colors.greenAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
      );

      _videoPlayerController.addListener(_videoListener);
      setState(() {});

      // Listen to volume changes
      volumeProvider.addListener(() {
        if (mounted) {
          _videoPlayerController.setVolume(volumeProvider.volume);
        }
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  void _videoListener() {
    if (!mounted) return;
    setState(() {
      _showThumbnail = !_videoPlayerController.value.isPlaying;
    });
  }

  void _playVideo() {
    setState(() {
      _showThumbnail = false;
    });
    _videoPlayerController.play();
  }

  void stopVideo() {
    _videoPlayerController.pause();
    _videoPlayerController.seekTo(Duration.zero);
    setState(() {
      _showThumbnail = true;
    });
  }

  @override
  void dispose() {
    // Remove volume listener when disposing
    final volumeProvider = Provider.of<VolumeProvider>(context, listen: false);
    volumeProvider.removeListener(() {});
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(child: Text(_errorMessage));
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Description
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 80),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[900] 
                : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5EFF8B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.description != null) ...[
                  SizedBox(height: 4),
                  Text(
                    widget.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Video Player
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: GestureDetector(
                onTap: () {
                  if (_showThumbnail) {
                    _playVideo();
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_chewieController != null)
                      Chewie(controller: _chewieController!),
                    if (_showThumbnail)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            widget.thumbnail ?? _buildDefaultThumbnail(),
                            Container(
                              color: Colors.black.withOpacity(0.3),
                            ),
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFF5EFF8B).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 32,
                                  color: Color(0xFF5EFF8B),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildDefaultThumbnail() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF5EFF8B).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow,
            size: 32,
            color: Color(0xFF5EFF8B),
          ),
        ),
      ),
    );
  }
} 