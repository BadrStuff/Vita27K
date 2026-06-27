//
//  EmulationController.swift
//  Vion
//
//  Created by Jarrod Norwell on 7/5/2026.
//

import MetalKit
import UIKit

enum PSVButton : Int32 {
    case cross = 0,
         circle = 1,
         square = 2,
         triangle = 3
    
    case select = 4,
         ps = 5,
         start = 6
    
    case l1 = 9,
         r1 = 10
    
    case l2 = -4
    case r2 = -5
    
    case up = 11,
         down = 12,
         left = 13,
         right = 14
    
    var int32: Int32 {
        rawValue
    }
}

class EmulationController : UIViewController {
    var containerView: UIView? = nil
    var metalView: MTKView? = nil
    
    var settingsButton: UIButton? = nil,
        selectButton: UIButton? = nil,
        startButton: UIButton? = nil
    
    var leftThumbstickView: ThumbstickView? = nil,
        rightThumbstickView: ThumbstickView? = nil
    
    var upButton: UIButton? = nil,
        downButton: UIButton? = nil,
        leftButton: UIButton? = nil,
        rightButton: UIButton? = nil
    
    var crossButton: UIButton? = nil,
        circleButton: UIButton? = nil,
        triangleButton: UIButton? = nil,
        squareButton: UIButton? = nil
    
    var l1Button: UIButton? = nil,
        r1Button: UIButton? = nil,
        l2Button: UIButton? = nil,
        r2Button: UIButton? = nil
    
    var constraints: (portrait: [NSLayoutConstraint], landscape: [NSLayoutConstraint]) = ([], [])
    
    var titleId: String
    init(titleId: String) {
        self.titleId = titleId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        containerView = UIView()
        guard let containerView else {
            return
        }
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        metalView = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        guard let metalView else {
            return
        }
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.contentScaleFactor = 1
        metalView.framebufferOnly = true
        metalView.preferredFramesPerSecond = 60
        if #available(iOS 26, *) {
            metalView.clipsToBounds = true
            metalView.cornerConfiguration = .corners(radius: .fixed(16.0))
        } else {
            metalView.clipsToBounds = true
            metalView.layer.cornerCurve = .continuous
            metalView.layer.cornerRadius = 16.0
        }
        if !iPhone {
            containerView.addSubview(metalView)
        } else {
            view.addSubview(metalView)
        }
        
        let settingsConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "ellipsis"), nil, .medium)
        settingsButton = .button(with: settingsConfiguration,
                                 actions: ({ _ in }, { _ in }), UIMenu(children: []))
        guard let settingsButton else {
            return
        }
        view.addSubview(settingsButton)
        
        
        let selectConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "minus"), nil, .medium)
        selectButton = .button(with: selectConfiguration, actions: ({ _ in
            button_press(PSVButton.select.int32)
        }, { _ in
            button_release(PSVButton.select.int32)
        }))
        guard let selectButton else {
            return
        }
        view.addSubview(selectButton)
        
        let startConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "plus"), nil, .medium)
        startButton = .button(with: startConfiguration, actions: ({ _ in
            button_press(PSVButton.start.int32)
        }, { _ in
            button_release(PSVButton.start.int32)
        }))
        guard let startButton else {
            return
        }
        view.addSubview(startButton)
        
        leftThumbstickView = ThumbstickView()
        guard let leftThumbstickView else {
            return
        }
        leftThumbstickView.translatesAutoresizingMaskIntoConstraints = false
        leftThumbstickView.label?.text = "L3"
        leftThumbstickView.didClick = {
            // bridgeSwift.press(button: .l3, slot: .one)
        }
        leftThumbstickView.didUnclick = {
            // bridgeSwift.release(button: .l3, slot: .one)
        }
        leftThumbstickView.didDrag = { point in
            drag_down(0, Int16(point.x))
            drag_down(1, Int16(point.y))
        }
        leftThumbstickView.didUndrag = {
            drag_up(0)
            drag_up(1)
        }
        view.addSubview(leftThumbstickView)
        
        rightThumbstickView = ThumbstickView()
        guard let rightThumbstickView else {
            return
        }
        rightThumbstickView.translatesAutoresizingMaskIntoConstraints = false
        rightThumbstickView.label?.text = "R3"
        rightThumbstickView.didClick = {
            // bridgeSwift.press(button: .r3, slot: .one)
        }
        rightThumbstickView.didUnclick = {
            // bridgeSwift.release(button: .r3, slot: .one)
        }
        rightThumbstickView.didDrag = { point in
            drag_down(2, Int16(point.x))
            drag_down(3, Int16(point.y))
        }
        rightThumbstickView.didUndrag = {
            drag_up(2)
            drag_up(3)
        }
        view.addSubview(rightThumbstickView)
        
        let upConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.up"))
        upButton = .button(with: upConfiguration, actions: ({ _ in
            button_press(PSVButton.up.int32)
        }, { _ in
            button_release(PSVButton.up.int32)
        }))
        guard let upButton else {
            return
        }
        view.addSubview(upButton)
        
        let downConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.down"))
        downButton = .button(with: downConfiguration, actions: ({ _ in
            button_press(PSVButton.down.int32)
        }, { _ in
            button_release(PSVButton.down.int32)
        }))
        guard let downButton else {
            return
        }
        view.addSubview(downButton)
        
        let leftConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.left"))
        leftButton = .button(with: leftConfiguration, actions: ({ _ in
            button_press(PSVButton.left.int32)
        }, { _ in
            button_release(PSVButton.left.int32)
        }))
        guard let leftButton else {
            return
        }
        view.addSubview(leftButton)
        
        let rightConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.right"))
        rightButton = .button(with: rightConfiguration, actions: ({ _ in
            button_press(PSVButton.right.int32)
        }, { _ in
            button_release(PSVButton.right.int32)
        }))
        guard let rightButton else {
            return
        }
        view.addSubview(rightButton)
        
        var crossConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "xmark"), nil, nil, .systemBlue)
        crossConfiguration.baseForegroundColor = .systemBlue
        crossButton = .button(with: crossConfiguration, actions: ({ _ in
            button_press(PSVButton.cross.int32)
        }, { _ in
            button_release(PSVButton.cross.int32)
        }))
        guard let crossButton else {
            return
        }
        view.addSubview(crossButton)
        
        var circleConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "circle"), nil, nil, .systemOrange)
        circleConfiguration.baseForegroundColor = .systemOrange
        circleButton = .button(with: circleConfiguration, actions: ({ _ in
            button_press(PSVButton.circle.int32)
        }, { _ in
            button_release(PSVButton.circle.int32)
        }))
        guard let circleButton else {
            return
        }
        view.addSubview(circleButton)
        
        var triangleConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "triangle"), nil, nil, .systemGreen)
        triangleConfiguration.baseForegroundColor = .systemGreen
        triangleButton = .button(with: triangleConfiguration, actions: ({ _ in
            button_press(PSVButton.triangle.int32)
        }, { _ in
            button_release(PSVButton.triangle.int32)
        }))
        guard let triangleButton else {
            return
        }
        view.addSubview(triangleButton)
        
        var squareConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "square"), nil, nil, .systemPink)
        squareConfiguration.baseForegroundColor = .systemPink
        squareButton = .button(with: squareConfiguration, actions: ({ _ in
            button_press(PSVButton.square.int32)
        }, { _ in
            button_release(PSVButton.square.int32)
        }))
        guard let squareButton else {
            return
        }
        view.addSubview(squareButton)
        
        let l1Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "L1")
        l1Button = .button(with: l1Configuration, actions: ({ _ in
            button_press(PSVButton.l1.int32)
        }, { _ in
            button_release(PSVButton.l1.int32)
        }))
        guard let l1Button else {
            return
        }
        view.addSubview(l1Button)
        
        let l2Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "L2")
        l2Button = .button(with: l2Configuration, actions: ({ _ in
            drag_down(PSVButton.l2.int32, Int16.max)
        }, { _ in
            drag_up(PSVButton.l2.int32)
        }))
        guard let l2Button else {
            return
        }
        view.addSubview(l2Button)
        
        let r1Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "R1")
        r1Button = .button(with: r1Configuration, actions: ({ _ in
            button_press(PSVButton.r1.int32)
        }, { _ in
            button_release(PSVButton.r1.int32)
        }))
        guard let r1Button else {
            return
        }
        view.addSubview(r1Button)
        
        let r2Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "R2")
        r2Button = .button(with: r2Configuration, actions: ({ _ in
            drag_down(PSVButton.r2.int32, Int16.max)
        }, { _ in
            drag_up(PSVButton.r2.int32)
        }))
        guard let r2Button else {
            return
        }
        view.addSubview(r2Button)
        
        if iPhone {
            constraints.portrait.append(contentsOf: [
                metalView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: 20.0),
                metalView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: 20.0),
                metalView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -20.0),
                metalView.heightAnchor.constraint(equalTo: metalView.safeAreaLayoutGuide.widthAnchor,
                                                  multiplier: 9.0 / 16.0),
                
                settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: -20.0),
                settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -20.0),
                selectButton.trailingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.leadingAnchor,
                                                       constant: -20.0),
                
                startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20.0),
                startButton.leadingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: 20.0),
                
                crossButton.bottomAnchor.constraint(equalTo: startButton.safeAreaLayoutGuide.topAnchor),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: selectButton.safeAreaLayoutGuide.topAnchor),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2)
            ])
            
            constraints.landscape.append(contentsOf: [
                metalView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: 20.0),
                metalView.bottomAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.topAnchor,
                                                  constant: -20.0),
                metalView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                metalView.widthAnchor.constraint(equalTo: metalView.safeAreaLayoutGuide.heightAnchor,
                                                 multiplier: 16.0 / 9.0),
                
                settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: -20.0),
                settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20.0),
                startButton.leadingAnchor.constraint(equalTo: metalView.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: 20),
                
                selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -20.0),
                selectButton.trailingAnchor.constraint(equalTo: metalView.safeAreaLayoutGuide.leadingAnchor,
                                                       constant: -20.0),
                
                crossButton.bottomAnchor.constraint(equalTo: startButton.safeAreaLayoutGuide.topAnchor,
                                                    constant: -20),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: selectButton.safeAreaLayoutGuide.topAnchor,
                                                   constant: -20),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2)
            ])
        } else {
            constraints.portrait.append(contentsOf: [
                containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                containerView.bottomAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.topAnchor, constant: -20),
                containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                
                metalView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
                metalView.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerYAnchor),
                metalView.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor, constant: -40.0),
                metalView.heightAnchor.constraint(equalTo: metalView.safeAreaLayoutGuide.widthAnchor,
                                                  multiplier: 9.0 / 16.0),
                
                settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: -20.0),
                settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -20.0),
                selectButton.trailingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.leadingAnchor,
                                                       constant: -20.0),
                
                startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20.0),
                startButton.leadingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: 20.0),
                
                crossButton.bottomAnchor.constraint(equalTo: startButton.safeAreaLayoutGuide.topAnchor),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: selectButton.safeAreaLayoutGuide.topAnchor),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2)
            ])
            
            constraints.landscape.append(contentsOf: [
                containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                containerView.bottomAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.topAnchor, constant: -20),
                containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                
                metalView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
                metalView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor,
                                               constant: 20),
                metalView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor,
                                                  constant: -20),
                metalView.widthAnchor.constraint(equalTo: metalView.safeAreaLayoutGuide.heightAnchor,
                                                 multiplier: 16.0 / 9.0),
                
                crossButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                   constant: -20),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: -20.0),
                settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                startButton.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                startButton.trailingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                
                selectButton.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                selectButton.leadingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor)
            ])
        }
        
#if targetEnvironment(simulator)
        view.addConstraints(constraints.portrait)
#else
        switch interfaceOrientation() {
        case .portrait:
            view.addConstraints(constraints.portrait)
        case .landscapeLeft, .landscapeRight:
            view.addConstraints(constraints.landscape)
        default:
            view.addConstraints(constraints.portrait)
        }
#endif
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in } completion: { context in
            switch self.interfaceOrientation() {
            case .portrait:
                self.view.removeConstraints(self.constraints.landscape)
                self.view.addConstraints(self.constraints.portrait)
            case .landscapeLeft, .landscapeRight:
                self.view.removeConstraints(self.constraints.portrait)
                self.view.addConstraints(self.constraints.landscape)
            default:
                break
            }
            
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    var running: Bool = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !titleId.isEmpty, !running else {
            return
        }
        
        running = true
        
        guard let metalView else {
            return
        }
        
        let width = metalView.bounds.width
        let height = metalView.bounds.height
        let titleide = titleId
        
        guard let dir = Bundle.main.resourceURL else {
            return
        }
        
        Thread.setThreadPriority(1.0)
        Thread.detachNewThread {
            Task {
                await MainActor.run {
                    guard let layer = metalView.layer as? CAMetalLayer else {
                        return
                    }
                    
                    boot_game(std.string(titleide), std.string(dir.appending(component: "fonts").path), Unmanaged.passUnretained(layer).toOpaque(), UInt32(width), UInt32(height))
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let metalView, let touch: UITouch = touches.first, touch.view == metalView else {
            return
        }
        
        let point = touch.location(in: metalView)
        
        let vitaX = point.x * metalView.contentScaleFactor
        let vitaY = point.y * metalView.contentScaleFactor
        
        update_touch_position(Float(vitaX), Float(vitaY), true, true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        update_touch_position(0, 0, false, false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let metalView, let touch: UITouch = touches.first, touch.view == metalView else {
            return
        }
        
        let point = touch.location(in: metalView)
        
        let vitaX = point.x * metalView.contentScaleFactor
        let vitaY = point.y * metalView.contentScaleFactor
        
        update_touch_position(Float(vitaX), Float(vitaY), true, true)
    }
}
