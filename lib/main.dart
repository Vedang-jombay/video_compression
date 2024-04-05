import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:better_player/better_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Compress',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoUploadScreen(),
    );
  }
}

class VideoUploadScreen extends StatefulWidget {
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
        BetterPlayerConfiguration(
          autoPlay: true,
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
        title: Text('Video Compress'),
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
                    child: Text('Record Video'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _pickVideo,
                    child: Text('Pick Video'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_betterPlayerController != null) ...[
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: BetterPlayer(
                    controller: _betterPlayerController!,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'File Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Video URL'),
                  subtitle: Text(videoUrl!),
                ),
                ListTile(
                  title: Text('Name'),
                  subtitle: Text(videoName!),
                ),
                ListTile(
                  title: Text('Size'),
                  subtitle: Text(videoSize!),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('Compress Video'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
