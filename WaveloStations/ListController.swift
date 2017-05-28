//
//  ListController.swift
//  WaveloStations
//
//  Created by Iza on 25.05.2017.
//  Copyright © 2017 IB. All rights reserved.
//


struct Station {
    var place: String!
    var stationsCount: String!
    var status: String!
}

import UIKit
import Alamofire

class ListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let reachability = Reachability()!
    var items = [Station]()
    var allItems = [Station]()
    var refresher = UIRefreshControl()

    @IBOutlet var firstBtn: UIButton!
    @IBOutlet var secondBtn: UIButton!
    @IBOutlet var thirdBtn: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    typealias JSONStandard = [String: AnyObject]
    
    var urlAPI: String = "https://zikit.carto.com/api/v2/sql?q=select%20*%20from%20public.propozycje_stacji"
    
    let picDictionary = ["1" : "doMontazu", "2" :  "doWyjasnienia", "4" : "przyszlosc", "3" : "istniejaceStacje"]
    var flag = Bool()
    
    
    @IBAction func sortingByTitle(_ sender: UIButton) {
        items = allItems.sorted { $0.place < $1.place }
        reload()
    }
    
    @IBAction func sotringPositionsUp(_ sender: UIButton) {
        items = allItems.sorted { $0.stationsCount.compare($1.stationsCount, options: .numeric) == .orderedAscending }
        reload()
    }
    
    @IBAction func sortingPositionsDown(_ sender: UIButton) {
        items = allItems.filter { $0.stationsCount != "brak danych"}
        items.sort { $0.stationsCount.compare($1.stationsCount, options: .numeric) == .orderedDescending }
        reload()
    }
    
    
    func settingView(){
        let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        self.flag = true
    }
    
    func reload(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.tableView.contentOffset = .zero
        })
    }
    
    func refresh(){
        items.removeAll()
        allItems.removeAll()
        callAlamo(url: urlAPI)
        tableView.reloadData()
        refresher.endRefreshing()
    }
    
    func internetChanged(note: Notification){
        let reachability = note.object as! Reachability
        if reachability.isReachable{
            DispatchQueue.main.async{
                if self.flag == true{
                    self.firstBtn.backgroundColor = UIColor(red: 82/255, green: 127/255, blue: 232/255, alpha: 1.0)
                    self.secondBtn.backgroundColor = UIColor(red: 129/255, green: 190/255, blue: 57/255, alpha: 1.0)
                    self.thirdBtn.backgroundColor = UIColor(red: 102/255, green: 204/255, blue: 255/255, alpha: 1.0)
                    self.items.removeAll()
                    self.allItems.removeAll()
                    
                }
                self.tableView.reloadData()
                self.callAlamo(url: self.urlAPI)
            }
        }else{
            DispatchQueue.main.async{
                self.firstBtn.backgroundColor = UIColor(red: 82/255, green: 127/255, blue: 232/255, alpha: 0.4)
                self.secondBtn.backgroundColor = UIColor(red: 129/255, green: 190/255, blue: 57/255, alpha: 0.4)
                self.thirdBtn.backgroundColor = UIColor(red: 102/255, green: 204/255, blue: 255/255, alpha: 0.4)
                self.settingView()
                self.flag = true
            }
        }
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
            
            if let rows = readableJSON["rows"] as? [JSONStandard]{
                for row in rows{
                    if let name = row["name"] as? String,
                        let status = row["status"] as? String,
                        !name.isEmpty{
                    
                                if let liczbaStanowisk = row["liczba_stanowisk"] as? String{
                                    items.append(Station.init(place: name, stationsCount: liczbaStanowisk, status: status))
                                }else{
                                    let liczbaStanowisk = "brak danych"
                                    items.append(Station.init(place: name, stationsCount: liczbaStanowisk, status: status))
                                }
                         }
                    }
                    self.allItems = items
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }catch{
            print(error)
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("error")
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
        cell.statusSign.image = UIImage(named: value!)
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
