import 'package:flutter/material.dart';
import 'package:google_speech/google_speech.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_recorder2/audio_recorder2.dart';
import 'dart:async';

class Transcriber extends StatefulWidget {
  @override
  _TranscriberState createState() => _TranscriberState();
}

class _TranscriberState extends State<Transcriber> {
  String _transcription = "";
  bool _isRecording = false;
  late SpeechToText _speechToText;

  // Replace with your actual API key
  final String apiKey = "AIzaSyDXaNyDjTE3kbhEyR2KbeMJf7GYH2ka69U";

  @override
  void initState() {
    super.initState();
    _initializeSpeechToText();
  }

  Future<void> _initializeSpeechToText() async {
    // Initialize Speech-to-Text with API key
    _speechToText = SpeechToText.viaToken('Bearer $apiKey');
  }

  Future<void> startRecording() async {
    // Check if recording is already in progress
    if (_isRecording) return;

    // Start recording
    await AudioRecorder2.start();
    setState(() {
      _isRecording = true;
    });

    // Start streaming transcription
    _streamTranscription();
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    // Stop recording
    await AudioRecorder2.stop();
    setState(() {
      _isRecording = false;
    });
  }

  void _streamTranscription() async {
    final config = StreamingRecognitionConfig(
      config: RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        sampleRateHertz: 16000,
        languageCode: 'ar', // Arabic language
        enableAutomaticPunctuation: true,
      ),
      interimResults: true,
    );

    // Start streaming audio from the recorder
    final stream = AudioRecorder2.audioStream; // Get audio stream from the recorder

    // Start streaming recognition
    final responseStream = _speechToText.streamingRecognize(config, stream);
    responseStream.listen((data) {
      setState(() {
        // Process and display the transcription
        _transcription = data.results
            .map((result) => result.alternatives.first.transcript)
            .join('\n');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Arabic Speech Transcription")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isRecording ? stopRecording : startRecording,
                child: Text(_isRecording ? "Stop Recording" : "Start Recording"),
              ),
              SizedBox(height: 20),
              Text("Transcription:"),
              SizedBox(height: 10),
              Text(_transcription),
            ],
          ),
        ),
      ),
    );
  }
}
