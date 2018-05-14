//
//  ViewController.swift
//  RealTimeDetection
//
//  Created by Shan on 2018/5/14.
//  Copyright © 2018年 Shan. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var name: UILabel!
    var confidence: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        name = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        name.textAlignment = .left
        name.textColor = .black
        name.text = "Name"
        
        confidence = UILabel()
        confidence.textAlignment = .left
        confidence.textColor = .black
        confidence.text = "Confidence"
        
        view.addSubview(name)
        name.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        name.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        name.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        name.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        name.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(confidence)
        confidence.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confidence.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10).isActive = true
        confidence.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        confidence.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        confidence.translatesAutoresizingMaskIntoConstraints = false
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {        
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            
            DispatchQueue.main.async {
                self.name.text = firstObservation.identifier
                self.confidence.text = "\(firstObservation.confidence)"
            }
            print(firstObservation.identifier, firstObservation.confidence)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    


}

