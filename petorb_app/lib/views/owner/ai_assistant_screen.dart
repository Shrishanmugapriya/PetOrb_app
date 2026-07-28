import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/pet_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/pet_provider.dart';

class OwnerAiAssistantScreen extends StatefulWidget {
  final PetModel pet;

  const OwnerAiAssistantScreen({super.key, required this.pet});

  @override
  State<OwnerAiAssistantScreen> createState() => _OwnerAiAssistantScreenState();
}

class _OwnerAiAssistantScreenState extends State<OwnerAiAssistantScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchHistory(widget.pet.id);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    Provider.of<ChatProvider>(context, listen: false).sendMessage(
      widget.pet.id,
      message.text,
      onProfileUpdated: () {
        petProvider.fetchPets();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryBrand.withOpacity(0.1),
              backgroundImage: widget.pet.photo.isNotEmpty ? NetworkImage(widget.pet.photo) : null,
              child: widget.pet.photo.isEmpty ? const Icon(Icons.pets, color: AppColors.primaryBrand, size: 14) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.pet.name} Assistant',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryText, fontSize: 15),
                ),
                Text(
                  'AI Care • ${widget.pet.breed}',
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.danger),
            tooltip: 'Clear Chat History',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Clear Conversation?'),
                  content: const Text('Are you sure you want to delete your chat logs with this assistant? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Clear logs', style: TextStyle(color: AppColors.danger))),
                  ],
                ),
              );
              if (confirm == true) {
                await chatProvider.clearHistory(widget.pet.id);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: Column(
          children: [
            // Status/Notification Bar if Gemini API key error happens
            if (chatProvider.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatProvider.errorMessage!,
                        style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // Main chat screen
            Expanded(
              child: chat_ui.Chat(
                messages: chatProvider.messages,
                onSendPressed: _handleSendPressed,
                user: const types.User(id: 'user'),
                showUserAvatars: true,
                showUserNames: true,
                theme: chat_ui.DefaultChatTheme(
                  primaryColor: AppColors.primaryBrand,
                  secondaryColor: AppColors.white,
                  inputBackgroundColor: AppColors.white,
                  inputTextColor: AppColors.primaryText,
                  inputBorderRadius: AppStyles.inputsBorderRadius,
                  inputTextCursorColor: AppColors.primaryBrand,
                  backgroundColor: Colors.transparent,
                  messageBorderRadius: 18.0,
                  sentMessageBodyTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  receivedMessageBodyTextStyle: const TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.w500),
                  dateDividerTextStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 11, fontWeight: FontWeight.bold),
                  inputContainerDecoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: AppStyles.softShadow,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
