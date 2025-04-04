import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/item_detail_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/item_list_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:pallet_pro_app/src/features/inventory/presentation/widgets/image_picker_grid.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/widgets/sales_channel_dropdown.dart';
import 'package:pallet_pro_app/src/global/utils/display_utils.dart';

/// A screen for adding a new item or editing an existing one.
///
/// The screen includes fields for all item properties including storage location
/// and sales channel, plus image upload capabilities.
class AddEditItemScreen extends ConsumerStatefulWidget {
  /// For editing, null for new item
  final Item? item;
  
  /// For adding items directly to a pallet
  final String? palletId;
  
  const AddEditItemScreen({
    this.item,
    this.palletId,
    Key? key,
  }) : super(key: key);
  
  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _storageLocationController;
  late final TextEditingController _sellingPriceController;
  
  ItemCondition _selectedCondition = ItemCondition.newItem;
  String? _selectedSalesChannel;
  
  // List of selected image files
  final List<XFile> _selectedImages = [];
  
  // List of image paths for existing item (if editing)
  final List<String> _existingImagePaths = [];
  
  // List of image paths that should be deleted (if editing)
  final List<String> _imagesToDelete = [];
  
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with values from item if editing
    _nameController = TextEditingController(text: widget.item?.name);
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '1');
    _purchasePriceController = TextEditingController(
      text: widget.item?.purchasePrice?.toString() ?? '',
    );
    _storageLocationController = TextEditingController(
      text: widget.item?.storageLocation ?? '',
    );
    _sellingPriceController = TextEditingController(
      text: widget.item?.salePrice?.toString() ?? '',
    );
    
    if (widget.item != null) {
      _selectedCondition = widget.item!.condition;
      _selectedSalesChannel = widget.item!.salesChannel;
      
      // TODO: Fetch existing image paths using ItemPhotoRepository
      // For now, using empty list
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _storageLocationController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final selectedImages = await picker.pickMultiImage();
    
    if (selectedImages.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(selectedImages);
      });
    }
  }
  
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }
  
  Future<XFile> _compressImage(XFile file) async {
    // Get temp directory
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    
    // Read file as bytes
    final bytes = await file.readAsBytes();
    
    // Compress image
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 1080, // HD resolution
      minWidth: 1080,
      quality: 85, // Adjust quality as needed (higher = better quality, larger size)
    );
    
    // Write compressed bytes to a new file
    final compressedFile = File(targetPath);
    await compressedFile.writeAsBytes(result);
    
    // Return the compressed file as XFile
    return XFile(compressedFile.path);
  }
  
  Future<List<XFile>> _compressSelectedImages() async {
    final List<XFile> compressedImages = [];
    
    for (final image in _selectedImages) {
      final compressedImage = await _compressImage(image);
      compressedImages.add(compressedImage);
    }
    
    return compressedImages;
  }
  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  
  void _markExistingImageForDeletion(int index) {
    setState(() {
      _imagesToDelete.add(_existingImagePaths[index]);
      _existingImagePaths.removeAt(index);
    });
  }
  
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        // Parse form values
        final quantity = int.tryParse(_quantityController.text) ?? 1;
        
        // For items in a pallet, purchase price is 0.0 initially (will be calculated later)
        final purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
            
        // Handle selling price (optional)
        final sellingPrice = _sellingPriceController.text.isNotEmpty 
            ? double.tryParse(_sellingPriceController.text) 
            : null;
        
        // Create or update the item
        if (widget.item == null) {
          // Check if we have a valid pallet ID
          if (widget.palletId == null || widget.palletId!.isEmpty) {
            _showErrorSnackBar('A valid pallet is required to add an item');
            setState(() {
              _isSubmitting = false;
            });
            return;
          }
          
          // Create a new item with a temporary ID (will be replaced by DB)
          final newItem = Item(
            id: const Uuid().v4(), // Temporary ID, will be replaced by DB
            palletId: widget.palletId!, // Use the provided pallet ID
            name: _nameController.text,
            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
            quantity: quantity,
            purchasePrice: purchasePrice,
            salePrice: sellingPrice, // Optional sale price
            condition: _selectedCondition,
            status: ItemStatus.inStock, // New items are initially in stock
            storageLocation: _storageLocationController.text.isNotEmpty ? _storageLocationController.text : null,
            salesChannel: _selectedSalesChannel,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          // Add the item to the repository
          final result = await ref.read(itemListProvider.notifier).addItem(newItem);
          
          if (result.isSuccess) {
            // Debug logging
            print('Item created with ID: ${result.value.id}');
            
            // Properly refresh the item list provider to update the UI
            ref.invalidate(itemListProvider);
            
            // Upload images if selected
            if (_selectedImages.isNotEmpty) {
              try {
                // Compress images first
                final compressedImages = await _compressSelectedImages();
                
                print('Starting upload of ${compressedImages.length} images for item ${result.value.id}');
                
                // Upload compressed images
                final uploadResult = await ref.read(itemDetailNotifierProvider(result.value.id).notifier)
                    .uploadItemPhotos(compressedImages);
                
                if (!uploadResult.isSuccess) {
                  print('Upload error: ${uploadResult.error?.message}');
                  _showErrorSnackBar('Item created, but there was an error uploading images: ${uploadResult.error?.message}');
                } else {
                  print('Successfully uploaded ${uploadResult.value.length} images');
                }
              } catch (imageError) {
                print('Exception during image upload: $imageError');
                _showErrorSnackBar('Item created, but there was an error processing images: $imageError');
              }
            }
            
            if (mounted) {
              Navigator.of(context).pop(true); // Return success
            }
          } else {
            _showErrorSnackBar('Failed to add item: ${result.error?.message}');
          }
        } else {
          // Update the existing item
          final updatedItem = widget.item!.copyWith(
            name: _nameController.text,
            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
            quantity: quantity,
            purchasePrice: purchasePrice,
            salePrice: sellingPrice, // Optional sale price
            condition: _selectedCondition,
            storageLocation: _storageLocationController.text.isNotEmpty ? _storageLocationController.text : null,
            salesChannel: _selectedSalesChannel,
            updatedAt: DateTime.now(),
          );
          
          // Update the item
          final result = await ref.read(itemDetailNotifierProvider(widget.item!.id).notifier)
              .updateItem(updatedItem);
          
          if (result.isSuccess) {
            // Delete any marked images
            if (_imagesToDelete.isNotEmpty) {
              await ref.read(itemDetailNotifierProvider(widget.item!.id).notifier)
                  .deleteItemPhotos(_imagesToDelete);
            }
            
            // Upload new images if selected
            if (_selectedImages.isNotEmpty) {
              try {
                // Compress images first
                final compressedImages = await _compressSelectedImages();
                
                print('Starting upload of ${compressedImages.length} images for item ${widget.item!.id}');
                
                // Upload compressed images
                final uploadResult = await ref.read(itemDetailNotifierProvider(widget.item!.id).notifier)
                    .uploadItemPhotos(compressedImages);
                
                if (!uploadResult.isSuccess) {
                  print('Upload error: ${uploadResult.error?.message}');
                  _showErrorSnackBar('Item updated, but there was an error uploading new images: ${uploadResult.error?.message}');
                } else {
                  print('Successfully uploaded ${uploadResult.value.length} images');
                }
              } catch (imageError) {
                print('Exception during image upload: $imageError');
                _showErrorSnackBar('Item updated, but there was an error processing images: $imageError');
              }
            }
            
            if (mounted) {
              Navigator.of(context).pop(true); // Return success
            }
          } else {
            _showErrorSnackBar('Failed to update item: ${result.error?.message}');
          }
        }
      } catch (e) {
        _showErrorSnackBar('An error occurred: ${e is AppException ? e.message : e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Always refresh the providers when navigating back
        ref.invalidate(itemListProvider);
        return true; // Allow the screen to pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
        ),
        body: _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity*',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _purchasePriceController,
                              decoration: InputDecoration(
                                labelText: 'Purchase Price (${getCurrencySymbol()})',
                                border: const OutlineInputBorder(),
                                hintText: 'Enter purchase price',
                                helperText: 'Price paid for this item',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sellingPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Selling Price (Optional)',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                          hintText: 'Set when ready to sell',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null || double.parse(value) < 0) {
                              return 'Enter a valid price';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<ItemCondition>(
                        decoration: const InputDecoration(
                          labelText: 'Condition',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCondition,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCondition = value;
                            });
                          }
                        },
                        items: ItemCondition.values.map((condition) {
                          String displayName;
                          switch (condition) {
                            case ItemCondition.newItem:
                              displayName = 'New';
                              break;
                            case ItemCondition.openBox:
                              displayName = 'Open Box';
                              break;
                            case ItemCondition.usedGood:
                              displayName = 'Used - Good';
                              break;
                            case ItemCondition.usedFair:
                              displayName = 'Used - Fair';
                              break;
                            case ItemCondition.damaged:
                              displayName = 'Damaged';
                              break;
                            case ItemCondition.forParts:
                              displayName = 'For Parts';
                              break;
                          }
                          return DropdownMenuItem(
                            value: condition,
                            child: Text(displayName),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _storageLocationController,
                        decoration: const InputDecoration(
                          labelText: 'Storage Location',
                          hintText: 'e.g., Living Room Bin 3, Garage Shelf B',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Sales Channel',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedSalesChannel,
                        onChanged: (value) {
                          setState(() {
                            _selectedSalesChannel = value;
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'Facebook Marketplace',
                            child: Text('Facebook Marketplace'),
                          ),
                          DropdownMenuItem(
                            value: 'Facebook Group',
                            child: Text('Facebook Group'),
                          ),
                          DropdownMenuItem(
                            value: 'eBay',
                            child: Text('eBay'),
                          ),
                          DropdownMenuItem(
                            value: 'Amazon',
                            child: Text('Amazon'),
                          ),
                          DropdownMenuItem(
                            value: 'Local Pickup',
                            child: Text('Local Pickup'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                            onPressed: _pickImages,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _takePicture,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_existingImagePaths.isNotEmpty || _selectedImages.isNotEmpty)
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              // Existing images (if editing)
                              ..._existingImagePaths.asMap().entries.map((entry) {
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(
                                        entry.value, // This should be a signed URL
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () => _markExistingImageForDeletion(entry.key),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              // New selected images
                              ..._selectedImages.asMap().entries.map((entry) {
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                        File(entry.value.path),
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () => _removeImage(entry.key),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        )
                      else
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text('No photos selected'),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(
                            widget.item == null ? 'Add Item' : 'Save Changes',
                            style: const TextStyle(fontSize: 16),
                          ),
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