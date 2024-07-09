// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    var locationService = Location();
    currentLocation = await locationService.getLocation();
    setState(() {
      currentLocation = currentLocation;
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
        googleApiKey: "AIzaSyC_QSwHlHXbLrprGX1NpXevP948eY8FtXM",
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
          width: 3,
        );

        polylines.add(polyline);
      });
    }
  }

  void _handleMapTap(LatLng tappedPoint) {
    if (currentLocation != null) {
      setState(() {
        markers.clear();
        polylines.clear();

        _addMarker(tappedPoint, "Destination", "Destination");

        if (currentLocation != null) {
          _getPolyline(
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            tappedPoint,
          );
        }

        mapController.animateCamera(
          CameraUpdate.newLatLng(tappedPoint),
        );
      });
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GooglePlacesAutoCompleteTextFormField(
                        textEditingController: controller,
                        googleAPIKey: "AIzaSyC_QSwHlHXbLrprGX1NpXevP948eY8FtXM",
                        debounceTime: 400,
                        isLatLngRequired: true,
                        itmClick: (prediction) {
                          if (prediction.lat != null &&
                              prediction.lng != null) {
                            controller.text = prediction.description!;
                            controller.selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: prediction.description!.length,
                              ),
                            );
                            mapController.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(
                                  prediction.lat as double,
                                  prediction.lng as double,
                                ),
                              ),
                            );
                            _handleMapTap(LatLng(
                              prediction.lat as double,
                              prediction.lng as double,
                            ));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _toggleMapType,
            child: const Icon(
              Icons.layers,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _goToMyLocation,
            child: const Icon(
              Icons.location_on,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
