import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService apiService;
  final FirebaseAuth auth;

  ProfileRepositoryImpl({
    required this.apiService,
    required this.auth,
  });

  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    try {
      final response = await apiService.get('/users/me/profile');

      // Trường hợp thành công và có dữ liệu
      if (response != null && response['status'] == 'success' && response['data'] != null) {
        final profile = UserProfileModel.fromJson(response['data']);
        return Right(profile);
      }

      // Nếu code chạy đến đây có nghĩa là response thành công nhưng data null
      return Right(_createDefaultProfile());

    } catch (e) {
      // Nếu lỗi là 404 (Not Found), trả về profile mặc định thay vì báo lỗi
      if (e.toString().contains('404')) {
        return Right(_createDefaultProfile());
      }

      // Các lỗi kết nối khác (500, No route to host) thì vẫn báo lỗi để người dùng biết
      return Left(ServerFailure(message: 'Lỗi kết nối: ${e.toString()}'));
    }
  }

// Hàm phụ tạo Profile mặc định với các giá trị bằng 0
  UserProfileModel _createDefaultProfile() {
    final firebaseUser = auth.currentUser;
    return UserProfileModel(
      userId: firebaseUser?.uid ?? '',
      email: firebaseUser?.email ?? '',
      name: firebaseUser?.displayName ?? 'Người dùng mới',
      photoUrl: firebaseUser?.photoURL,
      weight: 0.0,
      height: 0.0,
      age: 0,
      gender: 'Other',
      activityLevel: 'Sedentary',
      goal: 'Maintain',
      dailyCalorieTarget: 0.0,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserProfile profile) async {
    try {
      // Chuyển đổi Entity sang JSON qua Model
      final model = UserProfileModel.fromEntity(profile);
      final updateData = model.toJson();

      // Gửi yêu cầu cập nhật lên Server
      final response = await apiService.post(
        '/users/profile/update',
        data: updateData,
      );

      if (response != null && response['status'] == 'success') {
        // Đồng bộ DisplayName lên Firebase nếu có thay đổi (tùy chọn)
        final currentUser = auth.currentUser;
        if (currentUser != null && currentUser.displayName != profile.name) {
          await currentUser.updateDisplayName(profile.name);
          await currentUser.reload();
        }
        return const Right(null);
      }

      return Left(ServerFailure(message: 'Cập nhật hồ sơ thất bại'));
    } catch (e) {
      return Left(ServerFailure(message: 'Lỗi cập nhật: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> createProfile(UserProfile profile) async {
    // Với logic Sync-Firebase, Profile đã được khởi tạo ở Server.
    // Việc tạo profile thực chất là cập nhật thông tin chi tiết.
    return updateProfile(profile);
  }
}