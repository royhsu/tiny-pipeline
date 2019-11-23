// MARK: - Duplex

import TinyCombine

struct Duplex<Success, Failure> where Failure: Error {
    
    var id = DuplexID()
    
    var inbound: (DuplexID, DuplexBoundContext<Success, Failure>) -> Future<Success, Failure>
    
    var outbound: (DuplexID, DuplexBoundContext<Success, Failure>) -> Future<Success, Failure> = { _, context in
        
        // The default outbound only aggregates the given result.
        Future { $0(context.finalResult!) }
        
    }

}

