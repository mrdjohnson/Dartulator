//// Copyright (c) 2017, DJ. All rights reserved. Use of this source code
//
//// is governed by a BSD-style license that can be found in the LICENSE file.
//
//import 'package:angular2/core.dart';
//import 'package:angular2_components/angular2_components.dart';
//import 'package:dartulator/dartulator_button/dartulator_button.dart';
//import '../util/equation_processor.dart';
//
//@Component(
//  selector: 'dartulator_basic',
//  styleUrls: const ['dartulator_basic.css'],
//  templateUrl: 'dartulator_basic.html',
//  directives: const [materialDirectives, DartulatorButton],
//  providers: const [materialProviders],
//)
//class DartulatorBasic {
//  final List<List<String>> rows = [
//    ['!', ')', '%', 'C'],
//    ['7', '8', '9', '÷'],
//    ['4', '5', '6', '*'],
//    ['1', '2', '3', '-'],
//    ['0', '.', '=', '+']
//  ];
//
//  final List<String> specialOperators = ['=', 'C'];
//
//  var equationValue = "";
//  String calculationString = "";
//
//  void handle(item) {
//    print("handling item: " + item);
//    if (specialOperators.contains(item)) {
//      _handleSpecial(item);
//    } else {
//      calculationString += item;
//      equationValue = EquationProcessor.process(calculationString);
//    }
//  }
//
//  void _handleSpecial(item) {
//    switch (item) {
//      case 'C':
//        calculationString = "";
//        equationValue = "";
//        break;
//    }
//  }
//
//  void open() {
//    print("testy");
//  }
//}
