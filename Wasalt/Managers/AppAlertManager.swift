//
//  AppAlertManager.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 17/12/2025.
//

import AVFoundation
import Combine

// MARK: - InAppAlertManager → manages in-app alerts (banner + vibration + flash)
final class InAppAlertManager: ObservableObject {

    enum BannerType {
        case approaching
        case arrival
        case wrongDirection
    }

    @Published var isShowingBanner: Bool = false
    @Published var bannerMessage: String = ""
    @Published var isArrival: Bool = false
    @Published var bannerType: BannerType = .approaching

    private var flashTimer: Timer?
    private var isTorchOn: Bool = false
    private var isPatternRunning: Bool = false

    private let maxPatternDuration: TimeInterval = 5
    private let bannerAutoDismiss: TimeInterval = 2 * 60

    func showApproaching(message: String) {
        bannerMessage = message
        isArrival = false
        bannerType = .approaching
        showBanner(shouldUseFlash: false)
    }

    func showArrival(message: String) {
        bannerMessage = message
        isArrival = true
        bannerType = .arrival
        showBanner(shouldUseFlash: true)
    }

    func showWrongDirection(message: String) {
        bannerMessage = message
        isArrival = false
        bannerType = .wrongDirection
        showBanner(shouldUseFlash: false)
    }

    func dismiss() {
        isShowingBanner = false
        bannerMessage = ""
        stopPatternVibrationAndFlash()
    }

    private func showBanner(shouldUseFlash: Bool) {
        isShowingBanner = true
        startPatternVibrationAndFlash(useFlash: shouldUseFlash)

        DispatchQueue.main.asyncAfter(deadline: .now() + bannerAutoDismiss) { [weak self] in
            guard let self = self, self.isShowingBanner else { return }
            self.dismiss()
        }
    }

    private func startPatternVibrationAndFlash(useFlash: Bool) {
        stopPatternVibrationAndFlash()
        isPatternRunning = true

        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            guard let self = self, self.isPatternRunning else { return }
            self.vibrateOnce()
            if useFlash {
                self.toggleTorch()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + maxPatternDuration) { [weak self] in
            self?.stopPatternVibrationAndFlash()
        }
    }

    private func stopPatternVibrationAndFlash() {
        isPatternRunning = false
        flashTimer?.invalidate()
        flashTimer = nil
        setTorch(on: false)
    }

    private func vibrateOnce() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    private func toggleTorch() {
        isTorchOn.toggle()
        setTorch(on: isTorchOn)
    }

    private func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch error:", error.localizedDescription)
        }
    }
}

enum MetroAlertType: Equatable {
    case approaching(stationName: String, etaMinutes: Int)
    case arrival(stationName: String)
    case wrongDirection
}
