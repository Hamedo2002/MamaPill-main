import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/values.dart';

class CardSectionBody extends StatelessWidget {
  const CardSectionBody({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.height,
    this.width,
  });

  final Widget? Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? AppHeight.h200.h, // Increased height to prevent overflow
      width: width,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: AppPadding.mediumH,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
