import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data' show Uint8List;
import 'package:logging/logging.dart'; // Add this import for logging

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final SupabaseService _supabaseService = SupabaseService(
    supabase: Supabase.instance.client,
  );
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _logger = Logger('AddPropertyPage'); // Create a logger instance

  // Form fields
  String _propertyName = '';
  String _address = '';
  String? _floor;
  String _city = '';
  int _bathrooms = 1;
  int _bedrooms = 1;
  int _squareFeet = 0;
  double _price = 0;
  String _description = '';
  String _type = 'Apartment';
  String _listingType = 'rent';
  final List<dynamic> _selectedImages = [];
  final List<Uint8List?> _imagePreviews = [];

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
            _selectedImages.addAll(newImages);
            _imagePreviews.addAll(newPreviews);
          });
        }
      });
    } else {
      final pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            pickedFiles.map((xFile) => File(xFile.path)).toList(),
          );
          _imagePreviews.addAll(
            List.filled(pickedFiles.length, null),
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      _logger.info('Submitting form with ${_selectedImages.length} images');
      _logger.info('Property Name: $_propertyName');
      _logger.info('Address: $_address');
      _logger.info('Floor: $_floor');
      _logger.info('City: $_city');
      _logger.info('Bathrooms: $_bathrooms');
      _logger.info('Bedrooms: $_bedrooms');
      _logger.info('Square Feet: $_squareFeet');
      _logger.info('Price: $_price');
      _logger.info('Description: $_description');
      _logger.info('Type: $_type');
      _logger.info('Listing Type: $_listingType');
      await _supabaseService.addProperty(
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
        images: _selectedImages,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property added successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding property: ${e.toString()}')),
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
      appBar: AppBar(title: const Text('Add New Property')),
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
                      child: _selectedImages.isEmpty
                          ? Center(
                              child: TextButton.icon(
                                onPressed: _pickImages,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Add Photos'),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _selectedImages.length) {
                                  return Center(
                                    child: IconButton(
                                      onPressed: _pickImages,
                                      icon:
                                          const Icon(Icons.add_photo_alternate),
                                    ),
                                  );
                                }

                                return Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: kIsWeb
                                          ? Image.memory(
                                              _imagePreviews[index]!,
                                              width: 120,
                                              height: 140,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.broken_image,
                                                      size: 120),
                                            )
                                          : Image.file(
                                              _selectedImages[index] as File,
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
                                        onPressed: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                            _imagePreviews.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
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
                        onPressed: _submitForm,
                        child: const Text(
                          'Add Property',
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
