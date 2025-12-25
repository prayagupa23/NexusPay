# Supabase Integration Setup Guide

## Overview
All authentication screens have been integrated with Supabase. The app collects user data across 5 screens and saves it to the `upi_user` table in Supabase.

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Supabase
1. Open `lib/utils/supabase_config.dart`
2. Replace the placeholder values with your Supabase credentials:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

### 3. Database Schema
Ensure your Supabase database has the `upi_user` table with the following structure:
```sql
CREATE TABLE upi_user (
    user_id BIGSERIAL PRIMARY KEY,
    upi_id VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone_number CHAR(10) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL,
    pin CHAR(4) NOT NULL,
    city VARCHAR(30) NOT NULL,
    bank_account_number CHAR(12) UNIQUE NOT NULL,
    aadhaar_number CHAR(12) UNIQUE NOT NULL,
    bank_name VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_pin CHECK (pin ~ '^[0-9]{4}$'),
    CONSTRAINT chk_city CHECK (city IN ('Mumbai', 'Pune', 'Delhi', 'Bangalore', 'Hyderabad')),
    CONSTRAINT chk_bank CHECK (bank_name IN ('Union', 'BOI', 'BOBaroda', 'Kotak', 'HDFC')),
    CONSTRAINT chk_phone CHECK (phone_number ~ '^[0-9]{10}$'),
    CONSTRAINT chk_account CHECK (bank_account_number ~ '^[0-9]{12}$'),
    CONSTRAINT chk_aadhaar CHECK (aadhaar_number ~ '^[0-9]{12}$')
);
```

## Authentication Flow

### Screen 1: Personal Details Screen
- **Fields**: Full Name, Phone Number, Email
- **Validation**: 
  - Name: Minimum 3 characters
  - Phone: Exactly 10 digits
  - Email: Valid email format
- **Supabase Checks**: Validates phone and email uniqueness

### Screen 2: Verification Screen
- **Fields**: Aadhaar Number, Bank Account Number (with confirmation)
- **Validation**:
  - Aadhaar: Exactly 12 digits
  - Bank Account: Exactly 12 digits, must match confirmation
- **Supabase Checks**: Validates Aadhaar and bank account uniqueness

### Screen 3: Link Bank Account Screen
- **Fields**: Bank Selection, UPI ID (auto-generated)
- **Validation**:
  - Bank: Must be one of: Union, BOI, BOBaroda, Kotak, HDFC
  - UPI ID: Auto-generated from name and bank, can be edited
- **Supabase Checks**: Validates UPI ID uniqueness (auto-generates alternative if exists)

### Screen 4: Final Step Screen
- **Fields**: Date of Birth, Review Details
- **Validation**:
  - DOB: Must be valid date, user must be 18+ years old
  - Allows editing of name, email, phone
- **Data**: Saves DOB to registration state

### Screen 5: Set Up Security Screen
- **Fields**: 4-digit PIN, City Selection
- **Validation**:
  - PIN: Exactly 4 digits, not sequential (e.g., 1234, 4321, 0000)
  - City: Must be one of: Mumbai, Pune, Delhi, Bangalore, Hyderabad
- **Action**: Saves all data to Supabase and navigates to Home Screen

## Data Flow

1. **UserRegistrationState**: Singleton class that holds all registration data across screens
2. **SupabaseService**: Handles all database operations
3. **UserModel**: Data model matching the database schema

## Error Handling

- All screens show error messages for validation failures
- Duplicate checks are performed before saving
- Database errors are displayed to the user
- Loading states prevent multiple submissions

## Testing

1. Run the app: `flutter run`
2. Navigate through the registration flow
3. Check Supabase dashboard to verify data is saved correctly
4. Test duplicate prevention by trying to register with existing phone/email/UPI ID

## Notes

- All data is validated according to database constraints
- UPI ID is auto-generated but can be manually edited
- PIN validation prevents common weak PINs
- City and bank selections are limited to valid options from database constraints

