part of 'post_bloc.dart';

@immutable
abstract class PostEvent extends Equatable {
  const PostEvent();
  @override
  List<Object?> get props => [];
}

class LoadPosts extends PostEvent {
  final bool isRefresh;
  const LoadPosts({this.isRefresh = false});
}

class LoadMorePosts extends PostEvent {}
