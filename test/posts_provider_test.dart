ıimport 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suhub/posts/providers/posts_provider.dart';
import 'package:suhub/posts/services/posts_repository.dart';

class _MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  late PostsProvider provider;
  late _MockPostsRepository repo;

  setUp(() {
    repo = _MockPostsRepository();
    provider = PostsProvider(repo: repo);
  });

  test('createPost sets busy then clears on success', () async {
    when(() => repo.createPost(
          text: any(named: 'text'),
          category: any(named: 'category'),
          createdBy: any(named: 'createdBy'),
          authorUsername: any(named: 'authorUsername'),
          authorPhotoUrl: any(named: 'authorPhotoUrl'),
          authorPhotoAlignX: any(named: 'authorPhotoAlignX'),
          authorPhotoAlignY: any(named: 'authorPhotoAlignY'),
          imageUrl: any(named: 'imageUrl'),
        )).thenAnswer((_) async {});

    final future = provider.createPost(
      text: 'hello',
      category: 'general',
      createdBy: 'uid',
      authorUsername: 'user',
      authorPhotoUrl: '',
      authorPhotoAlignX: 0.0,
      authorPhotoAlignY: 0.0,
      imageUrl: null,
    );

    expect(provider.busy, isTrue);

    await future;

    expect(provider.busy, isFalse);
    expect(provider.error, isNull);
    verify(() => repo.createPost(
          text: 'hello',
          category: 'general',
          createdBy: 'uid',
          authorUsername: 'user',
          authorPhotoUrl: '',
          authorPhotoAlignX: 0.0,
          authorPhotoAlignY: 0.0,
          imageUrl: null,
        )).called(1);
  });

  test('createPost captures error when repo throws', () async {
    when(() => repo.createPost(
          text: any(named: 'text'),
          category: any(named: 'category'),
          createdBy: any(named: 'createdBy'),
          authorUsername: any(named: 'authorUsername'),
          authorPhotoUrl: any(named: 'authorPhotoUrl'),
          authorPhotoAlignX: any(named: 'authorPhotoAlignX'),
          authorPhotoAlignY: any(named: 'authorPhotoAlignY'),
          imageUrl: any(named: 'imageUrl'),
        )).thenThrow(Exception('boom'));

    await provider.createPost(
      text: 'fail',
      category: 'general',
      createdBy: 'uid',
      authorUsername: 'user',
      authorPhotoUrl: '',
      authorPhotoAlignX: 0.0,
      authorPhotoAlignY: 0.0,
      imageUrl: null,
    );

    expect(provider.busy, isFalse);
    expect(provider.error, contains('Exception'));
  });
}
