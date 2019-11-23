// MARK: - Duplex

import TinyCombine

struct Duplex<Success, Failure> where Failure: Error {
    
    var id = DuplexID()
    
    #warning("TODO: [Priority: high] delete prefix after removing old future type.")
    var inbound: (DuplexID, DuplexBoundContext<Success, Failure>) -> TinyCombine.Future<Success, Failure>
    
    #warning("TODO: [Priority: high] delete prefix after removing old future type.")
    var outbound: (DuplexID, DuplexBoundContext<Success, Failure>) -> TinyCombine.Future<Success, Failure> = { _, context in
        
        // The default outbound only aggregates the given result.
        TinyCombine.Future { $0(context.finalResult!) }
        
    }

}

