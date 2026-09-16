import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/style/style.dart';
import '../../../core/text/partner_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../domain/usecases/partner_usecases.dart';
import 'widgets/hotel_profile_fields.dart';
import 'widgets/review_note.dart';

/// Sửa hồ sơ đang chờ duyệt, hoặc cập nhật theo lý do từ chối rồi gửi lại.
@RoutePage()
class OwnerProfileFormScreen extends StatefulWidget {
  const OwnerProfileFormScreen({super.key});

  @override
  State<OwnerProfileFormScreen> createState() => _OwnerProfileFormScreenState();
}

class _OwnerProfileFormScreenState extends State<OwnerProfileFormScreen> {
  final _form = GlobalKey<FormState>();
  final _fields = HotelProfileControllers();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fields.fill(context.read<SessionCubit>().session?.hotelChain);
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final sessionCubit = context.read<SessionCubit>();
    final wasRejected =
        sessionCubit.session?.hotelChain?.approvalStatus == ApprovalStatus.rejected;
    setState(() => _saving = true);
    final result = await runAction(() => getIt<ResubmitOwnerProfile>()(_fields.toProfile()));
    if (!mounted) return;
    setState(() => _saving = false);
    if (!result.isSuccess) {
      AppToast.error(context, result.error!);
      return;
    }
    final session = sessionCubit.session;
    if (session != null) await sessionCubit.update(session.copyWith(hotelChain: result.value));
    if (!mounted) return;
    AppToast.success(
      context,
      wasRejected ? PartnerStrings.resubmitted : PartnerStrings.profileSaved,
    );
    await context.router.maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    final chain = context.select((SessionCubit cubit) => cubit.state.session?.hotelChain);
    final rejected = chain?.approvalStatus == ApprovalStatus.rejected;
    final reason = chain?.rejectionReason;
    return AppPage(
      title: PartnerStrings.profileTitle,
      body: Form(
        key: _form,
        child: ListView(
          padding: AppSpacing.page,
          children: [
            if (reason != null) ...[
              ReviewNote(
                title: rejected ? PartnerStrings.rejectionReason : PartnerStrings.previousRejection,
                text: reason,
                tone: rejected ? StatusTone.danger : StatusTone.info,
              ),
              const Gap(AppSpacing.md),
            ],
            const GroupLabel(PartnerStrings.hotelTitle),
            HotelProfileFields(fields: _fields),
          ],
        ),
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          label: rejected ? PartnerStrings.resubmitAction : PartnerStrings.saveProfile,
          icon: rejected ? Icons.send_rounded : null,
          expand: true,
          loading: _saving,
          onPressed: _submit,
        ),
      ),
    );
  }
}
