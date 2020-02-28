//
//  ViewController.swift
//  QR Pay Mobile Authenticator
//
//  Created by Batuhan Erden on 03/11/2018.
//  Copyright © 2018 Batuhan Erden. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var qrResponse = ""
    var key = ""
    var video = AVCaptureVideoPreviewLayer()
    
    @IBOutlet weak var square: UIImageView!
    @IBOutlet weak var uuidLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setKey()
        
        let session = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            print ("An error occured!")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        
        view.layer.addSublayer(video)
        
        self.view.bringSubview(toFront: square)
        // self.view.bringSubview(toFront: uuidLabel) // Shows the key on the screen!
        
        session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if self.qrResponse == "" && metadataObjects != nil && metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    self.qrResponse = object.stringValue!
                    
                    /*
                    ---> Un-comment the following for making a POST request
                    let postAuthenticationApiRequestUrl = "http://bank.com/api/"
                    let postAuthenticationApiRequestParams = "id=" + self.qrResponse + "&key=" + self.key
                    
                    _ = self.getApiResponse(url: postAuthenticationApiRequestUrl, params: postAuthenticationApiRequestParams)
                    
                    let alert = UIAlertController(title: "Success", message: "QR Code is successfully read!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (nil) in
                        self.qrResponse = ""
                    }))
                    
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    present(alert, animated: true, completion: nil)
                    */
                }
            }
        }
    }
    
    func setKey() -> Void {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            self.key = uuid
            uuidLabel.text = self.key
        }
    }
    
    func getApiResponse(url: String, params: String? = nil) -> NSDictionary {
        var apiRequestResolved = false
        var apiResponse : NSDictionary = [:]
        
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        
        if params == nil {
            request.httpMethod = "GET"
        } else {
            request.httpMethod = "POST"
            request.httpBody = params?.data(using: .utf8)
        }
        
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            if request.httpMethod == "GET" {
                if error != nil {
                    print(error!.localizedDescription)
                    apiRequestResolved = true
                } else {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                            apiResponse = jsonResponse
                            apiRequestResolved = true
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        apiRequestResolved = true
                    }
                }
            } else {
                if error != nil {
                    print(error!.localizedDescription)
                    apiRequestResolved = true
                }
                
                apiRequestResolved = true
            }
        }
        
        task.resume()
        
        var i = 0
        while !apiRequestResolved {
            i += 1
            if i % 1000000 == 0 {
                print(".", terminator:"")
            }
        }
        
        print(" >")
        return apiResponse
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
