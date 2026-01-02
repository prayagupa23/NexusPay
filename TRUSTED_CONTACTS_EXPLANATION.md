# 🔐 Trusted Contacts Verification System - Complete Explanation

## 📋 Overview

This system automatically verifies whether a person you're paying is a **trusted contact** (someone you've paid before) or an **unverified/unknown contact**. It helps prevent fraud by alerting you when you send money to suspicious or unknown accounts.

---

## 🔄 Complete Flow Diagram

```
User Initiates Payment
        ↓
Enter Recipient UPI ID & Amount
        ↓
Enter PIN & Confirm Payment
        ↓
[processPayment() Function Called]
        ↓
┌─────────────────────────────────────┐
│ STEP 1: Check Balance              │
│ - Verify sufficient funds          │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ STEP 2: Get Receiver Info          │
│ - Lookup receiver by UPI ID         │
│ - Get receiver's phone number       │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ STEP 3: Check Trusted Contact      │
│ - Query all your past transactions  │
│ - Check if receiverUpi exists      │
│ - Set isTrustedContact = true/false │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ STEP 4: Phone Verification          │
│ - Call Numlookup API                │
│ - Verify phone number validity      │
│ - Get location, carrier info        │
│ - Set isVerifiedContact = true/false│
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ STEP 5: Save Transaction           │
│ - Store transaction with flags:    │
│   • isTrustedContact                │
│   • isVerifiedContact               │
└─────────────────────────────────────┘
        ↓
Payment Success Screen
        ↓
User Returns to Home Screen
        ↓
┌─────────────────────────────────────┐
│ STEP 6: Check for Alerts           │
│ - Load recent transactions          │
│ - Find unverified/unknown contacts │
│ - Display alert card if found       │
└─────────────────────────────────────┘
```

---

## 🔍 Detailed Step-by-Step Explanation

### **STEP 1: Payment Initiation**

When a user wants to send money:

1. User selects a recipient (from contacts or enters UPI ID)
2. User enters amount
3. User enters PIN
4. `processPayment()` function is called in `SupabaseService`

**Location:** `lib/screens/pin_entry_screen.dart` → `_processPayment()`

---

### **STEP 2: Balance Check & Receiver Lookup**

```dart
// In processPayment() function (line 357-394)

// 1. Get sender's user info
final user = await getUserByPhone(phoneNumber);

// 2. Check balance
if (currentBalance < amount) {
  throw 'Insufficient balance';
}

// 3. Get receiver info by UPI ID
final receiver = await getUserByUpiId(receiverUpi);
```

**What happens:**
- Fetches sender's account details
- Verifies sufficient balance
- Looks up receiver in database using UPI ID

---

### **STEP 3: Trusted Contact Check**

```dart
// Lines 389-405 in supabase_service.dart

bool isTrustedContact = false;

if (receiver != null) {
  // Get all your past transactions
  final previousTransactions = await getUserTransactions(userId);
  
  // Check if you've paid this person before
  isTrustedContact = previousTransactions.any(
    (tx) => tx.receiverUpi == receiverUpi,
  );
}
```

**Logic:**
- ✅ **isTrustedContact = true**: You've sent money to this UPI ID before
- ❌ **isTrustedContact = false**: This is the first time paying this person

**Example:**
- First payment to `john@paytm` → `isTrustedContact = false`
- Second payment to `john@paytm` → `isTrustedContact = true`

---

### **STEP 4: Phone Number Verification (Numlookup API)**

```dart
// Lines 407-420 in supabase_service.dart

bool isVerifiedContact = false;

try {
  // Create verification service
  final phoneVerificationService = PhoneVerificationService();
  
  // Format phone number: "918169342724" → "+918169342724"
  final phoneNumber = '+91${receiver.phoneNumber}';
  
  // Call Numlookup API
  final verificationResult = await phoneVerificationService.validatePhoneNumber(phoneNumber);
  
  if (verificationResult != null && verificationResult.valid) {
    isVerifiedContact = true;
    // API returns: location, carrier, line_type, etc.
  }
} catch (e) {
  // If API fails, continue without verification
  // (Payment still goes through)
}
```

**API Call Details:**

**Request:**
```
GET https://api.numlookupapi.com/v1/validate/+918169342724?apikey=num_live_...
```

**Response:**
```json
{
  "valid": true,
  "number": "918169342724",
  "local_format": "08169342724",
  "international_format": "+918169342724",
  "country_prefix": "+91",
  "country_code": "IN",
  "country_name": "India (Republic of)",
  "location": "Mumbai",
  "carrier": "Reliance Jio Infocomm Ltd (RJIL)",
  "line_type": "mobile"
}
```

**What it verifies:**
- ✅ Phone number is valid and active
- ✅ Location (city/state)
- ✅ Carrier (network provider)
- ✅ Line type (mobile/landline)

**Possible Outcomes:**
- ✅ **isVerifiedContact = true**: Phone number is valid and verified
- ❌ **isVerifiedContact = false**: Phone number invalid, not found, or API failed

---

### **STEP 5: Save Transaction with Verification Flags**

```dart
// Lines 426-437 in supabase_service.dart

final transaction = TransactionModel(
  userId: userId,
  receiverUpi: receiverUpi,
  amount: amount,
  deviceId: deviceId,
  location: location,
  status: 'SUCCESS',
  utrReference: utrReference,
  isTrustedContact: isTrustedContact,      // ← NEW FIELD
  isVerifiedContact: isVerifiedContact,    // ← NEW FIELD
);

await createTransaction(transaction);
```

**Database Record:**
```sql
INSERT INTO transactions (
  user_id,
  receiver_upi,
  amount,
  status,
  is_trusted_contact,    -- true/false/null
  is_verified_contact    -- true/false/null
) VALUES (...);
```

**Possible Combinations:**

| isTrustedContact | isVerifiedContact | Meaning |
|-----------------|-------------------|---------|
| `true` | `true` | ✅ Trusted contact, verified phone |
| `true` | `false` | ⚠️ Trusted contact, but phone verification failed |
| `false` | `true` | ⚠️ New contact, but phone is verified |
| `false` | `false` | 🚨 **UNKNOWN USER** - Alert shown! |
| `null` | `false` | 🚨 Receiver not in system, phone not verified |

---

### **STEP 6: Alert Card Display (Home Screen)**

When user returns to home screen:

```dart
// Lines 407-462 in home_screen.dart

Future<void> _loadUnknownUserAlert() async {
  // 1. Get logged-in user
  final user = await _supabaseService.getUserByPhone(phoneNumber);
  
  // 2. Get recent transactions (last 10)
  final transactions = await _supabaseService.getUserTransactions(user.userId!, limit: 10);
  
  // 3. Find unverified/unknown transactions
  for (var tx in transactions) {
    // Check if transaction is with unknown user
    if (tx.isTrustedContact == false || 
        (tx.isTrustedContact == null && tx.isVerifiedContact == false)) {
      
      // Found an unknown user payment!
      // Display alert card
      setState(() {
        _unknownUserTransaction = tx;
        _unknownUser = receiver;
      });
      return;
    }
  }
}
```

**Alert Card Shows:**
- ⚠️ Warning icon
- "UNVERIFIED" badge
- Recipient name
- Transaction amount
- Verification status
- "Verify Contact" button

**When Alert Appears:**
- ✅ Payment was made to someone you haven't paid before (`isTrustedContact = false`)
- ✅ AND phone number couldn't be verified (`isVerifiedContact = false`)
- ✅ OR receiver doesn't exist in your system (`isTrustedContact = null`)

---

## 🎯 Real-World Scenarios

### **Scenario 1: Paying a Friend (Trusted Contact)**

```
1. You pay "john@paytm" ₹500
   → isTrustedContact = false (first time)
   → isVerifiedContact = true (phone verified)
   → Transaction saved

2. You pay "john@paytm" ₹1000 (second time)
   → isTrustedContact = true (paid before)
   → isVerifiedContact = true (phone verified)
   → No alert shown ✅
```

### **Scenario 2: Paying Unknown Scammer**

```
1. You pay "scammer123@paytm" ₹2000
   → isTrustedContact = false (first time)
   → isVerifiedContact = false (phone invalid/not found)
   → Transaction saved with flags

2. You return to home screen
   → System finds unverified transaction
   → 🚨 ALERT CARD APPEARS
   → Shows: "Unknown User Payment - ₹2000 to scammer123"
   → Warning: "This payment was made to an unverified contact"
```

### **Scenario 3: API Failure (Graceful Handling)**

```
1. You pay "friend@paytm" ₹500
   → isTrustedContact = false
   → Phone verification API fails (network error)
   → isVerifiedContact = false (but payment still goes through)
   → Alert might show, but user knows it's their friend
```

---

## 🔧 Key Components

### **1. PhoneVerificationService** (`lib/services/phone_verification_service.dart`)

**Purpose:** Communicates with Numlookup API

**Key Methods:**
- `validatePhoneNumber(String phoneNumber)` - Validates phone via API
- `extractPhoneFromUpiId(String upiId)` - Extracts phone from UPI ID

**Error Handling:**
- If API fails, returns `null` (doesn't block payment)
- Logs errors for debugging

---

### **2. TransactionModel** (`lib/models/transaction_model.dart`)

**New Fields:**
```dart
final bool? isTrustedContact;    // Have you paid this person before?
final bool? isVerifiedContact;    // Was phone number verified?
```

**Why nullable (`bool?`)?**
- `null` = Not checked yet (old transactions)
- `true` = Verified/Trusted
- `false` = Not verified/Not trusted

---

### **3. SupabaseService.processPayment()** (`lib/services/supabase_service.dart`)

**Enhanced Flow:**
1. Check balance
2. Get receiver info
3. **Check trusted contact** ← NEW
4. **Verify phone number** ← NEW
5. Save transaction with flags
6. Update balances

**Important:** Verification happens **during** payment, not after!

---

### **4. Home Screen Alert Section** (`lib/screens/home_screen.dart`)

**Component:** `_UnknownUserAlertSection`

**Behavior:**
- Loads on screen initialization
- Checks last 10 transactions
- Finds first unverified/unknown payment
- Displays alert card if found
- Hides if no alerts needed

---

## 🛡️ Security & Privacy

### **What Data is Sent to Numlookup API?**
- ✅ Only phone number (e.g., `+918169342724`)
- ❌ No personal information
- ❌ No transaction amounts
- ❌ No UPI IDs

### **What Happens if API Fails?**
- Payment still processes (doesn't block transaction)
- `isVerifiedContact` remains `false`
- Alert may show, but user can dismiss if they know the recipient

### **Database Privacy:**
- Verification flags stored locally in your database
- No external service has access to your transaction history
- Phone verification is one-time check, not stored externally

---

## 📊 Database Schema

```sql
ALTER TABLE transactions
ADD COLUMN is_trusted_contact BOOLEAN DEFAULT NULL,
ADD COLUMN is_verified_contact BOOLEAN DEFAULT NULL;
```

**Indexes for Performance:**
```sql
CREATE INDEX idx_transactions_trusted_contact 
ON transactions(user_id, is_trusted_contact) 
WHERE is_trusted_contact = false;
```

---

## 🚀 Benefits

1. **Fraud Prevention:** Alerts when paying unknown contacts
2. **User Awareness:** Shows verification status clearly
3. **Non-Intrusive:** Doesn't block payments, just warns
4. **Automatic:** Works in background, no user action needed
5. **Graceful Degradation:** Works even if API fails

---

## 🔄 Future Enhancements

Possible improvements:
- Cache verified contacts to reduce API calls
- Show verification status in payment screen before confirming
- Allow users to manually mark contacts as trusted
- Store verification results for faster lookups
- Add more verification sources (email, Aadhaar, etc.)

---

## ❓ FAQ

**Q: Does this block payments?**  
A: No, it only warns. Payments always go through.

**Q: What if I know the person but they're not verified?**  
A: You can still pay. The alert is just a warning.

**Q: Does it check every payment?**  
A: Yes, every payment is checked automatically.

**Q: What if the API is down?**  
A: Payment still processes, but verification might be skipped.

**Q: Can I disable alerts?**  
A: Currently no, but you can dismiss them by scrolling past.

---

## 📝 Summary

The system works by:
1. ✅ Checking if you've paid someone before (trusted contact)
2. ✅ Verifying their phone number via Numlookup API
3. ✅ Storing verification flags with each transaction
4. ✅ Alerting you on home screen if payment was to unknown user

**Result:** Better security awareness and fraud prevention! 🛡️

