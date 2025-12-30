import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suhub/providers/posts_provider.dart';
import 'package:suhub/services/posts_repository.dart';

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
        )).thenAnswer((_) async {});

    final future = provider.createPost(
      text: 'hello',
      category: 'general',
      createdBy: 'uid',
      authorUsername: 'user',
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
        )).called(1);
  });

  test('createPost captures error when repo throws', () async {
    when(() => repo.createPost(
          text: any(named: 'text'),
          category: any(named: 'category'),
          createdBy: any(named: 'createdBy'),
          authorUsername: any(named: 'authorUsername'),
        )).thenThrow(Exception('boom'));

    await provider.createPost(
      text: 'fail',
      category: 'general',
      createdBy: 'uid',
      authorUsername: 'user',
    );

    expect(provider.busy, isFalse);
    expect(provider.error, contains('Exception'));
  });
}
