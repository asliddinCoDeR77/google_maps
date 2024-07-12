import 'package:flutter/material.dart';
import 'package:google_maps/model/place.dart';
import 'package:google_maps/restaurantpage.dart';
import 'package:google_maps/widgets/add_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late GoogleMapController mapController;
  LocationData? currentLocation;
  LatLng initialPosition = const LatLng(41.2856806, 69.2034646);
  TextEditingController controller = TextEditingController();
  MapType currentMapType = MapType.normal;
  Set<Marker> markers = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};
  List<Place> places = [];
  bool _isAddingNewPlace = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    var locationService = Location();
    currentLocation = await locationService.getLocation();
    setState(() {
      _addMarker(
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        "Current Location",
        "You are here",
      );
    });
  }

  void _toggleMapType() {
    setState(() {
      currentMapType =
          currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  void _goToMyLocation() {
    if (currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _addMarker(LatLng position, String markerId, String markerTitle) {
    setState(() {
      markers.clear();
      polylines.clear();

      if (currentLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('CurrentLocation'),
            position:
                LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            infoWindow: const InfoWindow(
              title: "Current Location",
            ),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      }

      markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(
            title: markerTitle,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      if (currentLocation != null) {
        _getPolyline(
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          position,
        );
      }
    });
  }

  void _getPolyline(LatLng start, LatLng destination) async {
    List<PointLatLng> polylinePointsResult = [];
    PolylineResult? result;

    try {
      result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(start.latitude, start.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
        googleApiKey: "YOUR_GOOGLE_MAPS_API_KEY", // Replace with your API key
      );
    } catch (e) {
      print("Error fetching polyline: $e");
    }

    if (result != null && result.points.isNotEmpty) {
      for (var point in result.points) {
        polylinePointsResult.add(point);
      }

      setState(() {
        polylineCoordinates.clear();
        for (var point in polylinePointsResult) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        Polyline polyline = Polyline(
          polylineId: const PolylineId('poly'),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 6,
        );

        polylines.add(polyline);
      });
    }
  }

  void _handleMapTap(LatLng tappedPoint) {
    if (_isAddingNewPlace) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AddPlaceDialog(
          onPlaceAdded: (Place newPlace) {
            _addNewPlace(newPlace, tappedPoint);
          },
        ),
      );
    } else {
      Marker tappedMarker = markers.firstWhere(
        (marker) => marker.position == tappedPoint,
        orElse: () => markers.first,
      );
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(tappedMarker.infoWindow.title!),
          content: Text(
              'You tapped on ${tappedMarker.infoWindow.title!}. Show more details here.'),
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

  void _addNewPlace(Place newPlace, LatLng position) {
    setState(() {
      places.add(newPlace);
      _addMarker(position, newPlace.name, newPlace.address);
      _isAddingNewPlace = false;
    });
  }

  void _navigateToPlace(LatLng destination) {
    _getPolyline(
      LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      destination,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation != null
                  ? LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!)
                  : initialPosition,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onTap: _handleMapTap,
            mapType: currentMapType,
            markers: markers,
            polylines: polylines,
          ),
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: _toggleMapType,
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _goToMyLocation,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_location),
                      onPressed: () {
                        setState(() {
                          _isAddingNewPlace = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant), label: 'Restaurants'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestaurantPage(
                  places: places,
                  currentLocation: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                  onNavigateToPlace: _navigateToPlace,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
