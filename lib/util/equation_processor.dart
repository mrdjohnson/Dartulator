import "dart:collection";

import 'calculation.dart'
    show Calculation, UnaryCalculation, BinaryCalculation;
import 'dartulator_strings.dart' show parenthesis_open, parenthesis_close;

class EquationProcessor {

  // modified from https://www.tutorialspoint.com/javaexamples/data_intopost.htm
  static process(List equationList) {
    Queue calculations = new Queue();
    List postfixList = [];

    void _handleCalculation(Calculation newCalculation) {
      while (calculations.isNotEmpty) {
        if (calculations.last is String) {
          break;
        }

        Calculation lastCalculation = calculations.removeLast();

        if (lastCalculation.hasLessPrecedenceThan(newCalculation)) {
          calculations.addLast(lastCalculation);
          break;
        }

        postfixList.add(lastCalculation);
      }

      calculations.addLast(newCalculation);
    }

    void _handleParenthesis() {
      while (calculations.isNotEmpty) {
        var last = calculations.removeLast();
        if (last == parenthesis_open)
          break;
        else
          postfixList.add(last);
      }
    }

    _convert() {
      for (var equationItem in equationList) {
        if (equationItem is num) {
          postfixList.add(equationItem);
        } else if (equationItem == parenthesis_open) {
          calculations.addLast(equationItem);
        } else if (equationItem == parenthesis_close) {
          _handleParenthesis();
        } else {
          _handleCalculation(equationItem);
        }
      }

      while (calculations.isNotEmpty) {
        postfixList.add(calculations.removeLast());
      }

      return calculate(postfixList);
    }

    try {
      return _convert();
    } catch (exception) {
      return 'Error';
    }
  }

  //modified from http://kevinyavno.com/blog/?p=52
  static calculate(List infixList) {
    Queue<num> tempNumberList = new Queue();
    for (var infixItem in infixList) {
      if (infixItem is num) {
        tempNumberList.addLast(infixItem);
        continue;
      }

      Calculation calculate = infixItem as Calculation;
      num x = tempNumberList.removeLast();

      if (calculate is UnaryCalculation) {
        // ignore: invocation_of_non_function
        tempNumberList.addLast(calculate(x));
      } else if (calculate is BinaryCalculation) {
        num y = tempNumberList.removeLast();
        // ignore: invocation_of_non_function
        tempNumberList.addLast(calculate(y, x));
      } else {
        throw UnsupportedError;
      }
    }
    return tempNumberList.removeLast();
  }
}
