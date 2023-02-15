// ignore_for_file: prefer_const_constructors, cascade_invocations
import 'dart:collection';

import 'package:cellular_automaton/cellular_automaton.dart';
import 'package:test/test.dart';

void main() {
  group('$CellularAutomaton', () {
    test('can be instantiated', () {
      expect(
        CellularAutomaton<int, bool>(state: {}, rules: []),
        isNotNull,
      );
    });

    group('state', () {});

    group('rules', () {});

    group('step', () {
      test('applies rules', () async {
        final automaton = CellularAutomaton<int, bool>(
          state: {0: true, 1: true, 2: false},
          rules: [_NotBooleanRule()],
        );

        await automaton.step();
        expect(
          automaton.state,
          equals({0: false, 1: false, 2: true}),
        );

        await automaton.step();
        expect(
          automaton.state,
          equals({0: true, 1: true, 2: false}),
        );
      });

      test('throws $UndefinedStateException', () {
        final automaton = CellularAutomaton<int, bool>(
          state: {0: true, 1: true, 2: false},
          rules: [],
        );
        expect(
          automaton.step,
          throwsA(isA<UndefinedStateException>()),
        );
      });

      test('throws $LockedStateException when not awaited', () {
        final automaton = CellularAutomaton<int, bool>(
          state: {0: true, 1: true, 2: false},
          rules: [_NotBooleanRule()],
        );

        automaton.step();
        expect(
          automaton.step,
          throwsA(isA<LockedStateException>()),
        );
      });
    });

    group('alter', () {
      test('modifies state', () {
        final automaton = CellularAutomaton<int, bool>(
          state: {0: true, 1: true, 2: false},
          rules: [_NotBooleanRule()],
        );

        automaton.alter(state: {0: false, 1: false, 2: false});
        expect(
          automaton.state,
          equals({0: false, 1: false, 2: false}),
        );
      });

      test('modifies rules', () {
        final automaton = CellularAutomaton<int, bool>(
          state: {0: true, 1: true, 2: false},
          rules: [_NotBooleanRule()],
        );

        final newRules = [_AlwaysTrueRule()];
        automaton.alter(rules: newRules);
        expect(
          automaton.rules,
          equals(newRules),
        );
      });

      test('throws $LockedStateException when alter while locked', () {
        final automaton = CellularAutomaton<int, bool>(
          state: {0: true, 1: true, 2: false},
          rules: [_NotBooleanRule()],
        );

        automaton.step();
        expect(
          automaton.alter,
          throwsA(isA<LockedStateException>()),
        );
      });
    });
  });
}

class _NotBooleanRule extends Rule<int, bool> {
  @override
  Map<int, bool> neighbourhood(
    UnmodifiableMapView<int, bool> state,
    int coordinate,
  ) {
    return {coordinate: state[coordinate]!};
  }

  @override
  bool matches(
    UnmodifiableMapView<int, bool> neighbourhood,
    int coordinate,
  ) {
    return true;
  }

  @override
  bool apply(
    UnmodifiableMapView<int, bool> neighbourhood,
    int coordinate,
  ) {
    return !neighbourhood[coordinate]!;
  }
}

class _AlwaysTrueRule extends Rule<int, bool> {
  @override
  Map<int, bool> neighbourhood(
    UnmodifiableMapView<int, bool> state,
    int coordinate,
  ) {
    return {coordinate: state[coordinate]!};
  }

  @override
  bool matches(
    UnmodifiableMapView<int, bool> neighbourhood,
    int coordinate,
  ) {
    return true;
  }

  @override
  bool apply(
    UnmodifiableMapView<int, bool> neighbourhood,
    int coordinate,
  ) {
    return true;
  }
}
