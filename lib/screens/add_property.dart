// lib/screens/add_property_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

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
  String _listingType = 'rent'; // 'rent' or 'buy'
  // ignore: prefer_final_fields
  List<File> _selectedImages = []; // Can't be final because we modify it

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
    final pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(
          pickedFiles.map((xFile) => File(xFile.path)).toList(),
        );
      });
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
                            _selectedImages.isEmpty
                                ? Center(
                                  child: TextButton.icon(
                                    onPressed: _pickImages,
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: const Text('Add Photos'),
                                  ),
                                )
                                : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      _selectedImages.length +
                                      1, // +1 for add button
                                  itemBuilder: (context, index) {
                                    if (index == _selectedImages.length) {
                                      return Center(
                                        child: IconButton(
                                          onPressed: _pickImages,
                                          icon: const Icon(
                                            Icons.add_photo_alternate,
                                          ),
                                        ),
                                      );
                                    }

                                    return Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Image.file(
                                            _selectedImages[index],
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
                                            onPressed: () {
                                              setState(() {
                                                _selectedImages.removeAt(index);
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
