import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:payment_app/constants.dart';
import 'package:payment_app/payment_page.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");
  /// set the publishable key form my Strip

  Stripe.publishableKey = Constants.stripePublishableKey;
  Stripe.merchantIdentifier = 'com.johncolani.paymentApp'; // Add your Merchant ID here

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stripe Payment Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaymentPage(),
    );
  }
}