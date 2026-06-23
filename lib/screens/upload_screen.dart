import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/video_cubit.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _videoFile;
  VideoPlayerController? _videoPlayerController;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picked = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );

    if (picked != null) {
      _videoPlayerController?.dispose();
      setState(() {
        _videoFile = File(picked.path);
      });

      _videoPlayerController = VideoPlayerController.file(_videoFile!)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.play();
          _videoPlayerController!.setLooping(true);
        });
    }
  }

  void _clearSelection() {
    _videoPlayerController?.dispose();
    setState(() {
      _videoFile = null;
      _videoPlayerController = null;
      _titleController.clear();
      _descController.clear();
    });
  }

  void _upload() {
    if (_formKey.currentState!.validate() && _videoFile != null) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        context.read<VideoCubit>().uploadVideo(
              videoFile: _videoFile!,
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              userDetails: authState.userDetails,
            );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً لتتمكن من النشر')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoCubit, VideoState>(
      listener: (context, state) {
        if (state is VideoUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم نشر الفيديو بنجاح! 🎉', textAlign: TextAlign.right),
              backgroundColor: Colors.green,
            ),
          );
          _clearSelection();
        } else if (state is VideoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء النشر: ${state.message}', textAlign: TextAlign.right),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'نشر فيديو جديد',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          actions: _videoFile != null
              ? [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _clearSelection,
                  )
                ]
              : null,
        ),
        body: _videoFile == null ? _buildPickerPlaceholder() : _buildUploadForm(),
      ),
    );
  }

  Widget _buildPickerPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1.5),
              ),
              child: const Icon(
                Icons.video_library_rounded,
                size: 80,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'شارك إبداعاتك مع العالم',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'قم باختيار فيديو قصير لا يتعدى 60 ثانية للبدء',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.add_a_photo_rounded, color: Colors.black),
              label: const Text(
                'اختار فيديو من المعرض',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Video Player Preview
              Center(
                child: Container(
                  width: 160,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[800]!),
                    color: Colors.grey[950],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoPlayerController!.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController!),
                        )
                      : const Center(
                          child: CircularProgressIndicator(color: Colors.cyanAccent),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Title input
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'عنوان الفيديو',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال عنوان للفيديو';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description input
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'الوصف والوسوم (#هاشتاغ)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Upload status / Button
              BlocBuilder<VideoCubit, VideoState>(
                builder: (context, state) {
                  if (state is VideoUploading) {
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: state.progress,
                          backgroundColor: Colors.grey[800],
                          color: Colors.cyanAccent,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'جاري رفع الفيديو... ${(state.progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }

                  return Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Colors.cyanAccent, Colors.blueAccent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _upload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'نشر الآن',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80), // spacer for bottom nav bar padding
            ],
          ),
        ),
      ),
    );
  }
}
