import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:heisenbug/services/contact_sync_service.dart';
import 'package:heisenbug/services/recipient_honor_score_db.dart';
import 'package:heisenbug/models/recipient_honor_score_model.dart';
import 'package:heisenbug/theme/app_colors.dart';
// Removed unused import
import 'package:heisenbug/screens/payment_screen.dart';
import 'package:heisenbug/screens/contact_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heisenbug/services/supabase_service.dart';
import 'package:heisenbug/models/user_model.dart';
import 'package:heisenbug/models/user_profile_model.dart';
import 'package:heisenbug/utils/supabase_config.dart';
import 'package:heisenbug/core/user_session.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final ContactSyncService _contactSyncService;
  final RecipientHonorScoreDB _db = RecipientHonorScoreDB();

  List<Map<String, dynamic>> _allDeviceContacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];
  List<UserModel> _supabaseUsers = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  String? _userId;
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _loadUserId().then((_) {
      _contactSyncService = ContactSyncService(
        userId: _userId ?? 'default_user',
      );
      _loadSupabaseUsers();
      _checkPermissionAndLoadContacts();
    });
  }

  Future<void> _loadSupabaseUsers() async {
    try {
      debugPrint('=== START: Loading Trusted Users (3+ transactions) ===');
      
      // Get current user ID and UPI
      final prefs = await SharedPreferences.getInstance();
      final currentPhone = prefs.getString('logged_in_phone');
      
      if (currentPhone == null) {
        debugPrint('No logged in user found');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Get current user's profile to get user_id
      final currentUser = await _supabaseService.getUserByPhone(currentPhone);
      if (currentUser == null || currentUser.userId == null) {
        debugPrint('Failed to get current user profile');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      _userId = currentUser.userId!.toString();
      
      // Get trusted contacts (users with 3+ transactions)
      debugPrint('Fetching trusted contacts for user ID: $_userId');
      final trustedContacts = await _supabaseService.getTrustedContacts(int.parse(_userId!));
      
      debugPrint('Found ${trustedContacts.length} trusted contacts');
      
      // Convert TrustedContact list to UserModel list
      final trustedUsers = <UserModel>[];
      
      for (var contact in trustedContacts) {
        try {
          if (contact.upiId != null && contact.upiId!.isNotEmpty) {
            // Get user by UPI ID
            final user = await _supabaseService.getUserByUpiId(contact.upiId!);
            if (user != null) {
              trustedUsers.add(user);
              debugPrint('Added trusted user: ${user.fullName} (${user.upiId}) - ${contact.transactionCount} transactions');
            } else {
              debugPrint('No user found for UPI: ${contact.upiId}');
            }
          } else {
            debugPrint('Skipping contact with empty UPI ID');
          }
        } catch (e) {
          debugPrint('Error loading user with UPI ${contact.upiId}: $e');
        }
      }
      
      if (mounted) {
        setState(() {
          _supabaseUsers = trustedUsers;
          _isLoading = false;
        });
        debugPrint('Final trusted users count: ${_supabaseUsers.length}');
      }
      
      debugPrint('=== END: Loading Trusted Users ===');
    } catch (e) {
      debugPrint('Error loading trusted users: $e');
      if (e is Error) {
        debugPrint('Stack trace: ${e.stackTrace}');
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _currentUserUpi;

  Future<void> _loadUserId() async {
    try {
      // Get current user's phone number from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('logged_in_phone');
      
      if (phoneNumber == null) {
        debugPrint('No logged in phone number found');
        return;
      }
      
      debugPrint('Fetching user profile for phone: $phoneNumber');
      
      try {
        // Get user profile using the same method as profile screen
        final profile = await _supabaseService.getUserProfileByPhone(phoneNumber);
        
        if (profile != null) {
          setState(() {
            _userId = profile.userId?.toString();
            _currentUserUpi = profile.upiId;
          });
          
          debugPrint('Fetched current user UPI from profile: $_currentUserUpi');
          
          // Store in shared preferences for backward compatibility
          await prefs.setString('current_user_upi', _currentUserUpi ?? '');
        } else {
          debugPrint('No profile found for phone: $phoneNumber');
        }
      } catch (e) {
        debugPrint('Error fetching user profile: $e');
      }
    } catch (e) {
      debugPrint('Error in _loadUserId: $e');
    }
  }

  // Filter contacts based on search query
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = List.from(_allDeviceContacts);
      });
      return;
    }

    setState(() {
      _filteredContacts = _allDeviceContacts.where((contact) {
        final name = contact['name'].toString().toLowerCase();
        final number = contact['number'].toString().toLowerCase();
        return name.contains(query) || number.contains(query);
      }).toList();
    });
  }

  Future<void> _syncContacts() async {
    setState(() => _isLoading = true);
    try {
      await _contactSyncService.syncContactsToDB();
      await _checkPermissionAndLoadContacts();
      _showToast('Contacts synced successfully');
    } catch (e) {
      _showToast('Failed to sync contacts', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkPermissionAndLoadContacts() async {
    final status = await Permission.contacts.status;
    if (status.isGranted) {
      await _loadContacts();
    } else {
      final result = await Permission.contacts.request();
      if (result.isGranted) {
        await _loadContacts();
      } else {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadContacts() async {
    try {
      setState(() => _isLoading = true);

      // Get current user's UPI ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final currentUserUpi = prefs.getString('current_user_upi') ?? '';
      final currentUserPhoneNumber = currentUserUpi.replaceAll(RegExp(r'[^0-9+]'), '');

      // Get all contacts from device
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
      );

      // Get all honor scores from local DB
      final scores = await _db.getAllScoresForUser(_userId ?? '');

      // Process contacts and merge with scores
      final List<Map<String, dynamic>> contactMaps = [];

      for (final contact in contacts) {
        if (contact.phones.isNotEmpty) {
          for (final phone in contact.phones) {
            final phoneNumber = phone.number.replaceAll(RegExp(r'[^0-9+]'), '');
            
            // Skip if this is the current user's phone number or if phone number is empty
            if (phoneNumber.isEmpty || phoneNumber == currentUserPhoneNumber) {
              continue;
            }

            // Find matching score or use default
            final score = scores.firstWhere(
              (s) => s.numberId == phoneNumber,
              orElse: () => RecipientHonorScore(
                userId: _userId ?? '',
                numberId: phoneNumber,
                honorScore: 100, // Default score
              ),
            );

            contactMaps.add({
              'name': contact.displayName,
              'number': phoneNumber,
              'photo': contact.photo,
              'honorScore': score.honorScore,
              'hasPaid': score.honorScore < 100,
            });
          }
        }
      }

      // Sort contacts: paying first (by score desc), then non-paying (by name)
      contactMaps.sort((a, b) {
        final aPaid = a['hasPaid'] as bool;
        final bPaid = b['hasPaid'] as bool;

        if (aPaid && !bPaid) return -1;
        if (!aPaid && bPaid) return 1;
        if (aPaid && bPaid) {
          return (b['honorScore'] as int).compareTo(a['honorScore'] as int);
        }
        return (a['name'] as String).compareTo(b['name'] as String);
      });

      setState(() {
        _allDeviceContacts = contactMaps;
        _filteredContacts = List.from(_allDeviceContacts);
        _hasPermission = true;
        _isLoading = false;
      });
    } catch (e) {
      log('Error loading contacts: $e');
      _showToast('Failed to load contacts', isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? AppColors.dangerRed : AppColors.primaryBlue,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _handleContactTap(Map<String, dynamic> contact) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: _buildContactAvatar(contact),
                title: Text(
                  contact['name'] ?? 'Unknown',
                  style: TextStyle(
                    color: AppColors.darkPrimaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  contact['number'] ?? '',
                  style: TextStyle(color: AppColors.darkSecondaryText),
                ),
              ),
              const Divider(height: 1, thickness: 0.5),
              ListTile(
                leading: Icon(Icons.chat, color: AppColors.primaryBlue),
                title: const Text('Chat'),
                onTap: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  final currentUserUpi = prefs.getString('current_user_upi');

                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactDetailScreen(
                        name: contact['name'] ?? 'Unknown',
                        upiId: contact['number'] ?? '',
                        currentUserUpi: currentUserUpi ?? '',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.payment, color: AppColors.primaryBlue),
                title: const Text('Send Money'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        name: contact['name'] ?? 'Unknown',
                        upiId: contact['number'] ?? '',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Build a section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.darkMutedText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Build a Supabase user tile with honor score
  Widget _buildSupabaseUserTile(UserModel user) {
    final name = user.fullName ?? 'Unknown User';
    final upiId = user.upiId ?? 'No UPI ID';

    return FutureBuilder<UserProfileModel?>(
      future: _supabaseService.getUserProfileByUpiId(upiId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final honorScore =
            profile?.honorScore ?? 100; // Default to 100 if not found
        final scoreColor = _getScoreColor(honorScore);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          color: AppColors.darkSurface,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              name,
              style: TextStyle(
                color: AppColors.darkPrimaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upiId,
                  style: TextStyle(color: AppColors.darkSecondaryText),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scoreColor, width: 1),
                      ),
                      child: Text(
                        'Score: $honorScore',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.verified_user, color: Colors.blue),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.darkSurface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (BuildContext context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryBlue,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(upiId),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: scoreColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: scoreColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Trust Score: $honorScore/100',
                                  style: TextStyle(
                                    color: scoreColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.blue,
                          ),
                          title: const Text('Chat'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContactDetailScreen(
                                  name: name,
                                  upiId: upiId,
                                  currentUserUpi: _userId ?? '',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.send_rounded,
                            color: Colors.blue,
                          ),
                          title: const Text('Send Money'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PaymentScreen(name: name, upiId: upiId),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Build a contact card for device contacts
  Widget _buildContactCard(Map<String, dynamic> contact) {
    final honorScore = contact['honorScore'] as int;
    final hasPaid = contact['hasPaid'] as bool;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPaid
              ? AppColors.primaryBlue.withOpacity(0.5)
              : AppColors.darkSecondarySurface,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: _buildContactAvatar(contact),
        title: Text(
          contact['name'] ?? 'Unknown',
          style: TextStyle(
            color: AppColors.darkPrimaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          contact['number'] ?? '',
          style: TextStyle(color: AppColors.darkSecondaryText),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Score: $honorScore',
              style: TextStyle(
                color: _getScoreColor(honorScore),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasPaid)
              const Text(
                'Paid Before',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
          ],
        ),
        onTap: () => _handleContactTap(contact),
      ),
    );
  }

  // Build contact avatar with photo or initials
  Widget _buildContactAvatar(Map<String, dynamic> contact) {
    if (contact['photo'] != null) {
      return CircleAvatar(
        backgroundImage: MemoryImage(contact['photo']),
        radius: 24,
        backgroundColor: AppColors.primaryBlue,
      );
    }
    return CircleAvatar(
      backgroundColor: AppColors.primaryBlue,
      radius: 24,
      child: Text(
        contact['name']?.isNotEmpty == true
            ? contact['name'][0].toUpperCase()
            : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Get a consistent color for avatars based on name
  Color _getAvatarColor(String name) {
    // Simple hash function to generate consistent colors for names
    var hash = 0;
    for (var i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final index = hash.abs() % _avatarColors.length;
    return _avatarColors[index];
  }

  // Define some nice avatar colors
  final List<Color> _avatarColors = [
    Colors.blue[700]!,
    Colors.red[700]!,
    Colors.green[700]!,
    Colors.purple[700]!,
    Colors.orange[700]!,
    Colors.teal[700]!,
    Colors.pink[700]!,
    Colors.indigo[700]!,
  ];

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.successGreen;
    if (score >= 50) return AppColors.warningYellow;
    if (score >= 30) return AppColors.dangerRed;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkPrimaryText,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkPrimaryText),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPermissionAndLoadContacts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _syncContacts,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.sync, color: Colors.white),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
        ),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionDeniedUI();
    }

    return _buildContactList();
  }

  Widget _buildContactList() {
    final searchQuery = _searchController.text.toLowerCase();

    // Filter and limit Supabase users to 6
    final filteredSupabaseUsers = _supabaseUsers
        .where((user) {
          final name = user.fullName?.toLowerCase() ?? '';
          final upiId = user.upiId?.toLowerCase() ?? '';
          return searchQuery.isEmpty ||
              name.contains(searchQuery) ||
              upiId.contains(searchQuery);
        })
        .take(6)
        .toList();

    // Filter device contacts
    final filteredDeviceContacts = _filteredContacts.where((contact) {
      final name = contact['name']?.toString().toLowerCase() ?? '';
      final number = contact['number']?.toString().toLowerCase() ?? '';
      return searchQuery.isEmpty ||
          name.contains(searchQuery) ||
          number.contains(searchQuery);
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: AppColors.darkPrimaryText),
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              hintStyle: TextStyle(color: AppColors.darkMutedText),
              prefixIcon: Icon(Icons.search, color: AppColors.darkMutedText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.darkSecondarySurface,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 20,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),

        // Contacts list
        Expanded(
          child: ListView(
            children: [
              if (filteredSupabaseUsers.isNotEmpty) ...[
                _buildSectionHeader('Trusted App Users'),
                ...filteredSupabaseUsers
                    .map((user) => _buildSupabaseUserTile(user))
                    .toList(),
                const SizedBox(height: 8),
              ],
              if (filteredDeviceContacts.isNotEmpty) ...[
                _buildSectionHeader('Device Contacts'),
                ...filteredDeviceContacts
                    .map((contact) => _buildContactCard(contact))
                    .toList(),
              ],
              if (filteredSupabaseUsers.isEmpty &&
                  filteredDeviceContacts.isEmpty &&
                  !_isLoading) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No contacts available',
                      style: TextStyle(color: AppColors.darkMutedText),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDeniedUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.contact_phone,
              size: 64,
              color: AppColors.darkMutedText,
            ),
            const SizedBox(height: 24),
            Text(
              'Contacts Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkPrimaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please grant contacts permission to view your trusted contacts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkSecondaryText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _checkPermissionAndLoadContacts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Grant Permission'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => openAppSettings(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
