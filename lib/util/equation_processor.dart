import "dart:collection";

import 'calculation_handler.dart';
import 'dartulator_strings.dart';

class EquationProcessor {

  // modified from https://www.tutorialspoint.com/javaexamples/data_intopost.htm
  static process(List input) {
    Queue<String> operators = new Queue();
    List postfixList = [];

    int _getImportanceLevel(String symbol) {
      switch (symbol) {
        case '+':
        case '-':
          return 1;
        case '*':
        case '÷':
        case '/':
          return 2;
        case '^':
          return 3;
        case '!':
        case '%':
          return 4;
        default:
          return 5;
      }
    }

    void _handleOperator(String newOperator) {
      while (operators.isNotEmpty) {
        String lastOperator = operators.removeLast();
        if (lastOperator == '(') {
          operators.addLast(lastOperator);
          break;
        }

        if (_getImportanceLevel(lastOperator) < _getImportanceLevel(newOperator)) {
          operators.addLast(lastOperator);
          break;
        }

        postfixList.add(lastOperator);
      }

      operators.addLast(newOperator);
    }

    void _handleParenthesis(String char) {
      while (operators.isNotEmpty) {
        String last = operators.removeLast();
        if (last == '(')
          break;
        else
          postfixList.add(last);
      }
    }

    num _convert() {
      for (var equationItem in input) {
        if (equationItem is num) {
          postfixList.add(equationItem);
        } else if (equationItem == '(') {
          operators.addLast(equationItem);
        } else if (equationItem == ')') {
          _handleParenthesis(equationItem);
        } else {
          _handleOperator(equationItem);
        }
      }

      while (operators.isNotEmpty) {
        postfixList.add(operators.removeLast());
      }

      return calculate(postfixList);
    }


    try {
      return _convert();
    } catch (exception) {
      return 'Error';
    }
  }

  static const List _singleDigitOperators = const [
    '!',
    '%',
    pi,
    naturalE,
    sqrtSymbol
  ];

  //modified from http://kevinyavno.com/blog/?p=52
  static calculate(List infixList) {
    Queue<num> tempNumberList = new Queue();
    for (var equationItem in infixList) {
      if (equationItem is num) {
        tempNumberList.addLast(equationItem);
        continue;
      }

      Function operation = getOperation(equationItem);
      num x = tempNumberList.removeLast();

      if (_singleDigitOperators.contains(equationItem) ||
          (equationItem.length > 1 && equationItem != nthRoot)) {
        tempNumberList.addLast(operation(x));
      } else {
        num y = tempNumberList.removeLast();
        tempNumberList.addLast(operation(y, x));
      }
    }
    return tempNumberList.removeLast();
  }
}
