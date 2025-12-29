import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';

class SupportService {
  final Dio _dio = Dio();

  SupportService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          developer.log('Support API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Get contact information
  Future<ContactInfo?> getContactInfo() async {
    try {
      final response = await _dio.get(ApiConstants.supportContact);
      if (response.data['success'] == true && response.data['data'] != null) {
        return ContactInfo.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching contact info: $e');
      return null;
    }
  }

  /// Get FAQs with optional category filter
  Future<FAQData?> getFAQs({String? category}) async {
    try {
      final params = <String, dynamic>{};
      if (category != null && category != 'all') {
        params['category'] = category;
      }
      final response = await _dio.get(
        ApiConstants.supportFaq,
        queryParameters: params,
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        return FAQData.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching FAQs: $e');
      return null;
    }
  }

  /// Get support ticket stats
  Future<TicketStats?> getStats() async {
    try {
      final response = await _dio.get('${ApiConstants.supportTickets}/stats');
      if (response.data['success'] == true && response.data['data'] != null) {
        return TicketStats.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching stats: $e');
      return null;
    }
  }

  /// Get user's tickets with pagination and optional status filter
  Future<TicketListResult> getTickets({int page = 1, String? status}) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (status != null && status != 'all') {
        params['status'] = status;
      }
      final response = await _dio.get(
        ApiConstants.supportTickets,
        queryParameters: params,
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        final meta = response.data['meta'];
        return TicketListResult(
          tickets: data.map((json) => Ticket.fromJson(json)).toList(),
          currentPage: meta?['current_page'] ?? 1,
          lastPage: meta?['last_page'] ?? 1,
          total: meta?['total'] ?? 0,
        );
      }
      return TicketListResult(tickets: []);
    } catch (e) {
      developer.log('Error fetching tickets: $e');
      return TicketListResult(tickets: []);
    }
  }

  /// Create a new support ticket
  Future<ApiResult<Ticket>> createTicket({
    required String subject,
    required String category,
    required String message,
    String priority = 'medium',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.supportTickets,
        data: {
          'subject': subject,
          'category': category,
          'message': message,
          'priority': priority,
        },
      );

      if (response.data['success'] == true) {
        return ApiResult(
          success: true,
          message: response.data['message'] ?? 'Ombi lako limepokelewa.',
          data: response.data['data'] != null
              ? Ticket.fromJson(response.data['data'])
              : null,
        );
      }
      return ApiResult(
        success: false,
        message: response.data['message'] ?? 'Imeshindikana',
      );
    } on DioException catch (e) {
      return ApiResult(
        success: false,
        message: _handleError(e),
        errors: _extractErrors(e),
      );
    }
  }

  /// Get single ticket with messages
  Future<TicketDetail?> getTicket(String ticketNumber) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.supportTickets}/$ticketNumber',
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        return TicketDetail.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching ticket: $e');
      return null;
    }
  }

  /// Reply to a ticket
  Future<ApiResult<TicketMessage>> replyToTicket(
    String ticketNumber,
    String message,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.supportTickets}/$ticketNumber/reply',
        data: {'message': message},
      );

      if (response.data['success'] == true) {
        return ApiResult(
          success: true,
          message: response.data['message'] ?? 'Ujumbe umetumwa.',
          data: response.data['data'] != null
              ? TicketMessage.fromJson(response.data['data'])
              : null,
        );
      }
      return ApiResult(
        success: false,
        message: response.data['message'] ?? 'Imeshindikana.',
      );
    } on DioException catch (e) {
      return ApiResult(success: false, message: _handleError(e));
    }
  }

  /// Close a ticket
  Future<ApiResult<void>> closeTicket(String ticketNumber) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.supportTickets}/$ticketNumber/close',
      );
      return ApiResult(
        success: response.data['success'] == true,
        message: response.data['message'] ?? 'Tiketi imefungwa.',
      );
    } on DioException catch (e) {
      return ApiResult(success: false, message: _handleError(e));
    }
  }

  /// Reopen a ticket
  Future<ApiResult<void>> reopenTicket(String ticketNumber) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.supportTickets}/$ticketNumber/reopen',
      );
      return ApiResult(
        success: response.data['success'] == true,
        message: response.data['message'] ?? 'Tiketi imefunguliwa tena.',
      );
    } on DioException catch (e) {
      return ApiResult(success: false, message: _handleError(e));
    }
  }

  /// Report a bug
  Future<ApiResult<void>> reportBug({
    required String title,
    required String description,
    String? stepsToReproduce,
    String? deviceInfo,
    String? appVersion,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.bugReport,
        data: {
          'title': title,
          'description': description,
          if (stepsToReproduce != null) 'steps_to_reproduce': stepsToReproduce,
          if (deviceInfo != null) 'device_info': deviceInfo,
          if (appVersion != null) 'app_version': appVersion,
        },
      );

      if (response.data['success'] == true) {
        return ApiResult(
          success: true,
          message: response.data['message'] ?? 'Asante kwa kuripoti tatizo!',
        );
      }
      return ApiResult(
        success: false,
        message: response.data['message'] ?? 'Imeshindikana.',
      );
    } on DioException catch (e) {
      return ApiResult(
        success: false,
        message: _handleError(e),
        errors: _extractErrors(e),
      );
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        return e.response?.data['message'];
      }
      return 'Server error: ${e.response?.statusCode}';
    }
    return 'Connection error. Please check your internet.';
  }

  Map<String, List<String>>? _extractErrors(DioException e) {
    if (e.response?.data is Map && e.response?.data['errors'] != null) {
      final errors = e.response?.data['errors'] as Map<String, dynamic>;
      return errors.map(
        (key, value) =>
            MapEntry(key, (value as List).map((e) => e.toString()).toList()),
      );
    }
    return null;
  }
}

// ================== DATA MODELS ==================

/// Generic API result wrapper
class ApiResult<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, List<String>>? errors;

  ApiResult({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });
}

/// Contact information model
class ContactInfo {
  final String email;
  final String phone;
  final String whatsapp;
  final String workingHours;
  final String responseTime;
  final SocialLinks social;

  ContactInfo({
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.workingHours,
    required this.responseTime,
    required this.social,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      workingHours: json['working_hours']?.toString() ?? '',
      responseTime: json['response_time']?.toString() ?? '',
      social: SocialLinks.fromJson(json['social'] ?? {}),
    );
  }
}

class SocialLinks {
  final String? telegram;
  final String? instagram;
  final String? facebook;

  SocialLinks({this.telegram, this.instagram, this.facebook});

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      telegram: json['telegram']?.toString(),
      instagram: json['instagram']?.toString(),
      facebook: json['facebook']?.toString(),
    );
  }
}

/// FAQ data model
class FAQData {
  final List<FAQCategory> categories;
  final List<FAQ> faqs;

  FAQData({required this.categories, required this.faqs});

  factory FAQData.fromJson(Map<String, dynamic> json) {
    final cats = json['categories'] as List? ?? [];
    final faqs = json['faqs'] as List? ?? [];
    return FAQData(
      categories: cats.map((c) => FAQCategory.fromJson(c)).toList(),
      faqs: faqs.map((f) => FAQ.fromJson(f)).toList(),
    );
  }
}

class FAQCategory {
  final String id;
  final String name;
  final String icon;

  FAQCategory({required this.id, required this.name, required this.icon});

  factory FAQCategory.fromJson(Map<String, dynamic> json) {
    return FAQCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'help',
    );
  }
}

class FAQ {
  final int id;
  final String category;
  final String question;
  final String answer;

  FAQ({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'] ?? 0,
      category: json['category']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
    );
  }
}

/// Ticket stats model
class TicketStats {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;
  final int unreadMessages;

  TicketStats({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
    required this.unreadMessages,
  });

  factory TicketStats.fromJson(Map<String, dynamic> json) {
    return TicketStats(
      total: json['total'] ?? 0,
      open: json['open'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      resolved: json['resolved'] ?? 0,
      closed: json['closed'] ?? 0,
      unreadMessages: json['unread_messages'] ?? 0,
    );
  }
}

/// Ticket model
class Ticket {
  final int id;
  final String ticketNumber;
  final String subject;
  final String category;
  final String categoryLabel;
  final String priority;
  final String priorityLabel;
  final String? priorityColor;
  final String status;
  final String statusLabel;
  final String? statusColor;
  final int unreadCount;
  final String? lastMessageAt;
  final String createdAt;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.category,
    required this.categoryLabel,
    required this.priority,
    required this.priorityLabel,
    this.priorityColor,
    required this.status,
    required this.statusLabel,
    this.statusColor,
    required this.unreadCount,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      categoryLabel: json['category_label']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
      priorityLabel: json['priority_label']?.toString() ?? 'Wastani',
      priorityColor: json['priority_color']?.toString(),
      status: json['status']?.toString() ?? 'open',
      statusLabel: json['status_label']?.toString() ?? 'Wazi',
      statusColor: json['status_color']?.toString(),
      unreadCount: json['unread_count'] ?? 0,
      lastMessageAt: json['last_message_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
}

/// Ticket list result
class TicketListResult {
  final List<Ticket> tickets;
  final int currentPage;
  final int lastPage;
  final int total;

  TicketListResult({
    required this.tickets,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });
}

/// Ticket detail with messages
class TicketDetail {
  final int id;
  final String ticketNumber;
  final String subject;
  final String category;
  final String categoryLabel;
  final String priority;
  final String priorityLabel;
  final String? priorityColor;
  final String status;
  final String statusLabel;
  final String? statusColor;
  final String? assignedTo;
  final List<TicketMessage> messages;
  final bool canReply;
  final String? lastMessageAt;
  final String? resolvedAt;
  final String createdAt;

  TicketDetail({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.category,
    required this.categoryLabel,
    required this.priority,
    required this.priorityLabel,
    this.priorityColor,
    required this.status,
    required this.statusLabel,
    this.statusColor,
    this.assignedTo,
    required this.messages,
    required this.canReply,
    this.lastMessageAt,
    this.resolvedAt,
    required this.createdAt,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    final msgs = json['messages'] as List? ?? [];
    return TicketDetail(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      categoryLabel: json['category_label']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
      priorityLabel: json['priority_label']?.toString() ?? 'Wastani',
      priorityColor: json['priority_color']?.toString(),
      status: json['status']?.toString() ?? 'open',
      statusLabel: json['status_label']?.toString() ?? 'Wazi',
      statusColor: json['status_color']?.toString(),
      assignedTo: json['assigned_to']?.toString(),
      messages: msgs.map((m) => TicketMessage.fromJson(m)).toList(),
      canReply: json['can_reply'] == true,
      lastMessageAt: json['last_message_at']?.toString(),
      resolvedAt: json['resolved_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  bool get isOpen => status == 'open';
  bool get isClosed => status == 'closed';
}

/// Ticket message model
class TicketMessage {
  final int id;
  final String message;
  final bool isAdmin;
  final String senderName;
  final String? senderAvatar;
  final bool isRead;
  final String createdAt;

  TicketMessage({
    required this.id,
    required this.message,
    required this.isAdmin,
    required this.senderName,
    this.senderAvatar,
    required this.isRead,
    required this.createdAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] ?? 0,
      message: json['message']?.toString() ?? '',
      isAdmin: json['is_admin'] == true,
      senderName: json['sender_name']?.toString() ?? 'User',
      senderAvatar: json['sender_avatar']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
