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
      assetType: doc['assetType'] as String?, // Explicitly casting
      images: List<String>.from(doc['images'] ?? []),
      location: doc['location'] as String?, // Explicitly casting
      retailerAddress: doc['retailerAddress'] as String?, // Explicitly casting
      retailerName: doc['retailerName'] as String?, // Explicitly casting
      time: doc['time'] as String?, // Explicitly casting
      visitDate: doc['visitDate'] as String?, // Explicitly casting
      companyAsset: doc['companyAsset'] as String?, // Explicitly casting
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
