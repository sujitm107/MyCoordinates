//
//  PlacesListScreen.swift
//  Locations
//
//  Created by Sujit Molleti on 7/2/20.
//  Copyright © 2020 Sujit Molleti. All rights reserved.
//

import UIKit
import MapKit

protocol DirectionsDelegate {
    func setDirections(destination: namedCoordinate)
}

class SavedListScreen: UIViewController {
    
    var savedLocations: [namedCoordinate]?
    var directionsDelegate: DirectionsDelegate?
    
    @IBOutlet weak var locationsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved Locations"
        
        //forgot to setup dataSource that's why tableview protocol methods weren't working
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        // Do any additional setup after loading the view.
        
    }
    
}

extension SavedListScreen: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLocations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coordinateCell")!
        
        //why is textLabel an optional?
        cell.textLabel!.text = savedLocations![indexPath.row].name
        return cell
    }
    
    //method of the delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //giving directions to the delegate
        directionsDelegate?.setDirections(destination: savedLocations![indexPath.row]) //we can force unwrap savedLocations because if it was selected, it had to be present
        navigationController?.popViewController(animated: true)
        
    }
    
}
