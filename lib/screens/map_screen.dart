import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/suggestion_provider.dart';
import '../models/suggestion_model.dart';
import 'suggestion_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};

  static const LatLng _maputoCenter = LatLng(-25.969, 32.573);

  final Map<String, Color> _categoryColors = {
    'Mobilidade': Colors.orange,
    'Iluminação': Colors.amber,
    'Lazer': Colors.green,
    'Saneamento': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  void _loadSuggestions() {
    final provider = Provider.of<SuggestionProvider>(context, listen: false);
    provider.getSuggestionsStream().listen((suggestions) {
      _updateMarkers(suggestions);
    });
  }

  void _updateMarkers(List<SuggestionModel> suggestions) {
    setState(() {
      _markers.clear();

      for (var suggestion in suggestions) {
        final marker = Marker(
          markerId: MarkerId(suggestion.id),
          position: LatLng(suggestion.latitude, suggestion.longitude),
          icon: _getMarkerIcon(suggestion.category, suggestion.status),
          infoWindow: InfoWindow(
            title: suggestion.title,
            snippet: '${suggestion.votes} apoios | ${suggestion.category}',
            onTap: () {
              _showSuggestionDetail(suggestion);
            },
          ),
          onTap: () {
            _showSuggestionBottomSheet(suggestion);
          },
        );
        _markers.add(marker);
      }

      // Add administrative regions (districts of Maputo)
      _addMaputoDistricts();
    });
  }

  BitmapDescriptor _getMarkerIcon(String category, String status) {
    // Using default marker with custom colors
    // For custom icons, you would load from assets
    return BitmapDescriptor.defaultMarkerWithHue(
      _getMarkerHue(category),
    );
  }

  double _getMarkerHue(String category) {
    switch (category) {
      case 'Mobilidade':
        return BitmapDescriptor.hueOrange;
      case 'Iluminação':
        return BitmapDescriptor.hueYellow;
      case 'Lazer':
        return BitmapDescriptor.hueGreen;
      case 'Saneamento':
        return BitmapDescriptor.hueBlue;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _addMaputoDistricts() {
    // Adding Maputo city boundary (simplified)
    _polygons.add(
      Polygon(
        polygonId: const PolygonId('maputo_boundary'),
        points: _getMaputoBoundary(),
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.blue.withOpacity(0.1),
      ),
    );
  }

  List<LatLng> _getMaputoBoundary() {
    // Simplified Maputo city boundary coordinates
    return [
      const LatLng(-25.850, 32.450),
      const LatLng(-25.850, 32.700),
      const LatLng(-26.050, 32.700),
      const LatLng(-26.050, 32.450),
      const LatLng(-25.850, 32.450),
    ];
  }

  void _showSuggestionDetail(SuggestionModel suggestion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuggestionDetailScreen(suggestion: suggestion),
      ),
    );
  }

  void _showSuggestionBottomSheet(SuggestionModel suggestion) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _categoryColors[suggestion.category]?.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      suggestion.category,
                      style: TextStyle(
                        color: _categoryColors[suggestion.category],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${suggestion.votes}'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                suggestion.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                suggestion.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(suggestion.userName, style: const TextStyle(fontSize: 12)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSuggestionDetail(suggestion);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Ver detalhes'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Sugestões'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
            tooltip: 'Minha localização',
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _showLegend,
            tooltip: 'Legenda',
          ),
        ],
      ),
      body: Consumer<SuggestionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _maputoCenter,
              zoom: 12.0,
            ),
            markers: _markers,
            polygons: _polygons,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
          );
        },
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (_mapController != null) {
      // For now, center on Maputo
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: _maputoCenter,
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Legenda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem('Mobilidade', Colors.orange),
            _buildLegendItem('Iluminação', Colors.amber),
            _buildLegendItem('Lazer', Colors.green),
            _buildLegendItem('Saneamento', Colors.blue),
            const Divider(),
            _buildLegendItem('Pendente', Colors.grey),
            _buildLegendItem('Em Progresso', Colors.orange),
            _buildLegendItem('Concluído', Colors.green),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}