import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_data.freezed.dart';
// gはgenerateのg
part 'user_data.g.dart';

// プレフィックスが出てきたものにCommand + dを長押しで全ての要素を選択できる
@freezed
abstract class UserData with _$UserData {
  const factory UserData({
    required String uid,
    @Default('unknown') String userName,
    String? imageUrl,
    required String food,
    required int numberOfPancakes,
    required String add,
  }) = _UserData;

factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);
}