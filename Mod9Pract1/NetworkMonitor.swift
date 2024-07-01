//
//  NetworkMonitor.swift
//  P1Mod8
//
//  Created by Rodrigo Córdoba on 30/06/24.
//

import Foundation
import Network

class NetworkMonitor : ObservableObject{
    let netMonitor = NWPathMonitor()
    let queue = DispatchQueue(label: "networkMonitor")
    
    init(){
        
        netMonitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                print("WiFi")
            }
            
            else{
                print("No Wifi")
            }
        }
        
        netMonitor.start(queue: queue)
    }
}
