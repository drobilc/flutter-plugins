import Flutter
import UIKit
import HealthKit

public class SwiftHealthPlugin: NSObject, FlutterPlugin {

    let healthStore = HKHealthStore()
    var healthDataTypes = [HKSampleType]()
    var heartRateEventTypes = Set<HKSampleType>()
    var allDataTypes = Set<HKSampleType>()
    var dataTypesDict: [String: HKSampleType] = [:]
    var commumativedataTypesDict: [String: HKQuantityType] = [:]
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
    let WALKING_RUNNING_DURATION = "WALKING_RUNNING_DURATION"
    let CYCLING_DURATION = "CYCLING_DURATION"
    let SWIMMING_DURATION = "SWIMMING_DURATION"
    // Nutrition health-types
    let DIETARY_ENERGY_CONSUMED = "DIETARY_ENERGY_CONSUMED"
    let DIETARY_FAT_TOTAL = "DIETARY_FAT_TOTAL"
    let DIETARY_FAT_SATURATED = "DIETARY_FAT_SATURATED"
    let DIETARY_CHOLESTEROL = "DIETARY_CHOLESTEROL"
    let DIETARY_CARBOHYDRATES = "DIETARY_CARBOHYDRATES"
    let DIETARY_FIBER = "DIETARY_FIBER"
    let DIETARY_SUGAR = "DIETARY_SUGAR"
    let DIETARY_PROTEIN = "DIETARY_PROTEIN"
    let DIETARY_CALCIUM = "DIETARY_CALCIUM"
    let DIETARY_IRON = "DIETARY_IRON"
    let DIETARY_POTASSIUM = "DIETARY_POTASSIUM"
    let DIETARY_SODIUM = "DIETARY_SODIUM"
    let DIETARY_VITAMIN_A = "DIETARY_VITAMIN_A"
    let DIETARY_VITAMIN_C = "DIETARY_VITAMIN_C"
    let DIETARY_VITAMIN_D = "DIETARY_VITAMIN_D"

    let catagoryTypes = ["STEPS","ACTIVE_ENERGY_BURNED","BASAL_ENERGY_BURNED","DISTANCE_WALKING_RUNNING","FLIGHTS_CLIMBED","DISTANCE_CYCLING","RESTING_HEART_RATE","APPLE_EXERCISE_TIME"]


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

         /// Handle getWorkoutData
        else if (call.method.elementsEqual("getWorkoutData")){
            loadWorkoutData(completion: result)
        }
    }

    func checkIfHealthDataAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(HKHealthStore.isHealthDataAvailable())
    }

    func requestAuthorization(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let types = (arguments?["types"] as? Array) ?? []

        var typesToRequest = Set<HKSampleType>()
        typesToRequest.insert(HKObjectType.workoutType())
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

    func testStatisticsCollectionQueryCumulitive(date: Date,result: @escaping FlutterResult,hunit: HKUnit,datatypekey: String ) {

        //let dataType = dataQuantityTypeLookUp(key: datatypekey)
        
        guard let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to get the body mass type ***")
        }
        
        var interval = DateComponents()
        interval.hour = 24
        
        let calendar = Calendar.current
        let anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)

        let query = HKStatisticsCollectionQuery.init(quantityType: stepCount,
                                                     quantitySamplePredicate: nil,
                                                     options: [.cumulativeSum, .separateBySource],
                                                     anchorDate: date,
                                                     intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            let startDate = date
            var dataList = [[String:Any]]()
            
            results?.enumerateStatistics(from: startDate,
                                         to: Date(), with: { (result, stop) in
                                         dataList.append(
                                             [
                                                "value": result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0,
                                                "date_from": Int(result.startDate.timeIntervalSince1970 * 1000),
                                                "date_to": Int(result.startDate.timeIntervalSince1970 * 1000),
                                                "source_id": "_",
                                                "source_name": "Cumulitive"
                                             ]
                                         )
            })
            result([
                    "vall":dataList
                    ])
            return
        }
        
        
        HKHealthStore().execute(query)
    }



    func getData(call: FlutterMethodCall, result: @escaping FlutterResult ) {
        
        let arguments = call.arguments as? NSDictionary
        let dataTypeKey = (arguments?["dataTypeKey"] as? String) ?? "DEFAULT"
        let startDate = (arguments?["startDate"] as? NSNumber) ?? 0
        let endDate = (arguments?["endDate"] as? NSNumber) ?? 0


        let startDateModified = startDate.doubleValue
        let endDateModified = endDate.doubleValue 

        // Convert dates from milliseconds to Date()
        let dateFrom = Date(timeIntervalSince1970: startDateModified / 1000)
        let dateTo = Date(timeIntervalSince1970: endDateModified / 1000)

        
        
        let dataType = dataTypeLookUp(key: dataTypeKey)
        let predicate = HKQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        if(!catagoryTypes.contains(dataTypeKey)){

        let query = HKSampleQuery(sampleType: dataType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            x, samplesOrNil, error in

            guard let samples = samplesOrNil as? [HKQuantitySample] else {
                guard var samplesCategory = samplesOrNil as? [HKCategorySample] else {
                    result(FlutterError(code: "FlutterHealth", message: "Results are null", details: "\(error)"))
                    return
                }
                if (dataTypeKey == self.SLEEP_IN_BED) {
                    samplesCategory = samplesCategory.filter { $0.value == 0 }
                }
                if (dataTypeKey == self.SLEEP_AWAKE) {
                    samplesCategory = samplesCategory.filter { $0.value == 2 }
                }
                if (dataTypeKey == self.SLEEP_ASLEEP) {
                    samplesCategory = samplesCategory.filter { $0.value == 1 }
                }
                result(samplesCategory.map { sample -> NSDictionary in
                    let unit = self.unitLookUp(key: dataTypeKey)

                    return ["val":[[
                        "uuid": "\(sample.uuid)",
                        "value": sample.value,
                        "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                        "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                        "source_id": sample.sourceRevision.source.bundleIdentifier,
                        "source_name": sample.sourceRevision.source.name
                    ]]]
                })
                return
            }
            result(samples.map { sample -> NSDictionary in
                let unit = self.unitLookUp(key: dataTypeKey)
                let value = sample.quantity.doubleValue(for: unit)

                return ["val":[[
                    "uuid": "\(sample.uuid)",
                    "value": value,
                    "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                    "source_id": sample.sourceRevision.source.bundleIdentifier,
                    "source_name": sample.sourceRevision.source.name
                ]]]
            })
            return
        }
        HKHealthStore().execute(query)
        }
        else{
        
        let date = dateFrom

        let unitType = self.unitLookUp(key: dataTypeKey)

        guard let quantityObj = commumativedataTypesDict[dataTypeKey] else {
            fatalError("*** Unable to get the body mass type ***")
        }
        
        var interval = DateComponents()
        interval.hour = 24
        
        let calendar = Calendar.current
        let anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)

        let query = HKStatisticsCollectionQuery.init(quantityType: quantityObj,
                                                     quantitySamplePredicate: nil,
                                                     options: (dataTypeKey == "HEART_RATE" || dataTypeKey == "RESTING_HEART_RATE") ? [.discreteAverage , .discreteMin ,.discreteMax , .separateBySource] : [.cumulativeSum, .separateBySource],
                                                     anchorDate: date,
                                                     intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            let startDate = date
            var dataList = [[String:Any]]()

            results?.enumerateStatistics(from: startDate,
                                         to: dateTo, with: { (result, stop) in
                                         if(dataTypeKey == "HEART_RATE" || dataTypeKey == "RESTING_HEART_RATE"){
                                           dataList.append(
                                             [  
                                                "uuid": "\(result.averageQuantity()?.doubleValue(for: unitType) ?? 0)-\(Int((result.startDate.timeIntervalSince1970) * 1000))",
                                                "value": result.averageQuantity()?.doubleValue(for: unitType) ?? 0,
                                                "date_from": Int((result.startDate.timeIntervalSince1970) * 1000),
                                                "date_to": Int((result.startDate.timeIntervalSince1970) * 1000),
                                                "source_id": "_",
                                                "source_name": "Cumulitive"
                                             ]
                                         )
                                          }
                                         else{
                                             dataList.append(
                                             [  
                                                "uuid": "\(result.sumQuantity()?.doubleValue(for: unitType) ?? 0)-\(Int((result.startDate.timeIntervalSince1970) * 1000))",
                                                "value": result.sumQuantity()?.doubleValue(for: unitType) ?? 0,
                                                "date_from": Int((result.startDate.timeIntervalSince1970) * 1000),
                                                "date_to": Int((result.startDate.timeIntervalSince1970) * 1000),
                                                "source_id": "_",
                                                "source_name": "Cumulitive"
                                             ]
                                         )
                                         }
            })
            var dataDict:NSDictionary = ["vall":dataList]
            result(dataDict.map { sample -> NSDictionary in
                return [
                    "val":dataList
                ]
            })
            return
        }
        
        
        HKHealthStore().execute(query)
        }
    }

    func getWorkoutData (completion:
                        @escaping FlutterResult , sourcesSet: Set<HKSource>?) {
      
      // Get all workouts that came from all apps.
       let sourcePredicate = HKQuery.predicateForObjects(from: sourcesSet ?? [] );

       let startDate = Calendar.current.date(
         byAdding: .year,
         value: -2,
         to: Date())
       
       let endDate = Calendar.current.date(
        byAdding: .second,
        value: 0,
        to: Date())
       
       let timePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate , options: .strictStartDate)
      
      // Combine the predicates into a single predicate.
      let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
        [ sourcePredicate, timePredicate])
    
      let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    let query = HKSampleQuery(
      sampleType: .workoutType(),
      predicate: compound,
      limit: 0,
      sortDescriptors: [sortDescriptor]) { (query, samples, error) in
        DispatchQueue.main.async {
            
          guard
            let samples = samples as? [HKWorkout],
            error == nil
            else {
              completion(["hai":"\(error)"])
            return
          }
          
            let newMap: [NSDictionary] =  samples.map { sample -> NSDictionary in
                                    return [
                                        "uuid": "\(sample.uuid)",
                                        "total_distance": sample.totalDistance?.doubleValue(for: HKUnit.meterUnit(with: HKMetricPrefix.kilo)) ?? 0.0,
                                        "total_energy_burned": sample.totalEnergyBurned?.doubleValue(for: HKUnit.largeCalorie()) ?? 0.0,
                                        "total_flights_climbed": sample.totalFlightsClimbed?.doubleValue(for: HKUnit.count()) ?? 0,
                                        "total_swimming_stroke_count": sample.totalSwimmingStrokeCount?.doubleValue(for: HKUnit.count()) ?? 0,
                                        "duration": sample.duration, // In seconds
                                        "workout_type": sample.workoutActivityType.commonName,
                                        "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                                        "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                                        "source_id": sample.sourceRevision.source.bundleIdentifier,
                                        "source_name": sample.sourceRevision.source.name,
                                    ]
            }
            
          completion(newMap)
        }
    }
    
    HKHealthStore().execute(query)
  }
  
   func loadWorkoutData(completion:
      @escaping FlutterResult) {
   
      // Query the available source apps to collect workout data from
      let secondquery =  HKSourceQuery.init(sampleType: HKSampleType.workoutType(), samplePredicate: nil) { (query, samples, error) in
          DispatchQueue.main.async {
            //4. Cast the samples as HKWorkout
              let  sourceApps : Set<HKSource>? = samples;
              
              self.getWorkoutData(completion: completion, sourcesSet: sourceApps);
                
          }
      }
      
      HKHealthStore().execute(secondquery)
      
      
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
        unitDict[BODY_MASS_INDEX] = HKUnit.count()
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
        unitDict[APPLE_EXERCISE_TIME] = HKUnit.minute()
        unitDict[APPLE_STAND_HOUR] = HKUnit.init(from: "")
        unitDict[APPLE_STAND_TIME] = HKUnit.minute()
        unitDict[LOW_CARDIO_FITNESS_EVENT] = HKUnit.init(from: "")
        unitDict[VO2_MAX] = HKUnit.init(from: "ml/kg*min")
        unitDict[BODY_MASS] = HKUnit.gramUnit(with: .kilo)
        unitDict[LEAN_BODY_MASS] = HKUnit.gramUnit(with: .kilo)
        unitDict[BASAL_BODY_TEMPERATURE] = HKUnit.degreeCelsius()
        unitDict[CERVICAL_MUCUS_QUALITY] = HKUnit.init(from: "")
        unitDict[SEXUAL_ACTIVITY] = HKUnit.init(from: "")
        unitDict[RESPIRATORY_RATE] = HKUnit.init(from: "count/min")
        unitDict[BLOOD_ALCOHOL_CONTENT] = HKUnit.percent()
        unitDict[SIX_MINUTE_WALK_TEST_DISTANCE] = HKUnit.meter()
        unitDict[WALKING_SPEED] = HKUnit.init(from: "m/s")
        unitDict[WALKING_STEP_LENGTH] = HKUnit.meter()
        unitDict[WALKING_ASYMMETRY_PERCENTAGE] = HKUnit.percent()
        unitDict[WALKING_DOUBLE_SUPPORT_PERCENTAGE] = HKUnit.percent()
        unitDict[STAIR_ASCENT_SPEED] = HKUnit.init(from: "m/s")
        unitDict[STAIR_DESCENT_SPEED] = HKUnit.init(from: "m/s")
        unitDict[HANDWASHING_EVENT] = HKUnit.init(from: "")
        unitDict[UV_EXPOSURE] = HKUnit.count()
        unitDict[HIGH_HEART_RATE_EVENT] = HKUnit.init(from: "")
        unitDict[LOW_HEART_RATE_EVENT] = HKUnit.init(from: "")
        unitDict[IRREGULAR_HEART_RATE_EVENT] = HKUnit.init(from: "")

        // we will change the value of this parameter to minutes in flutter side
        // of the plugin
        unitDict[WALKING_RUNNING_DURATION] = HKUnit.meter()  
        unitDict[CYCLING_DURATION] = HKUnit.meter()
        unitDict[SWIMMING_DURATION] = HKUnit.meter()
        

        // Nutrition health-types
        unitDict[DIETARY_ENERGY_CONSUMED] = HKUnit.kilocalorie()
        unitDict[DIETARY_FAT_TOTAL] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_FAT_SATURATED] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_CHOLESTEROL] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_CARBOHYDRATES] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_FIBER] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_SUGAR] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_PROTEIN] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_CALCIUM] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_IRON] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_POTASSIUM] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_SODIUM] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_VITAMIN_A] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_VITAMIN_C] = HKUnit.gramUnit(with: .kilo)
        unitDict[DIETARY_VITAMIN_D] = HKUnit.gramUnit(with: .kilo)


        // Units for samples that will be added in iOS 15.0
        // unitDict[NUMBER_OF_ALCOHOLIC_BEVERAGES] = HKUnit.count()
        // unitDict[APPLE_WALKING_STEADINESS] = HKUnit.percent()
        // unitDict[APPLE_WALKING_STEADINESS_EVENT] = HKUnit.init(from: "")

        if #available(iOS 8.0, *) {
            dataTypesDict[NIKE_FUEL] = HKSampleType.quantityType(forIdentifier: .nikeFuel)!
            dataTypesDict[BODY_MASS] = HKSampleType.quantityType(forIdentifier: .bodyMass)!
            dataTypesDict[LEAN_BODY_MASS] = HKSampleType.quantityType(forIdentifier: .leanBodyMass)!
            dataTypesDict[RESPIRATORY_RATE] = HKSampleType.quantityType(forIdentifier: .respiratoryRate)!
            dataTypesDict[BLOOD_ALCOHOL_CONTENT] = HKSampleType.quantityType(forIdentifier: .bloodAlcoholContent)!
            dataTypesDict[DIETARY_ENERGY_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
            dataTypesDict[DIETARY_FAT_TOTAL] = HKSampleType.quantityType(forIdentifier: .dietaryFatTotal)!
            dataTypesDict[DIETARY_FAT_SATURATED] = HKSampleType.quantityType(forIdentifier: .dietaryFatSaturated)!
            dataTypesDict[DIETARY_CHOLESTEROL] = HKSampleType.quantityType(forIdentifier: .dietaryCholesterol)!
            dataTypesDict[DIETARY_CARBOHYDRATES] = HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!
            dataTypesDict[DIETARY_FIBER] = HKSampleType.quantityType(forIdentifier: .dietaryFiber)!
            dataTypesDict[DIETARY_SUGAR] = HKSampleType.quantityType(forIdentifier: .dietarySugar)!
            dataTypesDict[DIETARY_PROTEIN] = HKSampleType.quantityType(forIdentifier: .dietaryProtein)!
            dataTypesDict[DIETARY_CALCIUM] = HKSampleType.quantityType(forIdentifier: .dietaryCalcium)!
            dataTypesDict[DIETARY_IRON] = HKSampleType.quantityType(forIdentifier: .dietaryIron)!
            dataTypesDict[DIETARY_POTASSIUM] = HKSampleType.quantityType(forIdentifier: .dietaryPotassium)!
            dataTypesDict[DIETARY_SODIUM] = HKSampleType.quantityType(forIdentifier: .dietarySodium)!
            dataTypesDict[DIETARY_VITAMIN_A] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminA)!
            dataTypesDict[DIETARY_VITAMIN_C] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminC)!
            dataTypesDict[DIETARY_VITAMIN_D] = HKSampleType.quantityType(forIdentifier: .dietaryVitaminD)!
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
            commumativedataTypesDict[APPLE_EXERCISE_TIME] = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) 
        }
        if #available(iOS 10.0, *) {
            dataTypesDict[PUSH_COUNT] = HKSampleType.quantityType(forIdentifier: .pushCount)!
            dataTypesDict[DISTANCE_WHEELCHAIR] = HKSampleType.quantityType(forIdentifier: .distanceWheelchair)!
            dataTypesDict[SWIMMING_STROKE_COUNT] = HKSampleType.quantityType(forIdentifier: .swimmingStrokeCount)!
            dataTypesDict[DISTANCE_SWIMMING] = HKSampleType.quantityType(forIdentifier: .distanceSwimming)!
            dataTypesDict[SWIMMING_DURATION] = HKSampleType.quantityType(forIdentifier: .distanceSwimming)!
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
            //=============================================================================================================
            commumativedataTypesDict[STEPS] = HKObjectType.quantityType(forIdentifier: .stepCount)                                   // cummulative Types
            commumativedataTypesDict[ACTIVE_ENERGY_BURNED] = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
            commumativedataTypesDict[BASAL_ENERGY_BURNED] = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)
            commumativedataTypesDict[DISTANCE_WALKING_RUNNING] = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
            commumativedataTypesDict[FLIGHTS_CLIMBED] = HKObjectType.quantityType(forIdentifier: .flightsClimbed)
            commumativedataTypesDict[DISTANCE_CYCLING] = HKObjectType.quantityType(forIdentifier: .distanceCycling)
            commumativedataTypesDict[HEART_RATE] = HKObjectType.quantityType(forIdentifier: .heartRate)
            commumativedataTypesDict[RESTING_HEART_RATE] = HKObjectType.quantityType(forIdentifier: .restingHeartRate)
            commumativedataTypesDict[HEART_RATE_VARIABILITY_SDNN] = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
            // ==================================================================================================================
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
            dataTypesDict[WALKING_RUNNING_DURATION] = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
            dataTypesDict[CYCLING_DURATION] = HKSampleType.quantityType(forIdentifier: .distanceCycling)!
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

            // Only add units for audio exposure if iOS version is at least 13.0.
            unitDict[ENVIRONMENTAL_AUDIO_EXPOSURE] = HKUnit.decibelAWeightedSoundPressureLevel()
            unitDict[HEADPHONE_AUDIO_EXPOSURE] = HKUnit.decibelAWeightedSoundPressureLevel()
        }
        if #available(iOS 14.0, *) {
            dataTypesDict[STAIR_ASCENT_SPEED] = HKSampleType.quantityType(forIdentifier: .stairAscentSpeed)!
            dataTypesDict[STAIR_DESCENT_SPEED] = HKSampleType.quantityType(forIdentifier: .stairDescentSpeed)!
            dataTypesDict[WALKING_DOUBLE_SUPPORT_PERCENTAGE] = HKSampleType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!
            dataTypesDict[WALKING_ASYMMETRY_PERCENTAGE] = HKSampleType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!
            dataTypesDict[WALKING_STEP_LENGTH] = HKSampleType.quantityType(forIdentifier: .walkingStepLength)!
            dataTypesDict[WALKING_SPEED] = HKSampleType.quantityType(forIdentifier: .walkingSpeed)!
            dataTypesDict[HANDWASHING_EVENT] = HKSampleType.categoryType(forIdentifier: .handwashingEvent)!//here
            dataTypesDict[SIX_MINUTE_WALK_TEST_DISTANCE] = HKSampleType.quantityType(forIdentifier: .sixMinuteWalkTestDistance)!

            //=============================================================================================================
            commumativedataTypesDict[STEPS] = HKObjectType.quantityType(forIdentifier: .stepCount)                                   // cummulative Types
            commumativedataTypesDict[WALKING_STEP_LENGTH] = HKObjectType.quantityType(forIdentifier: .walkingStepLength)
            // ==================================================================================================================
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


extension HKWorkoutActivityType {
    
    /*
     Simple mapping of available workout types to a human readable name.
     */
    var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
        case .badminton:                    return "Badminton"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
        case .climbing:                     return "Climbing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cycling:                      return "Cycling"
        case .dance:                        return "Dance"
        case .danceInspiredTraining:        return "Dance Inspired Training"
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        case .handball:                     return "Handball"
        case .hiking:                       return "Hiking"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .lacrosse:                     return "Lacrosse"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports:                 return "Paddle Sports"
        case .play:                         return "Play"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Rowing"
        case .rugby:                        return "Rugby"
        case .running:                      return "Running"
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swimming"
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .volleyball:                   return "Volleyball"
        case .walking:                      return "Walking"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .yoga:                         return "Yoga"
        
        // iOS 10
        case .barre:                        return "Barre"
        case .coreTraining:                 return "Core Training"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .downhillSkiing:               return "Downhill Skiing"
        case .flexibility:                  return "Flexibility"
        case .highIntensityIntervalTraining:    return "High Intensity Interval Training"
        case .jumpRope:                     return "Jump Rope"
        case .kickboxing:                   return "Kickboxing"
        case .pilates:                      return "Pilates"
        case .snowboarding:                 return "Snowboarding"
        case .stairs:                       return "Stairs"
        case .stepTraining:                 return "Step Training"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"
        
        // iOS 11
        case .taiChi:                       return "Tai Chi"
        case .mixedCardio:                  return "Mixed Cardio"
        case .handCycling:                  return "Hand Cycling"
        
        // iOS 13
        case .discSports:                   return "Disc Sports"
        case .fitnessGaming:                return "Fitness Gaming"
        
        // Catch-all
        default:                            return "Other"
        }
    }
    
    /*
     Additional mapping for common name for activity types where appropriate.
     */
    var commonName: String {
        switch self {
        case .highIntensityIntervalTraining: return "HIIT"
        default: return name
        }
    }
    
    /*
     Mapping of available activity types to emojis, where an appropriate gender-agnostic emoji is available.
     */
    var associatedEmoji: String? {
        switch self {
        case .americanFootball:             return "🏈"
        case .archery:                      return "🏹"
        case .badminton:                    return "🏸"
        case .baseball:                     return "⚾️"
        case .basketball:                   return "🏀"
        case .bowling:                      return "🎳"
        case .boxing:                       return "🥊"
        case .curling:                      return "🥌"
        case .cycling:                      return "🚲"
        case .equestrianSports:             return "🏇"
        case .fencing:                      return "🤺"
        case .fishing:                      return "🎣"
        case .functionalStrengthTraining:   return "💪"
        case .golf:                         return "⛳️"
        case .hiking:                       return "🥾"
        case .hockey:                       return "🏒"
        case .lacrosse:                     return "🥍"
        case .martialArts:                  return "🥋"
        case .mixedMetabolicCardioTraining: return "❤️"
        case .paddleSports:                 return "🛶"
        case .rowing:                       return "🛶"
        case .rugby:                        return "🏉"
        case .sailing:                      return "⛵️"
        case .skatingSports:                return "⛸"
        case .snowSports:                   return "🛷"
        case .soccer:                       return "⚽️"
        case .softball:                     return "🥎"
        case .tableTennis:                  return "🏓"
        case .tennis:                       return "🎾"
        case .traditionalStrengthTraining:  return "🏋️‍♂️"
        case .volleyball:                   return "🏐"
        case .waterFitness, .waterSports:   return "💧"
        
        // iOS 10
        case .barre:                        return "🥿"
        case .crossCountrySkiing:           return "⛷"
        case .downhillSkiing:               return "⛷"
        case .kickboxing:                   return "🥋"
        case .snowboarding:                 return "🏂"
        
        // iOS 11
        case .mixedCardio:                  return "❤️"
        
        // iOS 13
        case .discSports:                   return "🥏"
        case .fitnessGaming:                return "🎮"
        
        // Catch-all
        default:                            return nil
        }
    }
    
    enum EmojiGender {
        case male
        case female
    }
    
    /*
     Mapping of available activity types to appropriate gender specific emojies.
     
     If a gender neutral symbol is available this simply returns the value of `associatedEmoji`.
     */
    func associatedEmoji(for gender: EmojiGender) -> String? {
        switch self {
        case .climbing:
            switch gender {
            case .female:                   return "🧗‍♀️"
            case .male:                     return "🧗🏻‍♂️"
            }
        case .dance, .danceInspiredTraining:
            switch gender {
            case .female:                   return "💃"
            case .male:                     return "🕺🏿"
            }
        case .gymnastics:
            switch gender {
            case .female:                   return "🤸‍♀️"
            case .male:                     return "🤸‍♂️"
            }
        case .handball:
            switch gender {
            case .female:                   return "🤾‍♀️"
            case .male:                     return "🤾‍♂️"
            }
        case .mindAndBody, .yoga, .flexibility:
            switch gender {
            case .female:                   return "🧘‍♀️"
            case .male:                     return "🧘‍♂️"
            }
        case .preparationAndRecovery:
            switch gender {
            case .female:                   return "🙆‍♀️"
            case .male:                     return "🙆‍♂️"
            }
        case .running:
            switch gender {
            case .female:                   return "🏃‍♀️"
            case .male:                     return "🏃‍♂️"
            }
        case .surfingSports:
            switch gender {
            case .female:                   return "🏄‍♀️"
            case .male:                     return "🏄‍♂️"
            }
        case .swimming:
            switch gender {
            case .female:                   return "🏊‍♀️"
            case .male:                     return "🏊‍♂️"
            }
        case .walking:
            switch gender {
            case .female:                   return "🚶‍♀️"
            case .male:                     return "🚶‍♂️"
            }
        case .waterPolo:
            switch gender {
            case .female:                   return "🤽‍♀️"
            case .male:                     return "🤽‍♂️"
            }
        case .wrestling:
            switch gender {
            case .female:                   return "🤼‍♀️"
            case .male:                     return "🤼‍♂️"
            }

        // Catch-all
        default:                            return associatedEmoji
        }
    }
    
}




