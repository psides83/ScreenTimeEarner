//
//  CurrentTimer.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/7/23.
//

import Foundation
import SwiftUI

public struct CurrentTimer: Codable, Identifiable, Equatable {
    public let id: Int
    let status: Status
    let amount: Double
    let total: Double
    
    enum Status: Codable {
        case idle, active, paused
    }

    enum CodingKeys: String, CodingKey {
        case id, status, amount, total
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            id = try Int(values.decode(Int.self, forKey: .id))
        } catch DecodingError.typeMismatch {
            id = try Int(values.decode(String.self, forKey: .id)) ?? 0
        }
        self.status = try values.decode(Status.self, forKey: .status)
        self.amount = try values.decode(Double.self, forKey: .amount)
        self.total = try values.decode(Double.self, forKey: .total)
    }
    
    init(id: Int, status: Status, amount: Double, total: Double) {
        self.id = id
        self.status = status
        self.amount = amount
        self.total = total
    }
}

extension Optional: RawRepresentable where Wrapped == CurrentTimer {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(CurrentTimer.self, from: data)
        else {
            return nil
        }
        
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        
        return result
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CurrentTimer.CodingKeys.self)
        try container.encode(self?.id, forKey: .id)
        try container.encode(self?.status, forKey: .status)
        try container.encode(self?.amount, forKey: .amount)
        try container.encode(self?.total, forKey: .total)
    }
}
