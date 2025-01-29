import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final String? label;
  final double value;
  final double size;
  final Color color;

  const StarRating({super.key, this.label, required this.value, this.size = 24, this.color = const Color.fromARGB(255, 255, 224, 130)});

  @override
  Widget build(BuildContext context) {
    if (value < 0 || value > 5) {
      throw RangeError.range(value, 0, 5);
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (label != null) Text(label ?? ""),
        ...[1,2,3,4,5].map((int num) {
          if (value >= num) return Icon(Icons.star, size: size, color: color);
          if (value+1 <= num) return Icon(Icons.star_border, size: size, color: color);

          int flexValue = (value%1*100).floor();
          return Stack(
            children: [
              Icon(Icons.star_border, size: size, color: color),
              SizedBox(
                width: size,
                height: size,
                child: ClipPath(
                  clipper: _StarClipper(),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        flex: flexValue,
                        child: Container(color: color)
                      ),
                      Flexible(flex: 100-flexValue, child: SizedBox())
                    ],
                  ),
                ),
              )
            ],
          );
        }),
      ]
    );
  }
}

class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double xScaling = size.width / 24;
    final double yScaling = size.height / 24;
    path.lineTo(11.5245 * xScaling,3.46353 * yScaling);
    path.cubicTo(11.6741 * xScaling,3.00287 * yScaling,12.3259 * xScaling,3.00287 * yScaling,12.4755 * xScaling,3.46353 * yScaling,);
    path.cubicTo(12.4755 * xScaling,3.46353 * yScaling,14.1329 * xScaling,8.56434 * yScaling,14.1329 * xScaling,8.56434 * yScaling,);
    path.cubicTo(14.1998 * xScaling,8.77035 * yScaling,14.3918 * xScaling,8.90983 * yScaling,14.6084 * xScaling,8.90983 * yScaling,);
    path.cubicTo(14.6084 * xScaling,8.90983 * yScaling,19.9717 * xScaling,8.90983 * yScaling,19.9717 * xScaling,8.90983 * yScaling,);
    path.cubicTo(20.4561 * xScaling,8.90983 * yScaling,20.6575 * xScaling,9.52964 * yScaling,20.2656 * xScaling,9.81434 * yScaling,);
    path.cubicTo(20.2656 * xScaling,9.81434 * yScaling,15.9266 * xScaling,12.9668 * yScaling,15.9266 * xScaling,12.9668 * yScaling,);
    path.cubicTo(15.7514 * xScaling,13.0941 * yScaling,15.678 * xScaling,13.3198 * yScaling,15.745 * xScaling,13.5258 * yScaling,);
    path.cubicTo(15.745 * xScaling,13.5258 * yScaling,17.4023 * xScaling,18.6266 * yScaling,17.4023 * xScaling,18.6266 * yScaling,);
    path.cubicTo(17.552 * xScaling,19.0873 * yScaling,17.0248 * xScaling,19.4704 * yScaling,16.6329 * xScaling,19.1857 * yScaling,);
    path.cubicTo(16.6329 * xScaling,19.1857 * yScaling,12.2939 * xScaling,16.0332 * yScaling,12.2939 * xScaling,16.0332 * yScaling,);
    path.cubicTo(12.1186 * xScaling,15.9059 * yScaling,11.8814 * xScaling,15.9059 * yScaling,11.7061 * xScaling,16.0332 * yScaling,);
    path.cubicTo(11.7061 * xScaling,16.0332 * yScaling,7.3671 * xScaling,19.1857 * yScaling,7.3671 * xScaling,19.1857 * yScaling,);
    path.cubicTo(6.97524 * xScaling,19.4704 * yScaling,6.448 * xScaling,19.0873 * yScaling,6.59768 * xScaling,18.6266 * yScaling,);
    path.cubicTo(6.59768 * xScaling,18.6266 * yScaling,8.25503 * xScaling,13.5258 * yScaling,8.25503 * xScaling,13.5258 * yScaling,);
    path.cubicTo(8.32197 * xScaling,13.3198 * yScaling,8.24864 * xScaling,13.0941 * yScaling,8.07339 * xScaling,12.9668 * yScaling,);
    path.cubicTo(8.07339 * xScaling,12.9668 * yScaling,3.73438 * xScaling,9.81434 * yScaling,3.73438 * xScaling,9.81434 * yScaling,);
    path.cubicTo(3.34253 * xScaling,9.52964 * yScaling,3.54392 * xScaling,8.90983 * yScaling,4.02828 * xScaling,8.90983 * yScaling,);
    path.cubicTo(4.02828 * xScaling,8.90983 * yScaling,9.39159 * xScaling,8.90983 * yScaling,9.39159 * xScaling,8.90983 * yScaling,);
    path.cubicTo(9.6082 * xScaling,8.90983 * yScaling,9.80018 * xScaling,8.77035 * yScaling,9.86712 * xScaling,8.56434 * yScaling,);
    path.cubicTo(9.86712 * xScaling,8.56434 * yScaling,11.5245 * xScaling,3.46353 * yScaling,11.5245 * xScaling,3.46353 * yScaling,);
    path.cubicTo(11.5245 * xScaling,3.46353 * yScaling,11.5245 * xScaling,3.46353 * yScaling,11.5245 * xScaling,3.46353 * yScaling,);
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}