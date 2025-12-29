import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../services/support_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketNumber;
  const TicketDetailScreen({super.key, required this.ticketNumber});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _supportService = SupportService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  TicketDetail? _ticket;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTicket() async {
    setState(() => _isLoading = true);
    final ticket = await _supportService.getTicket(widget.ticketNumber);
    if (mounted) {
      setState(() {
        _ticket = ticket;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    final result = await _supportService.replyToTicket(
      widget.ticketNumber,
      _messageController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (result.success) {
        _messageController.clear();
        _loadTicket();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _closeTicket() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Funga Tiketi?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tiketi hii itafungwa na huwezi kujibu tena.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hapana'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Funga'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _supportService.closeTicket(widget.ticketNumber);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success
                ? AppColors.success
                : AppColors.error,
          ),
        );
        if (result.success) _loadTicket();
      }
    }
  }

  Future<void> _reopenTicket() async {
    final result = await _supportService.reopenTicket(widget.ticketNumber);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? AppColors.success : AppColors.error,
        ),
      );
      if (result.success) _loadTicket();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.ticketNumber,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          if (_ticket != null && !_ticket!.isClosed)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _closeTicket,
              tooltip: 'Funga Tiketi',
            ),
          if (_ticket != null && _ticket!.isClosed)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _reopenTicket,
              tooltip: 'Fungua Tena',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ticket == null
          ? const Center(
              child: Text(
                'Tiketi haipatikani',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Column(
              children: [
                _buildTicketHeader(),
                Expanded(child: _buildMessagesList()),
                if (_ticket!.canReply) _buildInputBar(),
              ],
            ),
    );
  }

  Widget _buildTicketHeader() {
    final statusColor = _getStatusColor(_ticket!.status);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _ticket!.statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getPriorityColor(_ticket!.priority).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _ticket!.priorityLabel,
                  style: TextStyle(
                    color: _getPriorityColor(_ticket!.priority),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Gap(14),
          Text(
            _ticket!.subject,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Row(
            children: [
              Icon(
                Icons.category_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const Gap(4),
              Text(
                _ticket!.categoryLabel,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              if (_ticket!.assignedTo != null) ...[
                const Spacer(),
                Icon(
                  Icons.person_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const Gap(4),
                Text(
                  _ticket!.assignedTo!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _ticket!.messages.length,
      itemBuilder: (context, index) =>
          _buildMessageBubble(_ticket!.messages[index], index),
    );
  }

  Widget _buildMessageBubble(TicketMessage msg, int index) {
    final isAdmin = msg.isAdmin;
    return Align(
          alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              gradient: isAdmin
                  ? LinearGradient(
                      colors: [
                        AppColors.card,
                        AppColors.surface.withOpacity(0.5),
                      ],
                    )
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isAdmin ? 4 : 18),
                bottomRight: Radius.circular(isAdmin ? 18 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isAdmin
                          ? const Color(0xFF7C4DFF)
                          : AppColors.primary,
                      child: Text(
                        msg.senderName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      msg.senderName,
                      style: TextStyle(
                        color: isAdmin
                            ? AppColors.textSecondary
                            : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                Text(
                  msg.message,
                  style: TextStyle(
                    color: isAdmin ? Colors.white : Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const Gap(8),
                Text(
                  _formatDate(msg.createdAt),
                  style: TextStyle(
                    color: isAdmin ? AppColors.textTertiary : Colors.white60,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (40 * index).ms)
        .slideX(begin: isAdmin ? -0.1 : 0.1);
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.surface)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Andika ujumbe...',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Gap(12),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.warning;
      case 'in_progress':
        return const Color(0xFF448AFF);
      case 'resolved':
        return AppColors.success;
      case 'closed':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(String dateString) {
    try {
      final dt = DateTime.parse(dateString);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
