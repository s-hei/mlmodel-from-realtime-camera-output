//
//  ViewController.swift
//  play-camera
//
//  Created by Shuhei Yamasaki on 2019/02/10.
//  Copyright © 2019 Shuhei Yamasaki. All rights reserved.
//

import UIKit
import Vision
import AVKit

class ViewController: UIViewController, FrameExtractorDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var textLabel: UILabel!
    
    var frameExtractor: FrameExtractor!
    var mlmodel = MobileNet().model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: frameExtractor.captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    }
    
    func captured(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: mlmodel) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            self.textLabel.text = results.first?.identifier
            print(results.first?.identifier ?? "not found")
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
