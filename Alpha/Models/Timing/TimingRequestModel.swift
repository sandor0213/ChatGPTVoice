//
//  TimingRequestModel.swift
//  Alpha
//
//  Created by alex on 09.02.2023.
//

import Foundation

struct TimingRequestModel: Codable {
    let speechInputDuration, serverRequestDuration, voiceFeedbackDuration: Double?
    let questionID, userID: Int?

    enum CodingKeys: String, CodingKey {
        case speechInputDuration = "speech_input_duration"
        case serverRequestDuration = "server_request_duration"
        case voiceFeedbackDuration = "voice_feedback_duration"
        case questionID = "question_id"
        case userID = "user_id"
    }
}
