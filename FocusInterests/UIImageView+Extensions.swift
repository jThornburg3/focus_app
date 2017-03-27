//
//  UIImageView+Extensions.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func roundedImage() {

        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    
    func download(urlString: String) {
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        let urlSession = URLSession(configuration: .default)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print("There has been an image download error: \(error?.localizedDescription)")
                return
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let dta = data {
                            let img = UIImage(data: dta)
                            self.image = img!
                        }
                    } else {
                        print("The status code was not 200: \(httpResponse.statusCode)")
                    }
                }
            }
        }
        task.resume()
        
    }
}
