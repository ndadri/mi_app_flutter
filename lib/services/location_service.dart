import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    // Verificar si el servicio de ubicación está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  static Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Construir dirección legible
        String address = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.subLocality!;
        }
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }
        
        return address.isNotEmpty ? address : 'Ubicación desconocida';
      }
      
      return null;
    } catch (e) {
      print('Error en reverse geocoding: $e');
      return null;
    }
  }

  static Future<String?> getCurrentAddress() async {
    try {
      Position? position = await getCurrentLocation();
      if (position == null) return null;

      String? address = await getAddressFromCoordinates(
        position.latitude, 
        position.longitude
      );

      return address;
    } catch (e) {
      print('Error obteniendo dirección actual: $e');
      return null;
    }
  }
}
