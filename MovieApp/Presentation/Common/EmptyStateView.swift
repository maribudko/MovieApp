//
//  EmptyStateView.swift
//  MovieApp
//
//  Created by Mari Budko on 03.10.2025.
//

import UIKit
import SnapKit

final class EmptyStateView: UIView {
    private let stack = UIStackView()
    private let iconView = UIImageView()
    private let messageLabel = UILabel()
    
    init(message: String, icon: UIImage? = UIImage(systemName: "film")) {
        super.init(frame: .zero)
        configureUI()
        setIcon(icon)
        setMessage(message)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    // MARK: - Public API
    func setMessage(_ text: String) {
        messageLabel.text = text
        messageLabel.isHidden = text.isEmpty
    }
    
    func setIcon(_ image: UIImage?) {
        iconView.image = image
        iconView.isHidden = (image == nil)
    }
    
    private func configureUI() {
        backgroundColor = .clear
        isAccessibilityElement = false
        
        // Stack
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
            make.width.lessThanOrEqualTo(480)
        }
        
        // Icon
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .tertiaryLabel
        iconView.setContentHuggingPriority(.required, for: .vertical)
        iconView.setContentCompressionResistancePriority(.required, for: .vertical)
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(56)
        }
        
        // Message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true
        
        // Arrange
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(messageLabel)
    }
}

#if DEBUG
import SwiftUI

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewWrapper()
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }

    struct PreviewWrapper: UIViewRepresentable {
        func makeUIView(context: Context) -> UIView {
            return EmptyStateView(message: "No results found", icon: UIImage(systemName: "film"))
        }
        func updateUIView(_ uiView: UIView, context: Context) {}
    }
}
#endif


