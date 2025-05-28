import 'package:flutter/material.dart';

import '../models/subscription_plan.dart';


class SubscriptionScreen extends StatelessWidget {

final List<SubscriptionPlan> plans;

const SubscriptionScreen({required this.plans});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Subscription Plans')),
    body: ListView.builder(
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Card(
          child: ListTile(
            title: Text(plan.name),
            subtitle: Text('Features: ${plan.features.join(', ')}'),
            trailing: Text('\$${plan.price.toStringAsFixed(2)}'),
            onTap: () {
              // Logic to handle plan selection
            },
          ),
        );
      },
    ),
  );
}
}