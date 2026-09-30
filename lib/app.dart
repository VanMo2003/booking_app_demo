import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/component/feedback.dart';
import 'core/di/injector.dart';
import 'core/navigation/app_router.dart';
import 'core/text/app_strings.dart';
import 'core/text/auth_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/session/session_cubit.dart';
import 'features/chat/presentation/chat_hub.dart';
import 'features/favorite/presentation/favorites_cubit.dart';
import 'features/notification/presentation/app_events_listener.dart';
import 'features/notification/presentation/notification_badge_cubit.dart';

class BookingApp extends StatefulWidget {
  const BookingApp({super.key});

  @override
  State<BookingApp> createState() => _BookingAppState();
}

class _BookingAppState extends State<BookingApp> {
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionCubit>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider.value(value: getIt<FavoritesCubit>()),
        BlocProvider.value(value: getIt<NotificationBadgeCubit>()),
        BlocProvider.value(value: getIt<ChatUnreadCubit>()),
      ],
      child: BlocListener<SessionCubit, SessionState>(
        listenWhen: (previous, current) =>
            previous.session != null && current.session == null,
        listener: (context, state) {
          if (!session.consumeExpiredNotice()) return;
          _router.replaceAll([const CustomerShellRoute()]);
          AppToast.infoGlobal(AuthStrings.sessionExpired);
        },
        // Thông báo đẩy, deep link từ email, kiểm tra thông báo mới định kỳ.
        child: AppEventsListener(
          router: _router,
          child: MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: _router.config(),
            scaffoldMessengerKey: AppToast.messengerKey,
            locale: const Locale('vi'),
            supportedLocales: const [Locale('vi'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          ),
        ),
      ),
    );
  }
}
