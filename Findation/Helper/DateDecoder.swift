//
//  DateDecoder.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/5/25.
//

import Foundation

enum DateDecoderFactory {
    static func iso8601WithFractionalSecondsDecoder() -> JSONDecoder {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
            .withColonSeparatorInTimeZone
        ]
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            guard let date = isoFormatter.date(from: dateStr) else {
                throw DecodingError.dataCorruptedError(in: container,
                    debugDescription: "날짜 포맷이 ISO8601 형식이 아님: \(dateStr)")
            }
            return date
        }
        return decoder
    }
}
