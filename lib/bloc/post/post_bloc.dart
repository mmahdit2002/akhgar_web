import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mashinsazi_akhgar_web/models/wp_post.dart';
import 'package:mashinsazi_akhgar_web/services/wp_api_service.dart';
import 'package:meta/meta.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final WpApiService api;
  int _page = 1;

  PostBloc({required this.api}) : super(const PostState()) {
    on<LoadPosts>(_onLoadPosts);
    on<LoadMorePosts>(_onLoadMore);
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    if (event.isRefresh) {
      _page = 1;
    }
    emit(state.copyWith(status: PostStatus.loading, posts: event.isRefresh ? [] : state.posts));

    try {
      final posts = await api.fetchPosts(page: _page);
      emit(
        state.copyWith(
          status: PostStatus.success,
          posts: event.isRefresh ? posts : [...state.posts, ...posts],
          hasReachedMax: posts.length < 12,
        ),
      );
      _page++;
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMorePosts event, Emitter<PostState> emit) async {
    if (state.hasReachedMax || state.status == PostStatus.loading) return;

    emit(state.copyWith(status: PostStatus.loading));

    try {
      final newPosts = await api.fetchPosts(page: _page);
      emit(
        state.copyWith(
          status: PostStatus.success,
          posts: [...state.posts, ...newPosts],
          hasReachedMax: newPosts.length < 12,
        ),
      );
      _page++;
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }
}
