import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Upload App',
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
  String? originalVideoUrl;
  String? originalVideoName;
  String? originalVideoSize;
  bool isCompressing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null) {
      PlatformFile file = result.files.single;
      setState(() {
        originalVideoUrl = file.path;
        originalVideoName = file.name;
        originalVideoSize = _formatBytes(file.size);
      });

      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
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
        title: Text('Video Upload'),
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
                    onPressed: () {},
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
                  'Original File Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Video URL'),
                  subtitle: Text(originalVideoUrl ?? ''),
                ),
                ListTile(
                  title: Text('Name'),
                  subtitle: Text(originalVideoName ?? ''),
                ),
                ListTile(
                  title: Text('Size'),
                  subtitle: Text(originalVideoSize ?? ''),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isCompressing ? null : _compressVideo,
                  child: Text('Compress Video'),
                ),
                if (isCompressing) SizedBox(height: 20),
                if (isCompressing)
                  LinearProgressIndicator(
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _compressVideo() async {
    if (originalVideoUrl != null) {
      setState(() {
        isCompressing = true;
      });
      final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
      final String inputPath = originalVideoUrl!;
      final String outputPath =
      inputPath.replaceAll('.mp4', '_compressed.mp4');
      final int rc = await _flutterFFmpeg.execute(
          '-y -i $inputPath -vf "scale=iw/2:ih/2" -c:a copy $outputPath');
      if (rc == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDetailsPage(
              compressedVideoUrl: outputPath,
              compressedVideoName: outputPath.split('/').last,
              compressedVideoSize:
              _formatBytes(File(outputPath).lengthSync()),
            ),
          ),
        );
      }
      setState(() {
        isCompressing = false;
      });
    }
  }
}

class VideoDetailsPage extends StatelessWidget {
  final String compressedVideoUrl;
  final String compressedVideoName;
  final String compressedVideoSize;

  const VideoDetailsPage({
    required this.compressedVideoUrl,
    required this.compressedVideoName,
    required this.compressedVideoSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compressed Video Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compressed File Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(
                controller: BetterPlayerController(
                  BetterPlayerConfiguration(
                    autoPlay: false,
                    fit: BoxFit.contain,
                    aspectRatio: 16 / 9,
                  ),
                  betterPlayerDataSource: BetterPlayerDataSource(
                    BetterPlayerDataSourceType.file,
                    compressedVideoUrl,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('Video URL'),
              subtitle: Text(compressedVideoUrl),
            ),
            ListTile(
              title: Text('Name'),
              subtitle: Text(compressedVideoName),
            ),
            ListTile(
              title: Text('Size'),
              subtitle: Text(compressedVideoSize),
            ),
          ],
        ),
      ),
    );
  }
}
