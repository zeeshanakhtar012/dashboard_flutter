import 'package:cloud_firestore/cloud_firestore.dart';

class Module {
  String? assetType;
  String? name;
  List<String> images; // Assuming images will be a list of URLs
  String? location;
  String? retailerAddress;
  String? retailerName;
  String? time; // Can be a String or DateTime depending on your preference
  String? visitDate;
  String? companyAsset; // Only used for MarketIntelligence
  List<Map<String, dynamic>> dataByDate; // Add this field to hold dataByDate documents

  Module({
    this.assetType,
    required this.images,
    this.location,
    this.name,
    this.retailerAddress,
    this.retailerName,
    this.time,
    this.visitDate,
    this.companyAsset,
    this.dataByDate = const [], // Initialize with an empty list
  });

  factory Module.fromMap(Map<String, dynamic> doc) {
    return Module(
      assetType: doc['assetType'] as String?,
      images: List<String>.from(doc['images'] ?? []),
      location: doc['location'] as String?,
      name: doc['name'] as String?,
      retailerAddress: doc['retailerAddress'] as String?,
      retailerName: doc['retailerName'] as String?,
      time: _convertTimestampToString(doc['time']),
      visitDate: _convertTimestampToString(doc['visitDate']),
      companyAsset: doc['companyAsset'] as String?,
      dataByDate: [], // Initialize dataByDate as an empty list here
    );
  }

  static String? _convertTimestampToString(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate().toIso8601String();
    }
    return timestamp as String?;
  }

  Map<String, dynamic> toMap() {
    return {
      'assetType': assetType,
      'images': images,
      'location': location,
      'name': name,
      'retailerAddress': retailerAddress,
      'retailerName': retailerName,
      'time': time,
      'visitDate': visitDate,
      'companyAsset': companyAsset,
      'dataByDate': dataByDate, // Include dataByDate in the map
    };
  }
}
