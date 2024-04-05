import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Upload App',
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
        title: const Text('Video Upload'),
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
                  'Original File Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text('Video URL'),
                  subtitle: Text(originalVideoUrl ?? ''),
                ),
                ListTile(
                  title: const Text('Name'),
                  subtitle: Text(originalVideoName ?? ''),
                ),
                ListTile(
                  title: const Text('Size'),
                  subtitle: Text(originalVideoSize ?? ''),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isCompressing ? null : _compressVideo,
                  child: const Text('Compress Video'),
                ),
                if (isCompressing) const SizedBox(height: 20),
                if (isCompressing)
                  LinearProgressIndicator(
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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
      final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
      final String inputPath = originalVideoUrl!;
      final String outputPath =
      inputPath.replaceAll('.mp4', '_compressed.mp4');
      final int rc = await flutterFFmpeg.execute(
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

  const VideoDetailsPage({super.key, 
    required this.compressedVideoUrl,
    required this.compressedVideoName,
    required this.compressedVideoSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compressed Video Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compressed File Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(
                controller: BetterPlayerController(
                  const BetterPlayerConfiguration(
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
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Video URL'),
              subtitle: Text(compressedVideoUrl),
            ),
            ListTile(
              title: const Text('Name'),
              subtitle: Text(compressedVideoName),
            ),
            ListTile(
              title: const Text('Size'),
              subtitle: Text(compressedVideoSize),
            ),
          ],
        ),
      ),
    );
  }
}
