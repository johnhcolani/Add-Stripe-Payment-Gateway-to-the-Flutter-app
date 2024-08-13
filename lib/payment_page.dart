import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:payment_app/constants.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment() async {
    try {
      // Create a payment intent on your backend and retrieve the client secret
      Map<String, dynamic>? paymentIntent =
      await createPaymentIntent('20', 'USD');

      if (paymentIntent == null || paymentIntent['client_secret'] == null) {
        throw Exception('Failed to retrieve client secret from payment intent');
      }

      // Initialize the payment sheet with the client secret
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'US',
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
          style: ThemeMode.dark,
          merchantDisplayName: 'Demo Store',
        ),
      );

      // Display the payment sheet
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful")),
      );
    } catch (e) {
      if (e is StripeException) {
        if (e.error.code == 'Canceled') {
          // User canceled the payment sheet, do not show an error message
          print('Payment sheet was canceled by the user.');
          return;
        }
        // Handle other Stripe exceptions
        print('Error from Stripe: ${e.error.localizedMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stripe says: ${e.error.localizedMessage}')),
        );
      } else {
        // Handle any other unforeseen errors
        print('Unforeseen error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unforeseen error: $e')),
        );
      }
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful")),
        );

        paymentIntent = null;
      });
    } on StripeException catch (e) {
      print("Error from Stripe: ${e.error.localizedMessage}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.error.localizedMessage}")),
      );
    } catch (e) {
      print("Unforeseen error: $e");
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(String amount,
      String currency) async {
    try {
      // Define the request payload
      final Map<String, String> body = {
        'amount': (int.parse(amount) * 100)
            .toString(), // Stripe requires the amount in cents
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      // Make the API call to create a Payment Intent
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': Constants.authorization,

          // Your secret key here
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      // Log the response to see what's returned
      print('Stripe API response: ${response.body}');
      // Check if the response is successful
      if (response.statusCode == 200) {
        return json.decode(response.body); // Parse the response as JSON
      } else {
        print('Error creating payment intent: ${response.body}');
        return null;
      }
    } catch (err) {
      print('Error creating payment intent: $err');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/img.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.6),
        body: SafeArea(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 32,),
              SizedBox(
                width: 300,
                height: height * 0.2,
                child: Image.asset('assets/images/img_4.png'),
              ),
              SizedBox(height: height * 0.02),
              // Add some space between the images
              SizedBox(
                width: 250,
                height: 100,
                child: Image.asset('assets/images/logo-stripe.png'),
              ),
              SizedBox(height: height * 0.02),
              // Add some space between the logo and text
              Text(
                'Stripe Payment Gateway',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center, // Center the text
              ),
              SizedBox(height: height * 0.02),
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset('assets/images/img_3.png'),
              ),

              // Push the button to the bottom
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () async {
                    await makePayment();
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFA19343), // Golden color
                          Color(0xFFE1C460), // Lighter golden color
                          Color(0xFFA19343), // Golden color
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.1, 0.5, 0.9],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Make Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.1),
              // Add some space below the button
            ],
          ),
        ),
      ),
    );
  }
}