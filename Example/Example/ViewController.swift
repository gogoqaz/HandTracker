//
//  ViewController.swift
//  Example
//
//  Created by Tomoya Hirano on 2020/04/02.
//  Copyright © 2020 Tomoya Hirano. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, TrackerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toggleView: UISwitch!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var xyLabel:UILabel!
    @IBOutlet weak var featurePoint: UIView!
    let camera = Camera()
    let tracker: HandTracker = HandTracker()!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.setSampleBufferDelegate(self)
        camera.start()
        tracker.startGraph()
        tracker.delegate = self
        
//        previewLayer = AVCaptureVideoPreviewLayer(session: camera.session) as AVCaptureVideoPreviewLayer
//        previewLayer.frame = view.bounds
//        view.layer.addSublayer(previewLayer)
//        view.bringSubviewToFront(xyLabel)
//        view.bringSubviewToFront(featurePoint)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        tracker.processVideoFrame(pixelBuffer)

        DispatchQueue.main.async {
            if !self.toggleView.isOn {
                self.imageView.image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer!))
            }
        }
    }
    
//    func handTracker(_ handTracker: HandTracker!, didOutputLandmarks landmarks: [Landmark]!, andHand handSize: CGSize) {
//        print("")
//    }
    
    func handTracker(_ handTracker: HandTracker!, didOutputLandmarks landmarks: [Landmark]!, andHand handSize: CGSize) {

        var thumbUp = false
        var firstUp = false
        var secondUp = false
        var thirdUp = false
        var fourUp = false
        
        var pseudoFixKeyPoint = landmarks[2].x
        if (landmarks[3].x < pseudoFixKeyPoint && landmarks[4].x < pseudoFixKeyPoint)
        {
            thumbUp = true;
        }
        thumbUp = true;
        
        pseudoFixKeyPoint = landmarks[6].y;
        if (landmarks[7].y < pseudoFixKeyPoint && landmarks[8].y < pseudoFixKeyPoint)
        {
            firstUp = true;
        }

        pseudoFixKeyPoint = landmarks[10].y;
        if (landmarks[11].y < pseudoFixKeyPoint && landmarks[12].y < pseudoFixKeyPoint)
        {
            secondUp = true;
        }

        pseudoFixKeyPoint = landmarks[14].y;
        if (landmarks[15].y < pseudoFixKeyPoint && landmarks[16].y < pseudoFixKeyPoint)
        {
            thirdUp = true;
        }

        pseudoFixKeyPoint = landmarks[18].y;
        if (landmarks[19].y < pseudoFixKeyPoint && landmarks[20].y < pseudoFixKeyPoint)
        {
            fourUp = true;
        }
        
        if thumbUp && firstUp && secondUp && thirdUp && fourUp {
            DispatchQueue.main.async {
                self.xyLabel.text = "FIVE"
            }
            return
        }
        
        if let first = landmarks[safe:8], let second = landmarks[safe:12], let thr = landmarks[safe:16], let four = landmarks[safe:20], let thumb = landmarks[safe:4], let thumb2 = landmarks[safe:2] {
            
            if thumb.y < first.y && thumb.y < second.y && thumb.y < thr.y && thumb.y < four.y && thumb2.y > four.y {
                DispatchQueue.main.async {
                    if thumb.x < first.x {
                        self.xyLabel.text = "left"
                    } else {
                        self.xyLabel.text = "right"
                    }
                }
//                print("left")
            } else {
                DispatchQueue.main.async {
                    self.xyLabel.text = ""
                }
            }
        }
        
//        if let landmark = landmarks[safe : 8] {
//            DispatchQueue.main.async {
//                let width = self.view.frame.size.width
//                let height = self.view.frame.size.height
//                let x = CGFloat(landmark.x) * width
//                let y = CGFloat(landmark.y) * height
//                self.featurePoint.frame = CGRect(x: CGFloat(landmark.x) * width, y: CGFloat(landmark.y) * height, width: 5, height: 5)
//                self.xyLabel.text = "\(landmark.x) , \(landmark.y)"
//            }
//        }
//        print(landmarks!)
    }
    
    func handTracker(_ handTracker: HandTracker!, didOutputPixelBuffer pixelBuffer: CVPixelBuffer!) {
        DispatchQueue.main.async {
            if self.toggleView.isOn {
                self.imageView.image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
            }
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension CGFloat {
    func ceiling(toDecimal decimal: Int) -> CGFloat {
        let numberOfDigits = CGFloat(abs(pow(10.0, Double(decimal))))
        if self.sign == .minus {
            return CGFloat(Int(self * numberOfDigits)) / numberOfDigits
        } else {
            return CGFloat(ceil(self * numberOfDigits)) / numberOfDigits
        }
    }
}

extension Double {
    func ceiling(toDecimal decimal: Int) -> Double {
        let numberOfDigits = abs(pow(10.0, Double(decimal)))
        if self.sign == .minus {
            return Double(Int(self * numberOfDigits)) / numberOfDigits
        } else {
            return Double(ceil(self * numberOfDigits)) / numberOfDigits
        }
    }
}
