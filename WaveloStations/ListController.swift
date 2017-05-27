//
//  ListController.swift
//  WaveloStations
//
//  Created by Iza on 25.05.2017.
//  Copyright © 2017 IB. All rights reserved.
//

//class Station{
//    
//    var place: String!
//    var stationsCount: String!
//    var status: String!
//    
//    init(place: String, stationsCount: String, status: String){
//        self.place = place
//        self.stationsCount = stationsCount
//        self.status = status
//    }
//}


struct Station {
    var place: String!
    var stationsCount: String!
    var status: String!

}


import UIKit
import Alamofire

class ListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    typealias JSONStandard = [String: AnyObject]

    func reload(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.tableView.contentOffset = .zero
            
        })
    }
    
    @IBAction func sortingByTitle(_ sender: UIButton) {
        items.sort { $0.place < $1.place }
        reload()
    }
    
    @IBAction func sotringPositionsUp(_ sender: UIButton) {
        items.sort { $0.stationsCount.compare($1.stationsCount, options: .numeric) == .orderedAscending }
        reload()
    }
    
    @IBAction func sortingPositionsDown(_ sender: UIButton) {
        
        items.sort { $0.stationsCount.compare($1.stationsCount, options: .numeric) == .orderedDescending }
        reload()
    }
    
    
    
    @IBOutlet var tableView: UITableView!
    var items = [Station]()
    var urlAPI: String = "https://zikit.carto.com/api/v2/sql?q=select%20*%20from%20public.propozycje_stacji"
    
    let picDictionary = ["1" : "doMontazu", "2" :  "doWyjasnienia", "4" : "przyszlosc", "3" : "istniejaceStacje"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callAlamo(url: urlAPI)
    }
    
    
    func callAlamo(url: String){
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            self.parseData(JSONData: response.data!)
        })
    }
    
    func parseData(JSONData: Data){
        do{
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
           // print(readableJSON)
            if let rows = readableJSON["rows"] as? [JSONStandard]{
                print(rows)
               // print(readableJSON)
                
                for i in 0..<rows.count{
                let row = rows[i]
                if let name = row["name"] as? String{
                    if name.isEmpty == false{
                    if let status = row["status"] as? String{
                        if let liczbaStanowisk = row["liczba_stanowisk"] as? String{
                            print("status: \(status)")
                            print(name, status, liczbaStanowisk)
                            items.append(Station.init(place: name, stationsCount: liczbaStanowisk, status: status))
                           // print(readableJSON)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }

                        }else{
                            //print(name, status, liczbaStanowisk)
                            print("status: brak danych")
                            let liczbaStanowisk = "brak danych"
                            items.append(Station.init(place: name, stationsCount: liczbaStanowisk, status: status))
                            // print(readableJSON)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }

                        }
                    }
                    
                    }
                }
                    
            }
            }
        }catch{
            print(error)
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
        
        cell.place.text = items[indexPath.row].place
        cell.stationsCount.text = items[indexPath.row].stationsCount
        let num = items[indexPath.row].status
        let value = picDictionary[num!]
        print(num!, value!)
        cell.statusSign.image = UIImage(named: value!)
        
        return cell
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
