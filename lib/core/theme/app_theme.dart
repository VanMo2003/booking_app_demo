import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';

/// Theme Material 3 dựng hoàn toàn từ `core/color` và `core/style`, để widget
/// mặc định của Flutter (TextField, nút, tab, hộp thoại…) tự khớp giao diện.
abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.accent,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.accentSoft,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.info,
      onTertiary: AppColors.onPrimary,
      error: AppColors.danger,
      onError: AppColors.onPrimary,
      errorContainer: AppColors.dangerSoft,
      onErrorContainer: AppColors.danger,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkSecondary,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.ground,
      surfaceContainer: AppColors.ground,
      surfaceContainerHigh: AppColors.surfaceSunk,
      surfaceContainerHighest: AppColors.surfaceSunk,
      outline: AppColors.line,
      outlineVariant: AppColors.lineSoft,
      shadow: AppColors.ink,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.surface,
      inversePrimary: AppColors.primarySoft,
      surfaceTint: Colors.transparent,
    );

    const inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.smAll,
      borderSide: BorderSide(color: AppColors.line),
    );

    WidgetStateProperty<T> selected<T>(T on, T off) =>
        WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? on : off,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.ground,
      canvasColor: AppColors.surface,
      textTheme: AppTextStyles.textTheme(),
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ground,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.md,
        titleTextStyle: AppTextStyles.title,
        iconTheme: const IconThemeData(color: AppColors.ink, size: 24),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: AppColors.lineSoft),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lineSoft,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: AppTextStyles.body.colored(AppColors.inkTertiary),
        labelStyle: AppTextStyles.body.colored(AppColors.inkSecondary),
        floatingLabelStyle: AppTextStyles.bodyMedium.colored(AppColors.primary),
        helperStyle: AppTextStyles.caption,
        errorStyle: AppTextStyles.caption.colored(AppColors.danger),
        prefixIconColor: AppColors.inkSecondary,
        suffixIconColor: AppColors.inkSecondary,
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.lineSoft),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceSunk,
          disabledForegroundColor: AppColors.inkTertiary,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: AppTextStyles.button,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.inkTertiary,
          side: const BorderSide(color: AppColors.line),
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.ink),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 3,
        highlightElevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        extendedTextStyle: AppTextStyles.button,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft,
        disabledColor: AppColors.surfaceSunk,
        side: const BorderSide(color: AppColors.line),
        labelStyle: AppTextStyles.chip,
        secondaryLabelStyle: AppTextStyles.chip.colored(AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primarySoft,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppTextStyles.captionStrong.colored(AppColors.primary)
              : AppTextStyles.caption.colored(AppColors.inkSecondary),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.inkSecondary,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.inkSecondary,
        labelStyle: AppTextStyles.bodyStrong,
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.lineSoft,
        overlayColor: WidgetStateProperty.all(AppColors.primarySoft),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: AppTextStyles.title,
        contentTextStyle: AppTextStyles.body.colored(AppColors.inkSecondary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.line,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextStyles.bodyMedium.colored(AppColors.surface),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.inkSecondary,
        titleTextStyle: AppTextStyles.bodyMedium,
        subtitleTextStyle: AppTextStyles.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: selected(AppColors.onPrimary, AppColors.surface),
        trackColor: selected(AppColors.primary, AppColors.line),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: selected(AppColors.primary, Colors.transparent),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        side: const BorderSide(color: AppColors.inkTertiary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(
        fillColor: selected(AppColors.primary, AppColors.inkTertiary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primarySoft,
        circularTrackColor: Colors.transparent,
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.onPrimary,
        rangePickerHeaderBackgroundColor: AppColors.primary,
        rangePickerHeaderForegroundColor: AppColors.onPrimary,
        rangeSelectionBackgroundColor: AppColors.primarySoft,
        todayBorder: BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        textStyle: AppTextStyles.body,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: AppColors.ink,
          borderRadius: AppRadius.smAll,
        ),
        textStyle: AppTextStyles.caption.colored(AppColors.surface),
      ),
    );
  }
}
