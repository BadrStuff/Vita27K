//
//  GamesController.swift
//  Vita27K
//
//

import UIKit

class GamesController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<String, Game>? = nil
    var snapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    
    enum FileInstallType {
        case pkg, vpk, firmware, license, unknown
    }
    
    var fileInstallType: FileInstallType = .pkg
    
    var firmwareVersion: String {
        if let firmwareVersionString: String = UserDefaults.standard.string(forKey: "firmwareVersion") {
            if firmware_installed() {
                firmwareVersionString
            } else {
                "No Firmware"
            }
        } else {
            "No Firmware"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        if #available(iOS 26.0, *) {
            navigationItem.largeTitle = "Games"
            navigationItem.largeSubtitle = "PlayStation Vita"
        } else {
            navigationItem.title = "Games"
        }
        
        var configuration: UIButton.Configuration = if #available(iOS 26.0, *) {
            .prominentClearGlass()
        } else {
            .filled()
        }
        configuration.attributedTitle = AttributedString(firmwareVersion, attributes: AttributeContainer([
            .font : UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
        ]))
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = firmware_installed() ? .systemGreen : .systemOrange
        configuration.baseForegroundColor = .white
        
        navigationItem.trailingItemGroups = [
            UIBarButtonItemGroup.fixedGroup(items: [
                UIBarButtonItem(customView: UIButton(configuration: configuration))
            ]),
            UIBarButtonItemGroup.fixedGroup(items: [
                UIBarButtonItem(image: UIImage(systemName: "plus"), menu: UIMenu(children: [
                    UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                        UIAction(title: "FW", image: UIImage(systemName: "memorychip")) { action in
                            self.alertForFirmwareInstallation()
                        },
                        UIAction(title: "PKG", image: UIImage(systemName: "shippingbox")) { action in
                            self.alertForPKGInstallation()
                        },
                        UIAction(title: "ZIP, VPK", image: UIImage(systemName: "zipper.page")) { action in
                            self.alertForZIPVPKInstallation()
                        }
                    ]),
                    UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                        UIAction(title: "License", image: UIImage(systemName: "licenseplate")) { action in
                            self.alertForLicenseInstallation()
                        }
                    ])
                ]))/*,
                UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: UIMenu(preferredElementSize: .medium, children: [
                    UIAction(title: "About Vita27K", image: UIImage(systemName: "info")) { action in
                        
                    },
                    UIAction(title: "Exit", image: UIImage(systemName: "xmark"), attributes: .destructive) { action in
                        
                    }
                ]))*/
            ])
        ]
        navigationItem.style = .browser
        if #available(iOS 26.0, *) {
            navigationItem.title = navigationItem.largeTitle
            navigationItem.subtitle = navigationItem.largeSubtitle
        }
        view.backgroundColor = .systemBackground
        
        
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction { action in
                if let refreshControl: UIRefreshControl = action.sender as? UIRefreshControl {
                    refreshControl.beginRefreshing()
                    
                    Task {
                        await self.populate()
                    }
                    
                    refreshControl.endRefreshing()
                }
            })
        
        let headerCellRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader ) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            if let dataSource: UICollectionViewDiffableDataSource = self.dataSource,
               let letter: String = dataSource.sectionIdentifier(for: indexPath.section) {
                contentConfiguration.text = letter.uppercased()
            }
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        let cellRegistration: UICollectionView.CellRegistration<Cell, Game> = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.set(game: itemIdentifier, controller: self)
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        guard let dataSource else {
            return
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary( using: headerCellRegistration, for: indexPath)
        }
        
        snapshot = NSDiffableDataSourceSnapshot()
        
        Task {
            await populate()
        }
    }
    
    func populate() async {
        guard let dataSource, var snapshot else {
            return
        }
        
        let apps = scan_and_get_apps()
        
        let appsMappedToGames: [Game] = apps.map { applicationEntry in
            Game(applicationEntry: applicationEntry)
        }
        
        let letters: [String] = Array(Set(appsMappedToGames.map { game in
            game.details.title.prefix(1).uppercased()
        })).sorted()
        
        snapshot.appendSections(letters)
        snapshot.sectionIdentifiers.forEach { letter in
            snapshot.appendItems(appsMappedToGames.filter { game in
                game.details.title.prefix(1).uppercased() == letter
            }.sorted(), toSection: letter)
        }
        
        await dataSource.apply(snapshot)
    }
    
    func openDocumentPickerForInstall() {
        let documentPickerController: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [.item],
                                                                                                      asCopy: true)
        documentPickerController.delegate = self
        present(documentPickerController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let dataSource, let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let emulationController: EmulationController = EmulationController(titleId: item.details.path)
        emulationController.modalPresentationStyle = .fullScreen
        present(emulationController, animated: true)
    }
}

// MARK: PKG Install
extension GamesController {
    func alertForPKGInstallation() {
        let alertController: UIAlertController = UIAlertController(title: "Install Package",
                                                                   message: "Select a PKG package file to install its associated package",
                                                                   preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Select File", style: .default) { action in
            self.installPackageFromPKG()
        })
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        alertController.preferredAction = alertController.actions.first
        present(alertController, animated: true)
    }
    
    func installPackageFromPKG() {
        fileInstallType = .pkg
        openDocumentPickerForInstall()
    }
    
    // TODO: clean this up... wow it's bad
    func installPackagePKGs(_ urls: [URL]) {
        Thread.detachNewThread {
            for url in urls {
                let packageHeader: PackageHeader = get_package_header(std.string(url.path), Unmanaged.passUnretained(self).toOpaque())
                zrif_exists(std.string(url.path), packageHeader, { path, zrif, exists, context in
                    guard let context else {
                        return
                    }
                    
                    let gamesController: GamesController = Unmanaged<GamesController>.fromOpaque(context).takeUnretainedValue()
                    
                    if exists {
                        install_package_with_zrif(path, zrif, { progress, result, context in
                            if let context, progress >= 100 {
                                let gamesController: GamesController = Unmanaged<GamesController>.fromOpaque(context).takeUnretainedValue()
                                
                                Task { @MainActor in
                                    let alertController: UIAlertController = UIAlertController(title: "Install Successful",
                                                                                               message: "Successfully installed \(String(get_package_title()))",
                                                                                               preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { action in
                                        Task { @MainActor in
                                            await gamesController.populate()
                                        }
                                    })
                                    alertController.preferredAction = alertController.actions.last
                                    gamesController.present(alertController, animated: true)
                                }
                            }
                        }, Unmanaged.passUnretained(gamesController).toOpaque())
                    } else {
                        // TODO: request user 
                    }
                }, Unmanaged.passUnretained(self).toOpaque())
            }
        }
    }
}

// MARK: ZIP/VPK Install
extension GamesController {
    func alertForZIPVPKInstallation() {
        let alertController: UIAlertController = UIAlertController(title: "Install Package",
                                                                   message: "Select a ZIP/VPK package file to install its associated package",
                                                                   preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Select File", style: .default) { action in
            self.installPackageFromZIPVPK()
        })
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        alertController.preferredAction = alertController.actions.first
        present(alertController, animated: true)
    }
    
    func installPackageFromZIPVPK() {
        fileInstallType = .vpk
        openDocumentPickerForInstall()
    }
    
    // TODO: clean this up... wow it's bad
    func installPackageZIPVPKs(_ urls: [URL]) {
        Thread.detachNewThread {
            for url in urls {
                install_archive(std.string(url.path), { progress, result, context in
                    if let context, progress >= 100 {
                        let gamesController: GamesController = Unmanaged<GamesController>.fromOpaque(context).takeUnretainedValue()
                        
                        Task { @MainActor in
                            let alertController: UIAlertController = UIAlertController(title: "Install Successful",
                                                                                       message: "Successfully installed \(String(get_package_title()))",
                                                                                       preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { action in
                                Task { @MainActor in
                                    await gamesController.populate()
                                }
                            })
                            alertController.preferredAction = alertController.actions.last
                            gamesController.present(alertController, animated: true)
                        }
                    }
                }, Unmanaged.passUnretained(self).toOpaque())
            }
        }
    }
}

// MARK: Firmware Install
extension GamesController {
    func alertForFirmwareInstallation() {
        let alertController: UIAlertController = UIAlertController(title: "Install Firmware",
                                                                   message: "Select a PUP firmware file to install its associated firmware",
                                                                   preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Select File", style: .default) { action in
            self.installFirmwareFromPUP()
        })
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        alertController.preferredAction = alertController.actions.first
        present(alertController, animated: true)
    }
    
    func installFirmwareFromPUP() {
        fileInstallType = .firmware
        openDocumentPickerForInstall()
    }
    
    func installFirmwarePUP(_ url: URL? = nil) {
        guard let url: URL else {
            return
        }
        
        let alertController: UIAlertController = UIAlertController(title: "Installing Firmware", message: "0%", preferredStyle: .alert)
        present(alertController, animated: true)
        
        Thread.detachNewThread {
            let firmwareVersion: std.string = install_firmware(std.string(url.path), { progress, context in
                guard let context else {
                    return
                }
                
                let alertController: UIAlertController = Unmanaged.fromOpaque(context).takeUnretainedValue()
                
                DispatchQueue.main.async {
                    alertController.message = "Installation Progress: \(progress)%"
                }
            }, Unmanaged.passUnretained(alertController).toOpaque())
            
            let firmwareVersionString: String = String(firmwareVersion)
            UserDefaults.standard.set(firmwareVersionString, forKey: "firmwareVersion")
            
            var configuration: UIButton.Configuration = if #available(iOS 26.0, *) {
                .prominentClearGlass()
            } else {
                .filled()
            }
            configuration.attributedTitle = AttributedString(firmwareVersionString, attributes: AttributeContainer([
                .font : UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
            ]))
            configuration.cornerStyle = .capsule
            configuration.baseBackgroundColor = firmware_installed() ? .systemGreen : .systemOrange
            configuration.baseForegroundColor = .white
            
            DispatchQueue.main.async {
                let group = self.navigationItem.trailingItemGroups.removeFirst()
                group.barButtonItems = [UIBarButtonItem(customView: UIButton(configuration: configuration))]
                self.navigationItem.trailingItemGroups.insert(group, at: 0)
                
                alertController.title = "Install Successful"
                alertController.message = "Successfully installed firmware file"
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            }
        }
    }
}

// MARK: License Install
extension GamesController {
    func alertForLicenseInstallation() {
        let alertController: UIAlertController = UIAlertController(title: "Install License",
                                                                   message: "Select a BIN or RIF license file to allow for the associated game to be installed",
                                                                   preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Select File", style: .default) { action in
            self.installLicenseFromBINRIF()
        })
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        alertController.preferredAction = alertController.actions.first
        present(alertController, animated: true)
    }
    
    func installLicenseFromBINRIF() {
        fileInstallType = .license
        openDocumentPickerForInstall()
        if fileInstallType == .unknown {
            fileInstallType = .pkg
        }
    }
    
    func installBINRIFs(_ urls: [URL]) {
        for url in urls {
            var title: String = "Install Successful"
            var message: String = "Successfully installed license file"
            
            if !install_license(std.string(url.path)) {
                title = "Install Unsuccessful"
                message = "Failed to install license file\n\nCheck the log file for more information"
            }
            
            let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alertController, animated: true)
        }
    }
}

extension GamesController : UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        switch fileInstallType {
        case .pkg:
            installPackagePKGs(urls)
        case .vpk:
            installPackageZIPVPKs(urls)
        case .firmware:
            installFirmwarePUP(urls.first)
        case .license, .unknown:
            installBINRIFs(urls)
        }
    }
}
