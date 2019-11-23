// MARK: - DuplexID

import Foundation

struct DuplexID {
        
    var rawValue = UUID()

}

// MARK: - RawRepresentable

extension DuplexID: RawRepresentable { }

// MARK: - Hashable

extension DuplexID: Hashable { }
