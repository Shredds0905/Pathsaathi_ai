import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel? message;
  final bool isTyping;

  const ChatBubble({
    Key? key,
    this.message,
    this.isTyping = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message?.role == 'user';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.secondaryGradient,
                boxShadow: AppShadows.light,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ).animate().scale(delay: 100.ms),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isUser 
                    ? theme.colorScheme.primary 
                    : (isDark ? AppColors.surfaceDark : AppColors.surface),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(isUser ? AppRadius.lg : 4),
                  bottomRight: Radius.circular(isUser ? 4 : AppRadius.lg),
                ),
                boxShadow: AppShadows.light,
                border: isUser ? null : Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTyping)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white54 : Colors.black54,
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (c) => c.repeat())
                         .scale(
                           duration: 600.ms,
                           delay: Duration(milliseconds: index * 200),
                           begin: const Offset(0.5, 0.5),
                           end: const Offset(1, 1),
                         ).then().scale(
                           duration: 600.ms,
                           begin: const Offset(1, 1),
                           end: const Offset(0.5, 0.5),
                         );
                      }),
                    )
                  else if (message != null)
                    MarkdownBody(
                      data: message!.content,
                      styleSheet: MarkdownStyleSheet(
                        p: theme.textTheme.bodyLarge?.copyWith(
                          color: isUser 
                              ? Colors.white 
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                        ),
                        code: theme.textTheme.bodyMedium?.copyWith(
                          backgroundColor: isUser ? Colors.white24 : (isDark ? Colors.black26 : Colors.black12),
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isDark ? Colors.black45 : Colors.black87,
                          borderRadius: AppRadius.smBorder,
                        ),
                      ),
                    ),
                  
                  if (!isUser && !isTyping && message != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(Icons.copy, () {
                          Clipboard.setData(ClipboardData(text: message!.content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard')),
                          );
                        }),
                        const SizedBox(width: AppSpacing.sm),
                        _buildActionButton(Icons.volume_up, () {}),
                        const SizedBox(width: AppSpacing.sm),
                        _buildActionButton(Icons.thumb_up_outlined, () {}),
                        const SizedBox(width: AppSpacing.sm),
                        _buildActionButton(Icons.thumb_down_outlined, () {}),
                      ],
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ],
              ),
            ).animate().slideY(begin: 0.1, end: 0).fadeIn(),
          ),
          
          if (isUser) ...[
            Container(
              margin: const EdgeInsets.only(left: AppSpacing.sm),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.person, color: AppColors.primary, size: 16),
            ).animate().scale(delay: 100.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}
