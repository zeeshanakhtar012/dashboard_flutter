class User {
  String? userId;
  String? phoneNumber;
  String? fid;
  String? employeeId;
  String? designation;
  String? email;
  String? region;
  String? mbu;
  String? userName;
  String? userAddress;
  String? imageUrl;
  Map<String, dynamic>? linkedRetailers;

  User({
    this.userId,
    this.phoneNumber,
    this.fid,
    this.employeeId,
    this.designation,
    this.email,
    this.region,
    this.mbu,
    this.userAddress,
    this.userName,
    this.imageUrl,
    this.linkedRetailers,
  });

  // Factory method to create UserModel from Firestore document snapshot
  factory User.fromDocumentSnapshot(Map<String, dynamic> doc) {
    return User(
      userId: doc['userId'],
      phoneNumber: doc['phoneNumber'],
      fid: doc['fid'],
      employeeId: doc['employeeId'],
      email: doc['email'],
      designation: doc['designation'],
      region: doc['region'],
      userAddress: doc['userAddress'],
      userName: doc['userName'],
      mbu: doc['mbu'],
      imageUrl: doc.containsKey('imageUrl') ? doc['imageUrl'] : null,
      linkedRetailers: doc['linkedRetailers'] != null ? Map<String, dynamic>.from(doc['linkedRetailers']) : null,
    );
  }

  // Convert UserModel to a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'fid': fid,
      'employeeId': employeeId,
      'email': email,
      'designation': designation,
      'region': region,
      'userName': userName,
      'userAddress': userAddress,
      'mbu': mbu,
      'imageUrl': imageUrl,
      'linkedRetailers': linkedRetailers,
    };
  }
}
