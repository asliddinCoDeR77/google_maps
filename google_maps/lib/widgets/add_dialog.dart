import 'package:flutter/material.dart';
import 'package:google_maps/model/place.dart';

class AddPlaceDialog extends StatefulWidget {
  final Function(Place) onPlaceAdded;

  const AddPlaceDialog({Key? key, required this.onPlaceAdded})
      : super(key: key);

  @override
  _AddPlaceDialogState createState() => _AddPlaceDialogState();
}

class _AddPlaceDialogState extends State<AddPlaceDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _reviewsController = TextEditingController();
  String _imagePath = ''; // Store the image path here

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Place'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Place Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _reviewsController,
              decoration: const InputDecoration(labelText: 'Reviews'),
            ),
            // Add an input for image path or implement image picking
            TextField(
              controller: TextEditingController(text: _imagePath),
              decoration: const InputDecoration(labelText: 'Image Path'),
              onChanged: (value) {
                _imagePath = value;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _addressController.text.isNotEmpty &&
                _phoneController.text.isNotEmpty &&
                _reviewsController.text.isNotEmpty) {
              final newPlace = Place(
                name: _nameController.text,
                address: _addressController.text,
                image: _imagePath,
                phoneNumber: _phoneController.text,
                reviews: _reviewsController.text,
                latitude: 0.0, // Set this based on the selected location
                longitude: 0.0, // Set this based on the selected location
              );
              widget.onPlaceAdded(newPlace);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add Place'),
        ),
      ],
    );
  }
}
