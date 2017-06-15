//
//  ViewController.swift
//  CoreML Demo (Machine Learning)
//
//  Created by Alexander on 15.06.17.
//  Copyright © 2017 Alexander. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var probsLabel: UILabel!
    @IBOutlet weak var choosePicLabel: UILabel!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    
    let imagePicker = UIImagePickerController()
    
    let model = Resnet50()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientView.addGradient()
        
        probsLabel.text  = ""
        resultLabel.text = ""
        
        imagePicker.delegate   = self
        imagePicker.sourceType = .photoLibrary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addImage(_ sender: Any) {
        addImageButton.setTitle("", for: .normal)
        choosePicLabel.isHidden = true
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func recognize(_ sender: Any) {
        resultLabel.isHidden = false
        gradientView.isHidden = false
        
        let resizedImage = imageView.image?.resizeTo224px()
        
        guard let pxlBufImage = resizedImage?.pixelBuffer() else {
            return
        }
        
        do {
            let prediction = try model.prediction(image: pxlBufImage)
            
            let sortedPrediction = prediction.classLabelProbs.sorted(by: { (lhs, rhs) -> Bool in
                return lhs.value > rhs.value
            })
            
            resultLabel.text = prediction.classLabel.capitalized
            probsLabel.text = """
            \(sortedPrediction[0].key.capitalized): \(NSString(format: "%.2f", sortedPrediction[0].value))
            \(sortedPrediction[1].key.capitalized): \(NSString(format: "%.2f", sortedPrediction[1].value))
            \(sortedPrediction[2].key.capitalized): \(NSString(format: "%.2f", sortedPrediction[2].value))
            """
            
        } catch {
            print(error)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = image
        
        resultLabel.text = ""
        probsLabel.text = ""
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    
    func addGradient() {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.76).cgColor]
        gradientLayer.locations = [0.0, 0.8]
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}

