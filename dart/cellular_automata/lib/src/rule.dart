import 'dart:async';
import 'dart:collection';

/// {@template Rule}
/// A rule matches a cell to its next state according to its neighbourhood.
/// {@endtemplate}
abstract class Rule<Coordinate, Base> {
  /// {@macro Rule}
  const Rule();

  /// Reduces the state to the visible neighborhood of [coordinate].
  Map<Coordinate, Base> neighbourhood(
    UnmodifiableMapView<Coordinate, Base> state,
    Coordinate coordinate,
  );

  /// Whether the rule matches against the [neighbourhood].
  ///
  /// If true the rule should be [apply]ed.
  bool matches(
    UnmodifiableMapView<Coordinate, Base> neighbourhood,
    Coordinate coordinate,
  );

  /// Applies the rule to the [neighbourhood] and returns the new state of the
  /// cell at [coordinate].
  FutureOr<Base> apply(
    UnmodifiableMapView<Coordinate, Base> neighbourhood,
    Coordinate coordinate,
  );
}
