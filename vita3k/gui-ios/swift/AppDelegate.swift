//
//  AppDelegate.swift
//  Vita27K
//
//  Created by Jarrod Norwell on 4/5/2026.
//

import UIKit

@main class AppDelegate : UIResponder, UIApplicationDelegate {
    
    // Shared state to verify JIT across the app
    static var isJITAvailable: Bool = false

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // DelphiniOS-Style JIT Initialization & Detection
        setupJIT()
        
        return true
    }

    // MARK: - JIT Management (DelphiniOS Style)
    
    private func setupJIT() {
        // 1. Check if JIT is already granted (e.g., attached via StikDebug / AltStore / Jitterbug)
        if checkJITCapability() {
            AppDelegate.isJITAvailable = true
            print("[Vita27K] JIT is already enabled and executable memory is accessible.")
            return
        }
        
        // 2. Attempt automatic JIT attachment (DelphiniOS auto-enable fallback)
        requestAutomaticJIT { success in
            AppDelegate.isJITAvailable = success
            if success {
                print("[Vita27K] JIT successfully acquired via local trigger!")
            } else {
                print("[Vita27K] Warning: JIT could not be automatically enabled. The emulator may run in fallback interpreter mode.")
            }
        }
    }

    /// Tests whether the process is allowed to allocate executable RWX memory pages.
    private func checkJITCapability() -> Bool {
        var addr: UnsafeMutableRawPointer? = nil
        let pageCount = 1
        let pageSize = sysconf(_SC_PAGESIZE)
        
        // Attempt an RWX memory allocation test (Read, Write, Execute)
        let result = mmap(nil, pageSize * pageCount, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_ANON | MAP_PRIVATE, -1, 0)
        
        if result != MAP_FAILED {
            munmap(result, pageSize * pageCount)
            return true
        }
        return false
    }

    /// Triggers local port/debug service discovery to request JIT (similar to DelphiniOS / StikJIT integration)
    private func requestAutomaticJIT(completion: @escaping (Bool) -> Void) {
        // Hook for JITEnabler / StikJIT / SideJITServer trigger
        // In a full implementation, this sends a payload to localhost/debugserver
        DispatchQueue.global(qos: .userInitiated).async {
            let autoEnableSuccess = false // Set to true when integrating a specific helper framework
            DispatchQueue.main.async {
                completion(autoEnableSuccess)
            }
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
