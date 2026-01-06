import 'dart:developer';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:heisenbug/services/supabase_service.dart';
import 'package:heisenbug/utils/supabase_config.dart';

class ContactSyncService {
  final String userId;
  late final SupabaseService _supabaseService;

  ContactSyncService({required this.userId}) {
    _supabaseService = SupabaseService(SupabaseConfig.client);
  }

  Future<void> syncContactsToDB() async {
    try {
      log('🔄 Starting contact sync...');
      
      // Request contacts permission
      final permissionStatus = await Permission.contacts.status;
      log('📱 Current contacts permission status: $permissionStatus');
      
      if (!permissionStatus.isGranted) {
        log('🔒 Contacts permission not granted, requesting...');
        final result = await Permission.contacts.request();
        log('🔑 Permission request result: $result');
        if (!result.isGranted) {
          log('❌ Contact permission denied by user');
          return;
        }
      }

      log('🔍 Fetching device contacts...');
      // Get all device contacts
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );
      
      log('✅ Found ${contacts.length} device contacts');
      if (contacts.isEmpty) {
        log('⚠️ No contacts found on the device');
      } else {
        log('📞 First contact: ${contacts.first.displayName} - ${contacts.first.phones.isNotEmpty ? contacts.first.phones.first.number : 'No phone number'}');
      }

      // Initialize local DB
      final dbPath = join(await getDatabasesPath(), 'contacts_honor_scores.db');
      log('💾 Database path: $dbPath');
      
      final db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          log('🆕 Creating new database table');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS recipient_honor_scores(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              user_id TEXT NOT NULL, 
              number_id TEXT NOT NULL, 
              honor_score INTEGER DEFAULT 100, 
              UNIQUE(user_id, number_id)
            )
          ''');
        },
      );

      // Get existing contacts to preserve their scores
      log('🔎 Checking for existing contacts in database...');
      final List<Map<String, dynamic>> existingContacts = await db.query(
        'recipient_honor_scores',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      log('📊 Found ${existingContacts.length} existing contacts in database');
      final existingNumbers = existingContacts.map((e) => e['number_id'] as String).toSet();
      final batch = db.batch();
      int newContacts = 0;
      int updatedContacts = 0;
      int skippedContacts = 0;

      // Process all device contacts
      for (final contact in contacts) {
        final contactName = contact.displayName.isNotEmpty ? contact.displayName : 'Unknown';
        log('📱 Processing contact: $contactName');
        
        if (contact.phones.isEmpty) {
          log('   ⚠️ No phone numbers for contact: $contactName');
          continue;
        }
        
        for (final phone in contact.phones) {
          final originalNumber = phone.number?.trim() ?? '';
          log('   📞 Processing number: $originalNumber');
          
          try {
            final number = _normalizePhoneNumber(originalNumber);
            if (number == null || number.isEmpty) {
              log('   ⏩ Skipping invalid phone number: $originalNumber');
              skippedContacts++;
              continue;
            }
            
            log('   ✅ Valid number: $number');
            
            // Check if contact already exists
            if (!existingNumbers.contains(number)) {
              batch.insert(
                'recipient_honor_scores',
                {
                  'user_id': userId,
                  'number_id': number,
                  'honor_score': 100, // Default score for new contacts
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
              newContacts++;
              log('   ➕ Added new contact: $number');
            } else {
              updatedContacts++;
              log('   🔄 Updated existing contact: $number');
            }
          } catch (e) {
            log('❌ Error processing number $originalNumber: $e');
            continue;
          }
        }
      }
      
      log('💾 Committing changes to database...');
      try {
        await batch.commit(noResult: true);
        log('✅ Successfully committed ${newContacts + updatedContacts} contacts to local database');
      } catch (e) {
        log('❌ Error committing batch to database: $e');
        rethrow;
      }
      
      // Prepare contacts for Supabase sync
      final contactsForSupabase = <Map<String, dynamic>>[];
      for (final contact in contacts) {
        for (final phone in contact.phones) {
          final number = _normalizePhoneNumber(phone.number);
          if (number != null && number.isNotEmpty) {
            contactsForSupabase.add({
              'number_id': number,
              'honor_score': 100, // Default score for new contacts
            });
          }
        }
      }
      
      // Sync to Supabase
      if (contactsForSupabase.isNotEmpty) {
        log('☁️  Syncing ${contactsForSupabase.length} contacts to Supabase...');
        try {
          await _supabaseService.syncRecipientHonorScores(userId, contactsForSupabase);
          log('✅ Successfully synced contacts to Supabase');
        } catch (e) {
          log('❌ Error syncing to Supabase: $e');
          // Don't rethrow to allow the app to continue with local data
        }
      } else {
        log('ℹ️  No contacts to sync to Supabase');
      }
      
      await db.close();
      
      log('''
      ✅ Contact sync complete
      ==========================
      • Total device contacts: ${contacts.length}
      • New contacts added: $newContacts
      • Existing contacts updated: $updatedContacts
      • Contacts skipped (invalid numbers): $skippedContacts
      ==========================
      ''');
    } catch (e) {
      log('Error syncing contacts: $e');
      rethrow;
    }
  }
  
  String? _normalizePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null) return null;
    
    try {
      // Remove all non-digit characters
      var digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      // If empty after cleaning, return null
      if (digitsOnly.isEmpty) return null;
      
      // Handle numbers that start with 0 (assume local number)
      if (digitsOnly.startsWith('0')) {
        digitsOnly = '91' + digitsOnly.substring(1);
      }
      // Handle numbers without country code (assume India +91)
      else if (digitsOnly.length == 10) {
        digitsOnly = '91' + digitsOnly;
      }
      // Handle numbers with + but no country code
      else if (digitsOnly.startsWith('91') && digitsOnly.length == 12) {
        // Already in correct format
      }
      // Handle numbers with country code but without +
      else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
        // Already in correct format
      }
      
      // Ensure we have at least 10 digits (after country code)
      if (digitsOnly.length < 10) {
        log('⚠️ Number too short after normalization: $phoneNumber -> $digitsOnly');
        return null;
      }
      
      // Take last 10 digits if number is too long
      if (digitsOnly.length > 12) {
        digitsOnly = digitsOnly.substring(digitsOnly.length - 10);
        digitsOnly = '91' + digitsOnly; // Add back country code
      }
      
      log('🔢 Normalized: $phoneNumber -> $digitsOnly');
      return digitsOnly;
    } catch (e) {
      log('❌ Error normalizing number $phoneNumber: $e');
      return null;
    }
  }

  Future<bool> _requestContactPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  // Debug method to log all contacts in the database
  Future<void> debugLogAllContacts() async {
    try {
      final db = await openDatabase(
        join(await getDatabasesPath(), 'contacts_honor_scores.db'),
        version: 1,
      );
      
      final List<Map<String, dynamic>> contacts = await db.query(
        'recipient_honor_scores',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      log('📋 Found ${contacts.length} contacts in database:');
      for (final contact in contacts) {
        log('  - ${contact['number_id']} (Score: ${contact['honor_score']})');
      }
      
      await db.close();
    } catch (e) {
      log('Error reading contacts from database: $e');
    }
  }
}