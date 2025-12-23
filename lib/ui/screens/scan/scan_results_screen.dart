import 'package:flutter/material.dart';
import 'package:the_anti_basi/data/models/inventory_item.dart'; // Import InventoryItem

class ScanResultsScreen extends StatelessWidget {
  final InventoryItem item; // Expect an InventoryItem to be passed

  const ScanResultsScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Scanned Item: ${item.name}'),
            Text('Category: ${item.category.name}'),
            Text('Quantity: ${item.quantity} ${item.unit}'),
            Text('Expiry Date: ${item.expiryDate.toLocal().toString().split(' ')[0]}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}