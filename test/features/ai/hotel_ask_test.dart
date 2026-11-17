import 'package:booking_app_mobile/core/text/ai_strings.dart';
import 'package:booking_app_mobile/features/ai/data/models/ai_models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _answerJson({bool answered = true}) => {
      'hotelId': 6,
      'question': 'Có tour ăn uống buổi tối không?',
      'answered': answered,
      'answer': answered
          ? 'Dạ cơ sở mình có Food tour phố cổ, 450.000 đ mỗi khách, khởi hành 18:00 hằng ngày.'
          : 'Phần giờ nhận phòng cơ sở chưa công bố, anh/chị nhắn cho cơ sở giúp mình nhé.',
      'links': answered
          ? [
              {'label': 'Xem tour Food tour phố cổ', 'target': 'tours/7'},
            ]
          : <Map<String, dynamic>>[],
      'notes': <String>[],
    };

void main() {
  test('đọc câu trả lời và liên kết tour', () {
    final answer = AiModels.hotelAnswer(_answerJson());

    expect(answer.hotelId, 6);
    expect(answer.answered, isTrue);
    expect(answer.answer, contains('Food tour phố cổ'));
    expect(answer.links.single.target, 'tours/7');
  });

  test('hồ sơ chưa có thông tin thì không kèm liên kết nào', () {
    final answer = AiModels.hotelAnswer(_answerJson(answered: false));

    expect(answer.answered, isFalse);
    expect(answer.links, isEmpty);
    // Câu trả lời vẫn có, để bảng nói rõ là chưa có thông tin rồi mời khách nhắn cho cơ sở.
    expect(answer.answer, isNotNull);
    expect(AiStrings.askHotelChat, isNotEmpty);
  });

  test('thiếu answered coi như chưa trả lời được', () {
    final answer = AiModels.hotelAnswer({
      'hotelId': 6,
      'question': 'Có bể bơi không?',
    });

    expect(answer.answered, isFalse);
    expect(answer.answer, isNull);
    expect(answer.links, isEmpty);
    expect(answer.notes, isEmpty);
  });
}
