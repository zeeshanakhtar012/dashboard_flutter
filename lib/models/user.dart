import 'modules.dart';

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
  String? password;
  String? userAddress;
  String? imageUrl;
  Map<String, dynamic>? linkedRetailers;
  List<Module> modules; // Change from List<Map<String, dynamic>> to List<Module>

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
    this.password,
    this.imageUrl,
    this.linkedRetailers,
    List<Module>? modules, // Constructor parameter for modules
  }) : modules = modules ?? []; // Initialize modules list

  // Factory method to create User from Firestore document snapshot
  factory User.fromDocumentSnapshot(Map<String, dynamic> doc) {
    return User(
      userId: doc['userId'] as String?, // Explicitly casting
      phoneNumber: doc['phoneNumber'] as String?, // Explicitly casting
      fid: doc['fid'] as String?, // Explicitly casting
      employeeId: doc['employeeId'] as String?, // Explicitly casting
      email: doc['email'] as String?, // Explicitly casting
      designation: doc['designation'] as String?, // Explicitly casting
      region: doc['region'] as String?, // Explicitly casting
      userAddress: doc['userAddress'] as String?, // Explicitly casting
      userName: doc['userName'] as String?, // Explicitly casting
      password: doc['password'] as String?, // Explicitly casting
      mbu: doc['mbu'] as String?, // Explicitly casting
      imageUrl: doc.containsKey('imageUrl') ? doc['imageUrl'] as String? : null, // Safe access
      linkedRetailers: doc['linkedRetailers'] != null
          ? Map<String, dynamic>.from(doc['linkedRetailers'])
          : null,
      modules: doc['modules'] != null
          ? List<Module>.from(
        (doc['modules'] as List).map((item) => Module.fromMap(item)),
      )
          : [], // Initialize modules list from Firestore
    );
  }

  // Convert User to a Firestore-friendly map
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
      'modules': modules.map((module) => module.toMap()).toList(), // Include modules in the map
      'password': password,
    };
  }
}
