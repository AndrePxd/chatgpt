import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class MapController extends GetxController {
  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  final placesApiProvider =
      GoogleMapsPlaces(apiKey: 'AIzaSyDQokT0SoAgXvTySGMzAgetJ1va2sImjp4');
  final uuid = Uuid();

  GoogleMapController? mapController;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void searchPlace(BuildContext context) async {
    final prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: 'AIzaSyDQokT0SoAgXvTySGMzAgetJ1va2sImjp4',
    );
    if (prediction != null) {
      final details = await placesApiProvider.getDetailsByPlaceId(
        prediction.placeId!,
        sessionToken: uuid.v4(),
      );
      if (details.status == "OK") {
        final location = details.result.geometry?.location;
        if (location != null) {
          selectedLocation.value = LatLng(location.lat, location.lng);
          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(location.lat, location.lng),
              15.0,
            ),
          );
        }
      }
    }
  }

  void searchPlaceByAddress(BuildContext context, String address) async {
    final prediction = await placesApiProvider.autocomplete(
      address,
      sessionToken: uuid.v4(),
    );
    if (prediction.predictions.isNotEmpty) {
      final placeId = prediction.predictions[0].placeId;
      final details = await placesApiProvider.getDetailsByPlaceId(
        placeId!,
        sessionToken: uuid.v4(),
      );
      if (details.status == "OK") {
        final location = details.result.geometry?.location;
        if (location != null) {
          selectedLocation.value = LatLng(location.lat, location.lng);
          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(location.lat, location.lng),
              15.0,
            ),
          );
        }
      }
    }
  }
}

class MapWidget extends StatelessWidget {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(37.773972, -122.431297),
    zoom: 11.5,
  );

  final String direccion;

  MapWidget({Key? key, required this.direccion}) : super(key: key);

  final MapController mapController = Get.put(MapController());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Llama al método de búsqueda de dirección automáticamente después de que se construye el widget
      mapController.searchPlaceByAddress(context, direccion);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa'),
        backgroundColor: Color(0xFF212023),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar lugar',
                suffixIcon: Icon(Icons.search),
              ),
              onTap: () => mapController.searchPlace(context),
            ),
          ),
          Expanded(
            child: Obx(
              () => GoogleMap(
                onMapCreated: mapController.onMapCreated,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                initialCameraPosition: _initialCameraPosition,
                markers: mapController.selectedLocation.value != null
                    ? {
                        Marker(
                          markerId: MarkerId('selectedMarker'),
                          position: mapController.selectedLocation.value!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed),
                        ),
                      }
                    : {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
