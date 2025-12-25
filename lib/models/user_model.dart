class UserModel {
  final int? userId;
  final String upiId;
  final String fullName;
  final String phoneNumber; // 10 digits
  final String email;
  final DateTime dateOfBirth;
  final String pin; // 4 digits
  final String city;
  final String bankAccountNumber; // 12 digits
  final String aadhaarNumber; // 12 digits
  final String bankName;
  final DateTime? createdAt;

  UserModel({
    this.userId,
    required this.upiId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.dateOfBirth,
    required this.pin,
    required this.city,
    required this.bankAccountNumber,
    required this.aadhaarNumber,
    required this.bankName,
    this.createdAt,
  });

  // Convert to Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      if (userId != null) 'user_id': userId,
      'upi_id': upiId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0], // YYYY-MM-DD
      'pin': pin,
      'city': city,
      'bank_account_number': bankAccountNumber,
      'aadhaar_number': aadhaarNumber,
      'bank_name': bankName,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  // Create from Map (from Supabase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] as int?,
      upiId: map['upi_id'] as String,
      fullName: map['full_name'] as String,
      phoneNumber: map['phone_number'] as String,
      email: map['email'] as String,
      dateOfBirth: DateTime.parse(map['date_of_birth'] as String),
      pin: map['pin'] as String,
      city: map['city'] as String,
      bankAccountNumber: map['bank_account_number'] as String,
      aadhaarNumber: map['aadhaar_number'] as String,
      bankName: map['bank_name'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  // Validation methods
  static bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  static bool isValidPin(String pin) {
    return RegExp(r'^[0-9]{4}$').hasMatch(pin);
  }

  static bool isValidAccountNumber(String account) {
    return RegExp(r'^[0-9]{12}$').hasMatch(account);
  }

  static bool isValidAadhaar(String aadhaar) {
    return RegExp(r'^[0-9]{12}$').hasMatch(aadhaar);
  }

  static bool isValidCity(String city) {
    const validCities = ['Mumbai', 'Pune', 'Delhi', 'Bangalore', 'Hyderabad'];
    return validCities.contains(city);
  }

  static bool isValidBank(String bank) {
    const validBanks = ['Union', 'BOI', 'BOBaroda', 'Kotak', 'HDFC'];
    return validBanks.contains(bank);
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

