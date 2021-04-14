//
//  DataService.swift
//  Map_task
//
//  Created by moh on 4/12/21.
//  Copyright © 2021 moh. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Dataservice {
    
    static let instance = Dataservice()
    private let Sourceref = Firestore.firestore().collection("Source")
    private let Driversref = Firestore.firestore().collection("Drivers")
    
   func saveSource(sourceArr: [Source], handler: @escaping(_ status: Bool) ->()) {
        for source in sourceArr {
            Sourceref.addDocument(data: ["name" : source.name, "latitude": source.latitude, "longitude": source.longitude]) { (error) in
            if let error = error {
                print(error.localizedDescription)
                handler(false)
            }
         }
            print("saved")
      }
      handler(true)
    }
   func getSources(handler: @escaping(_ SourcesArr: [Source]) ->()) {
        var SourcesArr = [Source]()
        Sourceref.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            let documents = snapshot?.documents
            for docu in documents! {
                
                let data = docu.data()
                let name = data["name"] as! String
                let latit = data["latitude"] as! Double
                let long = data["longitude"] as! Double
                let source = Source(name: name, latitude: latit, longitude: long)
                SourcesArr.append(source)
                if SourcesArr.count == documents?.count {
                    handler(SourcesArr)
                  }
                }
               
                
            }
            //handler(SourcesArr)
        }
   func saveDrivers(drivers: [Driver], handler: @escaping(_ status: Bool) ->()) {
        
        for driver in drivers {
              Driversref.addDocument(data: ["name" : driver.name, "latitude": driver.latitude, "longitude": driver.longitude]) { (error) in
              if let error = error {
                  print(error.localizedDescription)
                  handler(false)
              }
              print("saved")
           }
        }
        handler(true)
    }
    func getdrivers(handler: @escaping(_ SourcesArr: [Driver]) ->()) {
        var Driversarr = [Driver]()
        Driversref.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            let documents = snapshot?.documents
            for docu in documents! {
                
                let data = docu.data()
                let name = data["name"] as! String
                let latit = data["latitude"] as! Double
                let long = data["longitude"] as! Double
                let driver = Driver(name: name, latitude: latit, longitude: long)
                Driversarr.append(driver)
                if Driversarr.count == documents?.count {
                    handler(Driversarr)
                  }
                }
               
                
            }
        
    }
    func deletedrivers() {
        
        Driversref.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            let documents = snapshot?.documents
            for document in documents! {
                self.Driversref.document(document.documentID).delete { (error) in
                    if let er = error {
                        print(er.localizedDescription)
                    }
                    else {
                        print("deleted all drivers successfully")
                    }
                }
            }
        }
    }
    
    
    
}
