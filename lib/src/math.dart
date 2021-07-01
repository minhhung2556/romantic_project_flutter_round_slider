import 'dart:math';
import 'dart:ui';

/// convert from degree to radian
const kDegToRad = pi / 180.0;

/// convert from degree to radian
const kRadToDeg = 180.0 / pi;

/// make number [a] be positive
double abs(double a) => a < 0 ? -a : a;

/// convert [degree] to radian
double toRad(double degree) => degree * kDegToRad;

/// convert [radian] to degree
double toDegree(double radian) => radian * kRadToDeg;

/// calculate factorial of [x]
double factorial(double x) {
  if (x < 3) {
    if (x < 2)
      return 1;
    else
      return 2;
  } else {
    double res = 1;
    for (double i = 2; i <= x; i++) {
      res *= i;
    }
    return res;
  }
}

const int _kSignMask = 0x80000000;
const double _kATanB = 0.596227;

/// calculate atan from [x] & [y]
double atan2(double x, double y) {
  // Extract the sign bits
  int uxS = _kSignMask & x.round();
  int uyS = _kSignMask & y.round();

  // Determine the quadrant offset
  double q = ((~uxS & uyS) >> 29 | uxS >> 30).toDouble();

  // Calculate the arc tangent in the first quadrant
  double bxyA = abs(_kATanB * x * y);
  double num = bxyA + y * y;
  double atan1Q = num / (x * x + bxyA + num);

// Translate it to the proper quadrant
  int uatan2Q = (uxS ^ uyS) | atan1Q.round();
  return q + uatan2Q.toDouble();
}

/// rotate a [point] by [alpha] with [origin].
/// [alpha] : in degree.
Offset rotate(Offset point, Offset origin, double alpha) {
  double dx = point.dx - origin.dx, dy = point.dy - origin.dy;
  var a = toRad(alpha);
  double cosA = cos(a), sinA = sin(a);
  var p1 = Offset(
      dx * cosA - dy * sinA + origin.dx, dx * sinA + dy * cosA + origin.dy);
  return p1;
}
