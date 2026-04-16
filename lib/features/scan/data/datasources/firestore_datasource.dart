import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scan_history_model.dart';

abstract class FirestoreDatasource {
  /// Lưu lịch sử scan vào Firestore
  /// Path: `/users/{userId}/scans/{scanId}`
  Future<void> saveScanHistory(String userId, ScanHistoryModel history);

  /// Lấy lịch sử scan của user
  /// Returns: List scan histories, sắp xếp mới nhất trước
  Future<List<ScanHistoryModel>> getScanHistory(
    String userId, {
    int limit = 50,
  });

  /// Lấy scan history theo ngày cụ thể
  Future<List<ScanHistoryModel>> getScanHistoryByDate(
    String userId,
    String date, // Format: "2026-04-14"
  );

  /// Xoá một scan history
  Future<void> deleteScanHistory(String userId, String scanId);
}

class FirestoreDatasourceImpl implements FirestoreDatasource {
  final FirebaseFirestore _firestore;

  FirestoreDatasourceImpl(this._firestore);

  @override
  Future<void> saveScanHistory(String userId, ScanHistoryModel history) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scans')
          .doc(history.id)
          .set(history.toJson());
    } catch (e) {
      throw FirestoreException('Failed to save scan history: $e');
    }
  }

  @override
  Future<List<ScanHistoryModel>> getScanHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('scans')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ScanHistoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to get scan history: $e');
    }
  }

  @override
  Future<List<ScanHistoryModel>> getScanHistoryByDate(
    String userId,
    String date,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('scans')
          .where('eatenDate', isEqualTo: date)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ScanHistoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to get scan history by date: $e');
    }
  }

  @override
  Future<void> deleteScanHistory(String userId, String scanId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scans')
          .doc(scanId)
          .delete();
    } catch (e) {
      throw FirestoreException('Failed to delete scan history: $e');
    }
  }
}

/// Exception khi Firestore operation fail
class FirestoreException implements Exception {
  final String message;
  const FirestoreException(this.message);

  @override
  String toString() => 'FirestoreException: $message';
}
