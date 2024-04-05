import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:better_player/better_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Compress',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoUploadScreen(),
    );
  }
}

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  BetterPlayerController? _betterPlayerController;
  String? videoUrl;
  String? videoName;
  String? videoSize;

  @override
  void initState() {
    super.initState();
    _resetSession();
  }

  void _resetSession() {
    _betterPlayerController = null;
    videoUrl = null;
    videoName = null;
    videoSize = null;
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null) {
      PlatformFile file = result.files.single;
      setState(() {
        videoUrl = file.path;
        videoName = file.name;
        videoSize = _formatBytes(file.size);
      });

      _betterPlayerController = BetterPlayerController(
        const BetterPlayerConfiguration(
          autoPlay: false,
          fit: BoxFit.contain,
          aspectRatio: 16 / 9,
        ),
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          file.path!,
        ),
      );

      setState(() {});
    }
  }

  String _formatBytes(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int index = 0;
    double size = bytes.toDouble();
    while (size > 1024) {
      size /= 1024;
      index++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[index]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Compress'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: const Text('Record Video'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _pickVideo,
                    child: const Text('Pick Video'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_betterPlayerController != null) ...[
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: BetterPlayer(
                    controller: _betterPlayerController!,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'File Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text('Video URL'),
                  subtitle: Text(videoUrl!),
                ),
                ListTile(
                  title: const Text('Name'),
                  subtitle: Text(videoName!),
                ),
                ListTile(
                  title: const Text('Size'),
                  subtitle: Text(videoSize!),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {

                  },
                  child: const Text('Compress Video'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
