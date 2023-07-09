import 'dart:convert';

class ScannedProduct {
  final String rfid_id;
  final String id;
  final List<String> bookIdList;
  final List<int> quantityList;
  final List<double> priceList;
  final double subtotal;
  final double estimatedTax;
  final double total;

  ScannedProduct({
    required this.rfid_id,
    required this.id,
    required this.bookIdList,
    required this.quantityList,
    required this.priceList,
    required this.subtotal,
    required this.estimatedTax,
    required this.total,
  });

  factory ScannedProduct.fromJson(Map<String, dynamic> json) {
    final scannedProductJson = json['scannedProduct'];
    return ScannedProduct(
      rfid_id: scannedProductJson['rfid_id'] ?? '',
      id: scannedProductJson['_id'],
      bookIdList: List<String>.from(scannedProductJson['bookIdList']),
      quantityList: List<int>.from(scannedProductJson['quantityList']),
      priceList: List<double>.from(scannedProductJson['priceList']),
      subtotal: scannedProductJson['subtotal'].toDouble(),
      estimatedTax: scannedProductJson['estimatedTax'].toDouble(),
      total: scannedProductJson['total'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rfid_id': rfid_id,
      'id': id,
      'bookIdList': bookIdList,
      'quantityList': quantityList,
      'priceList': priceList,
      'subtotal': subtotal,
      'estimatedTax': estimatedTax,
      'total': total,
    };
  }
}
