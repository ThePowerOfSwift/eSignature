//
//  OPenPDFViewController.swift
//  eSignaturePDF
//
//  Created by admin on 24/04/18.
//  Copyright © 2018 VNSoftech. All rights reserved.
//

import UIKit

class OPenPDFViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func openPDFBtnAction(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let pdfView = storyBoard.instantiateViewController(withIdentifier: "PDFView")
            as! PDFViewController
        self.navigationController?.pushViewController(pdfView, animated: true)
        //self.performSegue(withIdentifier: "OpenPDFView", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenPDFView"{
            _ = segue.destination as! PDFViewController
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
