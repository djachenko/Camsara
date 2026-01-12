//
//  FrameSource.swift
//  Camsara
//
//  Created by justin on 10/1/26.
//

import Combine
import CoreMedia


protocol FrameSource {
    var framePublisher: AnyPublisher<CMSampleBuffer, Never> { get }
}
