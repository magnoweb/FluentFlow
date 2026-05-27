import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FFLoading extends StatelessWidget {
  const FFLoading({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: Color(0xFF594AE2)));
}

class FFShimmerCard extends StatelessWidget {
  const FFShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
