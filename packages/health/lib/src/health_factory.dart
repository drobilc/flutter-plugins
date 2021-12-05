part of health;

/// Main class for the Plugin
class HealthFactory {
  static const MethodChannel _channel = MethodChannel('flutter_health');
  String? _deviceId;
  final _deviceInfo = DeviceInfoPlugin();

  static PlatformType _platformType =
      Platform.isAndroid ? PlatformType.ANDROID : PlatformType.IOS;

  /// Check if a given data type is available on the platform
  bool isDataTypeAvailable(HealthDataType dataType) =>
      _platformType == PlatformType.ANDROID
          ? _dataTypeKeysAndroid.contains(dataType)
          : _dataTypeKeysIOS.contains(dataType);

  /// Request access to GoogleFit or Apple HealthKit
  Future<bool> requestAuthorization(List<HealthDataType> types) async {
    /// If BMI is requested, then also ask for weight and height
    if (types.contains(HealthDataType.BODY_MASS_INDEX)) {
      if (!types.contains(HealthDataType.WEIGHT)) {
        types.add(HealthDataType.WEIGHT);
      }

      if (!types.contains(HealthDataType.HEIGHT)) {
        types.add(HealthDataType.HEIGHT);
      }
    }

    List<String> keys = types.map((e) => _enumToString(e)).toList();
    final bool isAuthorized =
        await _channel.invokeMethod('requestAuthorization', {'types': keys});
    return isAuthorized;
  }

  /// Calculate the BMI using the last observed height and weight values.
  Future<List<HealthDataPoint>> _computeAndroidBMI(
      DateTime startDate, DateTime endDate) async {
    List<HealthDataPoint> heights =
        await _prepareQuery(startDate, endDate, HealthDataType.HEIGHT);

    if (heights.isEmpty) {
      return [];
    }

    List<HealthDataPoint> weights =
        await _prepareQuery(startDate, endDate, HealthDataType.WEIGHT);

    double h = heights.last.value.toDouble();

    const dataType = HealthDataType.BODY_MASS_INDEX;
    final unit = _dataTypeToUnit[dataType]!;

    final bmiHealthPoints = <HealthDataPoint>[];
    for (var i = 0; i < weights.length; i++) {
      final bmiValue = weights[i].value.toDouble() / (h * h);
      final x = HealthDataPoint(bmiValue, dataType, unit, weights[i].dateFrom,
          weights[i].dateTo, _platformType, _deviceId!, '', '');

      bmiHealthPoints.add(x);
    }
    return bmiHealthPoints;
  }

  Future<List<HealthDataPoint>> sumedCalories(
      DateTime startDate, DateTime endDate) async {
    List<HealthDataPoint> result = [];

    final resultActiveEnergy = await _prepareQuery(
        startDate, endDate, HealthDataType.ACTIVE_ENERGY_BURNED);
    final resultBasalEnergy = await _prepareQuery(
        startDate, endDate, HealthDataType.BASAL_ENERGY_BURNED);
    resultActiveEnergy.forEach((element) {
      final value = element.value +
          resultBasalEnergy
              .where((basalElement) =>
                  basalElement._dateFrom == element.dateFrom &&
                  basalElement.dateTo == element.dateTo)
              .first
              .value;

      result.add(HealthDataPoint.create(
        value: value,
        type: HealthDataType.CALORIES,
        unit: element.unit,
        dateFrom: element.dateFrom,
        dateTo: element.dateTo,
        platform: element.platform,
        deviceId: element.deviceId,
        sourceId: element.sourceId,
        sourceName: element.sourceName,
      ));
    });

    return result;
  }

  /// Get an list of [HealthDataPoint] from an list of [HealthDataType]
  Future<List<HealthDataPoint>> getHealthDataFromTypes(
      DateTime startDate, DateTime endDate, List<HealthDataType> types) async {
    final dataPoints = <HealthDataPoint>[];

    for (var type in types) {
      List<HealthDataPoint> result = [];
      // Since CALORIES is sum of ACTIVE_ENERGY_BURNED and BASAL_ENERGY_BURNED,
      //we don't query those.
      if (type == HealthDataType.ACTIVE_ENERGY_BURNED ||
          type == HealthDataType.BASAL_ENERGY_BURNED) continue;
      if (type == HealthDataType.CALORIES) {
        result = await sumedCalories(startDate, endDate);
      } else {
        result = await _prepareQuery(startDate, endDate, type);
      }
      dataPoints.addAll(result);
    }
    return removeDuplicates(dataPoints);
  }

  Future<List<WorkoutDataPoint>> getWorkoutData() async {
    List<WorkoutDataPoint> dataPoints = [];

    dataPoints = await _queryWorkoutData();
    print(dataPoints);
    return removeWorkoutDuplicates(dataPoints);
  }

  Future<List<WorkoutDataPoint>> _queryWorkoutData() async {
    final fetchedDataPoints = await _channel.invokeMethod('getWorkoutData');
    if (fetchedDataPoints != null) {
      return fetchedDataPoints.map<WorkoutDataPoint>((e) {
        final num totalDistance = e['total_distance'];
        final num totalEnergyBurned = e['total_energy_burned'];
        final num totalFlightsClimbed = e['total_flights_climbed'];
        final num totalSwimmingStrokeCount = e['total_swimming_stroke_count'];
        final num duration = e['duration'];
        final DateTime from =
            DateTime.fromMillisecondsSinceEpoch(e['date_from']);
        final DateTime to = DateTime.fromMillisecondsSinceEpoch(e['date_to']);
        final String sourceId = e["source_id"];
        final String sourceName = e["source_name"];
        final String dataType = e["workout_type"];
        return WorkoutDataPoint(
          totalDistance,
          totalEnergyBurned,
          totalFlightsClimbed,
          totalSwimmingStrokeCount,
          duration,
          from,
          to,
          sourceId,
          sourceName,
          dataType,
        );
      }).toList();
    } else {
      return <WorkoutDataPoint>[];
    }
  }

  /// Prepares a query, i.e. checks if the types are available, etc.
  Future<List<HealthDataPoint>> _prepareQuery(
      DateTime startDate, DateTime endDate, HealthDataType dataType) async {
    // Ask for device ID only once
    _deviceId ??= _platformType == PlatformType.ANDROID
        ? (await _deviceInfo.androidInfo).androidId
        : (await _deviceInfo.iosInfo).identifierForVendor;

    // If not implemented on platform, throw an exception
    if (!isDataTypeAvailable(dataType)) {
      throw _HealthException(
          dataType, 'Not available on platform $_platformType');
    }

    // If BodyMassIndex is requested on Android, calculate this manually
    if (dataType == HealthDataType.BODY_MASS_INDEX &&
        _platformType == PlatformType.ANDROID) {
      return _computeAndroidBMI(startDate, endDate);
    }
    return await _dataQuery(startDate, endDate, dataType);
  }

  /// The main function for fetching health data
  Future<List<HealthDataPoint>> _dataQuery(
      DateTime startDate, DateTime endDate, HealthDataType dataType) async {
    // Set parameters for method channel request
    final args = <String, dynamic>{
      'dataTypeKey': _enumToString(dataType),
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch
    };

    var unit = _dataTypeToUnit[dataType]!;

    List<HealthDataType> hourErrorhealthTypes = [
      HealthDataType.HEART_RATE_VARIABILITY_SDNN,
      HealthDataType.WALKING_HEART_RATE,
      HealthDataType.WALKING_RUNNING_DURATION,
      HealthDataType.CYCLING_DURATION,
      HealthDataType.SWIMMING_DURATION,
    ];

    List<HealthDataType> activityDurationhealthTypes = [
      HealthDataType.WALKING_RUNNING_DURATION,
      HealthDataType.CYCLING_DURATION,
      HealthDataType.SWIMMING_DURATION,
    ];

    final fetchedDataPoints = await _channel.invokeMethod('getData', args);
    List<HealthDataPoint> hdpList = [];
    if (fetchedDataPoints != null) {
      for (Map e in fetchedDataPoints) {
        final List dtapoint = e['val'];
        dtapoint.forEach((element) {
          num value = element['value'];

          //Convert dateTime to UTC
          DateTime from = DateTime.fromMillisecondsSinceEpoch(
            element['date_from'],
          );
          DateTime to = DateTime.fromMillisecondsSinceEpoch(
            element['date_to'],
          );

          from = DateTime.utc(
              from.year, from.month, from.day, from.hour, from.minute);
          to = DateTime.utc(to.year, to.month, to.day, to.hour, to.minute);

          // Add 2 hours to the selected dataTypes
          // if (hourErrorhealthTypes.contains(dataType)) {
          //   from = from.add(Duration(hours: 2));
          //   to = to.add(Duration(hours: 2));
          // }

          final String sourceId = element["source_id"];
          final String sourceName = element["source_name"];

          //Convert value to minutes with decimals points
          if (activityDurationhealthTypes.contains(dataType)) {
            value = to.difference(from).inSeconds / 60;
            unit = HealthDataUnit.MINUTES;
          }
          if (dataType == HealthDataType.HEART_RATE_VARIABILITY_SDNN)
            value = value.ceil();
          hdpList.add(HealthDataPoint(
            value,
            dataType,
            unit,
            from,
            to,
            _platformType,
            _deviceId!,
            sourceId,
            sourceName,
          ));
        });
      }
      return hdpList;
    } else {
      return <HealthDataPoint>[];
    }
  }

  /// Given an array of [HealthDataPoint]s, this method will return the array
  /// without any duplicates.
  static List<HealthDataPoint> removeDuplicates(List<HealthDataPoint> points) {
    final unique = <HealthDataPoint>[];

    for (var p in points) {
      var seenBefore = false;
      for (var s in unique) {
        if (s == p) {
          seenBefore = true;
        }
      }
      if (!seenBefore) {
        unique.add(p);
      }
    }
    return unique;
  }

  /// Given an array of [HealthDataPoint]s, this method will return the array
  /// without any duplicates.
  static List<WorkoutDataPoint> removeWorkoutDuplicates(
      List<WorkoutDataPoint> points) {
    final unique = <WorkoutDataPoint>[];

    for (var p in points) {
      var seenBefore = false;
      for (var s in unique) {
        if (s == p) {
          seenBefore = true;
        }
      }
      if (!seenBefore) {
        unique.add(p);
      }
    }
    return unique;
  }
}
