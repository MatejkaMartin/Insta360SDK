import Foundation

public enum NotificationValue: Encodable, Decodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .integer(let value):
            try container.encode(value)
        case .array(let array):
            try container.encode(array)
        case .bool(let value):
            try container.encode(value)
        case .null: break
        case .object(let value):
            let transformed: [String: NotificationValue] = Dictionary(
                uniqueKeysWithValues:
                    value.map { key, value in (key.rawValue, value) }
            )
            try container.encode(transformed)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        } else if let number = try? container.decode(Float.self) {
            self = .number(number)
            return
        } else if let integer = try? container.decode(Int.self) {
            self = .integer(integer)
            return
        } else if let array = try? container.decode([NotificationValue].self) {
            self = .array(array)
            return
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
            return
        } else if let object = try? container.decode([String: NotificationValue].self)
        {
            let transformed: [NotificationKey: NotificationValue] = Dictionary(
                uniqueKeysWithValues:
                    object.map { key, value in
                        (NotificationKey(rawValue: key)!, value)
                    }
            )
            self = .object(transformed)
            return
        }
        self = .null

    }

    case string(String)
    case number(Float)
    case integer(Int)
    case array([NotificationValue])
    case object([NotificationKey: NotificationValue])
    case bool(Bool)
    case null
}
