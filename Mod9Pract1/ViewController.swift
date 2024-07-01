//
//  ViewController.swift
//  P1Mod8
//
//  Created by Rodrigo Córdoba on 28/06/24.
//

import UIKit
import Network
import AVFoundation

class ViewController: UIViewController {
    
    var avPlayer : AVAudioPlayer!
    
    
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var sliderVolume: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var sliderDuration: UISlider!
    var timer:Timer!
    @IBOutlet weak var npLabel: UILabel!
    
    var networkMonitor = NetworkMonitor()
    let audioSource = "http://janzelaznog.com/DDAM/iOS/"
    let audioParam = "imperial-march.mp3"
    

    @IBOutlet weak var connectionTypeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        connectionTypeLabel.text = networkMonitor.connectionType
        avPlayer = AVAudioPlayer()
        print("double sex")
        queryAudio()
        
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Do something
    }
    
    func queryAudio(){
        if networkMonitor.isReachable{
            let audioURL = audioSource + audioParam
            if let url = URL(string: audioURL){
                let libraryDirectoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
                let fileDestinationURL = libraryDirectoryURL.appendingPathComponent(url.lastPathComponent)
                print(fileDestinationURL)
                
                
                if FileManager.default.fileExists(atPath: fileDestinationURL.path){
                    print("File exists")
                }
                else{
                    print("No file found")
                    URLSession.shared.downloadTask(with: url){location, response, error in
                        guard let location = location, error == nil else {return}
                        do{
                            try FileManager.default.moveItem(at: location, to: fileDestinationURL)
                            print("File moved to Library folder")
                            
                        } 
                        catch{
                            print("error")
                        }
                    }.resume()
                }
                
                do{
                    avPlayer = try AVAudioPlayer(contentsOf: fileDestinationURL)
                    sliderVolume.value = avPlayer.volume
                    sliderDuration.maximumValue = Float(avPlayer.duration)
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {tmr in self.sliderDuration.value = Float(self.avPlayer.currentTime)})
                    //avPlayer.play()
                    
                }
                catch{
                    print("Error occurred when playing Audio stream")
                }
            }
        }
    }
    
    @IBAction func btnPlayTouch(_ sender: Any) {
        avPlayer.play()
    }
    
    @IBAction func btnStopTouch(_ sender: Any) {
        avPlayer.stop()
    }
    
    @IBAction func sliderVolumeChanged(_ sender: UISlider) {
        avPlayer.volume = sliderVolume.value
    }
    
    @IBAction func sliderDurationChanged(_ sender: Any) {
        avPlayer.currentTime = TimeInterval(sliderDuration.value)
    }
    
}

