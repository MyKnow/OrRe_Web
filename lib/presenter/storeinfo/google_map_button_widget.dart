import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../model/store_info_model.dart';
import 'package:orre_web/widget/text/text_widget.dart';

// 상태 관리를 위한 Provider
final locationToggleProvider =
    StateNotifierProvider<LocationToggleNotifier, bool>((ref) {
  return LocationToggleNotifier();
});

class LocationToggleNotifier extends StateNotifier<bool> {
  LocationToggleNotifier() : super(true);

  void toggle() => state = !state;
}

class GoogleMapButtonWidget extends ConsumerWidget {
  final StoreDetailInfo storeInfo;

  const GoogleMapButtonWidget({required this.storeInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.map, color: Colors.white),
      onPressed: () async {
        final LatLng coordinates = LatLng(
            storeInfo.locationInfo.latitude, storeInfo.locationInfo.longitude);
        final storeName = storeInfo.storeName;

        // GoogleMapWidget으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GoogleMapWidget(coordinates: coordinates, storeName: storeName),
          ),
        );
      },
    );
  }
}

class GoogleMapWidget extends ConsumerStatefulWidget {
  final LatLng coordinates;
  final String storeName;

  GoogleMapWidget({
    required this.coordinates,
    required this.storeName,
  });

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends ConsumerState<GoogleMapWidget> {
  late GoogleMapController _mapController;
  late Location _location;
  Marker? _storeMarker;

  @override
  void initState() {
    super.initState();
    _location = Location();
    _storeMarker = Marker(
      markerId: MarkerId(widget.storeName),
      position: widget.coordinates,
    );
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _moveToLocation(LatLng target) async {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 18.0,
        ),
      ),
    );
  }

  Future<void> _toggleLocation(WidgetRef ref) async {
    final isAtStoreLocation = ref.read(locationToggleProvider);
    if (isAtStoreLocation) {
      try {
        final locationData = await _location.getLocation();
        LatLng currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
        await _moveToLocation(currentLocation);
      } catch (e) {
        print('Error getting location: $e');
      }
    } else {
      await _moveToLocation(widget.coordinates);
    }
    ref.read(locationToggleProvider.notifier).toggle();
  }

  @override
  Widget build(BuildContext context) {
    final isAtStoreLocation = ref.watch(locationToggleProvider);
    final currentIcon = isAtStoreLocation ? Icons.my_location : Icons.store;

    return Scaffold(
      appBar: AppBar(
        title: TextWidget('${widget.storeName} 위치',
            color: Colors.white, fontSize: 32),
        backgroundColor: Color(0xFFFFB74D),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.coordinates,
              zoom: 18.0,
            ),
            markers: {_storeMarker!},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              onPressed: () => _toggleLocation(ref),
              child: Icon(currentIcon),
              backgroundColor: Color(0xFFFFB74D),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
