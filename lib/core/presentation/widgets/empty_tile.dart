import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/assets.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';

class EmptyTile extends StatelessWidget {
  const EmptyTile({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppWidth.screenWidth * 0.92,
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20).w,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: AppPadding.small.w,
            child: ImageIcon(
              const AssetImage(AppAssets.pills),
              size: AppHeight.h100.h,
              color: AppColors.primary.withOpacity(0.75),
            ),
          ),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: AppColors.disabled.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}
