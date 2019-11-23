import TinyCombine

//struct Duplex {
//
//    var inbound: (FirstResolvedElementPipeline.Context) -> Future<Void, Error>
//
//    var outbound: (FirstResolvedElementPipeline.Context) -> Future<Void, Error>
//
//}

final class FirstResolvedElementPipeline {
    
    // The current inbound stream of duplex.
    private var currentInboundStream: AnyCancellable?
    
//    private var currentInboundResultInfo: [Duplex.ID: Result<Void, Error>] = [:]
    
    // The current outbound stream of duplex.
    private var currentOutboundStream: AnyCancellable?
    
//    private var currentOutboundResultInfo: [Duplex.ID: Result<Void, Error>] = [:]
    
    
    init(_ elements: [Duplex]) {
        
        
    }
    
    func execute(block: @escaping (Context) -> Void) {
        
        
        
    }
    
    struct Context {
        
        private(set) var results: [Duplex.ID: Result<Void, Error>]
        
        /// You can use this to get the final result.
        private var pipelineDuplexIDForFinalResult: Result<Void, Error>?
        
        /// Update and reflect the final result.
        /// - parameter id: The id of duplex which produces the given result.
        mutating func updateResult(
            _ result: Result<Void, Error>,
            id: Duplex.ID
        ) {
            
            
            
        }
        
    }
    
}

// MARK: - DuplexBoundContext

struct DuplexBoundContext<Success, Failure> where Failure: Error {
      
    private(set) var resultInfo = DuplexBoundResultInfo<Success, Failure>()
    
    /// You can use this to get the final result.
    private(set) var finalResultID: Duplex.ID?
    
    /// Update and reflect the final result.
    /// - parameter result: The result for a duplex.
    /// - parameter id: The id of duplex which produces the given result.
    mutating func updateResult(
        _ result: Result<Success, Failure>,
        id: Duplex.ID
    ) {
        
        finalResultID = id
        
        resultInfo[id] = result
        
    }
    
}
