import 'package:auto_route/annotations.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/get_x/prj_get_view.dart';
import '../get_x/comment_controller.dart';
import '../widgets/comment_card.dart';
import '../widgets/shimmer_comment_card.dart';

@RoutePage()
class CommentPage extends PrjGetView<CommentController> with CcPullToRefreshMixin {
  const CommentPage({super.key});

  @override
  Widget? buildContent(BuildContext context) {
    final comments = controller.comments;
    final hasLoading =
        controller.layoutStatus.value == CcLayoutStatus.loading ||
        controller.layoutStatus.value == CcLayoutStatus.loadMore;

    return CcFadePageWrapper(
      child: buildPullToRefresh(
        context: context,
        onRefresh: controller.refreshData,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hasLoading ? 5 : comments.length,
          itemBuilder: (context, index) {
            if (hasLoading) {
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
