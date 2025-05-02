import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';
import '../services/supabase_service.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data' show Uint8List;
import 'package:logging/logging.dart';

class EditPropertyPage extends StatefulWidget {
  final PropertyModel property;

  const EditPropertyPage({super.key, required this.property});

  @override
  State<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _logger = Logger('EditPropertyPage');

  // Form fields
  late String _propertyName;
  late String _address;
  late String? _floor;
  late String _city;
  late int _bathrooms;
  late int _bedrooms;
  late int _squareFeet;
  late double _price;
  late String _description;
  late String _type;
  late String _listingType;

  // Keep track of existing images and newly added ones
  final List<String> _existingImages = [];
  final List<String> _imagesToDelete = [];
  final List<dynamic> _newImages = [];
  final List<Uint8List?> _newImagePreviews = [];

  bool _isLoading = false;

  final List<String> _propertyTypes = [
    'Apartment',
    'House',
    'Villa',
    'Condo',
    'Townhouse',
    'Office',
    'Commercial',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize form values from existing property
    _propertyName = widget.property.propertyName;
    _address = widget.property.address;
    _floor = widget.property.floor;
    _city = widget.property.city;
    _bathrooms = widget.property.bathrooms;
    _bedrooms = widget.property.bedrooms;
    _squareFeet = widget.property.squareFeet;
    _price = widget.property.price;
    _description = widget.property.description;
    _type = widget.property.type;
    _listingType = widget.property.listingType;

    // Load existing images
    if (_existingImages.isEmpty && _newImages.isEmpty) {
      _formKey.currentState!.save();
    }
  }

  Future<void> _pickImages() async {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.multiple = true;
      input.click();

      input.onChange.listen((event) async {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final newImages = <html.File>[];
          final newPreviews = <Uint8List?>[];

          for (var file in files) {
            newImages.add(file);
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);
            await reader.onLoadEnd.first;
            newPreviews.add(reader.result as Uint8List?);
          }

          setState(() {
            _newImages.addAll(newImages);
            _newImagePreviews.addAll(newPreviews);
          });
        }
      });
    } else {
      final pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newImages.addAll(
            pickedFiles.map((xFile) => File(xFile.path)).toList(),
          );
          _newImagePreviews.addAll(
            List.filled(pickedFiles.length, null),
          );
        });
      }
    }
  }

  void _removeExistingImage(String imageUrl) {
    setState(() {
      _existingImages.remove(imageUrl);
      _imagesToDelete.add(imageUrl);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
      _newImagePreviews.removeAt(index);
    });
  }

  Future<void> _updateProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_existingImages.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      _logger.info('Updating property ID: ${widget.property.id}');
      _logger.info('Property Name: $_propertyName');
      _logger.info('Existing images count: ${_existingImages.length}');
      _logger.info('New images count: ${_newImages.length}');
      _logger.info('Images to delete count: ${_imagesToDelete.length}');

      await _supabaseService.updateProperty(
        propertyId: widget.property.id,
        propertyName: _propertyName,
        address: _address,
        floor: _floor,
        city: _city,
        bathrooms: _bathrooms,
        bedrooms: _bedrooms,
        squareFeet: _squareFeet,
        price: _price,
        description: _description,
        type: _type,
        listingType: _listingType,
        newImages: _newImages.isNotEmpty ? _newImages : null,
        imagesToDelete: _imagesToDelete.isNotEmpty ? _imagesToDelete : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating property: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Property')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Property Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: (_existingImages.isEmpty && _newImages.isEmpty)
                          ? Center(
                              child: TextButton.icon(
                                onPressed: _pickImages,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Add Photos'),
                              ),
                            )
                          : ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // Existing images
                                ..._existingImages.map((url) => Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Image.network(
                                            url,
                                            width: 120,
                                            height: 140,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 120),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _removeExistingImage(url),
                                          ),
                                        ),
                                      ],
                                    )),
                                // New images
                                ..._newImages.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  return Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: kIsWeb
                                            ? Image.memory(
                                                _newImagePreviews[index]!,
                                                width: 120,
                                                height: 140,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(
                                                        Icons.broken_image,
                                                        size: 120),
                                              )
                                            : Image.file(
                                                _newImages[index] as File,
                                                width: 120,
                                                height: 140,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(
                                                        Icons.broken_image,
                                                        size: 120),
                                              ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _removeNewImage(index),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                // Add more button
                                Center(
                                  child: IconButton(
                                    onPressed: _pickImages,
                                    icon: const Icon(Icons.add_photo_alternate),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Listing Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('For Rent'),
                            value: 'rent',
                            groupValue: _listingType,
                            onChanged: (value) {
                              setState(() {
                                _listingType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('For Sale'),
                            value: 'buy',
                            groupValue: _listingType,
                            onChanged: (value) {
                              setState(() {
                                _listingType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _propertyName,
                      decoration: const InputDecoration(
                        labelText: 'Property Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter property name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _propertyName = value!.trim();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _address,
                      decoration: const InputDecoration(
                        labelText: 'Address *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _address = value!.trim();
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: _city,
                            decoration: const InputDecoration(
                              labelText: 'City *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter city';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _city = value!.trim();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _floor,
                            decoration: const InputDecoration(
                              labelText: 'Floor',
                              border: OutlineInputBorder(),
                            ),
                            onSaved: (value) {
                              _floor = value?.trim();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Property Type *',
                        border: OutlineInputBorder(),
                      ),
                      value: _type,
                      items: _propertyTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _type = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select property type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _price.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Price *',
                        hintText:
                            'Enter price (per night for rent, total for sale)',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter price';
                        }
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _price = double.parse(value!.trim());
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Bedrooms *',
                              border: OutlineInputBorder(),
                            ),
                            value: _bedrooms,
                            items: List.generate(10, (index) {
                              return DropdownMenuItem(
                                value: index + 1,
                                child: Text('${index + 1}'),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _bedrooms = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select number of bedrooms';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Bathrooms *',
                              border: OutlineInputBorder(),
                            ),
                            value: _bathrooms,
                            items: List.generate(10, (index) {
                              return DropdownMenuItem(
                                value: index + 1,
                                child: Text('${index + 1}'),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _bathrooms = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select number of bathrooms';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _squareFeet.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Square Feet *',
                        border: OutlineInputBorder(),
                        suffixText: 'sq ft',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter square feet';
                        }
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _squareFeet = int.parse(value!.trim());
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _description = value!.trim();
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _updateProperty,
                        child: const Text(
                          'Update Property',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
