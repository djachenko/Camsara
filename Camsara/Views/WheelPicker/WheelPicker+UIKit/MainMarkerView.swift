//
//  MainMarkerView.swift
//  Camsara
//
//  Created by justin on 31.12.2025.
//

import SnapKit
import UIKit


final class MainMarkerView: UIView {
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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainMarkerView {
    func set(labelColor: UIColor) {
        valueLabel.textColor = labelColor
    }

    func set(transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.valueLabel.transform = transform
        }
    }
}

extension MainMarkerView {
    func configure(value: String) {
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
