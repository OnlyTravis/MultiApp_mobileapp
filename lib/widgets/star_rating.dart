import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final String? label;
  final double value;

  const StarRating({super.key, this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value < 0 || value > 5) {
      throw RangeError.range(value, 0, 5);
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (label != null) Text(label ?? ""),
        ...[1,2,3,4,5].map((int num) => Icon(
          value >= num ? Icons.star : (value + 0.5 >= num ? Icons.star_half : Icons.star_border))
        ),
      ]
    );
  }
}