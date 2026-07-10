import 'package:auto_route/annotations.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../get_x/comment_controller.dart';
import 'widgets/comment_card.dart';
import 'widgets/shimmer_comment_card.dart';

@RoutePage()
class CommentPage extends CcGetView<CommentController> with CcPullRefreshMixin {
  const CommentPage({super.key});

  @override
  Widget? buildContent(BuildContext context) {
    final comments = controller.comments;
    final isLoading =
        controller.layoutStatus.value == CcLayoutStatus.loading ||
        controller.layoutStatus.value == CcLayoutStatus.loadMore;

    return FadePageWrapper(
      child: buildPullToRefresh(
        context: context,
        onRefresh: controller.refreshData,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: isLoading ? 5 : comments.length,
          itemBuilder: (context, index) {
            if (isLoading) {
              return const ShimmerCommentCard();
            }

            final comment = comments[index];
            return CommentCard(comment: comment);
          },
        ),
      ),
    );
  }
}
