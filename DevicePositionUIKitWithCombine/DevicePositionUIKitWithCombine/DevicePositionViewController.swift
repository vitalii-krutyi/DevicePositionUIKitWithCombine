//
//  ViewController.swift
//  DevicePositionUIKitWithCombine
//
//  Created by Vitalii Krutyi on 03.01.2026.
//

import UIKit
import Combine

struct Constants {
    static let deviceMotionUpdateInterval = 1.0 / 60.0

    static let frontalTiltThreshold: Double = 0.25
    static let lateralTiltThreshold: Double = 0.125
}

class DevicePositionViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var frontalTiltLabel: UILabel!
    @IBOutlet weak var lateralTiltLael: UILabel!
    @IBOutlet weak var positionLabel: UILabel!

    // MARK: - ViewModel

    lazy var viewModel = DevicePositionViewModel()

    // MARK: - Combine

    var bag = Set<AnyCancellable>()

    // MARK: - Life cycle ViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$deviceFrontalTilt
            .compactMap { $0?.message }
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: frontalTiltLabel)
            .store(in: &bag)

        viewModel.$deviceLateralTilt
            .compactMap { $0?.message }
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: lateralTiltLael)
            .store(in: &bag)

        viewModel.$devicePosition
            .compactMap { $0?.message }
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: positionLabel)
            .store(in: &bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stop()
    }
}

