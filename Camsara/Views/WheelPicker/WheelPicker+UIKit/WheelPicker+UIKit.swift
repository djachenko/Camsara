//
//  WheelPicker+UIKit.swift
//  Camsara
//
//  Created by justin on 26.12.2025.
//

import SnapKit
import SwiftUI

protocol WheelPickerUIViewDelegate: AnyObject {
    func wheelPickerView(_ view: WheelPickerUIView, didSelectValue value: Int)
}

final class WheelPickerUIView: UIView {
    private enum Constants {
        static let markerThickness = UIScreen.perfectPixel
    }

    let config: WheelPicker.Config
    let uiConfig: WheelPicker.UIConfig
    let verticalInset: Double

    private lazy var stackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = config.spacing - Constants.markerThickness
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private lazy var scrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.bounces = true
        scrollView.clipsToBounds = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: 0,
            bottom: verticalInset,
            right: 0
        )

        return scrollView
    }()

    private let indicatorView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black

        return view
    }()

    private(set) var currentValue: Int = 0
    private weak var delegate: WheelPickerUIViewDelegate?

    init(
        config: WheelPicker.Config,
        uiConfig: WheelPicker.UIConfig,
        verticalInset: Double,
        initialValue: Int, // Принимаем начальное значение
        delegate: WheelPickerUIViewDelegate? // Делегат для обратной связи
    ) {
        self.config = config
        self.uiConfig = uiConfig
        self.verticalInset = verticalInset
        currentValue = initialValue
        self.delegate = delegate

        super.init(frame: .zero)

        setupSelf()
        setupViews()
        setupContraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIScrollViewDelegate

extension WheelPickerUIView: UIScrollViewDelegate {
    private func calculateCurrentValue() -> Int? {
        let offsetY = scrollView.contentOffset.y + verticalInset
        let stepHeight = config.spacing

        let rawIndex = round(offsetY / stepHeight)
        let index = Int(max(0, min(rawIndex, CGFloat(config.steps.count - 1))))

        guard config.steps.indices.contains(index) else { return nil }
        return config.steps[index]
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let newValue = calculateCurrentValue(),
              newValue != currentValue else { return }

        currentValue = newValue
        delegate?.wheelPickerView(self, didSelectValue: newValue)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNearestValue()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestValue()
    }

    private func snapToNearestValue() {
        guard let nearestValue = calculateCurrentValue() else {
            return
        }

        scrollToValue(nearestValue, animated: true)
    }
}

// MARK: setup

private extension WheelPickerUIView {
    func setupSelf() {
        scrollView.delegate = self
    }

    func setupViews() {
        config.steps.forEach { step in
            let view = if config.mainSteps.contains(step) {
                makeMainMarkView(step: step)
            } else {
                makeMarkView()
            }

            stackView.addArrangedSubview(view)
        }

        scrollView.addSubview(stackView)

        addSubview(scrollView)
        addSubview(indicatorView)
    }

    func setupContraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }

        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView.snp.centerX)
            make.width.equalTo(40)

            make.verticalEdges.equalTo(scrollView.contentLayoutGuide.snp.verticalEdges)
        }

        indicatorView.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(Constants.markerThickness)
            make.centerY.equalTo(snp.centerY)
            make.centerX.equalTo(snp.centerX).offset(-20)
        }

        stackView.arrangedSubviews.forEach { view in
            let width = if view is MainMarkerView {
                uiConfig.mainMarkerWidth
            } else {
                uiConfig.markerWidth
            }

            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: Constants.markerThickness),
                view.widthAnchor.constraint(equalToConstant: width),
            ])
        }
    }
}

// MARK: builders

private extension WheelPickerUIView {
    func makeMarkView() -> UIView {
        let markView = MarkView()
        markView.backgroundColor = UIColor(uiConfig.markerColor)

        return markView
    }

    func makeMainMarkView(step: Int) -> UIView {
        let markView = MainMarkerView()
        markView.backgroundColor = UIColor(uiConfig.mainMarkerColor)
        markView.set(value: "\(step)")

        return markView
    }
}

// MARK: scroll behaviour

private extension WheelPickerUIView {
    func scrollToValue(_ value: Int, animated: Bool) {
        guard let index = config.steps.firstIndex(of: value) else {
            return
        }

        let targetOffsetY = CGFloat(index) * config.spacing - verticalInset

        scrollView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: animated)
    }
}

// MARK: WheelPickerUIViewHolder

struct WheelPickerUIViewHolder: UIViewRepresentable {
    let config: WheelPicker.Config
    let uiConfig: WheelPicker.UIConfig
    let verticalInset: Double
    @Binding var value: Int

    func makeUIView(context: Context) -> WheelPickerUIView {
        WheelPickerUIView(
            config: config,
            uiConfig: uiConfig,
            verticalInset: verticalInset,
            initialValue: value,
            delegate: context.coordinator
        )
    }

    func updateUIView(_ uiView: WheelPickerUIView, context: Context) {
        guard uiView.currentValue != value else {
            return
        }

        uiView.scrollToValue(
            value,
            animated: context.transaction.animation != nil
        )
    }

    func makeCoordinator() -> Coordinator {
        .init(value: $value)
    }
}

// MARK: Coordinator

final class Coordinator {
    @Binding var value: Int

    init(value: Binding<Int>) {
        self._value = value
    }
}

// MARK: WheelPickerUIViewDelegate

extension Coordinator: WheelPickerUIViewDelegate {
    func wheelPickerView(_ view: WheelPickerUIView, didSelectValue value: Int) {
        self.value = value
    }
}

#Preview {
    MainView(viewModel: .forPreview)
}
