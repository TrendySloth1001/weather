import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WeatherShimmer extends StatelessWidget {
  const WeatherShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[850]!,
        highlightColor: Colors.grey[700]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              _buildHeaderShimmer(),
              const SizedBox(height: 32),
              _buildMainWeatherShimmer(),
              const SizedBox(height: 32),
              _buildHourlyShimmer(),
              const SizedBox(height: 32),
              _buildDetailsShimmer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildMainWeatherShimmer() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 120,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyShimmer() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsShimmer() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }),
    );
  }
}
