import 'package:city_cab/screens/main_screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../models/direction_details.dart';
import '../../resources/assistant/assistant_methods.dart';

class PaymentAndRatingScreen extends StatelessWidget {
  DirectionDetails? tripDirectionDetails;


  PaymentAndRatingScreen(this.tripDirectionDetails, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment and Rating'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment Section
            Card(
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // Add your payment-related widgets here
                    // For example, credit card info, payment amount, etc.
                    const Text('Cash: **** **** ****'),
                    Text("Amount: ৳${AssistantMethods.calculateFares(tripDirectionDetails!, 1)}"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            // Rating Section
            Card(
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Rate Your Experience',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    // Rating Bar
                    RatingBar.builder(
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 30.0,
                      itemBuilder: (context, _) =>
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                      onRatingUpdate: (rating) {
                        // Handle rating updates
                        print('Rated: $rating');
                      },
                    ),
                    SizedBox(height: 10.0),
                    // Additional feedback or comments input
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Add comments (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10.0),
                    // Submit Rating Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (builder)=>MainScreen()));
                        // Handle submit rating
                        print('Rating Submitted!');
                      },
                      child: Text('Submit Rating'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}