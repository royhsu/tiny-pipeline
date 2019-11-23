// MARK: - DuplexID

import Foundation

public struct DuplexID {
        
    public var rawValue: UUID
    
    public init(rawValue: UUID = UUID()) { self.rawValue = rawValue }

}

// MARK: - RawRepresentable

extension DuplexID: RawRepresentable { }

// MARK: - Hashable

extension DuplexID: Hashable { }
