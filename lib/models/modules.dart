class Module {
  String? assetType;
  List<String> images; // Assuming images will be a list of URLs
  String? location;
  String? retailerAddress;
  String? retailerName;
  String? time; // Can be a String or DateTime depending on your preference
  String? visitDate;
  String? companyAsset; // Only used for MarketIntelligence

  Module({
    this.assetType,
    required this.images,
    this.location,
    this.retailerAddress,
    this.retailerName,
    this.time,
    this.visitDate,
    this.companyAsset,
  });

  factory Module.fromMap(Map<String, dynamic> doc) {
    return Module(
      assetType: doc['assetType'],
      images: List<String>.from(doc['images'] ?? []),
      location: doc['location'],
      retailerAddress: doc['retailerAddress'],
      retailerName: doc['retailerName'],
      time: doc['time'],
      visitDate: doc['visitDate'],
      companyAsset: doc['companyAsset'], // Optional, only for MarketIntelligence
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assetType': assetType,
      'images': images,
      'location': location,
      'retailerAddress': retailerAddress,
      'retailerName': retailerName,
      'time': time,
      'visitDate': visitDate,
      'companyAsset': companyAsset,
    };
  }
}
