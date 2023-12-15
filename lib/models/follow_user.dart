import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_user.freezed.dart';
// gはgenerateのg
part 'follow_user.g.dart';

// プレフィックスが出てきたものにCommand + dを長押しで全ての要素を選択できる
@freezed
abstract class UserData with _$UserData {
  const factory UserData({
    required String uid,
    @Default('unknown') String userName,
    String? imageUrl,
    String? food,
    required int numberOfPancakes,
    required int followers,
  }) = _UserData;

factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);
}