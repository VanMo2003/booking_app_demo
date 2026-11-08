import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/component/component.dart';
import '../../../core/config/app_config.dart';
import '../../../core/style/style.dart';
import '../../../core/text/discover_strings.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/tour.dart';

/// Link công khai của tour: trang nhỏ của BE (có ảnh xem trước cho Zalo, Messenger, Facebook) mở tour
/// trong ứng dụng.
String tourShareLink(Tour tour) => '${AppConfig.baseUrl}/app-links/tours/${tour.id}';

String tourShareText(Tour tour) => DiscoverStrings.shareText(
      tour.name,
      tour.destination ?? '',
      Fmt.money(tour.salePrice),
      tourShareLink(tour),
    );

/// Bảng chia sẻ: qua ứng dụng khác (Zalo, Messenger… — bảng chia sẻ của máy), Facebook, sao chép link.
Future<void> shareTour(BuildContext context, Tour tour) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(DiscoverStrings.shareVia, style: AppTextStyles.subtitle),
            const Gap(AppSpacing.xs),
            Text(tour.name, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            const Gap(AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.ios_share_rounded),
              title: Text('${DiscoverStrings.shareZalo}, ${DiscoverStrings.shareMessenger}, '
                  '${DiscoverStrings.shareMore.toLowerCase()}'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await SharePlus.instance.share(ShareParams(text: tourShareText(tour), subject: tour.name));
              },
            ),
            ListTile(
              leading: const Icon(Icons.facebook_rounded),
              title: const Text(DiscoverStrings.shareFacebook),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final url = Uri.https('www.facebook.com', '/sharer/sharer.php', {'u': tourShareLink(tour)});
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text(DiscoverStrings.copyLink),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await Clipboard.setData(ClipboardData(text: tourShareLink(tour)));
                if (context.mounted) AppToast.success(context, DiscoverStrings.linkCopied);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
