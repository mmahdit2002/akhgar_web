import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mashinsazi_akhgar_web/bloc/post/post_bloc.dart';
import 'package:mashinsazi_akhgar_web/ui/widgets/news_card_widget.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(const LoadPosts());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
        context.read<PostBloc>().add(LoadMorePosts());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اخبار و مقالات'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state.status == PostStatus.loading && state.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);

                    return Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: state.posts.length + (state.status == PostStatus.loading ? 3 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.posts.length) {
                              return const Center(
                                child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
                              );
                            }
                            return NewsCardWidget(
                              post: state.posts[index],
                              onTap: () => Get.toNamed('/news/${state.posts[index].id}'),
                            );
                          },
                        ),
                        if (state.hasReachedMax && state.posts.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('همه اخبار بارگذاری شدند', style: TextStyle(color: Colors.grey)),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
