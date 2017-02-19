// Copyright (c) 2017, DJ. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:math' show Random, PI, E;

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:dartulator/util/equation_processor.dart';

import 'util/calculation_handler.dart' show usingDegrees;
import 'util/dartulator_strings.dart';

//import 'package:dartulator/dartulator_basic/dartulator_basic.dart';


@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [materialDirectives /*, DartulatorBasic*/
  ],
  providers: const [materialProviders],
)
class AppComponent {
  final List<List<String>> basicRows = [
    ['(', ')', '%', clear],
    ['7', '8', '9', '÷'],
    ['4', '5', '6', '*'],
    ['1', '2', '3', '-'],
    ['0', '.', equals, '+']
  ];

  final List<List<String>> advancedRows = [
    [radians, degrees, factorial],
    [inverse, sine, naturalLog],
    [pi, cosine, logOfX],
    [naturalE, tangent, sqrtSymbol] /*,
    [answer, zeros, exponent]*/
  ];

  //would like to use this to generate correctly formatted buttons
//  final List<List<String>> advancedInverseRows = [
//    [radians, degrees, factorial],
//    [inverse, secant, eToPower],
//    [pi, cosecant, tenToPower],
//    [naturalE, cotangent, squared],
//    [random, zeros, nthRoot]
//  ];

  final RegExp nonNumberMatcher = new RegExp(r"[^0-9]");
  final List<String> basicOperators = const ['+', '-', '/', '÷', '*', '^'];

  String calculationDisplay = "0";
  List calculationDisplayList = ['0'];
  bool processingZeros = false;
  bool toggled = false;

  String closingParenthesis = "";

  num previousAnswerValue = 0;
  String previousAnswerString = "Ans = 0";
  bool previousAnswerUpdateNeeded = true;

  bool equationStarted = false;
  bool currentlyHandlingNumber = false;

  List equationItems = [0];

  void multiplyByLastIfNeeded([isNumber = false]) {
    if (!equationStarted ||
        equationItems.last == '(' ||
        (isNumber && currentlyHandlingNumber) ||
        (isNumber && equationItems.last == zerosShort)) {
      return;
    }

    var last = equationItems.last;
    if (last is num ||
        last == ')' ||
        !basicOperators.contains(last)) {
      addItem('*');
    }
  }

  void updatePreviousAnswer() {
    previousAnswerString ??= '$answer = ${previousAnswerValue}';
  }

  bool moveIsNotValid(item,
      {bool isBasicOperator: false, bool isNumber: false}) {
    //no matter what button was pressed, display goes to original
    toggled = false;

    //starting something new, or attempting to, show previous answer
    if (previousAnswerUpdateNeeded) {
      updatePreviousAnswer();
      previousAnswerUpdateNeeded = false;
    }

    /*  closing empty parenthesis or
          there are not parenthesis to close or
          inner parenthesis was not finished yet
      */
    if (item == ')' && (equationItems.last == '(' ||
        closingParenthesis.isEmpty ||
        basicOperators.contains(equationItems.last) ||
        equationItems.last == zerosShort)) {
      return true;
    }

    //starting an operation without a number
    if (isBasicOperator && equationItems.last == '(') {
      return true;
    }

    //trying to add E without a number
    if (item == zerosShort && !currentlyHandlingNumber) {
      return true;
    }

    //processing E with a symbol
    if (processingZeros && (item == '.' || !isNumber)) {
      return true;
    }

    //trying to make a double a double example: 2.34.5
    if (item == '.' && equationItems.last.toString().contains('.')) {
      return true;
    }

    //all checks passed
    return false;
  }

  void handleNumber(var item, { String displayOverride}) {
    print('determined $item was a number');
    if (moveIsNotValid(item, isNumber: true)) {
      return;
      //wrap things like pi and e in parenthesis
    } else if (displayOverride != null) {
      print("wrapping number in parenthesis");
      handleOperator('(', displayOverride: '');
    }

    multiplyByLastIfNeeded(true);
    addItem(item, displayOverride, item is String);

    //close wrapping
    if (displayOverride != null) {
      handleOperator(')', displayOverride: '');
      handleTotalItemsAdded(3);
    }
  }

  //thrown into a method to clarify what it is doing
  void handleTotalItemsAdded(num amount) {
    calculationDisplayList.add(amount);
  }

  void handleBasicOperator(item) {
    if (moveIsNotValid(item, isBasicOperator: true)) {
      return;
    }
    equationStarted = true;
    addItem(item);
  }

  void handleOperator(item,
      {bool checkMultiplier: true,
      String displayOverride}) {
    print('determined $item is operator');
    if (moveIsNotValid(item)) {
      return;
    }

    //we made it here which means we are no longer processing zeros
    processingZeros = false;

    if (item == '(') {
      closingParenthesis += ')';
    } else if (item == ')') {
      closingParenthesis = closingParenthesis.substring(1);
      checkMultiplier = false;
    }

    if (checkMultiplier) {
      multiplyByLastIfNeeded();
    }

    addItem(item, displayOverride);
  }

  void handleStartingEquation(item, isNumber) {
    //isNumber is the override for '.' and '-'
    //only allow things like 0 + (!^*-+/)
    if (isNumber ||
        (item != '!' &&
            item != '%' &&
            !basicOperators.contains(item))) {
      print("overwriting the previous value");
      clearEquationVariables();
    }
  }

  void addItem(item, [String display, bool isNumber = false]) {
    if (!equationStarted) {
      handleStartingEquation(item, isNumber);
      equationStarted = true;
    }

    //adding to current number
    if (isNumber && currentlyHandlingNumber) {
      print('increasing number value and exiting');
      equationItems.add(equationItems.removeLast() + item);
      addToCalculatorDisplay(item.toString());
      return;
    }

    //turn number into an actual num and then continue
    if (currentlyHandlingNumber) {
      print('converting previous string to actual number');
      equationItems.add(num.parse(equationItems.removeLast().toString()));
      currentlyHandlingNumber = false;
    }

    display ??= item.toString();
    print("adding $item displaying as $display and exiting");
    equationItems.add(item);
    addToCalculatorDisplay(display);

    currentlyHandlingNumber = isNumber;
  }

  //remove one digit (or decimal) from number
  void removeLastNumber() {
    String lastNumber = equationItems.removeLast().toString();
    lastNumber = lastNumber.substring(0, lastNumber.length - 1);

    if (lastNumber.isNotEmpty) {
      equationItems.add(lastNumber);
    }

    calculationDisplayList.removeLast();
    currentlyHandlingNumber = lastNumber.isNotEmpty;
  }

  void removeLast([skipNumberCheck = false]) {
    if (!equationStarted) {
      //clearEquationVariables will be called because of this
      calculationDisplayList.clear();
      return;
    }

    //if we added more than one item because of a single user click
    if (calculationDisplayList.last is num) {
      num amount = calculationDisplayList.removeLast();
      for (int x = 0; x < amount; x++) {
        removeLast(true);
      }
      return;
    }

    if (!skipNumberCheck) {
      if ((equationItems.last is num && equationStarted) ||
          currentlyHandlingNumber) {
        removeLastNumber();
        return;
      }
    }
    currentlyHandlingNumber = false;

    calculationDisplayList.removeLast();
    String item = equationItems.removeLast().toString();


    //ensure the parenthesis are always correct
    if (item == ')') {
      closingParenthesis += ')';
    } else if (item == '(') {
      closingParenthesis = closingParenthesis.substring(1);
    }
  }

  void handleBasic(item) {
    print("handling basic item: " + item);

    if (item == clear) {
      handleClear();
    } else if (item == equals) {
      handleEquals();
    } else if (item == '(' || item == ')') {
      handleOperator(item);
      //decimal or negative number cases
    } else if (item == '.' || (item == '-' && !currentlyHandlingNumber)) {
      handleNumber(item);
      //if this contains anything that is not a number
    } else if (nonNumberMatcher.hasMatch(item)) {
      handleBasicOperator(item);
    } else {
      handleNumber(item);
    }
  }

  void handleClear() {
    if (calculationDisplayList.last != "0") {
      removeLast();
    }

    // example 2E or 2E34
    processingZeros = equationItems.length > 1 &&
        (equationItems.last == zerosShort ||
            equationItems[equationItems.length - 2] == zerosShort);

    if (calcStringIsEmpty()) {
      clearEquationVariables();
      addToCalculatorDisplay('0');
      equationItems.add(0);
      equationStarted = false;
    } else {
      resetCalculatorDisplay();
    }

    if (!currentlyHandlingNumber) {
      currentlyHandlingNumber = equationStarted && equationItems.last is num;
    }
  }

  void clearEquationVariables() {
    calculationDisplayList.clear();
    equationItems.clear();
    calculationDisplay = "";
  }

  void handleEquals() {
    //close out the parenthesis
    while (closingParenthesis.isNotEmpty) {
      handleOperator(')');
    }

    //finish processing number
    if (currentlyHandlingNumber && equationItems.last != '-') {
      equationItems.add(num.parse(equationItems.removeLast()));
    }

    previousAnswerString = "$calculationDisplay = ";

    //apply magic
    var totalValue = EquationProcessor.process(equationItems);
    clearEquationVariables();

    //if total value returned an Error - todo find better NaN check
    if (totalValue is String || totalValue.toString() == "NaN") {
      equationItems.add(0);
      previousAnswerValue = 0;
    } else {
      equationItems.add(totalValue);

      //this fixes precision issues sqrt(2)*sqrt(2) = 2.000000000004
      if (totalValue is double) {
        totalValue = totalValue.toStringAsFixed(10);
        totalValue = num.parse(totalValue);
      }

      previousAnswerValue = totalValue;
    }

    addToCalculatorDisplay(totalValue.toString());
    equationStarted = false;
    previousAnswerUpdateNeeded = true;
    currentlyHandlingNumber = false;
  }

  void handleAdvanced(item) {
    print("handling advanced item: " + item);
    if (processingZeros) {
      return;
    }

    String displayOverride = null;
    bool checkMultiplier = true;

    switch (item) {
      case radians:
        usingDegrees = false;
        return;

      case degrees:
        usingDegrees = true;
        return;

      case inverse:
        toggled = !toggled;
        return;

      case random:
        double random = new Random().nextDouble();
        handleNumber(random);
        return;

      case answer:
        handleNumber(previousAnswerValue, displayOverride: answer);
        return;

      case pi:
        handleNumber(PI, displayOverride: pi);
        return;

      case naturalE:
        handleNumber(E, displayOverride: naturalE);
        return;

      case zeros:
        handleBasicOperator(zerosShort);
        return;

      case exponent:
        handleBasicOperator('^');
        return;

      case factorial:
        handleBasicOperator('!');
        return;

      case arccos:
        displayOverride = "arccos";
        break;
      case arctan:
        displayOverride = "arctan";
        break;
      case arcsin:
        displayOverride = "arcsin";
        break;

      case nthRoot:
        checkMultiplier = false;
        displayOverride = "^$sqrtSymbol";
        break;

      default:
    }

    handleOperator(item, displayOverride: displayOverride,
        checkMultiplier: checkMultiplier);
    handleOperator('(', checkMultiplier: false);
    handleTotalItemsAdded(2);
  }

  bool calcStringIsEmpty() {
    return calculationDisplayList.isEmpty ||
        calculationDisplayList.last == '0' ||
        calculationDisplayList.last == 'Error';
  }

  void addToCalculatorDisplay(String appendage) {
    calculationDisplay += appendage;
    calculationDisplayList.add(appendage);
  }

  //make sure display string and display list are on the same page
  void resetCalculatorDisplay() {
    isNotTotalValidator(item) => item is! num;
    calculationDisplay =
        calculationDisplayList.where(isNotTotalValidator).join('');
  }
}