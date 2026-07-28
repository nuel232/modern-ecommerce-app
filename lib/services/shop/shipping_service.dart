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

    http.Response response;
    try {
      response = await http.get(url).timeout(const Duration(seconds: 10));

      print('ORIGIN: ${ShopConfig.originAddress}');
      print('DESTINATION: $destinationAddress');
      print('FULL URL: $url');
    } catch (e) {
      throw Exception(
        'Could not reach shipping service — check your connection',
      );
    }

    if (response.statusCode != 200) {
      throw Exception('Distance API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 'OK') {
      throw Exception(
        'Distance API error: ${data['status']} — ${data['error_message'] ?? ''}',
      );
    }

    final elements = data['rows'][0]['elements'];

    if (elements[0]['status'] != 'OK') {
      throw Exception('Could not calculate distance: ${elements[0]['status']}');
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
