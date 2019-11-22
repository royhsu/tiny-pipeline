// MARK: - Duplex

import Foundation

struct Duplex {
    
    var id: ID
    
}

// MARK: - ID

extension Duplex {
    
    struct ID {
        
        var rawValue = UUID()
        
    }

}

// MARK: - RawRepresentable

extension Duplex.ID: RawRepresentable { }

// MARK: - Hashable

extension Duplex.ID: Hashable { }
