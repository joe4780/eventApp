import 'dart:html' as html; // For web platforms
import 'dart:io';
import 'dart:typed_data'; // For handling blobs in web
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

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
  html.MediaRecorder? _mediaRecorder; // Web-specific media recorder
  List<html.Blob> _recordedChunks = []; // Web-specific recorded audio data
  String? _blobUrl; // Store the blob URL separately

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _recorder = FlutterSoundRecorder();
      _player = FlutterSoundPlayer();
      _requestPermissions();
    }
    _loadAudioList();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return; // Ensure further actions don't continue without permission
      }
    }
  }

  Future<void> _startRecording() async {
    if (kIsWeb) {
      await _startWebRecording();
    } else {
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

  Future<void> _startWebRecording() async {
    final stream = await html.window.navigator.getUserMedia(audio: true);
    _mediaRecorder = html.MediaRecorder(stream);

    _mediaRecorder!.addEventListener('dataavailable', (html.Event event) {
      final html.BlobEvent blobEvent = event as html.BlobEvent;
      _recordedChunks.add(blobEvent.data!); // Store the Blob (audio data)
    });

    _mediaRecorder!.start();
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    if (kIsWeb && _mediaRecorder != null) {
      await _stopWebRecording();
    } else {
      await _recorder!.stopRecorder();
      await _recorder!.closeRecorder();
      setState(() {
        _isRecording = false;
        _isRecorded = true;
      });
    }
  }

  Future<void> _stopWebRecording() async {
    _mediaRecorder!.stop();
    final blob = html.Blob(_recordedChunks, 'audio/webm');
    _blobUrl =
        html.Url.createObjectUrlFromBlob(blob); // Store blob URL separately
    setState(() {
      _isRecording = false;
      _isRecorded = true;
      _filePath = _blobUrl; // Use the URL of the blob
    });
  }

  Future<void> _playAudio(String audioPath) async {
    if (audioPath != null) {
      if (kIsWeb) {
        _playWebAudio(audioPath);
      } else {
        await _player!.openPlayer();
        await _player!.startPlayer(
          fromURI: audioPath,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
            });
          },
        );
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  void _playWebAudio(String audioUrl) {
    final audioElement = html.AudioElement(audioUrl);
    audioElement.play().catchError((error) {
      print("Error playing audio: $error"); // Catch any error during playback
    });
    setState(() {
      _isPlaying = true;
    });
    audioElement.onEnded.listen((_) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _submitRecording() async {
    if (_filePath != null) {
      if (kIsWeb) {
        _downloadWebAudio(_blobUrl!); // Use the blob URL for download
      } else {
        _audioList.add(_filePath!);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('audioList', _audioList);
        setState(() {
          _isRecorded = false;
          _filePath = null;
        });
      }
      // For web, add the recorded audio to the list
      if (kIsWeb) {
        _audioList.add(_blobUrl!);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('audioList', _audioList);
      }
      _showSuccessDialog(); // Show success dialog
    }
  }

  void _downloadWebAudio(String blobUrl) {
    final anchor = html.AnchorElement(href: blobUrl)
      ..setAttribute(
          'download', 'recording_${DateTime.now().millisecondsSinceEpoch}.webm')
      ..click();
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
          content: const Text('Submit successfully'),
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
    if (!kIsWeb) {
      _recorder!.closeRecorder();
      _player!.closePlayer();
    }
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
              const Text(
                'RECORDS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _isRecording ? null : _startRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[100],
                      ),
                      child: const Text('VOICE RECORD'),
                    ),
                    const SizedBox(height: 8),
                    Text(_isRecording ? 'Recording...' : 'Ready to record'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isRecording ? _stopRecording : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[300],
                      ),
                      child: const Text('STOP RECORDING'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isRecorded && !_isPlaying
                          ? () => _playAudio(_filePath!)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[100],
                      ),
                      child: const Text('VOICE PLAY'),
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

  Widget _buildAudioItem(String text, String audioPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              await _playAudio(
                  audioPath); // Pass audioPath to play the correct audio
            },
          ),
        ],
      ),
    );
  }

  Future<void> _stopAudio() async {
    if (_isPlaying) {
      await _player!.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
    }
  }
}
