import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';

class NotificationService {
  final Dio _dio = Dio();

  NotificationService() {
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
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
      ),
    );
  }

  /// Get notifications list
  Future<NotificationResult> getNotifications({
    String? type,
    bool unreadOnly = false,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {
          if (type != null) 'type': type,
          if (unreadOnly) 'unread_only': true,
          'page': page,
        },
      );
      if (response.data['success'] == true) {
        return NotificationResult.fromJson(response.data);
      }
      return NotificationResult.empty();
    } catch (e) {
      developer.log('Error fetching notifications: $e');
      return NotificationResult.empty();
    }
  }

  /// Get unread count
  Future<UnreadCount> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      if (response.data['success'] == true && response.data['data'] != null) {
        return UnreadCount.fromJson(response.data['data']);
      }
      return UnreadCount(count: 0, hasUnread: false);
    } catch (e) {
      return UnreadCount(count: 0, hasUnread: false);
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String id) async {
    try {
      await _dio.put('/notifications/$id/read');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark all as read
  Future<bool> markAllAsRead() async {
    try {
      await _dio.put('/notifications/read-all');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String id) async {
    try {
      await _dio.delete('/notifications/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get announcements
  Future<AnnouncementResult> getAnnouncements() async {
    try {
      final response = await _dio.get('/announcements');
      if (response.data['success'] == true && response.data['data'] != null) {
        return AnnouncementResult.fromJson(response.data['data']);
      }
      return AnnouncementResult.empty();
    } catch (e) {
      developer.log('Error fetching announcements: $e');
      return AnnouncementResult.empty();
    }
  }

  /// Dismiss popup announcement
  Future<bool> dismissAnnouncement(int id) async {
    try {
      await _dio.post('/announcements/$id/dismiss');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Register FCM token to database
  Future<bool> registerFcmToken({
    required String fcmToken,
    String deviceType = 'android',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.fcmToken,
        data: {'fcm_token': fcmToken, 'device_type': deviceType},
      );
      if (response.data['success'] == true) {
        developer.log('FCM token registered successfully');
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error registering FCM token: $e');
      return false;
    }
  }

  /// Clear all notifications
  Future<ClearResult> clearAllNotifications() async {
    try {
      final response = await _dio.delete(ApiConstants.notificationsClearAll);
      if (response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        return ClearResult(
          success: true,
          deletedCount: data['deleted_count'] ?? 0,
          message: response.data['message'] ?? 'Arifa zimefutwa.',
        );
      }
      return ClearResult(
        success: false,
        deletedCount: 0,
        message: 'Imeshindwa kufuta arifa.',
      );
    } catch (e) {
      developer.log('Error clearing notifications: $e');
      return ClearResult(
        success: false,
        deletedCount: 0,
        message: 'Hitilafu imetokea.',
      );
    }
  }

  /// Get notification types with counts
  Future<List<NotificationType>> getNotificationTypes() async {
    try {
      final response = await _dio.get(ApiConstants.notificationsTypes);
      if (response.data['success'] == true && response.data['data'] != null) {
        final dataList = response.data['data'] as List;
        return dataList.map((t) => NotificationType.fromJson(t)).toList();
      }
      return [];
    } catch (e) {
      developer.log('Error fetching notification types: $e');
      return [];
    }
  }

  /// Get single notification by ID
  Future<AppNotification?> getNotification(String id) async {
    try {
      final response = await _dio.get(ApiConstants.notificationDetail(id));
      if (response.data['success'] == true && response.data['data'] != null) {
        return AppNotification.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching notification: $e');
      return null;
    }
  }
}

// ================== DATA MODELS ==================

class NotificationResult {
  final List<AppNotification> notifications;
  final int total;
  final int unreadCount;
  final int currentPage;
  final int lastPage;

  NotificationResult({
    required this.notifications,
    required this.total,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
  });

  factory NotificationResult.fromJson(Map<String, dynamic> json) {
    var dataList = [];
    var meta = json['meta'] ?? {};

    if (json['data'] is List) {
      dataList = json['data'];
    } else if (json['data'] is Map) {
      final dataObj = json['data'];
      if (dataObj['data'] is List) {
        dataList = dataObj['data'];
      }
      // If meta is not separate, it might be mixed in the data object
      if (meta.isEmpty) meta = dataObj;
    }

    return NotificationResult(
      notifications: dataList.map((n) => AppNotification.fromJson(n)).toList(),
      total: meta['total'] ?? 0,
      unreadCount: meta['unread_count'] ?? json['unread_count'] ?? 0,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
    );
  }

  factory NotificationResult.empty() => NotificationResult(
    notifications: [],
    total: 0,
    unreadCount: 0,
    currentPage: 1,
    lastPage: 1,
  );
}

class AppNotification {
  final String id;
  final String type;
  final String typeLabel;
  final String icon;
  final String color;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String createdAt;
  final String createdAtHuman;

  AppNotification({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
    required this.createdAtHuman,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      typeLabel: json['type_label']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'bell',
      color: json['color']?.toString() ?? '#3b82f6',
      title: json['title']?.toString() ?? data['title']?.toString() ?? '',
      message: json['message']?.toString() ?? data['message']?.toString() ?? '',
      data: data,
      isRead: json['is_read'] == true || json['read_at'] != null,
      createdAt: json['created_at']?.toString() ?? '',
      createdAtHuman: json['created_at_human']?.toString() ?? '',
    );
  }
}

class UnreadCount {
  final int count;
  final bool hasUnread;

  UnreadCount({required this.count, required this.hasUnread});

  factory UnreadCount.fromJson(Map<String, dynamic> json) => UnreadCount(
    count: json['count'] ?? 0,
    hasUnread: json['has_unread'] == true,
  );
}

class AnnouncementResult {
  final List<Announcement> popup;
  final List<Announcement> all;
  final int popupCount;
  final int totalCount;

  AnnouncementResult({
    required this.popup,
    required this.all,
    required this.popupCount,
    required this.totalCount,
  });

  factory AnnouncementResult.fromJson(Map<String, dynamic> json) {
    final popupList = json['popup'] as List? ?? [];
    final allList = json['all'] as List? ?? [];
    return AnnouncementResult(
      popup: popupList.map((a) => Announcement.fromJson(a)).toList(),
      all: allList.map((a) => Announcement.fromJson(a)).toList(),
      popupCount: json['popup_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
    );
  }

  factory AnnouncementResult.empty() =>
      AnnouncementResult(popup: [], all: [], popupCount: 0, totalCount: 0);
}

class Announcement {
  final int id;
  final String title;
  final String body;
  final String bodyPreview;
  final String type;
  final String typeLabel;
  final String icon;
  final String color;
  final String mediaType;
  final bool isVideo;
  final String? videoUrl;
  final int? videoDuration;
  final bool showAsPopup;
  final int maxPopupViews;
  final bool isRead;
  final int viewCount;
  final String? expiresAt;
  final String createdAt;
  final String createdAtHuman;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.bodyPreview,
    required this.type,
    required this.typeLabel,
    required this.icon,
    required this.color,
    required this.mediaType,
    required this.isVideo,
    this.videoUrl,
    this.videoDuration,
    required this.showAsPopup,
    required this.maxPopupViews,
    required this.isRead,
    required this.viewCount,
    this.expiresAt,
    required this.createdAt,
    required this.createdAtHuman,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    id: json['id'] ?? 0,
    title: json['title']?.toString() ?? '',
    body: json['body']?.toString() ?? '',
    bodyPreview: json['body_preview']?.toString() ?? '',
    type: json['type']?.toString() ?? 'info',
    typeLabel: json['type_label']?.toString() ?? '',
    icon: json['icon']?.toString() ?? 'info',
    color: json['color']?.toString() ?? '#3b82f6',
    mediaType: json['media_type']?.toString() ?? 'text',
    isVideo: json['is_video'] == true,
    videoUrl: json['video_url']?.toString(),
    videoDuration: json['video_duration'],
    showAsPopup: json['show_as_popup'] == true,
    maxPopupViews: json['max_popup_views'] ?? 1,
    isRead: json['is_read'] == true,
    viewCount: json['view_count'] ?? 0,
    expiresAt: json['expires_at']?.toString(),
    createdAt: json['created_at']?.toString() ?? '',
    createdAtHuman: json['created_at_human']?.toString() ?? '',
  );
}

class ClearResult {
  final bool success;
  final int deletedCount;
  final String message;

  ClearResult({
    required this.success,
    required this.deletedCount,
    required this.message,
  });
}

class NotificationType {
  final String type;
  final String label;
  final String icon;
  final String color;
  final int count;

  NotificationType({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.count,
  });

  factory NotificationType.fromJson(Map<String, dynamic> json) =>
      NotificationType(
        type: json['type']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        icon: json['icon']?.toString() ?? 'bell',
        color: json['color']?.toString() ?? '#6b7280',
        count: json['count'] ?? 0,
      );
}
