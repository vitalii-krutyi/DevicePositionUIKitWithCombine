//
//  DevicePositionViewModel.swift
//  DevicePositionUIKitWithCombine
//
//  Created by Vitalii Krutyi on 03.01.2026.
//

import UIKit
import Combine
import CoreMotion

enum DeviceFrontalTilt {
    case tiltedDown
    case tiltedUp
    case notTilted

    var message: String {
        switch self {
        case .tiltedDown:
            return "The device is tilted down"
        case .tiltedUp:
            return "The device is tilted up"
        case .notTilted:
            return ""
        }
    }
}

enum DeviceLateralTilt {
    case tiltedLeft
    case tiltedRight
    case notTilted

    var message: String {
        switch self {
        case .tiltedLeft:
            return "The device is tilted left"
        case .tiltedRight:
            return "The device is tilted right"
        case .notTilted:
            return ""
        }
    }
}

enum DevicePosition {
    case notVertical
    case vertical

    var message: String {
        switch self {
        case .notVertical:
            return "The device is not vertical"
        case .vertical:
            return "The device is vertical"
        }
    }
}

class DevicePositionViewModel: NSObject {
    // MARK: - Managers

    private let motionManager = CMMotionManager()

    // MARK: - Combine

    @Published var deviceFrontalTilt: DeviceFrontalTilt?
    @Published var deviceLateralTilt: DeviceLateralTilt?
    @Published var devicePosition: DevicePosition?
    private let gravityPublisher = PassthroughSubject<CMAcceleration, Never>()

    // MARK: - Life cycle ViewModel

    override init() {
        super.init()

        gravityPublisher
            .map { gravity -> DeviceFrontalTilt in
                if gravity.z < -Constants.frontalTiltThreshold {
                    return .tiltedUp
                } else if gravity.z > Constants.frontalTiltThreshold {
                    return .tiltedDown
                } else {
                    return .notTilted
                }
            }
            .removeDuplicates()
            .debounce(for: 0.25, scheduler: DispatchQueue.main)
            .assign(to: &$deviceFrontalTilt)

        gravityPublisher
            .map { gravity -> DeviceLateralTilt in
                if gravity.x < -Constants.lateralTiltThreshold {
                    return .tiltedLeft
                } else if gravity.x > Constants.lateralTiltThreshold {
                    return .tiltedRight
                } else {
                    return .notTilted
                }
            }
            .removeDuplicates()
            .debounce(for: 0.25, scheduler: DispatchQueue.main)
            .assign(to: &$deviceLateralTilt)

        Publishers.CombineLatest($deviceFrontalTilt, $deviceLateralTilt)
            .compactMap { frontalTilt, lateralTilt in
                guard let frontalTilt = frontalTilt,
                      let lateralTilt = lateralTilt else {
                    return nil
                }
                return frontalTilt == .notTilted && lateralTilt == .notTilted ?
                    .vertical :
                    .notVertical
            }
            .assign(to: &$devicePosition)
    }

    // MARK: - Open methods

    func start() {
        motionManager.deviceMotionUpdateInterval = Constants.deviceMotionUpdateInterval

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motionData, error in
            guard let motionData = motionData else { return }
            self?.gravityPublisher.send(motionData.gravity)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
