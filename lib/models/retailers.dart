class RetailerModel {
  String? retailerId;
  String? retailerFid;
  String? retailerMbu;
  String? posId;
  String? phoneNo;
  String? retailerName;
  String? retailerAddress;
  String? region;
  String? imageUrl;

  RetailerModel({
    this.retailerFid,
    this.retailerId,
    this.posId,
    this.phoneNo,
    this.retailerName,
    this.retailerAddress,
    this.region,
    this.retailerMbu,
    this.imageUrl,
  });

  // Convert Firestore document to RetailerModel
  factory RetailerModel.fromMap(Map<String, dynamic> doc) {
    return RetailerModel(
      retailerFid: doc['retailerFid'],
      retailerMbu: doc['retailerMbu'],
      retailerId: doc['retailerId'],
      posId: doc['posId'],
      phoneNo: doc['phoneNo'],
      retailerName: doc['retailerName'],
      retailerAddress: doc['retailerAddress'],
      region: doc['region'],
      imageUrl: doc['imageUrl'],
    );
  }

  // Convert RetailerModel to Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'retailerFid': retailerFid,
      'retailerId': retailerId,
      'posId': posId,
      'phoneNo': phoneNo,
      'retailerName': retailerName,
      'retailerMbu': retailerMbu,
      'retailerAddress': retailerAddress,
      'region': region,
      'imageUrl': imageUrl,
    };
  }
}
