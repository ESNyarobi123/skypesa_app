/// Model to represent blocked user information from the API
class BlockedInfo {
  final bool isBlocked;
  final String? blockedReason;
  final String? blockedAt;
  final String? blockedBy;
  final int? totalFlaggedClicks;
  final int? autoBlockThreshold;
  final BlockedSupport? support;
  final BlockedInstructions? instructions;
  final String? message;

  BlockedInfo({
    required this.isBlocked,
    this.blockedReason,
    this.blockedAt,
    this.blockedBy,
    this.totalFlaggedClicks,
    this.autoBlockThreshold,
    this.support,
    this.instructions,
    this.message,
  });

  factory BlockedInfo.fromJson(Map<String, dynamic> json) {
    // Check if is_blocked is in root or in blocking_info
    final isBlocked = json['is_blocked'] as bool? ?? false;

    // Extract blocking_info if exists
    final blockingInfo = json['blocking_info'] as Map<String, dynamic>?;

    return BlockedInfo(
      isBlocked: isBlocked,
      blockedReason: blockingInfo?['blocked_reason'] as String?,
      blockedAt: blockingInfo?['blocked_at'] as String?,
      blockedBy: blockingInfo?['blocked_by'] as String?,
      totalFlaggedClicks: blockingInfo?['total_flagged_clicks'] as int?,
      autoBlockThreshold: blockingInfo?['auto_block_threshold'] as int?,
      support: json['support'] != null
          ? BlockedSupport.fromJson(json['support'] as Map<String, dynamic>)
          : null,
      instructions: json['instructions'] != null
          ? BlockedInstructions.fromJson(
              json['instructions'] as Map<String, dynamic>,
            )
          : null,
      message: json['message'] as String?,
    );
  }

  /// Get formatted blocked date
  String get formattedBlockedDate {
    if (blockedAt == null) return 'Haijulikani';
    try {
      final date = DateTime.parse(blockedAt!);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return blockedAt!;
    }
  }

  /// Get WhatsApp URL with pre-filled message
  String get whatsappUrlWithMessage {
    if (support?.whatsappUrl == null) return '';
    final message =
        support?.message ??
        'Habari Admin, naomba msaada. Akaunti yangu imezuiwa.';
    return '${support!.whatsappUrl}?text=${Uri.encodeComponent(message)}';
  }
}

class BlockedSupport {
  final String? whatsapp;
  final String? whatsappUrl;
  final String? message;

  BlockedSupport({this.whatsapp, this.whatsappUrl, this.message});

  factory BlockedSupport.fromJson(Map<String, dynamic> json) {
    return BlockedSupport(
      whatsapp: json['whatsapp'] as String?,
      whatsappUrl: json['whatsapp_url'] as String?,
      message: json['message'] as String?,
    );
  }
}

class BlockedInstructions {
  final String? sw;
  final String? en;

  BlockedInstructions({this.sw, this.en});

  factory BlockedInstructions.fromJson(Map<String, dynamic> json) {
    return BlockedInstructions(
      sw: json['sw'] as String?,
      en: json['en'] as String?,
    );
  }
}
