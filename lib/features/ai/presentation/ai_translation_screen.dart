import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/style/style.dart';
import '../../../core/text/ai_strings.dart';
import '../domain/entities/ai.dart';
import '../domain/usecases/ai_usecases.dart';

/// Ngôn ngữ dịch được lấy từ /ai/status qua [AiAvailability] — app không giữ bản sao nào.
/// Chưa gọi được máy chủ thì chỉ hiện tiếng Anh, vì đó là ngôn ngữ chắc chắn có.
Map<String, String> aiLanguages() {
  if (!getIt.isRegistered<AiAvailability>()) return const {'en': 'English'};
  final languages = getIt<AiAvailability>().languages.value;
  return languages.isEmpty ? const {'en': 'English'} : languages;
}

@injectable
class AiTranslationCubit extends LoadCubit<HotelTranslation> {
  AiTranslationCubit(this._translate);

  final TranslateHotelPage _translate;
  late int _hotelId;
  String _lang = 'en';

  String get lang => _lang;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  Future<void> changeLanguage(String lang) {
    if (lang == _lang) return Future.value();
    _lang = lang;
    return load();
  }

  @override
  Future<void> load() => guard(() => _translate(_hotelId, _lang));
}

/// Nội dung cơ sở đã công bố, đọc bằng ngôn ngữ khác. Mỗi mục hiện bản dịch, mục nào chưa dịch được
/// thì hiện bản gốc và được đánh dấu — AI chỉ dịch, không thêm gì vào trang.
@RoutePage()
class AiTranslationScreen extends StatelessWidget {
  const AiTranslationScreen({super.key, required this.hotelId, this.subtitle});

  final int hotelId;
  final String? subtitle;

  static const _sections = <String, String>{
    'DESCRIPTION': AiStrings.translateDescription,
    'AMENITY': AiStrings.translateAmenities,
    'SERVICE': AiStrings.translateServices,
    'DISH': AiStrings.translateDishes,
    'TOUR': AiStrings.translateTours,
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiTranslationCubit>()..start(hotelId),
      child: Builder(
        builder: (context) => AppPage(
          title: AiStrings.translateTitle,
          subtitle: subtitle,
          body: BlocBuilder<AiTranslationCubit, LoadState<HotelTranslation>>(
            builder: (context, state) => Column(
              children: [
                const Gap(AppSpacing.sm),
                Builder(
                  builder: (context) {
                    final languages = aiLanguages();
                    return ChoiceChipBar<String>(
                      options: languages.keys.toList(),
                      selected: context.read<AiTranslationCubit>().lang,
                      labelOf: (lang) => languages[lang] ?? lang,
                      onSelected: context.read<AiTranslationCubit>().changeLanguage,
                    );
                  },
                ),
                Expanded(
                  child: LoadStateView<HotelTranslation>(
                    state: state,
                    onRetry: context.read<AiTranslationCubit>().load,
                    builder: (context, translation) => ListView(
                      padding: AppSpacing.page,
                      children: [
                        for (final note in translation.notes) ...[
                          NoticeBanner(text: note, tone: StatusTone.warning),
                          const Gap(AppSpacing.xs),
                        ],
                        for (final entry in _sections.entries)
                          if (translation.section(entry.key).isNotEmpty) ...[
                            SectionHeader(title: entry.value),
                            const Gap(AppSpacing.xs),
                            AppCard(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Column(
                                children: [
                                  for (final item in translation.section(entry.key))
                                    _ItemRow(item: item),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.md),
                          ],
                        Text(AiStrings.translateNote, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final TranslatedItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.text, style: AppTextStyles.bodyMedium),
          if (item.untranslated)
            // Mục chưa dịch được: nói rõ đây là bản gốc chứ không phải bản dịch.
            Text(AiStrings.translateOriginal, style: AppTextStyles.caption.colored(AppColors.warning))
          else
            Text(item.original, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
