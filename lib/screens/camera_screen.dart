import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/photo_bloc.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isFlashOn = false;
  bool _isTimerActive = false;
  int _timerSeconds = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.max,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Ошибка при инициализации камеры: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось инициализировать камеру: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    if (_controller != null) {
      _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    }
  }

  void _startTimer() {
    if (_isTimerActive) {
      _cancelTimer();
      return;
    }

    setState(() {
      _isTimerActive = true;
      _timerSeconds = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 1) {
          _timerSeconds--;
        } else {
          _timerSeconds = 0;
          timer.cancel();
          _takePhoto();
        }
      });
    });
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    if (mounted) {  // Добавлена проверка mounted
      setState(() {
        _isTimerActive = false;
        _timerSeconds = 0;
      });
    }
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      _cancelTimer();

      final image = await _controller!.takePicture();

      if (mounted) {
        try {
          final photoBloc = context.read<PhotoBloc>();
          photoBloc.add(AddPhoto(File(image.path)));
          Navigator.pop(context, true);
        } catch (e) {
          print('Ошибка при доступе к ФотобЛоку: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при сохранении фотографии')),
          );
        }
      }
    } catch (e) {
      print('Ошибка при съемке фотографии: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось сделать снимок: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Камера на весь экран (первая в стеке - самая нижняя)
          SizedBox.expand(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),


          // Верхняя панель (поверх камеры)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.3), // Полупрозрачная
              height: 56 + MediaQuery.of(context).padding.top,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Row(
                children: [
                  IconButton(///////////////////////////////////////////////////////////////////
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Новая фотография',
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

            ),
          ),
          // Нижняя панель (поверх камеры)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.black.withOpacity(0.3), // Полупрозрачный черный снизу
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Кнопка таймера
                  IconButton(
                    onPressed: _startTimer,
                    icon: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          _isTimerActive ? Icons.timer_3 : Icons.timer_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20), // Фиксированный отступ между таймером и съемкой

                  // Кнопка съемки
                  GestureDetector(
                    onTap: _isTimerActive ? null : _takePhoto,
                    child: Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        // child: _isTimerActive
                        //     ? Center(
                        //   child: Text(
                        //     '$_timerSeconds',
                        //     style: const TextStyle(
                        //       color: Colors.black,                      // отсчет таймера
                        //       fontSize: 26,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // )
                        //     : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Фиксированный отступ между съемкой и вспышкой

                  // Кнопка вспышки
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _isTimerActive
                          ? Icons.flash_off
                          : (_isFlashOn ? Icons.flash_on : Icons.flash_off),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}