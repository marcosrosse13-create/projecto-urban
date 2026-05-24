import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Verificar se o GPS está ativado
  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Solicitar permissão de localização
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermission.deniedForever;
    }

    return permission;
  }

  // Obter localização atual
  Future<Position?> getCurrentLocation() async {
    try {
      // Verificar se o GPS está ativado
      bool serviceEnabled = await isLocationEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Verificar permissões
      LocationPermission permission = await requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }

      // Obter posição
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Erro ao obter localização: $e');
      return null;
    }
  }

  // Obter nome do endereço a partir das coordenadas
  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        return addressParts.isNotEmpty ? addressParts.join(', ') : 'Localização desconhecida';
      }
      return 'Localização não encontrada';
    } catch (e) {
      print('Erro ao obter endereço: $e');
      return 'Erro ao obter endereço';
    }
  }

  // Verificar se há permissão de localização
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Abrir configurações de localização do dispositivo
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Abrir configurações do app
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // Calcular distância entre dois pontos (em metros)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Obter localização com timeout e retry
  Future<Position?> getCurrentLocationWithRetry({
    int maxAttempts = 3,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        Position? position = await getCurrentLocation();
        if (position != null) {
          return position;
        }
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print('Tentativa ${attempt + 1} falhou: $e');
        if (attempt == maxAttempts - 1) rethrow;
      }
    }
    return null;
  }
}

// Modelo para dados de localização
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      address: map['address'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  @override
  String toString() => '$latitude, $longitude';
}