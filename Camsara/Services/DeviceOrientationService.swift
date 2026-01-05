//
//  DeviceOrientationService.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//


import Combine
import UIKit

final class DeviceOrientationService: ObservableObject {
    enum Orientation {
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

    @Published var orientation = Orientation(deviceOrientation: UIDevice.current.orientation)

    private var cancellable: AnyCancellable?
    private var lastOrientation: UIDeviceOrientation = .portrait

    init() {
        // Включаем получение уведомлений об ориентации устройства
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        cancellable = NotificationCenter.default
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
            .map { Orientation(deviceOrientation: $0) }
//            .receive(on: RunLoop.main)
            .assign(to: \.orientation, on: self)
    }

    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
}
