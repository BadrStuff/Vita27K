//
//  SceneDelegate.swift
//  Vion
//
//  Created by Jarrod Norwell on 4/5/2026.
//

import UIKit

actor TempOnboardingModal {
    @MainActor
    func preInstallFirmware(controller: UIViewController) async {
        var firmwareController: OBController {
            let textFont: UIFont = if #available(iOS 17.0, *) {
                UIFont.regular(from: .extraLargeTitle)
            } else {
                UIFont.regular(from: .largeTitle)
            }
            
            let image: UIImage? = UIImage(systemName: "shippingbox.fill")
            
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: textFont,
                                                                           text: "Pre-Install Firmware")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: UIFont.regular(from: .body),
                                                                                    text: "Download the pre-install firmware in preparation for first use")
            
            let tertiaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                   color: .tertiaryLabel,
                                                                                   font: UIFont.regular(from: .callout),
                                                                                   text: "~123 MB")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, UIImage(systemName: "arrow.down")), { controller in
                    guard let url: URL = URL(string: "https://github.com/vion-app-org/RequiredFiles/releases/download/1.0/PREINSTALL.PUP"),
                          UIApplication.shared.canOpenURL(url) else {
                        return
                    }
                    
                    UIApplication.shared.open(url)
                }),
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    await self.firmware(controller: controller)
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: tertiaryTextConfiguration,
                                                                                     buttons: buttons, colors: Colour.vibrantBlues)
            
            let obController: OBController = OBController(configuration: configuration)
            obController.modalPresentationStyle = .fullScreen
            return obController
        }
        
        controller.present(firmwareController, animated: true)
    }
    
    @MainActor
    func firmware(controller: UIViewController) async {
        var fontPackageController: OBController {
            let textFont: UIFont = if #available(iOS 17.0, *) {
                UIFont.regular(from: .extraLargeTitle)
            } else {
                UIFont.regular(from: .largeTitle)
            }
            
            let image: UIImage? = UIImage(systemName: "memorychip.fill")
            
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: textFont,
                                                                           text: "Firmware")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: UIFont.regular(from: .body),
                                                                                    text: "Download the firmware in preparation for first use")
            
            let tertiaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                   color: .tertiaryLabel,
                                                                                   font: UIFont.regular(from: .callout),
                                                                                   text: "~134 MB")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, UIImage(systemName: "arrow.down")), { controller in
                    guard let url: URL = URL(string: "http://dsa01.psv.update.playstation.net/update/psv/image/2022_0209/rel_f2c7b12fe85496ec88a0391b514d6e3b/PSVUPDAT.PUP"),
                          UIApplication.shared.canOpenURL(url) else {
                        return
                    }
                    
                    UIApplication.shared.open(url)
                }),
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    await self.fontPackage(controller: controller)
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: tertiaryTextConfiguration,
                                                                                     buttons: buttons, colors: Colour.vibrantBlues)
            
            let obController: OBController = OBController(configuration: configuration)
            obController.modalPresentationStyle = .fullScreen
            return obController
        }
        
        controller.present(fontPackageController, animated: true)
    }
    
    @MainActor
    func fontPackage(controller: UIViewController) async {
        var fontPackageController: OBController {
            let textFont: UIFont = if #available(iOS 17.0, *) {
                UIFont.regular(from: .extraLargeTitle)
            } else {
                UIFont.regular(from: .largeTitle)
            }
            
            let image: UIImage? = UIImage(systemName: "character")
            
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: textFont,
                                                                           text: "Font Package")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: UIFont.regular(from: .body),
                                                                                    text: "Download the font package in preparation for first use")
            
            let tertiaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                   color: .tertiaryLabel,
                                                                                   font: UIFont.regular(from: .callout),
                                                                                   text: "~54 MB")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, UIImage(systemName: "arrow.down")), { controller in
                    guard let url: URL = URL(string: "https://github.com/vion-app-org/RequiredFiles/releases/download/1.0/FONTPKG.PUP"),
                          UIApplication.shared.canOpenURL(url) else {
                        return
                    }
                    
                    UIApplication.shared.open(url)
                }),
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    await self.whatsNew(controller: controller)
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: tertiaryTextConfiguration,
                                                                                     buttons: buttons, colors: Colour.vibrantBlues)
            
            let obController: OBController = OBController(configuration: configuration)
            obController.modalPresentationStyle = .fullScreen
            return obController
        }
        
        controller.present(fontPackageController, animated: true)
    }
    
    @MainActor
    func whatsNew(controller: UIViewController) async {
        var fontPackageController: OBControllerWithList {
            let textFont: UIFont = if #available(iOS 17.0, *) {
                UIFont.regular(from: .extraLargeTitle)
            } else {
                UIFont.regular(from: .largeTitle)
            }
            
            let image: UIImage? = UIImage(systemName: "sparkles")
            
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: textFont,
                                                                           text: "What's New")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: UIFont.regular(from: .body),
                                                                                    text: "What's new in the latest version of Vion")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    UserDefaults.standard.set(true, forKey: "vion.1.0.3.onboardingComplete")
                    
                    DispatchQueue.main.async {
                        let viewController: TabController = TabController()
                        viewController.modalPresentationStyle = .fullScreen
                        controller.present(viewController, animated: true)
                    }
                })
            ]
            
            let cells: [CellConfiguration] = [
                CellConfiguration(image: UIImage(systemName: "square.stack.3d.down.forward.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Onboarding"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Onboarding makes it easier than ever to set up Vion by prompting users to download the required files")
                ))
            ]
            
            let configuration: OBControllerWithListConfiguration = OBControllerWithListConfiguration(image: image,
                                                                                                     textConfiguration: textConfiguration,
                                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                                     tertiaryConfiguration: nil,
                                                                                                     buttons: buttons, cells: cells)
            
            let obController: OBControllerWithList = OBControllerWithList(configuration: configuration)
            obController.modalPresentationStyle = .overFullScreen
            return obController
        }
        
        controller.present(fontPackageController, animated: true)
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow? = nil
    
    var onboardingModel: TempOnboardingModal = TempOnboardingModal()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print_about()
        if let documentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            initialize_folders(std.string(documentDirectoryURL.path))
        }
        
        guard let windowScene: UIWindowScene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: windowScene)
        guard let window: UIWindow else {
            return
        }
        
        Task {
            let onboardingComplete: Bool = UserDefaults.standard.bool(forKey: "vion.1.0.3.onboardingComplete")
            
            var onboardingController: OBController {
                let textFont: UIFont = if #available(iOS 17.0, *) {
                    UIFont.regular(from: .extraLargeTitle)
                } else {
                    UIFont.regular(from: .largeTitle)
                }
                
                let image: UIImage? = UIImage(systemName: "shippingbox.fill")
                
                let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                               color: .label,
                                                                               font: textFont,
                                                                               text: "Vion")
                
                let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                        color: .secondaryLabel,
                                                                                        font: UIFont.regular(from: .body),
                                                                                        text: "PlayStation Vita emulation in the palm of your hands")
                
                let tertiaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                       color: .tertiaryLabel,
                                                                                       font: UIFont.regular(from: .callout),
                                                                                       text: "Developed by Jarrod Norwell\nLicensed under GPLv3")
                
                let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                    (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                        await self.onboardingModel.preInstallFirmware(controller: controller)
                    })
                ]
                
                let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                         textConfiguration: textConfiguration,
                                                                                         secondaryConfiguration: secondaryTextConfiguration,
                                                                                         tertiaryConfiguration: tertiaryTextConfiguration,
                                                                                         buttons: buttons, colors: Colour.vibrantBlues)
                
                return OBController(configuration: configuration)
            }
            
            window.rootViewController = if onboardingComplete {
                TabController()
            } else {
                onboardingController
            }
        }
        
        window.tintColor = .systemBlue
        window.makeKeyAndVisible()
        
        extractAndCopyResourcesFolder()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
    
    fileprivate func extractAndCopyResourcesFolder() {
        if let documentDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let resourcesDirectoryURL: URL = documentDirectoryURL.appending(component: "static_assets")
                .appending(component: "shaders-builtin")
            if FileManager.default.fileExists(atPath: resourcesDirectoryURL.path) {
                do {
                    try FileManager.default.removeItem(at: resourcesDirectoryURL)
                } catch {
                    print(#file, #function, #line, error, error.localizedDescription)
                }
            }
            
            if let resourcesZipURL: URL = Bundle.main.url(forResource: "shaders-builtin", withExtension: "zip", subdirectory: "zips") {
                unzip_file(resourcesZipURL.path, resourcesDirectoryURL.path)
                
                let macosxDirectoryURL: URL = resourcesDirectoryURL.appending(component: "__MACOSX")
                if FileManager.default.fileExists(atPath: macosxDirectoryURL.path) {
                    do {
                        try FileManager.default.removeItem(at: macosxDirectoryURL)
                    } catch {
                        print(#file, #function, #line, error, error.localizedDescription)
                    }
                }
            }
        }
    }
}
