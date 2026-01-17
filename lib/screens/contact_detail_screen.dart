import 'package:flutter/material.dart';
import 'package:heisenbug/screens/payment_screen.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../tile/avatar_tile.dart';
import '../models/transaction_model.dart';

class ContactDetailScreen extends StatefulWidget {
  final String name;
  final String upiId;
  final String currentUserUpi;

  const ContactDetailScreen({
    super.key,
    required this.name,
    required this.upiId,
    required this.currentUserUpi,
  });

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late Future<List<TransactionModel>> _transactionFuture;

  @override
  void initState() {
    super.initState();
    _transactionFuture = _fetchTransactions();
  }

  Future<List<TransactionModel>> _fetchTransactions() async {
    try {
      final response = await Supabase.instance.client
          .from('transactions')
          .select()
          .or(
            'receiver_upi.eq.${widget.upiId},receiver_upi.eq.${widget.currentUserUpi}',
          )
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((map) => TransactionModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
      return [];
    }
  }

  // --- REPORTING LOGIC ---

  void _showReportBottomSheet(BuildContext context) {
    final List<String> reasons = [
      "Fraudulent Activity",
      "Spam or Harassment",
      "Fake Profile/Impersonation",
      "Unauthorized Transaction",
      "Suspicious Links",
      "Abusive Language",
      "Other",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Report User",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select a reason for reporting ${widget.name}. Your report is confidential.",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText(context),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reasons.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        reasons[index],
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 15,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.mutedText(context),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _submitReport(reasons[index]);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitReport(String reason) async {
    try {
      // Maps to your user_reports table: reporter_name, reporter_upi, reported_name, reported_upi, reason
      await Supabase.instance.client.from('user_reports').insert({
        'reporter_name':
            'Current User', // You can replace this with a real name if available
        'reporter_upi': widget.currentUserUpi,
        'reported_name': widget.name,
        'reported_upi': widget.upiId,
        'reason': reason,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report submitted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit report: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final Color avatarBg = ContactAvatar.getAvatarBgColor(
      context,
      widget.name,
      isTrustedContact: false,
    );
    final Color avatarText = ContactAvatar.getAvatarTextColor(
      context,
      avatarBg,
    );

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [avatarBg.withOpacity(0.15), avatarBg.withOpacity(0)],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _buildHeader(context, statusBarHeight, avatarBg, avatarText),
              Expanded(
                child: FutureBuilder<List<TransactionModel>>(
                  future: _transactionFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final allTx = snapshot.data ?? [];
                    if (allTx.isEmpty) return _buildEmptyState();

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      itemCount: allTx.length,
                      itemBuilder: (context, index) {
                        final tx = allTx[index];
                        final bool isSentByMe = tx.receiverUpi == widget.upiId;
                        return _buildTransactionBubble(context, tx, isSentByMe);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassBottomBar(context, avatarBg),
    );
  }

  Widget _buildTransactionBubble(
    BuildContext context,
    TransactionModel tx,
    bool isSent,
  ) {
    final bool isSuccess = tx.status == 'SUCCESS';
    final Color themeBlue = const Color(0xFF1A56DB);

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.72,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(28),
            topRight: const Radius.circular(28),
            bottomLeft: Radius.circular(isSent ? 28 : 8),
            bottomRight: Radius.circular(isSent ? 8 : 28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isSent
                ? themeBlue.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: (isSuccess ? themeBlue : Colors.orange)
                      .withOpacity(0.03),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isSuccess
                                  ? Icons.verified_rounded
                                  : Icons.pending_rounded,
                              size: 14,
                              color: isSuccess
                                  ? Colors.green.shade400
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isSuccess ? "SECURE PAYMENT" : "PROCESSING",
                              style: TextStyle(
                                letterSpacing: 1.2,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isSuccess
                                    ? Colors.green.shade400
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          tx.createdAt != null
                              ? DateFormat('hh:mm a').format(tx.createdAt!)
                              : '',
                          style: TextStyle(
                            color: AppColors.mutedText(context),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "₹",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText(
                                context,
                              ).withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tx.amount.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryText(context),
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSent
                          ? "Sent to ${widget.name}"
                          : "Received from ${widget.name}",
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: themeBlue.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: themeBlue,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Transaction Protected",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: themeBlue,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double statusBarHeight,
    Color bg,
    Color text,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, statusBarHeight + 4, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withOpacity(0.8),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryText(context),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              _buildHeroAvatar(bg, text),
              const SizedBox(width: 12),
              _buildNameSection(context),
              const Spacer(),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroAvatar(Color bg, Color text) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [bg, bg.withOpacity(0.8)]),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.name[0].toUpperCase(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: text,
        ),
      ),
    );
  }

  Widget _buildNameSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.name,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText(context),
          ),
        ),
        Text(
          widget.upiId,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText(context).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.verified_user_rounded,
          color: Colors.blue.shade400,
          size: 18,
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: AppColors.primaryText(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppColors.surface(context),
          onSelected: (value) {
            if (value == 'report') {
              _showReportBottomSheet(context);
            } else if (value == 'block') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Block feature coming soon")),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'report',
              child: Text(
                "Report User",
                style: TextStyle(color: AppColors.primaryText(context)),
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Text(
                "Block User",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            "Secure UPI Payment Chat",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBottomBar(BuildContext context, Color themeColor) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          decoration: BoxDecoration(
            color: AppColors.surface(context).withOpacity(0.85),
            border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              _buildPayButton(),
              const SizedBox(width: 12),
              _buildMessageInput(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      height: 52,
      width: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF003AB5)],
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PaymentScreen(name: widget.name, upiId: widget.upiId),
            ),
          ).then((value) {
            setState(() {
              _transactionFuture = _fetchTransactions();
            });
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "PAY",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Expanded(
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bg(context).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          style: TextStyle(color: AppColors.primaryText(context)),
          decoration: InputDecoration(
            hintText: "Send a message...",
            border: InputBorder.none,
            suffixIcon: const Icon(
              Icons.send_rounded,
              color: Color(0xFF1A56DB),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
