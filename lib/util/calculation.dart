library calculation;

import 'dart:math';

import 'dartulator_strings.dart';

enum Precedence { i, ii, iii, iv, v }

abstract class Calculation implements Function {
  static bool usingDegrees = false;

  final Precedence _precedenceLevel;

  const Calculation(this._precedenceLevel);

  bool hasLessPrecedenceThan(Calculation other) {
    return _precedenceLevel.index < other._precedenceLevel.index;
  }

  @override
  String toString() => "";

// for the arc(sine cosine tangent) functions to switch the answer to degrees if need be
  static Function arcTrigWrapper(num arcTrigFunction(x)) {
    num _convertedArcTrigFunction(num x) {
      num value = arcTrigFunction(x);
      if (usingDegrees) {
        value *= 180 / PI;
      }
      return value;
    }
    return _convertedArcTrigFunction;
  }

// for the sine cosine tangent functions to switch the answer to degrees if need be
  static Function trigWrapper(num trigFunction(x)) {
    num _convertedTrigFunction(num x) {
      if (usingDegrees) {
        x *= PI / 180;
      }
      return trigFunction(x);
    }
    return _convertedTrigFunction;
  }
}

abstract class UnaryCalculation extends Calculation {
  const UnaryCalculation(Precedence levelOfImportance)
      : super(levelOfImportance);

  num call(num x);
}

abstract class BinaryCalculation extends Calculation {
  const BinaryCalculation(Precedence levelOfImportance)
      : super(levelOfImportance);

  num call(num x, num y);
}

class BasicCalculation {}

const Map<String, Calculation> _calculations = const {
  add: const AddCalculation(),
  arccos: const ArcCosineCalculation(),
  arcsin: const ArcSineCalculation(),
  arctan: const ArcTangentCalculation(),

  cosine: const CosineCalculation(),

  divide: const DivideCalculation(),
  divide_human: const DivideCalculation(),

  eToPower: const BaseECalculation(),
  exponent: const ExponentCalculation(),
  exponent_symbol: const ExponentCalculation(),

  factorial: const FactorialCalculation(),
  factorial_symbol: const FactorialCalculation(),

  logOfX: const LogCalculation(),

  multiply: const MultiplyCalculation(),

  naturalLog: const NaturalLogCalculation(),
  nthRootSymbol: const NthRootCalculation(),

  percent_symbol: const PercentCalculation(),

  sine: const SineCalculation(),
  subtract: const SubtractCalculation(),
  sqrtSymbol: const SqrtCalculation(),
  squared: const SquaredCalculation(),

  tangent: const TangentCalculation(),
  tenToPower: const BaseTenCalculation(),

  zerosShort: const ZerosCalculation()
};

getCalculation(String key) => _calculations[key] ?? key;


class AddCalculation extends BinaryCalculation
    implements BasicCalculation {

  const AddCalculation() : super(Precedence.i);

  num call(num x, num y) => x + y;
}

class ArcCosineCalculation extends UnaryCalculation {

  const ArcCosineCalculation() : super(Precedence.v);

  num call(num x) => Calculation.arcTrigWrapper(acos)(x);
}

class ArcSineCalculation extends UnaryCalculation {

  const ArcSineCalculation() : super(Precedence.v);

  num call(num x) => Calculation.arcTrigWrapper(asin)(x);
}

class ArcTangentCalculation extends UnaryCalculation {

  const ArcTangentCalculation() : super(Precedence.v);

  num call(num x) => Calculation.arcTrigWrapper(atan)(x);
}


class BaseTenCalculation extends UnaryCalculation {

  const BaseTenCalculation() : super(Precedence.v);

  num call(num exponent) => pow(10, exponent);
}

class BaseECalculation extends UnaryCalculation {

  const BaseECalculation() : super(Precedence.v);

  num call(num exponent) => pow(E, exponent);
}


class CosineCalculation extends UnaryCalculation {

  const CosineCalculation() : super(Precedence.v);

  num call(num x) => Calculation.trigWrapper(cos)(x);
}


class DivideCalculation extends BinaryCalculation
    implements BasicCalculation {

  const DivideCalculation() : super(Precedence.ii);

  num call(num x, num y) => x / y;
}


class ExponentCalculation extends BinaryCalculation
    implements BasicCalculation {

  const ExponentCalculation() : super(Precedence.iv);

  num call(num x, num y) => pow(x, y);
}


class FactorialCalculation extends UnaryCalculation {

  const FactorialCalculation() : super(Precedence.iv);

  num gamma(num x) {
    return sqrt(2 * PI / x) *
        pow((1 / E) * (x + 1 / (12 * x - 1 / (10 * x))), x);
  }

  num call(num x) {
    if (x.toString().contains(".")) {
      return gamma(x + 1);
    }

    int total = 1;
    while (x > 1) {
      total *= x--;
    }
    return total;
  }
}


class LogCalculation extends UnaryCalculation {

  const LogCalculation() : super(Precedence.v);

  num call(num x) => log(x) / log(10);
}


class MultiplyCalculation extends BinaryCalculation
    implements BasicCalculation {

  const MultiplyCalculation() : super(Precedence.ii);

  num call(num x, num y) => x * y;
}


class NaturalLogCalculation extends UnaryCalculation {

  const NaturalLogCalculation() : super(Precedence.v);

  num call(num x) => log(x);
}

class NthRootCalculation extends BinaryCalculation {

  const NthRootCalculation() : super(Precedence.v);

  num call(num root, num exponent) => pow(root, 1 / exponent);
}


class PercentCalculation extends BinaryCalculation {

  const PercentCalculation() : super(Precedence.iv);

  num call(num x, num y) => x * .01;
}


class SineCalculation extends UnaryCalculation {

  const SineCalculation() : super(Precedence.v);

  num call(num x) => Calculation.trigWrapper(sin)(x);
}

class SubtractCalculation extends BinaryCalculation
    implements BasicCalculation {

  const SubtractCalculation() : super(Precedence.i);

  num call(num x, num y) => x - y;
}

class SquaredCalculation extends UnaryCalculation {

  const SquaredCalculation() : super(Precedence.v);

  num call(num base) => pow(base, 2);
}

class SqrtCalculation extends UnaryCalculation {

  const SqrtCalculation() : super(Precedence.v);

  num call(num x) => sqrt(x);
}


class TangentCalculation extends UnaryCalculation {

  const TangentCalculation() : super(Precedence.v);

  num call(num x) => Calculation.trigWrapper(tan)(x);
}


class ZerosCalculation extends BinaryCalculation {

  const ZerosCalculation() : super(Precedence.v);

  num call(num multiplier, num exponent) => multiplier * pow(10, exponent);
}
