import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearup_garage/presentation/customer/customer_chat.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';

class CustomerMessagesPage extends StatefulWidget {
  const CustomerMessagesPage({super.key});

  @override
  State<CustomerMessagesPage> createState() => _CustomerMessagesPageState();
}

class _CustomerMessagesPageState extends State<CustomerMessagesPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const AppScaffold(
        body: Center(
          child: Text(
            'Please log in to view messages',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
          ),
        ),
      );
    }

    return AppScaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('chats')
                .where('customerId', isEqualTo: _currentUser.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.secondary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: AppTheme.error),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading messages',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Messages with service providers will appear here',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!.docs;

          // Sort manually by lastMessageTime (most recent first)
          chats.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['lastMessageTime'] as Timestamp?;
            final bTime = bData['lastMessageTime'] as Timestamp?;

            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;

            return bTime.compareTo(aTime); // Descending order
          });

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              return _buildChatTile(chatData);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chatData) {
    final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
    final timeString =
        lastMessageTime != null ? _formatTime(lastMessageTime.toDate()) : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary,
          child: Text(
            (chatData['providerName'] ?? 'P')[0].toUpperCase(),
            style: const TextStyle(
              color: AppTheme.buttonText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          chatData['providerName'] ?? 'Service Provider',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          chatData['lastMessage'] ?? 'No messages yet',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeString,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  color: AppTheme.buttonText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CustomerChatScreen(
                    bookingId: chatData['bookingId'] ?? '',
                    providerId: chatData['providerId'] ?? '',
                    providerName:
                        chatData['providerName'] ?? 'Service Provider',
                  ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
