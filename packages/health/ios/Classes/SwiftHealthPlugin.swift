import Flutter
import UIKit
import HealthKit

public class SwiftHealthPlugin: NSObject, FlutterPlugin {

    let healthStore = HKHealthStore()
    var healthDataTypes = [HKSampleType]()
    var heartRateEventTypes = Set<HKSampleType>()
    var allDataTypes = Set<HKSampleType>()
    var dataTypesDict: [String: HKSampleType] = [:]
    var unitDict: [String: HKUnit] = [:]

    // Health Data Type Keys
    let ACTIVE_ENERGY_BURNED = "ACTIVE_ENERGY_BURNED"
    let BASAL_ENERGY_BURNED = "BASAL_ENERGY_BURNED"
    let BLOOD_GLUCOSE = "BLOOD_GLUCOSE"
    let BLOOD_OXYGEN = "BLOOD_OXYGEN"
    let BLOOD_PRESSURE_DIASTOLIC = "BLOOD_PRESSURE_DIASTOLIC"
    let BLOOD_PRESSURE_SYSTOLIC = "BLOOD_PRESSURE_SYSTOLIC"
    let BODY_FAT_PERCENTAGE = "BODY_FAT_PERCENTAGE"
    let BODY_MASS_INDEX = "BODY_MASS_INDEX"
    let BODY_TEMPERATURE = "BODY_TEMPERATURE"
    let ELECTRODERMAL_ACTIVITY = "ELECTRODERMAL_ACTIVITY"
    let HEART_RATE = "HEART_RATE"
    let HEART_RATE_VARIABILITY_SDNN = "HEART_RATE_VARIABILITY_SDNN"
    let HEIGHT = "HEIGHT"
    let HIGH_HEART_RATE_EVENT = "HIGH_HEART_RATE_EVENT"
    let IRREGULAR_HEART_RATE_EVENT = "IRREGULAR_HEART_RATE_EVENT"
    let LOW_HEART_RATE_EVENT = "LOW_HEART_RATE_EVENT"
    let RESTING_HEART_RATE = "RESTING_HEART_RATE"
    let STEPS = "STEPS"
    let WAIST_CIRCUMFERENCE = "WAIST_CIRCUMFERENCE"
    let WALKING_HEART_RATE = "WALKING_HEART_RATE"
    let WEIGHT = "WEIGHT"
    let DISTANCE_WALKING_RUNNING = "DISTANCE_WALKING_RUNNING"
    let FLIGHTS_CLIMBED = "FLIGHTS_CLIMBED"
    let WATER = "WATER"
    let MINDFULNESS = "MINDFULNESS"
    let SLEEP_IN_BED = "SLEEP_IN_BED"
    let SLEEP_ASLEEP = "SLEEP_ASLEEP"
    let SLEEP_AWAKE = "SLEEP_AWAKE"
    let DISTANCE_CYCLING = "DISTANCE_CYCLING"
    let PUSH_COUNT = "PUSH_COUNT"
    let DISTANCE_WHEELCHAIR = "DISTANCE_WHEELCHAIR"
    let SWIMMING_STROKE_COUNT = "SWIMMING_STROKE_COUNT"
    let DISTANCE_SWIMMING = "DISTANCE_SWIMMING"
    let DISTANCE_DOWNGHILL_SNOW_SPORTS = "DISTANCE_DOWNGHILL_SNOW_SPORTS"
    let NIKE_FUEL = "NIKE_FUEL"
    let APPLE_EXERCISE_TIME = "APPLE_EXERCISE_TIME"
    let APPLE_STAND_HOUR = "APPLE_STAND_HOUR"
    let APPLE_STAND_TIME = "APPLE_STAND_TIME"
    let LOW_CARDIO_FITNESS_EVENT = "LOW_CARDIO_FITNESS_EVENT"
    let BODY_MASS = "BODY_MASS"
    let LEAN_BODY_MASS = "LEAN_BODY_MASS"
    let BASAL_BODY_TEMPERATURE = "BASAL_BODY_TEMPERATURE"
    let CERVICAL_MUCUS_QUALITY = "CERVICAL_MUCUS_QUALITY"
    let SEXUAL_ACTIVITY = "SEXUAL_ACTIVITY"
    let ENVIRONMENTAL_AUDIO_EXPOSURE = "ENVIRONMENTAL_AUDIO_EXPOSURE"
    let HEADPHONE_AUDIO_EXPOSURE = "HEADPHONE_AUDIO_EXPOSURE"
    let RESPIRATORY_RATE = "RESPIRATORY_RATE"
    let BLOOD_ALCOHOL_CONTENT = "BLOOD_ALCOHOL_CONTENT"
    let NUMBER_OF_ALCOHOLIC_BEVERAGES = "NUMBER_OF_ALCOHOLIC_BEVERAGES"
    let APPLE_WALKING_STEADINESS = "APPLE_WALKING_STEADINESS"
    let APPLE_WALKING_STEADINESS_EVENT = "APPLE_WALKING_STEADINESS_EVENT"
    let SIX_MINUTE_WALK_TEST_DISTANCE = "SIX_MINUTE_WALK_TEST_DISTANCE"
    let WALKING_SPEED = "WALKING_SPEED"
    let WALKING_STEP_LENGTH = "WALKING_STEP_LENGTH"
    let WALKING_ASYMMETRY_PERCENTAGE = "WALKING_ASYMMETRY_PERCENTAGE"
    let WALKING_DOUBLE_SUPPORT_PERCENTAGE = "WALKING_DOUBLE_SUPPORT_PERCENTAGE"
    let STAIR_ASCENT_SPEED = "STAIR_ASCENT_SPEED"
    let STAIR_DESCENT_SPEED = "STAIR_DESCENT_SPEED"
    let HANDWASHING_EVENT = "HANDWASHING_EVENT"
    let UV_EXPOSURE = "UV_EXPOSURE"
    let VO2_MAX = "VO2_MAX"


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_health", binaryMessenger: registrar.messenger())
        let instance = SwiftHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Set up all data types
        initializeTypes()

        /// Handle checkIfHealthDataAvailable
        if (call.method.elementsEqual("checkIfHealthDataAvailable")){
            checkIfHealthDataAvailable(call: call, result: result)
        }
        /// Handle requestAuthorization
        else if (call.method.elementsEqual("requestAuthorization")){
            requestAuthorization(call: call, result: result)
        }

        /// Handle getData
        else if (call.method.elementsEqual("getData")){
            getData(call: call, result: result)
        }
    }

    func checkIfHealthDataAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(HKHealthStore.isHealthDataAvailable())
    }

    func requestAuthorization(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let types = (arguments?["types"] as? Array) ?? []

        var typesToRequest = Set<HKSampleType>()

        for key in types {
            let keyString = "\(key)"
            typesToRequest.insert(dataTypeLookUp(key: keyString))
        }

        if #available(iOS 11.0, *) {
            healthStore.requestAuthorization(toShare: nil, read: typesToRequest) { (success, error) in
                result(success)
            }
        } 
        else {
            result(false)// Handle the error here.
        }
    }

    func getData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let dataTypeKey = (arguments?["dataTypeKey"] as? String) ?? "DEFAULT"
        let startDate = (arguments?["startDate"] as? NSNumber) ?? 0
        let endDate = (arguments?["endDate"] as? NSNumber) ?? 0

        // Convert dates from milliseconds to Date()
        let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)

        let dataType = dataTypeLookUp(key: dataTypeKey)
        let predicate = HKQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)

        let query = HKSampleQuery(sampleType: dataType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            x, samplesOrNil, error in

            guard let samples = samplesOrNil as? [HKQuantitySample] else {
                guard let samplesCategory = samplesOrNil as? [HKCategorySample] else {
                    result(FlutterError(code: "FlutterHealth", message: "Results are null", details: "\(error)"))
                    return
                }
                result(samplesCategory.map { sample -> NSDictionary in
                    let unit = self.unitLookUp(key: dataTypeKey)

                    return [
                        "uuid": "\(sample.uuid)",
                        "value": sample.value,
                        "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                        "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                        "source_id": sample.sourceRevision.source.bundleIdentifier,
                        "source_name": sample.sourceRevision.source.name
                    ]
                })
                return
            }
            result(samples.map { sample -> NSDictionary in
                let unit = self.unitLookUp(key: dataTypeKey)
                var value = -404.0
                
                do {
                    value = sample.quantity.doubleValue(for: unit)
                } catch {
                    print("Could not convert value for unit \(unit)")
                }

                return [
                    "uuid": "\(sample.uuid)",
                    "value": value,
                    "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                    "source_id": sample.sourceRevision.source.bundleIdentifier,
                    "source_name": sample.sourceRevision.source.name
                ]
            })
            return
        }
        HKHealthStore().execute(query)
    }

    func unitLookUp(key: String) -> HKUnit {
        guard let unit = unitDict[key] else {
            return HKUnit.count()
        }
        return unit
    }

    func dataTypeLookUp(key: String) -> HKSampleType {
        guard let dataType_ = dataTypesDict[key] else {
            return HKSampleType.quantityType(forIdentifier: .bodyMass)!
        }
        return dataType_
    }

    func initializeTypes() {
        unitDict[ACTIVE_ENERGY_BURNED] = HKUnit.kilocalorie()
        unitDict[BASAL_ENERGY_BURNED] = HKUnit.kilocalorie()
        unitDict[BLOOD_GLUCOSE] = HKUnit.init(from: "mg/dl")
        unitDict[BLOOD_OXYGEN] = HKUnit.percent()
        unitDict[BLOOD_PRESSURE_DIASTOLIC] = HKUnit.millimeterOfMercury()
        unitDict[BLOOD_PRESSURE_SYSTOLIC] = HKUnit.millimeterOfMercury()
        unitDict[BODY_FAT_PERCENTAGE] = HKUnit.percent()
        unitDict[BODY_MASS_INDEX] = HKUnit.init(from: "")
        unitDict[BODY_TEMPERATURE] = HKUnit.degreeCelsius()
        unitDict[ELECTRODERMAL_ACTIVITY] = HKUnit.siemen()
        unitDict[HEART_RATE] = HKUnit.init(from: "count/min")
        unitDict[HEART_RATE_VARIABILITY_SDNN] = HKUnit.secondUnit(with: .milli)
        unitDict[HEIGHT] = HKUnit.meter()
        unitDict[RESTING_HEART_RATE] = HKUnit.init(from: "count/min")
        unitDict[STEPS] = HKUnit.count()
        unitDict[WAIST_CIRCUMFERENCE] = HKUnit.meter()
        unitDict[WALKING_HEART_RATE] = HKUnit.init(from: "count/min")
        unitDict[WEIGHT] = HKUnit.gramUnit(with: .kilo)
        unitDict[DISTANCE_WALKING_RUNNING] = HKUnit.meter()
        unitDict[FLIGHTS_CLIMBED] = HKUnit.count()
        unitDict[WATER] = HKUnit.liter()
        unitDict[MINDFULNESS] = HKUnit.init(from: "")
        unitDict[SLEEP_IN_BED] = HKUnit.init(from: "")
        unitDict[SLEEP_ASLEEP] = HKUnit.init(from: "")
        unitDict[SLEEP_AWAKE] = HKUnit.init(from: "")
        unitDict[DISTANCE_CYCLING] = HKUnit.meter()
        unitDict[PUSH_COUNT] = HKUnit.count()
        unitDict[DISTANCE_WHEELCHAIR] = HKUnit.meter()
        unitDict[SWIMMING_STROKE_COUNT] = HKUnit.count()
        unitDict[DISTANCE_SWIMMING] = HKUnit.meter()
        unitDict[DISTANCE_DOWNGHILL_SNOW_SPORTS] = HKUnit.meter()
        unitDict[NIKE_FUEL] = HKUnit.count()
        unitDict[APPLE_EXERCISE_TIME] = HKUnit.init(from: "")
        unitDict[APPLE_STAND_HOUR] = HKUnit.init(from: "")
        unitDict[APPLE_STAND_TIME] = HKUnit.init(from: "")
        unitDict[LOW_CARDIO_FITNESS_EVENT] = HKUnit.init(from: "")
        unitDict[VO2_MAX] = HKUnit.init(from: "")
        unitDict[BODY_MASS] = HKUnit.gramUnit(with: .kilo)
        unitDict[LEAN_BODY_MASS] = HKUnit.gramUnit(with: .kilo)
        unitDict[BASAL_BODY_TEMPERATURE] = HKUnit.degreeCelsius()
        unitDict[CERVICAL_MUCUS_QUALITY] = HKUnit.init(from: "")
        unitDict[SEXUAL_ACTIVITY] = HKUnit.init(from: "")
        unitDict[ENVIRONMENTAL_AUDIO_EXPOSURE] = HKUnit.decibelAWeightedSoundPressureLevel()
        unitDict[HEADPHONE_AUDIO_EXPOSURE] = HKUnit.decibelAWeightedSoundPressureLevel()
        unitDict[RESPIRATORY_RATE] = HKUnit.init(from: "count/min")
        unitDict[BLOOD_ALCOHOL_CONTENT] = HKUnit.percent()
        unitDict[NUMBER_OF_ALCOHOLIC_BEVERAGES] = HKUnit.percent()
        unitDict[BLOOD_ALCOHOL_CONTENT] = HKUnit.percent()
        unitDict[NUMBER_OF_ALCOHOLIC_BEVERAGES] = HKUnit.count()
        unitDict[APPLE_WALKING_STEADINESS] = HKUnit.percent()
        unitDict[APPLE_WALKING_STEADINESS_EVENT] = HKUnit.init(from: "")
        unitDict[SIX_MINUTE_WALK_TEST_DISTANCE] = HKUnit.meter()
        unitDict[WALKING_SPEED] = HKUnit.init(from: "")
        unitDict[WALKING_STEP_LENGTH] = HKUnit.meter()
        unitDict[WALKING_ASYMMETRY_PERCENTAGE] = HKUnit.percent()
        unitDict[WALKING_DOUBLE_SUPPORT_PERCENTAGE] = HKUnit.percent()
        unitDict[STAIR_ASCENT_SPEED] = HKUnit.init(from: "")
        unitDict[STAIR_DESCENT_SPEED] = HKUnit.init(from: "")
        unitDict[HANDWASHING_EVENT] = HKUnit.init(from: "")
        unitDict[UV_EXPOSURE] = HKUnit.count()

        if #available(iOS 8.0, *) {
            dataTypesDict[NIKE_FUEL] = HKSampleType.quantityType(forIdentifier: .nikeFuel)!
            dataTypesDict[BODY_MASS] = HKSampleType.quantityType(forIdentifier: .bodyMass)!
            dataTypesDict[LEAN_BODY_MASS] = HKSampleType.quantityType(forIdentifier: .leanBodyMass)!
            dataTypesDict[RESPIRATORY_RATE] = HKSampleType.quantityType(forIdentifier: .respiratoryRate)!
            dataTypesDict[BLOOD_ALCOHOL_CONTENT] = HKSampleType.quantityType(forIdentifier: .bloodAlcoholContent)!
        }
        if #available(iOS 9.0, *) {
            dataTypesDict[UV_EXPOSURE] = HKSampleType.quantityType(forIdentifier: .uvExposure)!
            dataTypesDict[BASAL_BODY_TEMPERATURE] = HKSampleType.quantityType(forIdentifier: .basalBodyTemperature)!
            dataTypesDict[APPLE_STAND_HOUR] = HKSampleType.categoryType(forIdentifier: .appleStandHour)!
            dataTypesDict[CERVICAL_MUCUS_QUALITY] = HKSampleType.categoryType(forIdentifier: .cervicalMucusQuality)!
            dataTypesDict[SEXUAL_ACTIVITY] = HKSampleType.categoryType(forIdentifier: .sexualActivity)!
        }
        if #available(iOS 9.3, *) {
            dataTypesDict[APPLE_EXERCISE_TIME] = HKSampleType.quantityType(forIdentifier: .appleExerciseTime)!
        }
        if #available(iOS 10.0, *) {
            dataTypesDict[PUSH_COUNT] = HKSampleType.quantityType(forIdentifier: .pushCount)!
            dataTypesDict[DISTANCE_WHEELCHAIR] = HKSampleType.quantityType(forIdentifier: .distanceWheelchair)!
            dataTypesDict[SWIMMING_STROKE_COUNT] = HKSampleType.quantityType(forIdentifier: .swimmingStrokeCount)!
            dataTypesDict[DISTANCE_SWIMMING] = HKSampleType.quantityType(forIdentifier: .distanceSwimming)!
        }
        if #available(iOS 11.0, *) {
            dataTypesDict[ACTIVE_ENERGY_BURNED] = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!
            dataTypesDict[BASAL_ENERGY_BURNED] = HKSampleType.quantityType(forIdentifier: .basalEnergyBurned)!
            dataTypesDict[BLOOD_GLUCOSE] = HKSampleType.quantityType(forIdentifier: .bloodGlucose)!
            dataTypesDict[BLOOD_OXYGEN] = HKSampleType.quantityType(forIdentifier: .oxygenSaturation)!
            dataTypesDict[BLOOD_PRESSURE_DIASTOLIC] = HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)!
            dataTypesDict[BLOOD_PRESSURE_SYSTOLIC] = HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)!
            dataTypesDict[BODY_FAT_PERCENTAGE] = HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!
            dataTypesDict[BODY_MASS_INDEX] = HKSampleType.quantityType(forIdentifier: .bodyMassIndex)!
            dataTypesDict[BODY_TEMPERATURE] = HKSampleType.quantityType(forIdentifier: .bodyTemperature)!
            dataTypesDict[ELECTRODERMAL_ACTIVITY] = HKSampleType.quantityType(forIdentifier: .electrodermalActivity)!
            dataTypesDict[HEART_RATE] = HKSampleType.quantityType(forIdentifier: .heartRate)!
            dataTypesDict[HEART_RATE_VARIABILITY_SDNN] = HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
            dataTypesDict[HEIGHT] = HKSampleType.quantityType(forIdentifier: .height)!
            dataTypesDict[RESTING_HEART_RATE] = HKSampleType.quantityType(forIdentifier: .restingHeartRate)!
            dataTypesDict[STEPS] = HKSampleType.quantityType(forIdentifier: .stepCount)!
            dataTypesDict[WAIST_CIRCUMFERENCE] = HKSampleType.quantityType(forIdentifier: .waistCircumference)!
            dataTypesDict[WALKING_HEART_RATE] = HKSampleType.quantityType(forIdentifier: .walkingHeartRateAverage)!
            dataTypesDict[WEIGHT] = HKSampleType.quantityType(forIdentifier: .bodyMass)!
            dataTypesDict[DISTANCE_WALKING_RUNNING] = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
            dataTypesDict[FLIGHTS_CLIMBED] = HKSampleType.quantityType(forIdentifier: .flightsClimbed)!
            dataTypesDict[WATER] = HKSampleType.quantityType(forIdentifier: .dietaryWater)!
            dataTypesDict[MINDFULNESS] = HKSampleType.categoryType(forIdentifier: .mindfulSession)!
            dataTypesDict[SLEEP_IN_BED] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_ASLEEP] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_AWAKE] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[DISTANCE_CYCLING] = HKSampleType.quantityType(forIdentifier: .distanceCycling)!
            dataTypesDict[VO2_MAX] = HKSampleType.quantityType(forIdentifier: .vo2Max)!
        }
        if #available(iOS 11.2, *) {
            dataTypesDict[DISTANCE_DOWNGHILL_SNOW_SPORTS] = HKSampleType.quantityType(forIdentifier: .distanceDownhillSnowSports)!
        }
        // Set up heart rate data types specific to the apple watch, requires iOS 12
        if #available(iOS 12.2, *) {
            dataTypesDict[HIGH_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!
            dataTypesDict[LOW_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!
            dataTypesDict[IRREGULAR_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!

            heartRateEventTypes =  Set([
                HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!,
                HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!,
                HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!,
                ])
        }
        if #available(iOS 13.0, *) {
            dataTypesDict[APPLE_STAND_TIME] = HKSampleType.quantityType(forIdentifier: .appleStandTime)!
            dataTypesDict[HEADPHONE_AUDIO_EXPOSURE] = HKSampleType.quantityType(forIdentifier: .headphoneAudioExposure)!
            dataTypesDict[ENVIRONMENTAL_AUDIO_EXPOSURE] = HKSampleType.quantityType(forIdentifier: .environmentalAudioExposure)!
        }
        if #available(iOS 14.0, *) {
            dataTypesDict[STAIR_ASCENT_SPEED] = HKSampleType.quantityType(forIdentifier: .stairAscentSpeed)!
            dataTypesDict[STAIR_DESCENT_SPEED] = HKSampleType.quantityType(forIdentifier: .stairDescentSpeed)!
            dataTypesDict[WALKING_DOUBLE_SUPPORT_PERCENTAGE] = HKSampleType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!
            dataTypesDict[WALKING_ASYMMETRY_PERCENTAGE] = HKSampleType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!
            dataTypesDict[WALKING_STEP_LENGTH] = HKSampleType.quantityType(forIdentifier: .walkingStepLength)!
            dataTypesDict[WALKING_SPEED] = HKSampleType.quantityType(forIdentifier: .walkingSpeed)!
            dataTypesDict[HANDWASHING_EVENT] = HKSampleType.categoryType(forIdentifier: .handwashingEvent)!
            dataTypesDict[SIX_MINUTE_WALK_TEST_DISTANCE] = HKSampleType.quantityType(forIdentifier: .sixMinuteWalkTestDistance)!
        }
        if #available(iOS 14.3, *) {
            dataTypesDict[LOW_CARDIO_FITNESS_EVENT] = HKSampleType.categoryType(forIdentifier: .lowCardioFitnessEvent)!
        }
        // Upcoming data types for iOS 15+
        /*if #available(iOS 15.0, *) {
            dataTypesDict[NUMBER_OF_ALCOHOLIC_BEVERAGES] = HKSampleType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!
            dataTypesDict[APPLE_WALKING_STEADINESS] = HKSampleType.quantityType(forIdentifier: .appleWalkingSteadiness)!
            dataTypesDict[APPLE_WALKING_STEADINESS_EVENT] = HKSampleType.categoryType(forIdentifier: .appleWalkingSteadinessEvent)!
        }*/

        healthDataTypes = Array(dataTypesDict.values)

        // Concatenate heart events and health data types (both may be empty)
        allDataTypes = Set(heartRateEventTypes + healthDataTypes)
    }
}




