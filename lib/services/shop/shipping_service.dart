import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:morden_ecommerce_app/util/shipping_config.dart';

class ShippingService {
  static String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static Future<double> getDistanceInKm(String destinationAddress) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json'
      '?origins=${Uri.encodeComponent(ShopConfig.originAddress)}'
      '&destinations=${Uri.encodeComponent(destinationAddress)}'
      '&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to reach distance API');
    }

    final data = jsonDecode(response.body);
    final elements = data['rows']?[0]?['elements'];

    if (elements == null || elements[0]['status'] != 'OK') {
      throw Exception('Could not calculate distance for that address');
    }

    final distanceMeters = elements[0]['distance']['value'];
    return distanceMeters / 1000;
  }

  static Future<double> calculateShippingCost({
    required String destinationAddress,
    required bool isExpress,
  }) async {
    final distanceInKm = await getDistanceInKm(destinationAddress);
    final rates = await ShippingConfig.fetchRates();

    double cost = rates['baseFee']! + (distanceInKm * rates['ratePerKm']!);
    if (isExpress) {
      cost *= rates['expressMultiplier']!;
    }

    return cost.roundToDouble();
  }
}
