import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;


  const PageIndicatorWidget({
    super.key,
    required this.currentPage,
    this.totalPages = 3,
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: currentPage == index ? 8.w : 2.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: currentPage == index
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withAlpha(77),
            borderRadius: BorderRadius.circular(12),
            boxShadow: currentPage == index
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withAlpha(77),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
