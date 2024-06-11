//
//  NetworkManager.swift
//  SpeedTest
//
//  Created by admin on 5/23/24.
//

/*
 {
   "type": "outages.summary",
   "metadata": {
     "requestTime": "2024-05-23T21:42:37+00:00",
     "responseTime": "2024-05-23T21:42:37+00:00"
   },
   "requestParameters": {
     "from": "1615497553",
     "until": "1716497553",
     "limit": 2000,
     "page": null,
     "relatedTo": null,
     "entityType": "county",
     "entityCode": "2159",
     "orderBy": null,
     "ignoreMethods": null
   },
   "error": null,
   "perf": null,
   "data": [
     {
       "scores": {
         "merit-nt.median": 5781323.941934165,
         "bgp.sarima": 463096.7519192687,
         "bgp.median": 637108.3001328021,
         "ping-slash24.sarima": 1818.4438040345822,
         "ping-slash24.median": 1282881.6435257462,
         "overall": 650945358117973.4
       },
       "event_cnt": 11,
       "entity": {
         "code": "2159",
         "name": "Santa Clara",
         "type": "county",
         "attrs": {
           "fqid": "geo.netacuity.NA.US.4416.2159",
           "region_code": "4416",
           "region_name": "California",
           "country_code": "US",
           "country_name": "United States"
         }
       }
     }
   ],
   "copyright": "This data is Copyright (c) 2021-2024 Georgia Tech Research Corporation. All Rights Reserved."
 }
 */

import Foundation
import CoreLocation

struct OutageSummary: Codable {
    var type: String?
    var metadata: MetaData?
    var requestParameters: RequestParameters?
    var error: String?
    var perf: String?
    var data: Array<SummaryData?>?
    
    enum CodingKeys: String, CodingKey {
        case type
        case metadata
        case requestParameters
        case error
        case perf
        case data
    }
}

struct SummaryData: Codable {
    var scores: Scores?
    var eventCnt: Int?
}

struct Scores: Codable {
    var meritNtMedian: Double?
    var bgpSarima: Double?
    var bgpMedian: Double?
    var pingSlash24Sarima: Double?
    var pingSlash24Median: Double?
    var overall: Double?
    
    enum CodingKeys: String, CodingKey {
        case meritNtMedian = "merit-nt.median"
        case bgpSarima = "bgp.sarima"
        case bgpMedian = "bgp.median"
        case pingSlash24Sarima = "ping-slash24.sarima"
        case pingSlash24Median = "ping-slash24.median"
        case overall
    }
}

struct RequestParameters: Codable {
    var from: String?
    var until: String?
    var limit: Int?
    var page:  Int?
    var relatedTo: String?
    var entityType:  String?
    var entityCode:  String?
    var orderBy:  String?
    var ignoreMethods:  String?
}

struct MetaData: Codable {
    var requestTime: String?
    var responseTime: String?
}

enum EntityType: String {
    case asn
    case county
    case country
    case region
    case continent
}

struct EntityData: Codable {
    var code: String?
    var name: String?
    var type: String?
}

struct EntitiesLookup: Codable {
    var data: [EntityData]?
}

class NetworkManager {
    // Shared instance for singleton pattern
    static let shared = NetworkManager()
    let geocoder = CLGeocoder()
    
    
    // Private initializer for singleton pattern
    private init() {}
    
    var baseUrlString = "https://api.ioda.inetintel.cc.gatech.edu/v2"
    
    // Make GET request
    func getRequest(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            completionHandler(data, response, error)
        }
        task.resume()
    }
    
    func parseJSON<T: Codable>(data: Data, forType type: T.Type, completion: (T?) -> Void) -> Void {
        let decoder = JSONDecoder()
        do {
            let responseData = try decoder.decode(type.self, from: data)
            completion(responseData)
        } catch {
            completion(nil)
        }
    }
    
    func getCountyFromCoordinates(location: CLLocation, completion: @escaping (String?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let e = error {
                print("Error while trying to find county from location: \(e)")
                completion(nil)
            }
            if let placemark = placemarks?.first {
                let county = self.removeCountyFromString(placemark.subAdministrativeArea)
                completion(county)
            } else {
                print("No county available based on provided info")
                completion(nil)
            }
        }
    }
    
    func removeCountyFromString(_ county: String?) -> String {
        guard let county = county else {return ""}
        var countyArr = county.components(separatedBy: " ")
        if !countyArr.isEmpty {
            countyArr.removeLast()
        }
        let countyName = countyArr.joined(separator: " ")
        return countyName
    }
    
    func getEntityCode(searchString: String, entityType: EntityType, completion: @escaping (String?) -> Void) -> Void {
        guard let url = URL(string: baseUrlString + "/entities/query?" + "entityType=\(entityType)" + "&" + "search=\(searchString)") else {
            completion(nil)
            return
        }
        print(url.absoluteString)
        var entityCode = ""
        getRequest(url: url) { (data, response, error) in
            print((response as! HTTPURLResponse).statusCode)
            if let e = error {
                print("Request error: \(e)")
                return
            } else {
                guard let d = data else { return }
                self.parseJSON(data: d, forType: EntitiesLookup.self) { entityLookup in
                    if let data = entityLookup?.data {
                        guard let code = data.first?.code else { return }
                        entityCode = code
                        completion(entityCode)
                    }
                    else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func getOutageScoreForEntity(searchString: String, entityType: EntityType, from: String, until: String, completion: @escaping (Scores?) -> Void) -> Void{
        getEntityCode(searchString: searchString, entityType: entityType, completion: { code in
            guard let receivedCode = code else { return }
            guard let url = URL(string: self.baseUrlString + "/outages/summary?" + "entityType=\(entityType)" + "&" + "entityCode=\(receivedCode)" + "&" + "from=\(from)" + "&" + "until=\(until)") else {
                completion(nil)
                return
            }
            print(url.absoluteString)
            self.getRequest(url: url) { (data, response, error) in
                print((response as! HTTPURLResponse).statusCode)
                if let e = error {
                    print("Request error: \(e)")
                    return
                } else {
                    guard let d = data else { return }
                    self.parseJSON(data: d, forType: OutageSummary.self) { outageSummary in
                        if let summary = outageSummary {
                            guard let summaryData = summary.data?.first else { return }
                            guard let scores = summaryData?.scores else { return }
                            completion(scores)
                        }
                        else {
                            completion(nil)
                        }
                    }
                }
            }
        })
    }
}
