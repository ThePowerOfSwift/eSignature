//
//  PDFViewController.swift
//  eSignaturePDF
//
//  Created by admin on 23/04/18.
//  Copyright © 2018 VNSoftech. All rights reserved.
//

import UIKit
import PDFKit
import EPSignature
import MessageUI

class ImageStampAnnotation: PDFAnnotation {
    
    var image: UIImage!
    
 
    init(with image: UIImage!, forBounds bounds: CGRect, withProperties properties: [AnyHashable : Any]?) {
        super.init(bounds: bounds, forType: PDFAnnotationSubtype.stamp, withProperties: properties)
        
        self.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
          guard let cgImage = self.image.cgImage else { return }
          context.draw(cgImage, in: self.bounds)
        
    }
}


class PDFViewController: UIViewController,EPSignatureDelegate,MFMailComposeViewControllerDelegate {
    var currentlySelectedAnnotation: PDFAnnotation?
    var signatureImage: UIImage?
     
    @IBOutlet var pdfContainerView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      setUpForPDFReader()
     }
    
    
    override func viewDidAppear(_ animated: Bool) {
        guard let signatureImage = signatureImage, let page = pdfContainerView.currentPage else { return }
        let pageBounds = page.bounds(for: .cropBox)
        let imageBounds = CGRect(x: pageBounds.midX, y: pageBounds.midY, width: 200, height: 100)
        let imageStamp = ImageStampAnnotation(with: signatureImage, forBounds: imageBounds, withProperties: nil)
        page.addAnnotation(imageStamp)
    }
    
    
    func setUpForPDFReader() {
 
       
        let url = Bundle.main.url(forResource: "sample", withExtension: "pdf")
        pdfContainerView.document = PDFDocument(url: url!)
        
        
//        if let documentURL = URL(string: "https://blogs.adobe.com/security/SampleSignedPDFDocument.pdf"),
//            let data = try? Data(contentsOf: documentURL),
//            let document = PDFDocument(data: data) {
//
//            // Set document to the view, center it, and set background color
//            pdfContainerView.document = document
           pdfContainerView.autoScales = true
//            pdfContainerView.backgroundColor = UIColor.lightGray
//
            let panAnnotationGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanAnnotation(sender:)))
           pdfContainerView.addGestureRecognizer(panAnnotationGesture)
//
//        }
    }
    
    
    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
      //  self.dismiss(animated: true, completion: nil)
    }
    @objc func didPanAnnotation(sender: UIPanGestureRecognizer) {
        let touchLocation = sender.location(in: pdfContainerView)
        
        guard let page = pdfContainerView.page(for: touchLocation, nearest: true)
            else {
                return
        }
        let locationOnPage = pdfContainerView.convert(touchLocation, to: page)
        
        switch sender.state {
        case .began:
            
            guard let annotation = page.annotation(at: locationOnPage) else {
                return
            }
            
            if annotation.isKind(of: ImageStampAnnotation.self) {
                currentlySelectedAnnotation = annotation
            }
            
        case .changed:
            
            guard let annotation = currentlySelectedAnnotation else {
                return
            }
            let initialBounds = annotation.bounds
            // Set the center of the annotation to the spot of our finger
            annotation.bounds = CGRect(x: locationOnPage.x - (initialBounds.width / 2), y: locationOnPage.y - (initialBounds.height / 2), width: initialBounds.width, height: initialBounds.height)
            
            
            print("move to \(locationOnPage)")
        case .ended, .cancelled, .failed:
            currentlySelectedAnnotation = nil
        default:
            break
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Add Signature Button Action
    @IBAction func addSignatureBtnAction(_ sender: UIBarButtonItem) {
        let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: true)
        
        signatureVC.subtitleText = "I agree to the terms and conditions"
        signatureVC.title = "Abhilasha"
        // self.navigationController?.pushViewController(signatureVC, animated: true)
        let nav = UINavigationController(rootViewController: signatureVC)
        
        present(nav, animated: true, completion: nil)
    }
    
    
    //MARK:- SAVE File Action
    
    @IBAction func saveFileAction(_ sender: UIBarButtonItem) {
        
        
       /* let rect = CGRect.zero
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, rect, nil)

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
        docURL = docURL?.appendingPathComponent("sample.pdf")
        pdfData.write(toFile: "\(documentsPath)/sample.pdf", atomically: true)
     
        print("saved success fully")*/
        
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//        let filePath = "\(documentsPath)/\(filename).pdf"
//        let url = NSURL(fileURLWithPath: filePath)
//        let urlRequest = NSURLRequest(URL: url)
//        webView.loadRequest(urlRequest)
    }
    
    //MARK:- Signature Delegate Methods
    
    func epSignature(_: EPSignatureViewController, didCancel error : NSError) {
        print("User canceled")
    }
    
    func epSignature(_: EPSignatureViewController, didSign signatureImage : UIImage, boundingRect: CGRect) {
        print(signatureImage)
        let page = pdfContainerView.currentPage
        if signatureImage == signatureImage{
            let pageBounds = page?.bounds(for: .cropBox)
            let imageBounds = CGRect(x: (pageBounds?.midX)!, y: (pageBounds?.midY)!, width: 200, height: 100)
            let imageStamp = ImageStampAnnotation(with: signatureImage, forBounds: imageBounds, withProperties: nil)
            page?.addAnnotation(imageStamp)
        }
       
    }
    //MARK:-  sending your eSignature to your Gmail
   
    @IBAction func tapedMailBtn(_ sender: Any) {
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            print("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setToRecipients(["hrsolution909@gmail.com"])
            
            mailComposer.setSubject("IOS InterviewTask On PDF Signature")
            mailComposer.setMessageBody("Hi,i am completed my task its completed the pdf file signature and move the signature where you want place it.And sending mail also completed but i am not testing the functionality why because of i don't have iphone device thats it.Remaing all functionality working fine", isHTML: false)
            
            if let filePath = Bundle.main.path(forResource: "sample", ofType: "pdf") {
                print("File path loaded.")
                
                if let fileData = NSData(contentsOfFile: filePath) {
                    print("File data loaded.")
                    mailComposer.addAttachmentData(fileData as Data, mimeType: "text/pdf", fileName: "sample")
                }
            }
            self.present(mailComposer, animated: true, completion: nil)
            
        }
        
        
    }
    private func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismiss(animated: true, completion: nil)
     }
     
    
}
