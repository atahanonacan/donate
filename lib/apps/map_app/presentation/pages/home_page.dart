import 'dart:io';
import 'package:donate/apps/map_app/domain/model/alert_model.dart';
import 'package:donate/apps/map_app/presentation/controller/alert_controller.dart';
import 'package:donate/apps/map_app/presentation/controller/location_controller.dart';
import 'package:donate/apps/map_app/presentation/widgets/menu_widget.dart';
import 'package:donate/core/ui/widgets/custom_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/toolset/ui/custom_icons_icons.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool menuOpened = false;
  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(alertsProvider);
    final location = ref.watch(locationProvider);
    return Scaffold(
        body: ColoredBox(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        child: ColoredBox(
          color: Colors.white,
          child: Stack(children: [
            _buildMap(alerts, location),
            if (!menuOpened)
              Padding(
                  // Menu Button
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton.filled(
                    onPressed: () {
                      setState(() {
                        menuOpened = true;
                      });
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(16.0),
                      )),
                      iconSize: 36,
                    ),
                    icon: const Icon(
                      CustomIcons.menu,
                    ),
                  )),
            Positioned(
              right: 0,
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/account');
                    },
                    icon: Image.asset(
                      'assets/images/logo_shadow.png',
                      width: 60,
                    ),
                  )),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/list');
                  },
                  label: const Text('List View'),
                ),
              ),
            ),
            if (menuOpened)
              FoldableMenu(onBackPressed: () {
                setState(() {
                  menuOpened = false;
                });
              })
          ]),
        ),
      ),
    ));
  }

  Widget _buildMap(
      AsyncValue<List<Alert>> asyncAlerts, AsyncValue<Position> asyncLocation) {
    if (!Platform.isAndroid) {
      return const Text("This app is only available on Android");
    }
    if (asyncLocation is AsyncError || asyncAlerts is AsyncError) {
      debugPrint(asyncLocation.error.toString() + asyncAlerts.error.toString());
      return const Text("An error occured");
    } else if (asyncLocation is AsyncLoading || asyncAlerts is AsyncLoading) {
      return const CustomProgressIndicator();
    }

    final alertSet = asyncAlerts.value!
        .map((e) => Marker(
              infoWindow: InfoWindow(title: e.description),
              markerId: const MarkerId('Your Location'),
              position: LatLng(e.position.latitude, e.position.longitude),
            ))
        .toSet();
    final location = asyncLocation.value!;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        zoom: 11.0,
      ),
      markers: alertSet,
    );
  }
}
