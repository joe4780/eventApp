import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isRecorded = false;
  bool _isPlaying = false;
  String? _filePath;
  List<String> _audioList = [];
  int _playingIndex = -1; // Track which audio is currently playing

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _requestPermissions();
    _loadAudioList();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission is required')),
      );
      return; // Exit if permission is denied
    }
  }

  Future<void> _startRecording() async {
    await _requestPermissions();
    if (!_isRecording) {
      Directory appDir = await getApplicationDocumentsDirectory();
      String filePath =
          '${appDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.openRecorder();
      await _recorder!.startRecorder(toFile: filePath);
      setState(() {
        _isRecording = true;
        _isRecorded = false;
        _filePath = filePath;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _isRecorded = true;
      });
    }
  }

  Future<void> _playAudio(String audioPath, int index) async {
    await _player!.openPlayer();
    await _player!.startPlayer(
      fromURI: audioPath,
      whenFinished: () {
        setState(() {
          _isPlaying = false;
          _playingIndex = -1; // Reset playing index when finished
        });
      },
    );
    setState(() {
      _isPlaying = true;
      _playingIndex = index; // Set the current playing index
    });
  }

  Future<void> _submitRecording() async {
    if (_filePath != null) {
      _audioList.add(_filePath!);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('audioList', _audioList);
      setState(() {
        _isRecorded = false;
        _filePath = null;
      });
      _showSuccessDialog(); // Show success dialog
    }
  }

  Future<void> _loadAudioList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedAudioList = prefs.getStringList('audioList');
    if (savedAudioList != null) {
      setState(() {
        _audioList = savedAudioList;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Submitted successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  'RECORDS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Button for voice recording
                        ElevatedButton(
                          onPressed:
                              _isRecording ? _stopRecording : _startRecording,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[100],
                          ),
                          child: Text(
                              _isRecording ? 'STOP RECORDING' : 'VOICE RECORD'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Button for playing the audio
                        ElevatedButton(
                          onPressed: _isRecorded && !_isPlaying
                              ? () => _playAudio(_filePath!, _audioList.length)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[100],
                          ),
                          child: const Text('VOICE PLAY'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _isRecorded ? _submitRecording : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[300],
                        ),
                        child: const Text('SUBMIT'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AUDIOS LIST'),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _audioList.length,
                          itemBuilder: (context, index) {
                            String audioPath = _audioList[index];
                            return _buildAudioItem(
                              'AUDIO ${index + 1}',
                              audioPath,
                              index,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioItem(String text, String audioPath, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                _playingIndex == index ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () async {
                if (_playingIndex == index) {
                  await _player!.stopPlayer();
                  setState(() {
                    _isPlaying = false;
                    _playingIndex = -1; // Reset playing index
                  });
                } else {
                  await _playAudio(audioPath, index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
