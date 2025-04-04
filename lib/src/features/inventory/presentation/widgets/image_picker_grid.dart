import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A reusable widget for displaying selected images in a grid with the ability
/// to add more images from camera or gallery
class ImagePickerGrid extends StatelessWidget {
  final List<XFile> selectedImages;
  final List<String> existingImageUrls;
  final Function() onPickImages;
  final Function() onTakePhoto;
  final Function(int) onRemoveImage;
  final Function(int) onRemoveExistingImage;
  
  const ImagePickerGrid({
    Key? key,
    required this.selectedImages,
    this.existingImageUrls = const [],
    required this.onPickImages,
    required this.onTakePhoto,
    required this.onRemoveImage,
    required this.onRemoveExistingImage,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Calculate total items (existing + new + add buttons)
    final int totalItems = existingImageUrls.length + selectedImages.length + 2;
    // Calculate grid columns based on width
    final int columns = MediaQuery.of(context).size.width > 600 ? 4 : 3;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: onPickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
            ElevatedButton.icon(
              onPressed: onTakePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (existingImageUrls.isEmpty && selectedImages.isEmpty)
          Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text('No photos selected'),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: totalItems,
            itemBuilder: (context, index) {
              // First show existing images
              if (index < existingImageUrls.length) {
                return _buildExistingImageItem(index);
              }
              // Then show newly selected images
              else if (index < existingImageUrls.length + selectedImages.length) {
                final newIndex = index - existingImageUrls.length;
                return _buildNewImageItem(newIndex);
              }
              // Finally show add buttons
              else {
                return index == totalItems - 2
                    ? _buildAddImageButton(context, true) // Gallery
                    : _buildAddImageButton(context, false); // Camera
              }
            },
          ),
      ],
    );
  }
  
  Widget _buildExistingImageItem(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              existingImageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => 
                Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.error),
                ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => onRemoveExistingImage(index),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNewImageItem(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              File(selectedImages[index].path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => 
                Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.error),
                ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => onRemoveImage(index),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddImageButton(BuildContext context, bool isGallery) {
    return GestureDetector(
      onTap: isGallery ? onPickImages : onTakePhoto,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(color: Colors.grey.shade300),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isGallery ? Icons.photo_library : Icons.camera_alt,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 4),
                Text(
                  isGallery ? 'Gallery' : 'Camera',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw a dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 4.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();

    // Draw top line
    double currentX = 0;
    while (currentX < size.width) {
      path.moveTo(currentX, 0);
      path.lineTo(currentX + dashWidth, 0);
      currentX += dashWidth + dashSpace;
    }

    // Draw right line
    double currentY = 0;
    while (currentY < size.height) {
      path.moveTo(size.width, currentY);
      path.lineTo(size.width, currentY + dashWidth);
      currentY += dashWidth + dashSpace;
    }

    // Draw bottom line
    currentX = size.width;
    while (currentX > 0) {
      path.moveTo(currentX, size.height);
      path.lineTo(currentX - dashWidth, size.height);
      currentX -= dashWidth + dashSpace;
    }

    // Draw left line
    currentY = size.height;
    while (currentY > 0) {
      path.moveTo(0, currentY);
      path.lineTo(0, currentY - dashWidth);
      currentY -= dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 