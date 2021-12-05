part of health;

/// A [WorkoutDataPoint] object corresponds to a data point captures from
/// GoogleFit or Apple HealthKit
class WorkoutDataPoint {
  num _totalDistance;
  num _totalEnergyBurned;
  num _totalFlightsClimbed;
  num _totalSwimmingStrokeCount;
  num _duration;
  DateTime _dateFrom;
  DateTime _dateTo;
  String _sourceId;
  String _sourceName;
  String _dataType;

  WorkoutDataPoint(
    this._totalDistance,
    this._totalEnergyBurned,
    this._totalFlightsClimbed,
    this._totalSwimmingStrokeCount,
    this._duration,
    this._dateFrom,
    this._dateTo,
    this._sourceId,
    this._sourceName,
    this._dataType,
  ) {}

  /// Converts a json object to the [HealthDataPoint]
  factory WorkoutDataPoint.fromJson(json) => WorkoutDataPoint(
        json['total_distance'],
        json['total_energy_burned'],
        json['total_flights_climbed'],
        json['total_swimming_stroke_count'],
        json['duration'],
        DateTime.parse(json['date_from']),
        DateTime.parse(json['date_to']),
        json['source_id'],
        json['source_name'],
        json['workout_type'],
      );

  /// Converts the [HealthDataPoint] to a json object
  Map<String, dynamic> toJson() => {
        'total_distance': totalDistance,
        'total_energy_burned': totalEnergyBurned,
        'total_flights_climbed': totalFlightsClimbed,
        'total_swimming_stroke_count': totalSwimmingStrokeCount,
        'duration': duration,
        'date_from': dateFrom,
        'date_to': dateTo,
        'source_id': sourceId,
        'source_name': sourceName,
        'data_type': dataType,
      };

  /// Converts the [HealthDataPoint] to a string
  String toString() => '${this.runtimeType} - '
      'total_distance: $totalDistance, '
      'total_energy_burned: $totalEnergyBurned, '
      'total_flights_climbed: $totalFlightsClimbed, '
      'total_swimming_stroke_count: $totalSwimmingStrokeCount, '
      'duration: $duration, '
      'dateFrom: $dateFrom, '
      'dateTo: $dateTo, '
      'sourceId: $sourceId,'
      'sourceName: $sourceName,';

  /// Get the quantity value of the data point
  num get totalDistance => _totalDistance;

  num get totalEnergyBurned => _totalEnergyBurned;

  num get totalFlightsClimbed => _totalFlightsClimbed;

  num get totalSwimmingStrokeCount => _totalSwimmingStrokeCount;

  num get duration => _duration;

  /// Get the start of the datetime interval
  DateTime get dateFrom => _dateFrom;

  /// Get the end of the datetime interval
  DateTime get dateTo => _dateTo;

  /// Get the id of the source from which
  /// the data point was extracted
  String get sourceId => _sourceId;

  /// Get the name of the source from which
  /// the data point was extracted
  String get sourceName => _sourceName;

  String get dataType => _dataType;

  /// An equals (==) operator for comparing two data points
  /// This makes it possible to remove duplicate data points.
  @override
  bool operator ==(Object o) {
    return o is WorkoutDataPoint &&
        this.totalDistance == o.totalDistance &&
        this.totalEnergyBurned == o.totalEnergyBurned &&
        this.totalFlightsClimbed == o.totalFlightsClimbed &&
        this.totalSwimmingStrokeCount == o.totalSwimmingStrokeCount &&
        this.duration == o.duration &&
        this.dateFrom == o.dateFrom &&
        this.dateTo == o.dateTo &&
        this.sourceId == o.sourceId &&
        this.sourceName == o.sourceName &&
        this.dataType == o.dataType;
  }

  /// Override required due to overriding the '==' operator
  @override
  int get hashCode => toJson().hashCode;
}
