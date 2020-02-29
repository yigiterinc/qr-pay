//
//  ViewController.swift
//  QR Pay Mobile Authenticator
//

import UIKit
import AVFoundation
import AudioToolbox
import Speech

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
        
        // TODO: Remove the following line of code!!! You master!!!
        let price = getPriceFromFile(fileName: "test")
        
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
    
    func setKey() -> Void {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            self.key = uuid
            uuidLabel.text = self.key
        }
    }
    
    // TODO: Remove this function when actual qr json response is being taken into the account!
    func getPriceFromFile(fileName: String) -> Double {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                    return getPriceFromQrJson(jsonObject: jsonObject)
                }
            } catch {
                print("An error occurred while reading price from qr json!")
            }
        }
        
        return -1.0
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if self.qrResponse == "" && metadataObjects != nil && metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    self.qrResponse = object.stringValue!
                    
                    speak(price: self.qrResponse)
                    
                    let bankRequestBody = self.getApiResponse(url: "https://finside.co/api/qr-pay/prepare", params: "?price=" + self.qrResponse + "&ip=" + self.getIp(), isGet: true, hasBody: false, body: NSDictionary())
                    
                    let alert = UIAlertController(title: "Success", message: "QR Code is successfully read!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (nil) in
                        self.qrResponse = ""
                    }))
                    
                    
                    let bankResponse = self.getApiResponse(url: "https://ybpb2b.alternatifbank.com.tr/ExternalGatewayAPI/api/home/executeCommand/", params: nil, isGet: false, hasBody: true, body: bankRequestBody)
                    
                    print(bankResponse)
                    
                    let _ = self.getApiResponse(url: "https://finside.co/api/qr-pay/receive", params: nil, isGet: true, hasBody: false, body: NSDictionary())
                    
                    while (0 == 0) {
                        do {
                            let mes = self.getApiResponse(url: "https://finside.co/api/qr-pay/read", params: nil, isGet: true, hasBody: false, body: NSDictionary())

                            if (mes["authenticated"] as? String == "-1") {
                                let alert2 = UIAlertController(title: "Success", message: "Transaction is completed", preferredStyle: .alert)
                                alert2.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (nil) in
                                    self.qrResponse = ""
                                }))
                                
                                present(alert2, animated: true, completion: nil)
                                break;
                            }
                        } catch {
                            print("ERRTRRR")
                        }
                    }
                }
            }
        }
    }
    
    func getPriceFromQrJsonRepsonse(qrJsonResponse: String) -> Double {
        let data = qrJsonResponse.data(using: .utf8)!

        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:Any] {
                return getPriceFromQrJson(jsonObject: jsonObject)
            }
        } catch {
            print("An error occurred while handling price!")
        }

        return -1.0
    }
    
    func getPriceFromQrJson(jsonObject: [String:Any]) -> Double {
        if let data = jsonObject["data"] as? [String:AnyObject] {
            if let message = data["Message"] as? [String:AnyObject] {
                if let transferAmount = message["TransferAmount"] as? [String:AnyObject] {
                    return transferAmount["Value"] as? Double ?? -1.0
                }
            }
        }
        
        return -1.0
    }
    
    func speak(price: String) {
        let speechSynthesizer = AVSpeechSynthesizer()
        let speech = price + " TL işlem yapılıyor, onaylıyor musunuz?"
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: speech)
        
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "tr-TR")
        
        speechSynthesizer.speak(speechUtterance)
    }
    
    func getApiResponse(url: String, params: String? = nil, isGet: Bool, hasBody: Bool, body: NSDictionary) -> NSDictionary {
        var apiRequestResolved = false
        var apiResponse : NSDictionary = [:]
        
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        
        if isGet {
            request.httpMethod = "GET"
        } else {
            request.httpMethod = "POST"
            
            if hasBody {
                request.httpBody = body as? Data
            }
        }
        
        if params == nil {
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
    
    func getIp() -> String {
        let authenticationIpApiResponse = self.getApiResponse(url: "https://api.ipify.org/?format=json", isGet: true, hasBody: false, body: NSDictionary())
        return authenticationIpApiResponse["ip"]! as! String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
