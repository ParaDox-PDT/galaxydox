import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/onboarding/data/onboarding_local_data_source.dart';
import '../../../../firebase_options.dart';
import '../../data/datasources/notifications_local_data_source.dart';
import 'notification_navigation_service.dart';
import 'notifications_provider.dart';
import '../widgets/foreground_notification_toast.dart';

const notificationTopicName = 'notifications';
const notificationChannelId = 'galaxydox_notifications';
const _notificationChannelName = 'GalaxyDox updates';
const _notificationChannelDescription =
    'Launches local alerts for new GalaxyDox content.';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  // Foreground taps are handled in the main isolate. No extra work is needed
  // here because remote push taps arrive through Firebase Messaging callbacks.
}

final notificationLifecycleControllerProvider =
    Provider<NotificationLifecycleController>((ref) {
      final controller = NotificationLifecycleController(ref);
      ref.onDispose(controller.dispose);
      return controller;
    });

class NotificationLifecycleController {
  NotificationLifecycleController(this._ref)
    : _messaging = FirebaseMessaging.instance,
      _localNotifications = FlutterLocalNotificationsPlugin();

  final Ref _ref;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSubscription;

  bool _initialized = false;
  GoRouter? _router;
  GlobalKey<NavigatorState>? _navigatorKey;
  OverlayEntry? _foregroundToastEntry;

  Future<void> initialize({
    required GoRouter router,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _router = router;
    _navigatorKey = navigatorKey;
    if (kIsWeb) return;

    if (_initialized) {
      await _restoreTopicSubscriptionIfPossible();
      return;
    }

    _initialized = true;
    await _initializeLocalNotifications();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _onMessageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _onMessageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleOpenedMessage(message, waitForSplash: false),
    );

    await _restoreTopicSubscriptionIfPossible();

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      unawaited(_handleOpenedMessage(initialMessage, waitForSplash: true));
    }
  }

  Future<void> requestPermissionIfNeeded() async {
    if (kIsWeb) return;

    final preferences = OnboardingLocalDataSource();
    if (!preferences.hasCompletedOnboarding) return;

    if (preferences.hasRequestedNotificationPermission) {
      await _restoreTopicSubscriptionIfPossible();
      return;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    final granted = _isPermissionGranted(settings.authorizationStatus);

    await preferences.saveNotificationPermissionRequest(granted: granted);
    await _syncTopicSubscription(granted);

    if (granted) {
      _ref.invalidate(notificationsProvider);
    }
  }

  void dispose() {
    if (_onMessageSubscription != null) {
      unawaited(_onMessageSubscription!.cancel());
    }
    if (_onMessageOpenedSubscription != null) {
      unawaited(_onMessageOpenedSubscription!.cancel());
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    const channel = AndroidNotificationChannel(
      notificationChannelId,
      _notificationChannelName,
      description: _notificationChannelDescription,
      importance: Importance.max,
    );

    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(channel);
  }

  Future<void> _restoreTopicSubscriptionIfPossible() async {
    final preferences = OnboardingLocalDataSource();
    if (!preferences.hasCompletedOnboarding ||
        !preferences.hasRequestedNotificationPermission) {
      return;
    }

    final settings = await _messaging.getNotificationSettings();
    final granted = _isPermissionGranted(settings.authorizationStatus);

    await preferences.setNotificationPermissionGranted(granted);
    await _syncTopicSubscription(granted);
  }

  Future<void> _syncTopicSubscription(bool granted) async {
    try {
      if (granted) {
        await _messaging.getToken();
        await _messaging.subscribeToTopic(notificationTopicName);
      } else {
        await _messaging.unsubscribeFromTopic(notificationTopicName);
      }
    } catch (error) {
      debugPrint('FCM TOPIC SYNC ERROR: $error');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _ref.invalidate(notificationsProvider);

    final title =
        message.notification?.title ??
        _readFirstNonEmpty(message.data, const ['title']);
    final body =
        message.notification?.body ??
        _readFirstNonEmpty(message.data, const ['body']);

    if ((title ?? '').trim().isEmpty && (body ?? '').trim().isEmpty) {
      return;
    }

    _showForegroundToast(
      title: title ?? 'GalaxyDox',
      body: (body ?? '').trim().isEmpty ? null : body,
    );
  }

  Future<void> _handleOpenedMessage(
    RemoteMessage message, {
    required bool waitForSplash,
  }) async {
    final notificationId = _extractNotificationId(message.data);
    if (notificationId != null && notificationId.isNotEmpty) {
      await NotificationsLocalDataSource().markAsRead(notificationId);
    }
    _ref.invalidate(notificationsProvider);

    final payload = NotificationNavigationPayload(
      typeRaw: _readFirstNonEmpty(message.data, const ['type']),
      routeId: _readFirstNonEmpty(message.data, const ['route_id']),
    );

    await _routeFromPayload(payload, waitForSplash: waitForSplash);
  }

  Future<void> _handleLocalNotificationResponse(
    NotificationResponse response,
  ) async {
    final rawPayload = response.payload;
    if (rawPayload == null || rawPayload.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(rawPayload) as Map<String, dynamic>;
      final notificationId = decoded['notification_id']?.toString().trim();
      if (notificationId != null && notificationId.isNotEmpty) {
        await NotificationsLocalDataSource().markAsRead(notificationId);
      }
      _ref.invalidate(notificationsProvider);

      await _routeFromPayload(
        NotificationNavigationPayload(
          typeRaw: decoded['type']?.toString(),
          routeId: decoded['route_id']?.toString(),
        ),
        waitForSplash: false,
      );
    } catch (error) {
      debugPrint('LOCAL NOTIFICATION PAYLOAD ERROR: $error');
    }
  }

  Future<void> _routeFromPayload(
    NotificationNavigationPayload payload, {
    required bool waitForSplash,
  }) async {
    final router = _router;
    if (router == null) return;

    if (waitForSplash) {
      await Future<void>.delayed(
        AppConstants.splashDuration + const Duration(milliseconds: 350),
      );
    }

    if (!_ref.mounted) return;
    _ref
        .read(notificationNavigationServiceProvider)
        .pushFromPayload(router, payload);
  }

  bool _isPermissionGranted(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  String? _extractNotificationId(Map<String, dynamic> data) {
    return _readFirstNonEmpty(data, const [
      'notification_id',
      'id',
      'doc_id',
      'document_id',
    ]);
  }

  String? _readFirstNonEmpty(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  void _showForegroundToast({required String title, String? body}) {
    final overlay = _navigatorKey?.currentState?.overlay;
    if (overlay == null) return;

    _foregroundToastEntry?.remove();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => ForegroundNotificationToast(
        title: title,
        body: body,
        onTap: () => _openNotificationsInbox(),
        onDismissed: () {
          if (_foregroundToastEntry == entry) {
            _foregroundToastEntry = null;
          }
          entry.remove();
        },
      ),
    );

    _foregroundToastEntry = entry;
    overlay.insert(entry);
  }

  void _openNotificationsInbox() {
    final router = _router;
    if (router == null) return;

    router.pushNamed(AppRoutes.notificationsName);
  }
}
