import AVFoundation
import Observation
import Speech

/// Wraps on-device speech-to-text (per the PRD: no cloud dependency or
/// per-use cost). This only produces a transcript — parsing that free text
/// into discrete categorized time blocks is a separate, not-yet-built step.
@Observable
final class SpeechTranscriber {
    enum AuthorizationState {
        case notDetermined, authorized, denied
    }

    var transcript: String = ""
    var isRecording = false
    var authorizationState: AuthorizationState = .notDetermined
    var errorMessage: String?

    /// Rolling buffer of recent input levels (0...1), newest last, for driving a live waveform.
    private(set) var audioLevels: [Float] = Array(repeating: 0, count: 24)

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                let granted = status == .authorized
                self?.authorizationState = granted ? .authorized : .denied
                completion(granted)
            }
        }
    }

    func start() {
        guard !isRecording else { return }
        transcript = ""
        errorMessage = nil

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Couldn't start the microphone."
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if let recognizer, recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.recordLevel(from: buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            errorMessage = "Couldn't start the microphone."
            recognitionRequest = nil
            return
        }
        isRecording = true

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            Task { @MainActor in
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if error != nil || result?.isFinal == true {
                    self.stop()
                }
            }
        }
    }

    func stop() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func recordLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return }
        var sum: Float = 0
        for i in 0..<frameLength { sum += abs(channelData[i]) }
        let level = min(max((sum / Float(frameLength)) * 18, 0), 1)
        Task { @MainActor in
            self.audioLevels.removeFirst()
            self.audioLevels.append(level)
        }
    }
}
