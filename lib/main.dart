import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImagePickerGalleryScreen(),
    );
  }
}

class ImagePickerGalleryScreen extends StatefulWidget {
  @override
  _ImagePickerGalleryScreenState createState() => _ImagePickerGalleryScreenState();
}

class _ImagePickerGalleryScreenState extends State<ImagePickerGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  PageController _pageController = PageController();
  int _currentIndex = 0;

  // Pick multiple images from gallery
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  // Capture an image using the camera
  Future<void> _captureImage() async {
    final XFile? capturedFile = await _picker.pickImage(source: ImageSource.camera);
    if (capturedFile != null) {
      setState(() {
        _selectedImages.add(File(capturedFile.path));
      });
    }
  }

  // Navigate to the previous image
  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navigate to the next image
  void _goToNext() {
    if (_currentIndex < _selectedImages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick & View Images"),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: _pickImages, // Pick images from gallery
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _captureImage, // Capture image from camera
          ),
        ],
      ),
      body: _selectedImages.isEmpty
          ? Center(
        child: Text("No images selected. Tap gallery or camera icon."),
      )
          : Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PhotoViewGallery.builder(
            itemCount: _selectedImages.length,
            pageController: _pageController,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(_selectedImages[index]),
                minScale: PhotoViewComputedScale.contained * 1.0,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                heroAttributes: PhotoViewHeroAttributes(tag: index),
              );
            },
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(color: Colors.black),
          ),

          // Image Counter (1 / N)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${_currentIndex + 1} / ${_selectedImages.length}",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // Dot Indicator
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_selectedImages.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: _currentIndex == index ? 12 : 8,
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.white : Colors.grey,
                  ),
                );
              }),
            ),
          ),

          // Previous Button
          Positioned(
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
              onPressed: _goToPrevious,
            ),
          ),

          // Next Button
          Positioned(
            right: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
              onPressed: _goToNext,
            ),
          ),
        ],
      ),
    );
  }
}

