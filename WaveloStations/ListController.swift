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
    
    
    func settingView(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 200
        self.view.addSubview(blurEffectView)
        
        var imageView : UIImageView
        //imaheView.contentMode =
        imageView  = UIImageView(frame:CGRect(x:100, y:200, width:100, height:100));
        imageView.image = UIImage(named:"nowifi")
        imageView.contentMode = .center
        imageView.tag = 100
        self.view.addSubview(imageView)
        self.flag = true
        items.removeAll()
        allItems.removeAll()
    }
    
    typealias JSONStandard = [String: AnyObject]

    func reload(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.tableView.contentOffset = .zero
            
        })
    }
    
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
    
    
    
    @IBOutlet var tableView: UITableView!
    var items = [Station]()
    var allItems = [Station]()
    
    var urlAPI: String = "https://zikit.carto.com/api/v2/sql?q=select%20*%20from%20public.propozycje_stacji"
    
    let picDictionary = ["1" : "doMontazu", "2" :  "doWyjasnienia", "4" : "przyszlosc", "3" : "istniejaceStacje"]
    var flag = Bool()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachability.whenReachable = { _ in
            DispatchQueue.main.async{
                if (self.flag == true){
                    if let viewWithTag = self.view.viewWithTag(100) {
                        viewWithTag.removeFromSuperview()
                    }
                    if let viewWithTag = self.view.viewWithTag(200) {
                        viewWithTag.removeFromSuperview()
                    }

                }
                 //self.callAlamo(url: self.urlAPI)
            }
            
        }
        reachability.whenUnreachable = { _ in
            DispatchQueue.main.async{
                    self.settingView()
//                    self.flag = true
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("error")
        }
    }
    
    
    func internetChanged(note: Notification){
        let reachability = note.object as! Reachability
        if reachability.isReachable{
            if flag == true{
                
                    if let viewWithTag = self.view.viewWithTag(100) {
                        viewWithTag.removeFromSuperview()
                    }
                    if let viewWithTag = self.view.viewWithTag(200) {
                        viewWithTag.removeFromSuperview()
                    }
                    
                
                    //self.tableView.reloadData()
            }
            DispatchQueue.main.async{
                self.tableView.reloadData()
                //self.callAlamo(url: self.urlAPI)
            }
            self.callAlamo(url: self.urlAPI)
        }else{
            DispatchQueue.main.async{
                
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
