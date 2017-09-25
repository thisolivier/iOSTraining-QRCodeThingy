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

    @IBOutlet var sceneView: ARSCNView!
    var qRRequest:VNDetectBarcodesRequest?
    var qRTimer = Timer()
    var testCounterForTimer:Int = 0
    
    /************************/
    /* The QR Functionality */
    /************************/
    // Runs a detection with the current image from the sceneView
    @objc func detectQR(){
        let cameraCurrent = sceneView.session.currentFrame?.capturedImage
        let handler = VNImageRequestHandler(cvPixelBuffer: cameraCurrent!, options: [.properties : ""])
        // Perform the barcode-request. This will call the completion-handler of the barcode-request.
        guard let _ = try? handler.perform([qRRequest!]) else {
            return print("Could not perform barcode-request!")
        }
    }
    // Setup for a barcode detector
    func setupCodeRequest(){
        qRRequest = VNDetectBarcodesRequest(completionHandler: {(request, error) in
            // Loopm through the found results
            for result in request.results! {
                
                // Cast the result to a barcode-observation
                if let barcode = result as? VNBarcodeObservation {
                    // Print barcode-values
                    print("Payload: \(barcode.payloadStringValue!)")
                    
                    // Get the bounding box for the bar code and find the center
                    var rect = barcode.boundingBox
                    // Flip coordinates
                    rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
                    rect = rect.applying(CGAffineTransform(translationX: 0, y: 1))
                    let center = CGPoint(x: rect.midX, y: rect.midY)
                    print ("Payload: \(barcode.payloadStringValue!) at \(center)")
                }
            }
        })
    }
    // Starts a timer with a callback
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        qRTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.detectQR), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        print("Loaded and empty")
        setupCodeRequest()
        scheduledTimerWithTimeInterval()
        
    }
    
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
