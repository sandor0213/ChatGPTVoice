//
//  ViewController.swift
//  ChildQuestionApp
//
//  Created by alex on 07.02.2023.
//

import UIKit
import AVFoundation
import Speech

final class ViewController: UIViewController {
    
    private struct Constant {
        static let localeIdUkr = "uk"
        static let localeIdEng = "en-US"
        static let localeId = localeIdEng
        static let defaultAgeKey = "defaultAge"
    }
    
    @IBOutlet weak var recognitionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var recognizeSpeechButton: UIButton!
    @IBOutlet weak var textToSpeechButton: UIButton!
    @IBOutlet weak var pickerBackView: UIView!
    @IBOutlet weak var agePickerView: UIPickerView!
    @IBOutlet weak var editAgeButton: UIButton!
    
    private var audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: Constant.localeId))
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isRecording = false
    
    private let ages = (2...17).map({ $0 })
    private var durationArray: [Double] = []
    private var questionId = -1
    private let synth = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.integer(forKey: Constant.defaultAgeKey) == 0 {
            UserDefaults.standard.set(5, forKey: Constant.defaultAgeKey)
        }
        synth.delegate = self
        requestSpeechAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editAgeButton.semanticContentAttribute = .forceRightToLeft
        changeDefaultAge()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        synth.stopSpeaking(at: .immediate)
    }
    
    @IBAction func recognizeSpeechAction(_ sender: UIButton) {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @IBAction func readRecognizedTextAction(_ sender: Any) {
        guard !answerTextView.text.isEmpty else { return }
        recognizeSpeechButton.isEnabled = false
        textToSpeechButton.isEnabled = false
        if isRecording {
            stopRecording()
        }
        textToSpeech(text: answerTextView.text, language: Constant.localeId)
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        NetworkManager.Authorization.signOut { [weak self] result in
            switch result {
            case .success:
                UserDefaults.standard.set(5, forKey: Constant.defaultAgeKey)
                UserDefaults.standard.removeObject(forKey: Constants.authorizationTokenKey)
                UserDefaults.standard.removeObject(forKey: Constants.userIdKey)
                self?.navigationController?.pushViewController(UIStoryboard.controller(.main, type: LoginViewController.self, identifier: .loginViewController), animated: true)
            case .failure(let error):
                self?.presentAlert(withTitle: "An error occurred. Please try again later", message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func editAgeAction(_ sender: Any) {
        agePickerView.selectRow(ages.firstIndex(of: UserDefaults.standard.integer(forKey: Constant.defaultAgeKey)) ?? 3, inComponent: 0, animated: false)
        pickerBackView.isHidden = false
    }
    
    @IBAction func doneAction(_ sender: Any) {
        UserDefaults.standard.set(ages[agePickerView.selectedRow(inComponent: 0)], forKey: Constant.defaultAgeKey)
        changeDefaultAge()
        pickerBackView.isHidden = true
    }
}

private extension ViewController {
    func changeDefaultAge() {
        editAgeButton.setTitle("Age: \(UserDefaults.standard.integer(forKey: Constant.defaultAgeKey)) ", for: .normal)
    }
    
    func startRecording() {
        durationArray = [CACurrentMediaTime()]
        textToSpeechButton.isEnabled = false
        recognitionTextView.text = ""
        answerTextView.text = ""
        recordAndRecognizeSpeech()
        isRecording = true
        recognizeSpeechButton.backgroundColor = UIColor.red
        recognizeSpeechButton.setTitle("Stop", for: .normal)
    }
    
    func stopRecording() {
        durationArray.append(CACurrentMediaTime())
        textToSpeechButton.isEnabled = true
        cancelRecording()
        isRecording = false
        recognizeSpeechButton.backgroundColor = UIColor.clear
        recognizeSpeechButton.setTitle("Recognize Speech", for: .normal)
        recognizeSpeechButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.sendQuestion()
        }
    }
    
    //MARK: - Set up AudioSession (for using default microphone)
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setMode(AVAudioSession.Mode.default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    func sendQuestion() {
        durationArray.append(CACurrentMediaTime())
        NetworkManager.Speech.questions(model: QuestionRequestModel(question: Question(text: recognitionTextView.text, age: UserDefaults.standard.integer(forKey: Constant.defaultAgeKey), clientInfo: "\(UIDevice.current.systemVersion)"))) { [weak self] result in
            self?.durationArray.append(CACurrentMediaTime())
            switch result {
            case .success(let model):
                self?.questionId = model.question?.id ?? -1
                self?.answerTextView.text = model.question?.response?.text?.replacingOccurrences(of: "\n\n", with: "") ?? ""
                self?.textToSpeech(text: self?.answerTextView.text ?? "", language: Constant.localeId)
            case .failure:
                self?.recognizeSpeechButton.isEnabled = true
            }
        }
    }
    
    func sendTimings() {
        if durationArray.indices.contains(5) {
            NetworkManager.Speech.timings(model: TimingRequestModel(speechInputDuration: durationArray[1] - durationArray[0], serverRequestDuration: durationArray[3] - durationArray[2], voiceFeedbackDuration: durationArray[5] - durationArray[4], questionID: questionId, userID: UserDefaults.standard.integer(forKey: Constants.userIdKey))) { _ in }
        }
    }
}

extension ViewController: SFSpeechRecognizerDelegate {
    //MARK: - Cancel Recording
    func cancelRecording() {
        recognitionTask?.finish()
        recognitionTask = nil
        
        //MARK: - Stop audio
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    //MARK: - Recognize Speech
    func recordAndRecognizeSpeech() {
        setupAudioSession()
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            presentAlert(withTitle: "Speech Recognizer Error", message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            presentAlert(withTitle: "Speech Recognizer Error", message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            presentAlert(withTitle: "Speech Recognizer Error", message: "Speech recognition is not currently available. Check back at a later time.")
            return
        }
        
        //MARK: - Convert speech to text
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [weak self] result, error in
            if let result = result {
                self?.recognitionTextView.text = result.bestTranscription.formattedString
            } else if let error = error {
                print(error)
            }
        })
    }
    
    //MARK: - Check Authorization Status
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recognizeSpeechButton.isEnabled = true
                case .denied:
                    self.recognizeSpeechButton.isEnabled = false
                    self.recognitionTextView.text = "User denied access to speech recognition"
                case .restricted:
                    self.recognizeSpeechButton.isEnabled = false
                    self.recognitionTextView.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.recognizeSpeechButton.isEnabled = false
                    self.recognitionTextView.text = "Speech recognition not yet authorized"
                @unknown default:
                    return
                }
            }
        }
    }
}

//MARK: - Text To Speech
private extension ViewController {
    func textToSpeech(text: String, language: String) {
        durationArray.append(CACurrentMediaTime())
        setupAudioSession()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        synth.speak(utterance)
    }
}

extension ViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        textToSpeechButton.isEnabled = true
        recognizeSpeechButton.isEnabled = true
        durationArray.append(CACurrentMediaTime())
        sendTimings()
    }
}

//MARK: - PickerView
extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        ages.count
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(ages[row])"
    }
}
