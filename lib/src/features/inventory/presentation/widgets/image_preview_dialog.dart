import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';

/// A full-screen dialog for previewing and managing individual photos
class ImagePreviewDialog extends StatelessWidget {
  final ItemPhoto? existingPhoto;
  final XFile? newPhoto;
  final bool isPrimary;
  final Function()? onDelete;
  final Function()? onSetPrimary;
  final Function()? onReplace;

  const ImagePreviewDialog({
    Key? key,
    this.existingPhoto,
    this.newPhoto,
    this.isPrimary = false,
    this.onDelete,
    this.onSetPrimary,
    this.onReplace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Full-screen image
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: _buildImage(),
              ),
            ),
            
            // Top app bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      if (isPrimary)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'PRIMARY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom action bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (onDelete != null)
                          _buildActionButton(
                            icon: Icons.delete,
                            label: 'Delete',
                            color: Colors.red,
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDelete!();
                            },
                          ),
                        if (onSetPrimary != null && !isPrimary)
                          _buildActionButton(
                            icon: Icons.star,
                            label: 'Set Primary',
                            color: Colors.blue,
                            onPressed: () {
                              Navigator.of(context).pop();
                              onSetPrimary!();
                            },
                          ),
                        if (onReplace != null)
                          _buildActionButton(
                            icon: Icons.swap_horiz,
                            label: 'Replace',
                            color: Colors.orange,
                            onPressed: () {
                              Navigator.of(context).pop();
                              onReplace!();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (existingPhoto != null) {
      return Image.network(
        existingPhoto!.imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  'Error loading image',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[800],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.white,
              ),
            ),
          );
        },
      );
    } else if (newPhoto != null) {
      return Image.file(
        File(newPhoto!.path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  'Error loading image',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Text(
            'No image available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// A grid widget for displaying photos with preview capability
class PhotoGridWidget extends StatelessWidget {
  final List<ItemPhoto> existingPhotos;
  final List<XFile> newPhotos;
  final Function(ItemPhoto) onExistingPhotoTap;
  final Function(XFile) onNewPhotoTap;
  final Function(ItemPhoto) onExistingPhotoDelete;
  final Function(XFile) onNewPhotoDelete;
  final Function(ItemPhoto)? onSetPrimary;

  const PhotoGridWidget({
    Key? key,
    required this.existingPhotos,
    required this.newPhotos,
    required this.onExistingPhotoTap,
    required this.onNewPhotoTap,
    required this.onExistingPhotoDelete,
    required this.onNewPhotoDelete,
    this.onSetPrimary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allPhotos = [
      ...existingPhotos.map((photo) => _PhotoItem.existing(photo)),
      ...newPhotos.map((photo) => _PhotoItem.newPhoto(photo)),
    ];

    if (allPhotos.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_camera, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No photos yet'),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: allPhotos.length,
      itemBuilder: (context, index) {
        final photoItem = allPhotos[index];
        return _buildPhotoThumbnail(context, photoItem);
      },
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context, _PhotoItem photoItem) {
    return GestureDetector(
      onTap: () => _showPreviewDialog(context, photoItem),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: photoItem.isExisting 
                    ? Colors.grey.shade300 
                    : Colors.green.shade300,
                width: photoItem.isExisting ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: photoItem.isExisting
                  ? Image.network(
                      photoItem.existingPhoto!.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => 
                        Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.error),
                        ),
                    )
                  : Image.file(
                      File(photoItem.newPhoto!.path),
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
          
          // Status indicators
          if (photoItem.isExisting && photoItem.existingPhoto!.isPrimary)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PRIMARY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          if (!photoItem.isExisting)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                if (photoItem.isExisting) {
                  onExistingPhotoDelete(photoItem.existingPhoto!);
                } else {
                  onNewPhotoDelete(photoItem.newPhoto!);
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, _PhotoItem photoItem) {
    showDialog(
      context: context,
      builder: (context) => ImagePreviewDialog(
        existingPhoto: photoItem.existingPhoto,
        newPhoto: photoItem.newPhoto,
        isPrimary: photoItem.isExisting && photoItem.existingPhoto!.isPrimary,
        onDelete: () {
          if (photoItem.isExisting) {
            onExistingPhotoDelete(photoItem.existingPhoto!);
          } else {
            onNewPhotoDelete(photoItem.newPhoto!);
          }
        },
        onSetPrimary: photoItem.isExisting && onSetPrimary != null
            ? () => onSetPrimary!(photoItem.existingPhoto!)
            : null,
        onReplace: () {
          // TODO: Implement replace functionality
        },
      ),
    );
  }
}

/// Helper class to represent either an existing photo or a new photo
class _PhotoItem {
  final ItemPhoto? existingPhoto;
  final XFile? newPhoto;
  
  _PhotoItem.existing(this.existingPhoto) : newPhoto = null;
  _PhotoItem.newPhoto(this.newPhoto) : existingPhoto = null;
  
  bool get isExisting => existingPhoto != null;
}
