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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// A screen for adding a new item or editing an existing one.
///
/// The screen includes fields for all item properties including storage location
/// and sales channel, plus image upload capabilities.
class AddEditItemScreen extends ConsumerStatefulWidget {
  /// The ID of the pallet this item belongs to
  final String? palletId;
  
  /// Optional item to edit. If null, a new item will be created.
  final Item? item;
  
  const AddEditItemScreen({
    Key? key,
    this.palletId,
    this.item,
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
  
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        final quantity = int.tryParse(_quantityController.text) ?? 1;
        
        // Handle purchase price based on context:
        // 1. For items without a pallet: use user-entered price
        // 2. For items in a pallet: use 0.0 initially (will be calculated later)
        final isPalletItem = widget.palletId != null && widget.palletId != 'no_pallet';
        final purchasePrice = isPalletItem 
            ? 0.0 // For pallet items, will be allocated later based on pallet cost
            : double.tryParse(_purchasePriceController.text) ?? 0.0;
            
        // Handle selling price (optional)
        final sellingPrice = _sellingPriceController.text.isNotEmpty 
            ? double.tryParse(_sellingPriceController.text) 
            : null;
        
        // Create or update the item
        if (widget.item == null) {
          // Create a new item with a temporary ID (will be replaced by DB)
          final newItem = Item(
            id: const Uuid().v4(), // Temporary ID, will be replaced by DB
            palletId: widget.palletId ?? 'no_pallet', // Use 'no_pallet' for items without a pallet
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
            // Also add to the SimpleItemListNotifier for UI updates
            // Create a SimpleItem from the real Item
            final simpleItem = SimpleItem(
              id: result.value.id,
              name: result.value.name,
              description: result.value.description,
              palletId: result.value.palletId,
              condition: result.value.condition.name,
              quantity: result.value.quantity,
              purchasePrice: result.value.purchasePrice,
              status: result.value.status.name,
              createdAt: result.value.createdAt,
            );
            ref.read(simpleItemListNotifierProvider.notifier).addItem(simpleItem);
            
            // Upload images if selected
            if (_selectedImages.isNotEmpty) {
              // Compress images first
              final compressedImages = await _compressSelectedImages();
              
              // Upload compressed images
              final uploadResult = await ref.read(itemDetailNotifierProvider(result.value.id).notifier)
                  .uploadItemPhotos(compressedImages);
              
              if (!uploadResult.isSuccess) {
                _showErrorSnackBar('Item created, but there was an error uploading images');
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
              // Compress images first
              final compressedImages = await _compressSelectedImages();
              
              // Upload compressed images
              final uploadResult = await ref.read(itemDetailNotifierProvider(widget.item!.id).notifier)
                  .uploadItemPhotos(compressedImages);
              
              if (!uploadResult.isSuccess) {
                _showErrorSnackBar('Item updated, but there was an error uploading new images');
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
    return Scaffold(
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
                              labelText: 'Purchase Price',
                              prefixText: '\$',
                              border: const OutlineInputBorder(),
                              hintText: widget.palletId != null && widget.palletId != 'no_pallet' 
                                ? 'Auto-calculated' 
                                : '0.00',
                              helperText: widget.palletId != null && widget.palletId != 'no_pallet'
                                ? 'Will be allocated from pallet'
                                : 'Enter if known',
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
    );
  }
} 