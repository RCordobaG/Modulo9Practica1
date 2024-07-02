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
    
    var audioURL : URL!
    var fileFound : Bool = false
    
    var libraryDirectoryURL : URL!
    var fileDestinationURL: URL!
    
    var isPlaying : Bool!
    

    @IBOutlet weak var connectionTypeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        avPlayer = AVAudioPlayer()
        isPlaying = false
        // Do any additional setup after loading the view.
        connectionTypeLabel.text = networkMonitor.connectionType
        audioURL = URL(string: (audioSource + audioParam))
        libraryDirectoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        fileDestinationURL = libraryDirectoryURL?.appendingPathComponent(audioURL.lastPathComponent)
        
        print(fileDestinationURL!)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FileManager.default.fileExists(atPath: fileDestinationURL.path){
            print("File exists")
            displayAlert(title: "File exists", message: "The required found is already on the Library folder", button: "Understood")
            self.fileFound = true
            playAudio(file: fileFound)
        }
        else{
            print("File not found")
            displayAlert(title: "File not found", message: "This app will now download an mp3 file over the network if connected through WiFi", button: "Understood")
            self.fileFound = false
            
            if(networkMonitor.connectionType == "WiFi"){
                queryAudio()
                while(!self.fileFound){
                    
                }
                displayAlert(title: "File downloaded", message: "File has been downloaded", button: "Understood")
            }
            
            else if (networkMonitor.connectionType == "Cellular"){
                displayAlert(title: "No WiFi", message: "You are connected using cellular. This may incur in charges. Please switch to WiFi", button: "Understood")
            }
            
            else{
                displayAlert(title: "No Internet", message: "Can not reach the internet", button: "Understood")
            }
            
            playAudio(file: fileFound)
        }
    }
    
    func queryAudio(){
        if networkMonitor.isReachable{
            URLSession.shared.downloadTask(with: audioURL){location, response, error in
                guard let location = location, error == nil else {return}
                do{
                    try FileManager.default.moveItem(at: location, to: self.fileDestinationURL)
                    print("File moved to Library folder")
                    self.fileFound = true
                }
                catch{
                    print("Error downloading the file")
                    self.fileFound = false
                }
            }.resume()
        }
        
        else{
            print("Network is unreachable")
        }
    }
    
    func playAudio(file : Bool){
        if file{
            do{
                print("File: ")
                print(fileFound)
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
    
    @IBAction func btnPlayTouch(_ sender: Any) {
        if fileFound{
            if avPlayer == nil{
                
            }
            else{
                if !isPlaying{
                    avPlayer.play()
                    isPlaying = true
                }
                else{
                    avPlayer.stop()
                    isPlaying = false
                }
            }
            
        }
        else{
            print("File not loaded")
        }
    }
    
    @IBAction func btnStopTouch(_ sender: Any) {
        if fileFound{
            if avPlayer ==  nil{
                
            }
            else{
                avPlayer.stop()
                isPlaying = false
                sliderDuration.value = 0.0
                avPlayer.currentTime = TimeInterval(sliderDuration.value)
            }
        }
        else{
            print("File not loaded")
        }
    }
    
    @IBAction func sliderVolumeChanged(_ sender: UISlider) {
        if fileFound{
            avPlayer.volume = sliderVolume.value
        }
        else{
            print("File not loaded")
        }
    }
    
    @IBAction func sliderDurationChanged(_ sender: Any) {
        if fileFound{
            avPlayer.currentTime = TimeInterval(sliderDuration.value)
        }
        else{
            print("File not loaded")
        }
    }
    
    
    func displayAlert(title:String, message:String, button:String){
        let ac = UIAlertController(title: title, message:message, preferredStyle: .alert)
        let action = UIAlertAction(title: button, style: .default) {
            alertAction in
            // Este codigo se ejecutará cuando el usuario toque el botón
        }
        ac.addAction(action)
        self.present(ac, animated: true)

    }
    
}

