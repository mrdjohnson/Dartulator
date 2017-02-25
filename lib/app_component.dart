// Copyright (c) 2017, DJ. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:math' show Random, PI, E;

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import 'util/calculation.dart'
    show Calculation, BasicCalculation, getCalculation;
import 'util/dartulator_strings.dart';
import 'util/equation_processor.dart';

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
    [parenthesis_open, parenthesis_close, percent_symbol, clear],
    ['7', '8', '9', divide],
    ['4', '5', '6', multiply],
    ['1', '2', '3', subtract],
    ['0', decimal, equals, add]
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

  final RegExp nonNumberMatcher = new RegExp(r"[\D]");

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
        equationItems.last == parenthesis_open ||
        (isNumber && currentlyHandlingNumber) ||
        (isNumber && equationItems.last == zerosShort)) {
      return;
    }

    var last = equationItems.last;
    if (last is num ||
        last == parenthesis_close ||
        last is! BasicCalculation) {
      addItem(multiply);
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
    if (item == parenthesis_close && (equationItems.last == parenthesis_open ||
        closingParenthesis.isEmpty ||
        equationItems.last is BasicCalculation ||
        equationItems.last == zerosShort)) {
      return true;
    }

    //starting an operation without a number
    if (isBasicOperator && equationItems.last == parenthesis_open) {
      return true;
    }

    //trying to add E without a number
    if (item == zerosShort && !currentlyHandlingNumber) {
      return true;
    }

    //processing E with a symbol
    if (processingZeros && (item == decimal || !isNumber)) {
      return true;
    }

    //trying to make a double a double example: 2.34.5
    if (item == decimal && equationItems.last.toString().contains(decimal)) {
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
      handleOperator(parenthesis_open, displayOverride: '');
    }

    multiplyByLastIfNeeded(true);
    addItem(item, displayOverride, item is String || item == subtract);

    //close wrapping
    if (displayOverride != null) {
      handleOperator(parenthesis_close, displayOverride: '');
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

    if (item == parenthesis_open) {
      closingParenthesis += parenthesis_close;
    } else if (item == parenthesis_close) {
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
        (item != factorial_symbol &&
            item != percent_symbol &&
            item is! BasicCalculation)) {
      print("overwriting the previous value");
      clearEquationVariables();
    }
  }

  void addItem(item, [String display, bool isNumber = false]) {
    if (!equationStarted) {
      handleStartingEquation(item, isNumber);
      equationStarted = true;
    }

    display ??= item.toString();

    //adding to current number
    if (isNumber && currentlyHandlingNumber) {
      print('increasing number value and exiting');
      equationItems.add(equationItems.removeLast() + item);
      addToCalculatorDisplay(display);
      return;
    }

    if (currentlyHandlingNumber) {
      //attempting to do negative pi or negative e
      if (equationItems.last == subtract) {
        addItem('1', '', true);
        addItem(multiply, '');
        handleTotalItemsAdded(3);
      } else {
        print('converting previous string to actual number');
        equationItems.add(num.parse(equationItems.removeLast().toString()));
        currentlyHandlingNumber = false;
      }
    }

    if (item == parenthesis_close) {
      closingParenthesis = closingParenthesis.substring(1);
    }

    print("adding $item displaying as $display and exiting");
    equationItems.add(getCalculation(item));
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

  void removeLast() {
    if (!equationStarted) {
      //clearEquationVariables will be called because of this
      calculationDisplayList.clear();
      return;
    }

    //if we added more than one item because of a single user click
    if (calculationDisplayList.last is num) {
      num amount = calculationDisplayList.removeLast();
      for (int x = 0; x < amount; x++) {
        removeLast();
      }
      return;
    }

    // if the last displayed item is not one of these
    bool isManualNumber = ![pi, answer, naturalE].contains(
        calculationDisplayList.last);

    if (isManualNumber &&
        ((equationItems.last is num && equationStarted) ||
            currentlyHandlingNumber)) {
      removeLastNumber();
      return;
    }
    currentlyHandlingNumber = false;

    calculationDisplayList.removeLast();
    String item = equationItems.removeLast().toString();


    //ensure the parenthesis are always correct
    if (item == parenthesis_close) {
      closingParenthesis += parenthesis_close;
    } else if (item == parenthesis_open) {
      closingParenthesis = closingParenthesis.substring(1);
    }
  }

  bool startingNegativeNumber(String item) {
    if (item != subtract) return false;

    if (equationItems.last.toString() != '0' &&
        !equationStarted) return false;

    return !currentlyHandlingNumber;
  }

  void handleBasic(item) {
    print("handling basic item: " + item);

    if (item == clear) {
      handleClear();
    } else if (item == equals) {
      handleEquals();
    } else if (item == parenthesis_open || item == parenthesis_close) {
      handleOperator(item);
      //decimal or negative number cases
    } else if (item == decimal || startingNegativeNumber(item)) {
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
      addItem(parenthesis_close);
    }

    //finish processing number
    if (currentlyHandlingNumber && equationItems.last != subtract) {
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
      if (totalValue.toString().contains(decimal)) {
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
        Calculation.usingDegrees = false;
        return;

      case degrees:
        Calculation.usingDegrees = true;
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
        handleBasicOperator(exponent_symbol);
        return;

      case factorial:
        handleBasicOperator(factorial_symbol);
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

      case nthRootSymbol:
        checkMultiplier = false;
        displayOverride = "$exponent_symbol$sqrtSymbol";
        break;

      default:
    }

    handleOperator(item, displayOverride: displayOverride,
        checkMultiplier: checkMultiplier);
    handleOperator(parenthesis_open, checkMultiplier: false);
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