class AddressModel {
  final String addressId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String whatsAppNumber;
  final String streetAddress;
  final String city;
  final String state;
  final bool isDefault;

  AddressModel({
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.whatsAppNumber,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.addressId,
    required this.isDefault,
  });

  String get fullAddress => '$streetAddress, $city, $state';

  //convert address to a map (storing in Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'whatsAppNumber': whatsAppNumber,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'addressId': addressId,
      'isDefault': isDefault,
    };
  }

  //convert map to address (retrieving from Firestore)
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      whatsAppNumber: map['whatsAppNumber'] ?? '',
      streetAddress: map['streetAddress'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      addressId: map['addressId'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }
}
