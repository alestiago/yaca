import 'dart:async';
import 'dart:collection';

import 'package:cellular_automaton/cellular_automaton.dart';

export 'rule.dart';

/// Exception thrown by [CellularAutomaton].
abstract class CellularAutomatonException implements Exception {}

/// Exception thrown when a [CellularAutomaton] is stepped without a rule
/// matching the current state.
class UndefinedStateException implements CellularAutomatonException {}

/// Exception thrown when a [CellularAutomaton] is stepped or altered while
/// locked.
///
/// A [CellularAutomaton] is locked when it is altering its internal
/// configuration. For example, stepping into a new state or updating its
/// rules.
class LockedStateException implements CellularAutomatonException {}

/// {@template CellularAutomaton}
/// A cellular automaton.
/// {@endtemplate}
class CellularAutomaton<Coordinate, Base> {
  /// {@macro CellularAutomaton}
  CellularAutomaton({
    required Map<Coordinate, Base> state,
    required List<Rule<Coordinate, Base>> rules,
  })  : _state = Map.from(state),
        _rules = List.from(rules);

  /// A map of reflecting the state of the two-dimensional cellular automaton.
  UnmodifiableMapView<Coordinate, Base> get state {
    if (_locked) throw LockedStateException();
    return UnmodifiableMapView(_state);
  }

  final Map<Coordinate, Base> _state;

  /// Rules that define the behavior of the automaton.
  UnmodifiableListView<Rule<Coordinate, Base>> get rules =>
      UnmodifiableListView(_rules);

  final List<Rule<Coordinate, Base>> _rules;

  bool _locked = false;

  /// Whether the automaton is locked.
  bool get locked => _locked;

  /// Steps the generation forward by one.
  ///
  /// The state of the automaton is updated according to the rules.
  ///
  /// Throws [UndefinedStateException] if no rule matches the current state.
  /// Throws [LockedStateException] if the automaton is locked when called.
  FutureOr<void> step() async {
    if (_locked) throw LockedStateException();
    final previousStateView = UnmodifiableMapView<Coordinate, Base>(
      Map<Coordinate, Base>.from(_state),
    );

    _locked = true;
    for (final mapEntry in previousStateView.entries) {
      final coordinate = mapEntry.key;
      late UnmodifiableMapView<Coordinate, Base> neighbourhoodView;
      final rule = _rules.firstWhere(
        (rule) {
          final neighbourhood = rule.neighbourhood(
            previousStateView,
            coordinate,
          );
          neighbourhoodView = UnmodifiableMapView(neighbourhood);
          return rule.matches(neighbourhoodView, coordinate);
        },
        orElse: () => throw UndefinedStateException(),
      );
      _state[coordinate] = await rule.apply(neighbourhoodView, coordinate);
    }
    _locked = false;
  }

  /// Creates a copy of the automaton with the given parameters.
  ///
  /// Throws [LockedStateException] if the automaton is locked when called.
  void alter({
    Map<Coordinate, Base>? state,
    List<Rule<Coordinate, Base>>? rules,
  }) {
    if (_locked) throw LockedStateException();

    _locked = true;
    if (state != null) {
      _state
        ..clear()
        ..addAll(state);
    }
    if (rules != null) {
      _rules
        ..clear()
        ..addAll(rules);
    }
    _locked = false;
  }
}
