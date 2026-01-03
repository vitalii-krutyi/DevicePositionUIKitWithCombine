//
//  ViewController.swift
//  DevicePositionUIKitWithCombine
//
//  Created by Vitalii Krutyi on 03.01.2026.
//

import UIKit

struct Constants {
    static let deviceMotionUpdateInterval = 1.0 / 60.0

    static let frontalTiltThreshold: Double = 0.25
    static let lateralTiltThreshold: Double = 0.125
}

class DevicePositionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

