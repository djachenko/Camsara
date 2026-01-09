//
//  DeviceOrientationService.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import Combine
import UIKit


enum DeviceOrientation {
    case portrait
    case landscapeLeft
    case landscapeRight
    case portraitUpsideDown
    case unknown

    init(deviceOrientation: UIDeviceOrientation) {
        self = switch deviceOrientation {
        case .portrait:
            .portrait
        case .portraitUpsideDown:
            .portraitUpsideDown
        case .landscapeLeft:
            .landscapeLeft
        case .landscapeRight:
            .landscapeRight
        default:
            .unknown
        }
    }
}

final class DeviceOrientationService: ObservableObject {
    @Published var orientation = DeviceOrientation(deviceOrientation: UIDevice.current.orientation)

    private var lastOrientation: UIDeviceOrientation = .portrait

    init() {
        // Включаем получение уведомлений об ориентации устройства
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { _ in UIDevice.current.orientation }
            .filter { [weak self] newOrientation in
                // Фильтруем плоские ориентации и слишком частые обновления
                guard newOrientation.isValidInterfaceOrientation,
                      newOrientation != self?.lastOrientation else {
                    return false
                }

                self?.lastOrientation = newOrientation

                return true
            }
            .map { DeviceOrientation(deviceOrientation: $0) }
            .assign(to: &$orientation)
    }

    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
}
