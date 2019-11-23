import TinyCombine

final class NewPipeline<Success, Failure> where Failure: Error {
    
    // The inbound.
    private let inboundConnection = DuplexBoundConnection<Success, Failure>()
    
    // The outbound.
    private let outboundConnection = DuplexBoundConnection<Success, Failure>()
    
    init(_ elements: [Duplex<Success, Failure>]) {
        
        
    }
    
    func execute(block: @escaping () -> Void) {
        
        
        
    }
    
}
