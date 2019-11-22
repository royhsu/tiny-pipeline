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
