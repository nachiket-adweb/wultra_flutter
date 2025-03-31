import Flutter
import UIKit
import WultraSSLPinning
import os.log // Import os.log for logging

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private let log = OSLog(subsystem: "com.example.wultra_ssl_pinning", category: "AppDelegate")

    var certStore: CertStore?

    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        // Set up method channel
        let channel = FlutterMethodChannel(
            name: "com.example.wultra_ssl_pinning",
            binaryMessenger: controller.binaryMessenger
        )
          
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
                case "initCertStore":
                    self?.initCertStore(result: result)
                case "getUpdateOnFingerprints":
                    self?.getUpdateOnFingerprints(result: result)
                default:
                    result(FlutterMethodNotImplemented)
            }
        }
          
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func initCertStore(result: FlutterResult) {
        let configuration = CertStoreConfiguration(
            serviceUrl: URL(string: "https://mus.adwebtech.com:8080/app/init?appName=wultra_flutter_ios")!,
            publicKey: "BJqTD7ccVijKYYlP9lIc22pE795OKikxjyERJZoqTpxHTkt/YnlRUU/3HF8/ZAjBY1M3HFjgsVM5bATtn+BKxN8=",
            useChallenge: true
        )
        certStore = CertStore.powerAuthCertStore(configuration: configuration)
        if certStore != nil {
            os_log("ios>>> CertStore Successfully Initialized", log: log, type: .info)
            result(true) // CertStore initialized successfully
        } else {
            os_log("ios>>> CertStore Failed to Initialize", log: log, type: .error)
            result(false) // CertStore initialization failed
        }
    }
    
    private func getUpdateOnFingerprints(result: @escaping FlutterResult) {
        // Ensure certStore is not nil
        guard let certStore = certStore else {
            os_log("ios>>> CertStore is nil in getUpdateOnFingerprints()", log: log, type: .error)
            result("msg failed: CertStore not initialized")
            return
        }
        certStore.update { (updateResult, error) in
            if updateResult == .ok {
                os_log("ios>>> Update OK:: %{public}@", log: self.log, type: .info, String(describing: updateResult))
                result("msg success") // Fingerprints updated successfully
            } else if updateResult == .storeIsEmpty {
                os_log("ios>>> Update storeIsEmpty:: %{public}@", log: self.log,
                   type: .info,
                   String(describing: updateResult)
                )
                result("Fingerprints updated, but store is empty or expired")
            } else {
                os_log("ios>>> Update Failed:: \nResult: %{public}@, \nError: %{public}@", log: self.log,
                   type: .error,
                   String(describing: updateResult), String(describing: error)
                )
                result("Unknown error")
            }
        }
    }
}
