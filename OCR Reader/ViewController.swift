//
//  ViewController.swift
//  OCR Reader
//
//  Created by Anshuman Dash on 8/3/18.
//  Copyright © 2018 Anshuman Dash All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- Objects
    var imagePicker = UIImagePickerController()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        imagePicker.delegate = self
    }
    
    //MARK:- Action Methods
    @IBAction func cameraAction(_ sender: Any) {
        let actionSheetAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheetAlertController.addAction(cancelAction)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alert) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        actionSheetAlertController.addAction(cameraAction)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (alert) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        actionSheetAlertController.addAction(galleryAction)
        
        self.present(actionSheetAlertController, animated: true, completion: nil)
    }
    
    //MARK:- Custom Methods
    func performImageRecognition(_image: UIImage) {
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .auto
            tesseract.image = _image.g8_blackAndWhite()
            tesseract.recognize()
            textView.text = tesseract.recognizedText
        }
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

// MARK:- UIImagePickerController & UINavigationController Delegates
extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage,
            let scaledImage = pickedImage.scaleImage(_maxDimension: 640)
            {
                dismiss(animated: true, completion: {
                    self.performImageRecognition(_image: scaledImage)
                    })
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- UIImage
extension UIImage {
    func scaleImage(_maxDimension: CGFloat) -> UIImage? {
        var scaledSize = CGSize(width: _maxDimension, height: _maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height/size.width
            scaledSize.height = scaledSize.width * scaleFactor
        }
        else {
            let scaleFactor = size.width/size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

