//
//  WheelPicker+UIKit.swift
//  Camsara
//
//  Created by justin on 26.12.2025.
//

import SwiftUI
import SnapKit

private final class MarkView: UIView {}

private final class MainMarkerView: UIView {
    private let valueLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize,
            weight: .semibold
        )
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSelf()
        setupViews()
        setupContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainMarkerView {
    func set(value: String) {
        valueLabel.isHidden = false
        valueLabel.text = value
    }
}

private extension MainMarkerView {
    func setupSelf() {}

    func setupViews() {
        addSubview(valueLabel)
        valueLabel.isHidden = true
    }

    func setupContraints() {
        valueLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
    }
}

final class WheelPickerUIView: UIView {
    let config: WheelPicker.Config
    let uiConfig: WheelPicker.UIConfig
    let verticalInset: Double

    private lazy var stackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = config.spacing
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

    init(
        config: WheelPicker.Config,
        uiConfig: WheelPicker.UIConfig,
        verticalInset: Double
    ) {
        self.config = config
        self.uiConfig = uiConfig
        self.verticalInset = verticalInset

        super.init(frame: .zero)

        setupSelf()
        setupViews()
        setupContraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WheelPickerUIView {
    func setupSelf() {}

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
            make.height.equalTo(1)
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
                view.heightAnchor.constraint(equalToConstant: 0.4),
                view.widthAnchor.constraint(equalToConstant: width),
            ])
        }
    }
}

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

struct WheelPickerUIViewHolder: UIViewRepresentable {
    let config: WheelPicker.Config
    let uiConfig: WheelPicker.UIConfig
    let verticalInset: Double

    func makeUIView(context: Context) -> some UIView {
        WheelPickerUIView(
            config: config,
            uiConfig: uiConfig,
            verticalInset: verticalInset
        )
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#Preview {
    MainView(viewModel: .forPreview)
}

