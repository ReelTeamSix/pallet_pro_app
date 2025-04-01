import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/storage_repository.dart';
import 'package:pallet_pro_app/src/features/inventory/data/repositories/supabase_storage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storage_client/storage_client.dart'; // Import the storage client
import '../../../../../test_helpers.dart';

// A simple mock for XFile since it's used in the repository
class MockXFile extends Mock implements XFile {}

// Mock for the StorageFileApi used by Supabase
class MockStorageFileApi extends Mock implements StorageFileApi {}

// Additional class for registering fallback
class FileObjectFake extends Fake implements FileObject {}

void main() {
  // Register fallback values
  setUpAll(() {
    setupTestEnvironment();
    registerFallbackValue(Uint8List(0)); // Empty Uint8List
    registerFallbackValue(FileOptions());
    registerFallbackValue(FileObjectFake());
    registerFallbackValue(<String>[]);
  });

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;
  late MockSupabaseStorageClient mockStorageClient;
  late StorageRepository storageRepository;
  late MockXFile mockFile;
  late MockStorageFileApi mockFileApi;

  setUp(() async {
    // Create a new setup for each test
    mockSupabaseClient = await initializeMockSupabase();
    mockGoTrueClient = mockSupabaseClient.auth as MockGoTrueClient;
    mockUser = MockUser();
    mockFile = MockXFile();
    mockStorageClient = mockSupabaseClient.storage as MockSupabaseStorageClient;
    mockFileApi = MockStorageFileApi();
    
    // Create the repository with the mock client
    storageRepository = SupabaseStorageRepository(mockSupabaseClient);
    
    // Setup common stub behavior
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');
    when(() => mockSupabaseClient.storage).thenReturn(mockStorageClient);
    
    // Setup storage client behavior
    when(() => mockStorageClient.from(any())).thenReturn(mockFileApi);
  });

  group('SupabaseStorageRepository', () {
    test('uploadItemPhoto uploads a file and returns the path', () async {
      // Arrange
      final testBytes = Uint8List.fromList([1, 2, 3, 4]);
      when(() => mockFile.readAsBytes()).thenAnswer((_) async => testBytes);
      when(() => mockFile.name).thenReturn('test.jpg');
      
      // Setup upload success response
      when(() => mockFileApi.uploadBinary(
        any(), 
        any(), 
        fileOptions: any(named: 'fileOptions')
      )).thenAnswer((_) async => 'test-user-id/test-item-id/test.jpg');
      
      // Act
      final result = await storageRepository.uploadItemPhoto(
        itemId: 'test-item-id',
        fileName: 'test.jpg',
        file: mockFile,
      );
      
      // Assert
      expect(result, equals('test-user-id/test-item-id/test.jpg'));
      verify(() => mockFileApi.uploadBinary(
        any(),
        any(),
        fileOptions: any(named: 'fileOptions'),
      )).called(1);
    });
    
    test('deleteItemPhotos deletes the specified paths', () async {
      // Arrange - return a proper List<FileObject> with empty list
      when(() => mockFileApi.remove(any())).thenAnswer((_) async => <FileObject>[]);
      
      // Act
      await storageRepository.deleteItemPhotos([
        'test-user-id/test-item-id/test1.jpg',
        'test-user-id/test-item-id/test2.jpg',
      ]);
      
      // Assert
      verify(() => mockFileApi.remove(any())).called(1);
    });
    
    test('createSignedPhotoUrl creates a signed URL for the specified path', () async {
      // Arrange
      when(() => mockFileApi.createSignedUrl(any(), any()))
          .thenAnswer((_) async => 'https://test-signed-url.com/photo.jpg');
      
      // Act
      final result = await storageRepository.createSignedPhotoUrl(
        'test-user-id/test-item-id/test.jpg',
      );
      
      // Assert
      expect(result, equals('https://test-signed-url.com/photo.jpg'));
      verify(() => mockFileApi.createSignedUrl(
        any(),
        any(),
      )).called(1);
    });
    
    test('throws Exception when user is not authenticated', () {
      // Arrange - simulate no user logged in
      when(() => mockGoTrueClient.currentUser).thenReturn(null);
      
      // Act & Assert - any operation should throw
      expect(
        () => storageRepository.uploadItemPhoto(
          itemId: 'test-item-id',
          fileName: 'test.jpg',
          file: mockFile,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('User not authenticated'),
        )),
      );
    });
  });
} 