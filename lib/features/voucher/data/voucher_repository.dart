import 'package:injectable/injectable.dart';

import '../../../core/network/json_reader.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/voucher.dart';
import 'voucher_api.dart';

abstract final class VoucherModel {
  static Voucher fromJson(Json json) => Voucher(
        id: json.integer('id'),
        code: json.str('code'),
        title: json.str('title'),
        description: json.strOrNull('description'),
        discountType: DiscountType.parse(json.strOrNull('discountType')),
        value: json.decimal('value'),
        maxDiscount: json.decimalOrNull('maxDiscount'),
        minOrderAmount: json.decimalOrNull('minOrderAmount'),
        startsAt: json.date('startsAt') ?? DateOnly.today(),
        endsAt: json.date('endsAt') ?? DateOnly.today(),
        usageLimit: json.intOrNull('usageLimit'),
        usedCount: json.integer('usedCount'),
        perCustomerLimit: json.integer('perCustomerLimit', 1),
        active: json.flag('active', true),
        hotelChainId: json.intOrNull('hotelChainId'),
        hotelChainName: json.strOrNull('hotelChainName'),
        hotelId: json.intOrNull('hotelId'),
        hotelName: json.strOrNull('hotelName'),
      );

  static VoucherCheck check(Json json) => VoucherCheck(
        valid: json.flag('valid'),
        message: json.str('message'),
        code: json.str('code'),
        tourAmount: json.decimal('tourAmount'),
        discount: json.decimal('discount'),
        finalAmount: json.decimal('finalAmount'),
      );

  static Map<String, dynamic> toJson(VoucherRequest r) => {
        if (r.code != null) 'code': r.code,
        if (r.title != null) 'title': r.title,
        if (r.description != null) 'description': r.description,
        if (r.discountType != null) 'discountType': r.discountType!.value,
        if (r.value != null) 'value': r.value!.round(),
        if (r.maxDiscount != null) 'maxDiscount': r.maxDiscount!.round(),
        if (r.minOrderAmount != null) 'minOrderAmount': r.minOrderAmount!.round(),
        if (r.startsAt != null) 'startsAt': Fmt.apiDate(r.startsAt!),
        if (r.endsAt != null) 'endsAt': Fmt.apiDate(r.endsAt!),
        if (r.usageLimit != null) 'usageLimit': r.usageLimit,
        if (r.perCustomerLimit != null) 'perCustomerLimit': r.perCustomerLimit,
        if (r.active != null) 'active': r.active,
        if (r.hotelChainId != null) 'hotelChainId': r.hotelChainId,
        if (r.hotelId != null) 'hotelId': r.hotelId,
      };
}

abstract interface class VoucherRepository {
  Future<List<Voucher>> available({int? hotelId});

  Future<VoucherCheck> check({required String code, required int tourId, required int guests, int children = 0});

  Future<List<Voucher>> list({int? hotelChainId, int? hotelId});

  Future<Voucher> save(VoucherRequest request, {int? id});

  Future<void> delete(int id);
}

@LazySingleton(as: VoucherRepository)
class VoucherRepositoryImpl implements VoucherRepository {
  VoucherRepositoryImpl(this._api);

  final VoucherApi _api;

  @override
  Future<List<Voucher>> available({int? hotelId}) async =>
      (await _api.available(hotelId)).parseList(VoucherModel.fromJson);

  @override
  Future<VoucherCheck> check({required String code, required int tourId, required int guests, int children = 0}) async =>
      (await _api.check({'code': code.trim(), 'tourId': tourId, 'guests': guests, 'children': children}))
          .parse(VoucherModel.check);

  @override
  Future<List<Voucher>> list({int? hotelChainId, int? hotelId}) async =>
      (await _api.list(hotelChainId, hotelId)).parseList(VoucherModel.fromJson);

  @override
  Future<Voucher> save(VoucherRequest request, {int? id}) async {
    final body = VoucherModel.toJson(request);
    final response = id == null ? await _api.create(body) : await _api.update(id, body);
    return response.parse(VoucherModel.fromJson);
  }

  @override
  Future<void> delete(int id) async => (await _api.delete(id)).ensureSuccess();
}
