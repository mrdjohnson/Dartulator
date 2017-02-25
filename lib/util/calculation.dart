library calculation;

import 'dart:math';

import 'dartulator_strings.dart';

enum Precedence { i, ii, iii, iv, v }

abstract class Calculation implements Function {
  static bool usingDegrees = false;

  final Precedence _precedenceLevel;

  const Calculation(this._precedenceLevel);

  bool hasLessPrecedenceThan(Calculation other) =>
      _precedenceLevel.index < other._precedenceLevel.index;

  @override
  String toString() => "";
}

abstract class UnaryCalculation extends Calculation {
  const UnaryCalculation(Precedence precedenceLevel)
      : super(precedenceLevel);

  num _calculate(num x);

  num call(num x) => _calculate(x);
}

// use calculate to get value of answer so that incase there are any
abstract class BinaryCalculation extends Calculation {
  const BinaryCalculation(Precedence precedenceLevel)
      : super(precedenceLevel);

  num _calculate(num x, num y);

  num call(num x, num y) => _calculate(x, y);
}

abstract class TrigCalculation extends UnaryCalculation {
  const TrigCalculation(Precedence precedenceLevel)
      : super(precedenceLevel);

// switch the answer to degrees if need be
  @override
  num call(num x) {
    if (Calculation.usingDegrees) {
      x *= PI / 180;
    }
    return _calculate(x);
  }
}

abstract class ArcTrigCalculation extends UnaryCalculation {
  const ArcTrigCalculation(Precedence precedenceLevel)
      : super(precedenceLevel);

// switch the answer to degrees if need be
  @override
  num call(num x) {
    num value = _calculate(x);
    if (Calculation.usingDegrees) {
      value *= 180 / PI;
    }
    return value;
  }
}

//Empty classes for assisting validators
class BasicCalculation {}

const Map<String, Calculation> _calculations = const {
  add: const AdditionCalculation(),
  arccos: const ArcCosineCalculation(),
  arcsin: const ArcSineCalculation(),
  arctan: const ArcTangentCalculation(),

  cosine: const CosineCalculation(),

  divide: const DivisionCalculation(),
  divide_human: const DivisionCalculation(),

  eToPower: const BaseECalculation(),
  exponent: const ExponentCalculation(),
  exponent_symbol: const ExponentCalculation(),

  factorial: const FactorialCalculation(),
  factorial_symbol: const FactorialCalculation(),

  logOfX: const LogCalculation(),

  multiply: const MultiplicationCalculation(),

  naturalLog: const NaturalLogCalculation(),
  nthRootSymbol: const NthRootCalculation(),

  percent_symbol: const PercentCalculation(),

  sine: const SineCalculation(),
  subtract: const SubtractionCalculation(),
  sqrtSymbol: const SqrtCalculation(),
  squared: const SquaredCalculation(),

  tangent: const TangentCalculation(),
  tenToPower: const BaseTenCalculation(),

  zerosShort: const ZerosCalculation()
};

getCalculation(String key) => _calculations[key] ?? key;


class AdditionCalculation extends BinaryCalculation
    implements BasicCalculation {

  const AdditionCalculation() : super(Precedence.i);

  num _calculate(num x, num y) => x + y;
}

class ArcCosineCalculation extends ArcTrigCalculation {

  const ArcCosineCalculation() : super(Precedence.v);

  num _calculate(num x) => acos(x);
}

class ArcSineCalculation extends ArcTrigCalculation {

  const ArcSineCalculation() : super(Precedence.v);

  num _calculate(num x) => asin(x);
}

class ArcTangentCalculation extends ArcTrigCalculation {

  const ArcTangentCalculation() : super(Precedence.v);

  num _calculate(num x) => atan(x);
}


class BaseTenCalculation extends UnaryCalculation {

  const BaseTenCalculation() : super(Precedence.v);

  num _calculate(num exponent) => pow(10, exponent);
}

class BaseECalculation extends UnaryCalculation {

  const BaseECalculation() : super(Precedence.v);

  num _calculate(num exponent) => pow(E, exponent);
}


class CosineCalculation extends TrigCalculation {

  const CosineCalculation() : super(Precedence.v);

  num _calculate(num x) => cos(x);
}


class DivisionCalculation extends BinaryCalculation
    implements BasicCalculation {

  const DivisionCalculation() : super(Precedence.ii);

  num _calculate(num x, num y) => x / y;
}


class ExponentCalculation extends BinaryCalculation
    implements BasicCalculation {

  const ExponentCalculation() : super(Precedence.iv);

  num _calculate(num x, num y) => pow(x, y);
}


class FactorialCalculation extends UnaryCalculation {

  const FactorialCalculation() : super(Precedence.iv);

  num gamma(num x) {
    return sqrt(2 * PI / x) *
        pow((1 / E) * (x + 1 / (12 * x - 1 / (10 * x))), x);
  }

  num _calculate(num x) {
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

  num _calculate(num x) => log(x) / log(10);
}


class MultiplicationCalculation extends BinaryCalculation
    implements BasicCalculation {

  const MultiplicationCalculation() : super(Precedence.ii);

  num _calculate(num x, num y) => x * y;
}


class NaturalLogCalculation extends UnaryCalculation {

  const NaturalLogCalculation() : super(Precedence.v);

  num _calculate(num x) => log(x);
}

class NthRootCalculation extends BinaryCalculation {

  const NthRootCalculation() : super(Precedence.v);

  num _calculate(num root, num exponent) => pow(root, 1 / exponent);
}


class PercentCalculation extends BinaryCalculation {

  const PercentCalculation() : super(Precedence.iv);

  num _calculate(num x, num y) => x * .01;
}


class SineCalculation extends TrigCalculation {

  const SineCalculation() : super(Precedence.v);

  num _calculate(num x) => sin(x);
}

class SubtractionCalculation extends BinaryCalculation
    implements BasicCalculation {

  const SubtractionCalculation() : super(Precedence.i);

  num _calculate(num x, num y) => x - y;
}

class SquaredCalculation extends UnaryCalculation {

  const SquaredCalculation() : super(Precedence.v);

  num _calculate(num base) => pow(base, 2);
}

class SqrtCalculation extends UnaryCalculation {

  const SqrtCalculation() : super(Precedence.v);

  num _calculate(num x) => sqrt(x);
}


class TangentCalculation extends TrigCalculation {

  const TangentCalculation() : super(Precedence.v);

  num _calculate(num x) => tan(x);
}


class ZerosCalculation extends BinaryCalculation {

  const ZerosCalculation() : super(Precedence.v);

  num _calculate(num multiplier, num exponent) => multiplier * pow(10, exponent);
}
