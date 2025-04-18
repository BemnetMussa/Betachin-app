// lib/screens/edit_property_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';
import '../services/supabase_service.dart';

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

  // Form fields
  late String _propertyName;
  late String _address;
  String? _floor;
  late String _city;
  late int _bathrooms;
  late int _bedrooms;
  late int _squareFeet;
  late double _price;
  late String _description;
  late String _type;
  late String _listingType;
  List<String> _existingImageUrls = [];
  final List<File> _newImages = [];
  final List<String> _imagesToDelete = [];

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
    _initializeFormValues();
  }

  void _initializeFormValues() {
    final property = widget.property;

    _propertyName = property.propertyName;
    _address = property.address;
    _floor = property.floor;
    _city = property.city;
    _bathrooms = property.bathrooms;
    _bedrooms = property.bedrooms;
    _squareFeet = property.squareFeet;
    _price = property.price;
    _description = property.description;
    _type = property.type;
    _listingType = property.listingType;
    _existingImageUrls = List<String>.from(property.imageUrls);
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(
          pickedFiles.map((xFile) => File(xFile.path)).toList(),
        );
      });
    }
  }

  void _removeExistingImage(String imageUrl) {
    setState(() {
      _existingImageUrls.remove(imageUrl);
      _imagesToDelete.add(imageUrl);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
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
        newImages: _newImages,
        imagesToDelete: _imagesToDelete,
      );

      // Add mounted check to avoid using BuildContext across async gaps
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      // Add mounted check to avoid using BuildContext across async gaps
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating property: ${e.toString()}')),
      );
    } finally {
      // Add mounted check before setState
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Property')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Images section
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
                        child:
                            _existingImageUrls.isEmpty && _newImages.isEmpty
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
                                    ..._existingImageUrls.map(
                                      (imageUrl) => Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Image.network(
                                              imageUrl,
                                              width: 120,
                                              height: 140,
                                              fit: BoxFit.cover,
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
                                              onPressed:
                                                  () => _removeExistingImage(
                                                    imageUrl,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // New images
                                    ..._newImages.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final file = entry.value;

                                      return Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Image.file(
                                              file,
                                              width: 120,
                                              height: 140,
                                              fit: BoxFit.cover,
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
                                              onPressed:
                                                  () => _removeNewImage(index),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),

                                    // Add button
                                    Center(
                                      child: IconButton(
                                        onPressed: _pickImages,
                                        icon: const Icon(
                                          Icons.add_photo_alternate,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Listing type
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

                      // Property name
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Property Name *',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _propertyName,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter property name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _propertyName = value!;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _address,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _address = value!;
                        },
                      ),
                      const SizedBox(height: 16),

                      // City and Floor
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'City *',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: _city,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter city';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _city = value!;
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
                              initialValue: _floor,
                              onSaved: (value) {
                                _floor = value;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Property type
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Property Type *',
                          border: OutlineInputBorder(),
                        ),
                        value: _type,
                        items:
                            _propertyTypes.map((type) {
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

                      // Price
                      TextFormField(
                        decoration: InputDecoration(
                          labelText:
                              'Price * (${_listingType == 'rent' ? 'per night' : 'total'})',
                          border: const OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        initialValue: _price.toString(),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _price = double.parse(value!);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Bedrooms and Bathrooms
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Square feet
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Square Feet *',
                          border: OutlineInputBorder(),
                          suffixText: 'sq ft',
                        ),
                        initialValue: _squareFeet.toString(),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter square feet';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _squareFeet = int.parse(value!);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        initialValue: _description,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _description = value!;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text(
                            'Save Changes',
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
