import 'package:flutter/material.dart';

import '../color/app_colors.dart';
import '../style/app_dimens.dart';
import '../style/app_text_styles.dart';
import '../text/explore_strings.dart';
import 'app_network_image.dart';

/// Băng chuyền ảnh vuốt ngang, có chấm vị trí và bộ đếm.
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.paths,
    this.placeholderIcon = Icons.apartment_rounded,
  });

  final List<String> paths;
  final IconData placeholderIcon;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final paths = widget.paths;
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: paths.isEmpty ? 1 : paths.length,
          onPageChanged: (index) => setState(() => _index = index),
          itemBuilder: (context, index) => AppNetworkImage(
            path: paths.isEmpty ? null : paths[index],
            placeholderIcon: widget.placeholderIcon,
          ),
        ),
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x4D000000), Color(0x00000000), Color(0x40000000)],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
        ),
        if (paths.length > 1) ...[
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < paths.length; i++)
                  AnimatedContainer(
                    duration: AppDurations.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(
                        alpha: i == _index ? 1 : 0.6,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 14,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '${_index + 1}/${paths.length}',
                style: AppTextStyles.captionStrong.colored(AppColors.onPrimary),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Đoạn văn dài thu gọn, có nút Xem thêm.
class ExpandableText extends StatefulWidget {
  const ExpandableText(this.text, {super.key, this.maxLines = 4, this.style});

  final String text;
  final int maxLines;
  final TextStyle? style;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? AppTextStyles.body.colored(AppColors.inkSecondary);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: widget.maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: AppDurations.normal,
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: style,
                maxLines: _expanded ? null : widget.maxLines,
                overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            if (overflows)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _expanded ? ExploreStrings.readLess : ExploreStrings.readMore,
                    style: AppTextStyles.bodyStrong.colored(AppColors.primary),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
