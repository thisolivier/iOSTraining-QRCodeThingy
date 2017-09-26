//
//  ViewController.swift
//  iOSTraining-PirateDrawing
//
//  Created by Olivier Butler on 25/09/2017.
//  Copyright © 2017 Olivier Butler. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate {
    
    /*******************/
    /* Initialization  */
    /*******************/
    
    @IBOutlet var sceneView: ARSCNView!
    // Variable for storing the barcode request
    var qRRequest:VNDetectBarcodesRequest?
    // Creates a new timer object
    var qRTimer = Timer()
    
    override func viewDidLoad() {
        // Basic setup
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = false
        setupVisionRequest()
        
        // Starts our timer which will detect QR codes on a loop
        scheduledTimerWithTimeInterval()
    }

    /************************/
    /* The QR Functionality */
    /************************/
    
    // Setup for a barcode detector object, which will scan for barcodes, and process the results
    func setupVisionRequest(){
        qRRequest = VNDetectBarcodesRequest(completionHandler: {
            (request, error) in
            // Loop through the found results
            for result in request.results! {
                // Cast the result to a barcode-observation
                if let barcode = result as? VNBarcodeObservation {
                    // Get the bounding box for the bar code and find the center
                    var rect = barcode.boundingBox
                    rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
                    rect = rect.applying(CGAffineTransform(translationX: 0, y: 1))
                    let center = CGPoint(x: rect.midX, y: rect.midY)
                    print ("Payload: \(barcode.payloadStringValue!) at \(center)")
                }
            }
        })
    }
    
    // Gets the current image from the ARSCNView (Augmented Reality Scene View) and makes an Image Request Handler using that image.
    // It then calls the handler's perform method, and passes it the request we made earlier.
    @objc func detectQR(){
        let cameraCurrent = sceneView.session.currentFrame?.capturedImage
        let visionImageHandler = VNImageRequestHandler(cvPixelBuffer: cameraCurrent!, options: [.properties : ""])
        guard let _ = try? visionImageHandler.perform([qRRequest!]) else {
            return print("Could not perform barcode-request!")
        }
    }
    
    // Starts a timer with a callback of the QR detection function. Repeats every 1 seconds.
    func scheduledTimerWithTimeInterval(){
        qRTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.detectQR), userInfo: nil, repeats: true)
    }
    
    
    /********************************/
    /* Fulfilling scene delegate    */
    /********************************/
    /* We don't use any of this yet */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}
