import 'dart:math';

import 'dartulator_strings.dart';

bool usingDegrees = false;

num _add(num x, num y) => x + y;

num _subtract(num x, num y) => x - y;

num _multiply(num x, num y) => x * y;

num _divide(num x, num y) => x / y;

num _percent(num x) => x * .01;

num _nthRoot(num root, num exponent) => pow(root, 1 / exponent);

num _tenBase(num exponent) => pow(10, exponent);

num _multiplyPi(num multiplier) => _multiply(multiplier, PI);

num _multiplyNaturalE(num multiplier) => _multiply(multiplier, E);

num _baseE(num exponent) => pow(E, exponent);

num _log(num x) => log(x) / log(10);

num _baseTen(num multiplier, num exponent) => _multiply(multiplier, _tenBase(exponent));

// for the arc(sine cosine tangent) functions to switch the answer to degrees if need be
Function _arcTrigWrapper(num arcTrigFunction(x)) {
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
Function _trigWrapper(num trigFunction(x)) {
  num _convertedTrigFunction(num x) {
    if (usingDegrees) {
      x *= PI / 180;
    }
    return trigFunction(x);
  }
  return _convertedTrigFunction;
}

//modified from http://stackoverflow.com/questions/15454183/how-to-make-a-function-that-computes-the-factorial-for-numbers-with-decimals
num _gamma(num x) {
  return sqrt(2 * PI / x) *
      pow((1 / E) * (x + 1 / (12 * x - 1 / (10 * x))), x);
}

num _factorial(num x) {
  if (x.toString().contains(".")) {
    return _gamma(x + 1);
  }

  int total = 1;
  while (x > 1) {
    total *= x--;
  }
  return total;
}

Function getOperation(String symbol) {
  switch (symbol) {
    case '*':
      return _multiply;
    case "-":
      return _subtract;
    case "÷":
    case "/":
      return _divide;
    case "+":
      return _add;
    case "^":
      return pow;
    case "%":
      return _percent;
    case "!":
      return _factorial;
    case pi:
      return _multiplyPi;
    case naturalE:
      return _multiplyNaturalE;
    case sqrtSymbol:
      return sqrt;
    case zerosShort:
      return _baseTen;
    case tenToPower:
      return _tenBase;
    case sine:
      return _trigWrapper(sin);
    case cosine:
      return _trigWrapper(cos);
    case tangent:
      return _trigWrapper(tan);
    case arcsin:
      return _arcTrigWrapper(asin);
    case arccos:
      return _arcTrigWrapper(acos);
    case arctan:
      return _arcTrigWrapper(atan);
    case logOfX:
      return _log;
    case naturalLog:
      return log;
    case eToPower:
      return _baseE;
    case nthRoot:
      return _nthRoot;
  }
  throw UnsupportedError;
}