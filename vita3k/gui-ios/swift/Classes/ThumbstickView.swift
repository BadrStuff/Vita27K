//
//  ThumbstickView.swift
//  Vion
//
//  Created by Jarrod Norwell on 7/5/2026.
//

import UIKit

class ThumbstickView : UIView, UIGestureRecognizerDelegate {
    var label: UILabel? = nil
    
    var deadZone: CGFloat = 0.15
    
    var didDrag: ((CGPoint) -> Void)?
    var didUndrag: (() -> Void)?
    
    var didClick: (() -> Void)?
    var didUnclick: (() -> Void)?
    
    private(set) var normalizedPoint: CGPoint = .zero {
        didSet {
            didDrag?(normalizedPoint)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageView: UIImageView = UIImageView(image: UIImage(systemName: "app.background.dotted")?
            .applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: .secondarySystemBackground)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(imageView, belowSubview: self)
        
        label = UILabel()
        guard let label else {
            return
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        label.textColor = .clear
        addSubview(label)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        // let gestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        // gestureRecognizer.delegate = self
        // gestureRecognizer.minimumPressDuration = 2 / 3
        // addGestureRecognizer(gestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        print("long pressed")
        switch gestureRecognizer.state {
        case .began:
            didClick?()
        default:
            didUnclick?()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0.0, 2 / 3, 1.0] as [NSNumber]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = bounds

        layer.mask = gradient
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        update(with: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        update(with: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        normalizedPoint = .zero
        didUndrag?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        normalizedPoint = .zero
        didUndrag?()
    }
    
    private func update(with touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }
        
        normalizedPoint = normalize(location: touch.location(in: self))
    }
    
    private func normalize(location: CGPoint) -> CGPoint {
        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else {
            return .zero
        }

        var x = (location.x / w) * 2 - 1
        var y = (location.y / h) * 2 - 1

        let magnitude = sqrt(x * x + y * y)
        guard magnitude > deadZone else {
            return .zero
        }

        let scaled = (magnitude - deadZone) / (1 - deadZone)
        let scale = scaled / magnitude

        x *= scale
        y *= scale

        return CGPoint(
            x: CGFloat(clampToInt16(x)),
            y: CGFloat(clampToInt16(y))
        )
    }

    private func clampToInt16(_ value: CGFloat) -> Int16 {
        let scaled = Int32(round(value * CGFloat(Int16.max)))

        return Int16(
            min(
                max(scaled, Int32(Int16.min)),
                Int32(Int16.max)
            )
        )
    }
}
