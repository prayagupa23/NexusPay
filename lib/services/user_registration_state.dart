import '../models/user_model.dart';

/// Global state holder for user registration data
/// This allows data to be collected across multiple screens
class UserRegistrationState {
  static final UserRegistrationState _instance = UserRegistrationState._internal();
  factory UserRegistrationState() => _instance;
  UserRegistrationState._internal();

  // Step 1: Personal Details
  String? fullName;
  String? phoneNumber;
  String? email;

  // Step 2: Verification
  String? aadhaarNumber;
  String? bankAccountNumber;

  // Step 3: Bank Account
  String? bankName;
  String? upiId;

  // Step 4: Final Step
  DateTime? dateOfBirth;

  // Step 5: Security
  String? pin;
  String? city;

  // Check if all required fields are filled
  bool get isComplete {
    return fullName != null &&
        phoneNumber != null &&
        email != null &&
        aadhaarNumber != null &&
        bankAccountNumber != null &&
        bankName != null &&
        upiId != null &&
        dateOfBirth != null &&
        pin != null &&
        city != null;
  }

  // Create UserModel from collected data
  UserModel? toUserModel() {
    if (!isComplete) return null;

    return UserModel(
      upiId: upiId!,
      fullName: fullName!,
      phoneNumber: phoneNumber!,
      email: email!,
      dateOfBirth: dateOfBirth!,
      pin: pin!,
      city: city!,
      bankAccountNumber: bankAccountNumber!,
      aadhaarNumber: aadhaarNumber!,
      bankName: bankName!,
    );
  }

  // Clear all data (for logout or new registration)
  void clear() {
    fullName = null;
    phoneNumber = null;
    email = null;
    aadhaarNumber = null;
    bankAccountNumber = null;
    bankName = null;
    upiId = null;
    dateOfBirth = null;
    pin = null;
    city = null;
  }

  // Get progress percentage
  double get progress {
    int filled = 0;
    if (fullName != null) filled++;
    if (phoneNumber != null) filled++;
    if (email != null) filled++;
    if (aadhaarNumber != null) filled++;
    if (bankAccountNumber != null) filled++;
    if (bankName != null) filled++;
    if (upiId != null) filled++;
    if (dateOfBirth != null) filled++;
    if (pin != null) filled++;
    if (city != null) filled++;
    return filled / 10;
  }
}

