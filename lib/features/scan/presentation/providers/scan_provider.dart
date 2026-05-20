import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ai_remote_datasource.dart';
import '../../data/datasources/cloudinary_datasource.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../data/repositories/scan_repository_impl.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/usecases/analyze_food_usecase.dart';
import '../../domain/usecases/save_scan_history_usecase.dart';
import '../viewmodels/scan_viewmodel.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final aiRemoteDatasourceProvider = Provider<AiRemoteDatasource>((ref) {
  return AiRemoteDatasourceImpl(ref.watch(dioProvider));
});

final cloudinaryDatasourceProvider = Provider<CloudinaryDatasource>((ref) {
  return CloudinaryDatasourceImpl(ref.watch(dioProvider));
});

final firestoreDatasourceProvider = Provider<FirestoreDatasource>((ref) {
  return FirestoreDatasourceImpl(FirebaseFirestore.instance);
});

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepositoryImpl(
    aiRemoteDatasource: ref.watch(aiRemoteDatasourceProvider),
    cloudinaryDatasource: ref.watch(cloudinaryDatasourceProvider),
    firestoreDatasource: ref.watch(firestoreDatasourceProvider),
  );
});

final analyzeFoodUseCaseProvider = Provider<AnalyzeFoodUseCase>((ref) {
  return AnalyzeFoodUseCase(repository: ref.watch(scanRepositoryProvider));
});

final saveScanHistoryUseCaseProvider = Provider<SaveScanHistoryUseCase>((ref) {
  return SaveScanHistoryUseCase(repository: ref.watch(scanRepositoryProvider));
});

final scanViewModelProvider =
    StateNotifierProvider<ScanViewModel, ScanState>((ref) {
  return ScanViewModel(
    analyzeFoodUseCase: ref.watch(analyzeFoodUseCaseProvider),
    saveScanHistoryUseCase: ref.watch(saveScanHistoryUseCaseProvider),
    scanRepository: ref.watch(scanRepositoryProvider),
  );
});
