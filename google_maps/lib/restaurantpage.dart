import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps/model/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantPage extends StatefulWidget {
  final List<Place> places;
  final LatLng currentLocation;
  final Function(LatLng) onNavigateToPlace;

  const RestaurantPage({
    Key? key,
    required this.places,
    required this.currentLocation,
    required this.onNavigateToPlace,
  }) : super(key: key);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
      ),
      body: ListView.builder(
        itemCount: widget.places.length,
        itemBuilder: (context, index) {
          final place = widget.places[index];
          return Card(
            child: ListTile(
              title: Text(place.name),
              subtitle: Text(place.address),
              leading: Image.file(
                File(place.image),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editPlace(context, index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deletePlace(index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.directions),
                    onPressed: () {
                      widget.onNavigateToPlace(LatLng(
                        place.latitude,
                        place.longitude,
                      ));
                    },
                  ),
                ],
              ),
              onTap: () {
                _showPlaceDetails(context, place);
              },
            ),
          );
        },
      ),
    );
  }

  void _editPlace(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlacePage(place: widget.places[index]),
      ),
    ).then((updatedPlace) {
      if (updatedPlace != null) {
        setState(() {
          widget.places[index] = updatedPlace;
        });
      }
    });
  }

  void _deletePlace(int index) {
    setState(() {
      widget.places.removeAt(index);
    });
  }

  void _showPlaceDetails(BuildContext context, Place place) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(place.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(place.image)),
            Text('Address: ${place.address}'),
            Text('Phone: ${place.phoneNumber}'),
            Text('Reviews: ${place.reviews}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class EditPlacePage extends StatefulWidget {
  final Place place;

  const EditPlacePage({Key? key, required this.place}) : super(key: key);

  @override
  _EditPlacePageState createState() => _EditPlacePageState();
}

class _EditPlacePageState extends State<EditPlacePage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _reviewsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place.name);
    _addressController = TextEditingController(text: widget.place.address);
    _phoneController = TextEditingController(text: widget.place.phoneNumber);
    _reviewsController = TextEditingController(text: widget.place.reviews);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _reviewsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Place'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveChanges();
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    final updatedPlace = Place(
      name: _nameController.text,
      address: _addressController.text,
      image: widget.place.image,
      phoneNumber: _phoneController.text,
      reviews: _reviewsController.text,
      latitude: widget.place.latitude,
      longitude: widget.place.longitude,
    );
    Navigator.of(context).pop(updatedPlace);
  }
}
