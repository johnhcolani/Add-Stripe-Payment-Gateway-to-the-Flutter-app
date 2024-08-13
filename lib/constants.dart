import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static final String stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  static final String authorization = dotenv.env['AUTHORIZATION']!;
}