import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearup_garage/core/theme/app_theme.dart';
import 'package:gearup_garage/core/ui/app_scaffold.dart';

class ProviderChatScreen extends StatefulWidget {
  final String bookingId;
  final String customerId;
  final String customerName;

  const ProviderChatScreen({
    super.key,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<ProviderChatScreen> createState() => _ProviderChatScreenState();
}

class _ProviderChatScreenState extends State<ProviderChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String? _currentProviderId;
  String? _currentProviderName;

  @override
  void initState() {
    super.initState();
    _getCurrentProviderId();
  }

  Future<void> _getCurrentProviderId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('service_providers')
                .where('email', isEqualTo: currentUser.email)
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          final providerData = querySnapshot.docs.first.data();
          setState(() {
            _currentProviderId = querySnapshot.docs.first.id;
            _currentProviderName =
                providerData['businessName'] ?? 'Service Provider';
          });
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _currentUser == null ||
        _currentProviderId == null) {
      return;
    }

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.bookingId)
          .collection('messages')
          .add({
            'text': message,
            'senderId': _currentUser.uid,
            'senderEmail': _currentUser.email,
            'senderType': 'provider',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });

      // Update chat metadata
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.bookingId)
          .set({
            'bookingId': widget.bookingId,
            'customerId': widget.customerId,
            'customerName': widget.customerName,
            'providerId': _currentProviderId!, // Use the actual provider ID
            'providerName': _currentProviderName ?? 'Service Provider',
            'providerEmail': _currentUser.email,
            'lastMessage': message,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'lastMessageSender': 'provider',
          }, SetOptions(merge: true));

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.customerName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Customer',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.bookingId)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.secondary),
                  );
                }

                if (snapshot.hasError) {
                  print('Provider chat error: ${snapshot.error}'); // Debug log
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error,
                          size: 64,
                          color: AppTheme.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading messages',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Force rebuild to retry
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.buttonText,
                          ),
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
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start a conversation with your customer',
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

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = messageData['senderId'] == _currentUser?.uid;

                    return _buildMessageBubble(messageData, isMe);
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                top: BorderSide(color: AppTheme.inputBorder, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: AppTheme.buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData, bool isMe) {
    final timestamp = messageData['timestamp'] as Timestamp?;
    final timeString =
        timestamp != null
            ? '${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
            : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              messageData['text'] ?? '',
              style: TextStyle(
                color: isMe ? AppTheme.buttonText : AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            if (timeString.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                timeString,
                style: TextStyle(
                  color:
                      isMe
                          ? AppTheme.buttonText.withOpacity(0.7)
                          : AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
