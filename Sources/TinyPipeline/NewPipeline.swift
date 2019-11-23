import TinyCombine

final class NewPipeline<Success, Failure> where Failure: Error {
    
    // The inbound.
    private let inboundConnection = DuplexBoundConnection<Success, Failure>()
    
    // The outbound.
    private let outboundConnection = DuplexBoundConnection<Success, Failure>()
    
    private let elements: [Duplex<Success, Failure>]
    
    init(_ elements: [Duplex<Success, Failure>]) {
        
        guard !elements.isEmpty else {
            
            preconditionFailure("Must contains at least one duplex.")
            
        }
        
        self.elements = elements
        
    }
    
    func execute(completion: @escaping (Result<Success, Failure>) -> Void) {
        
        processRemainingDuplex(completion: completion)
        
    }
    
    private func processRemainingDuplex(
        completion: @escaping (Result<Success, Failure>) -> Void
    ) {
        
        if let (id, bound, kind) = nextDuplex() {

            let connection: DuplexBoundConnection<Success, Failure>
            
            switch kind {
                
            case .inbound: connection = inboundConnection
                
            case .outbound: connection = outboundConnection
                
            }
            
            connection.autoconnect(
                to: bound,
                duplexID: id,
                onDisconnect: {

                    self.processRemainingDuplex(completion: completion)
                    
                }
            )

        }
        else {

            guard
                let finalResult = outboundConnection.boundContext.finalResult
            else { preconditionFailure("Must contain at least one result.") }

            completion(finalResult)

        }
        
    }
    
    private enum DuplexBoundKind {
        
        case inbound, outbound
        
    }
    
    #warning("TODO: [Priority: high] delete prefix after removing old future type.")
    private func nextDuplex()
        -> (id: DuplexID, bound: TinyCombine.Future<Success, Failure>, kind: DuplexBoundKind)? {
        
        let resolvedInboundDuplexIDs = inboundConnection
            .boundContext
            .resultInfo
            .keys
        
        if let nextInboundDuplex = elements.first(
            where: { !resolvedInboundDuplexIDs.contains($0.id) }
        ) {
        
            let inbound = nextInboundDuplex.inbound(
                nextInboundDuplex.id,
                inboundConnection.boundContext
            )
            
            return (nextInboundDuplex.id, inbound, .inbound)
            
        }
            
        let resolvedOutboundDuplexIDs = outboundConnection
            .boundContext
            .resultInfo
            .keys
            
        if let nextOutboundDuplex = elements.first(
            where: { !resolvedOutboundDuplexIDs.contains($0.id) }
        ) {
            
            let isBeginningOfOutbounds = (outboundConnection.boundContext.finalResultID == nil)
            
            let outbound = nextOutboundDuplex.outbound(
                nextOutboundDuplex.id,
                isBeginningOfOutbounds
                    ? inboundConnection.boundContext // The first outbound replies on the result from the last inbound.
                    : outboundConnection.boundContext
            )
            
            return (nextOutboundDuplex.id, outbound, .outbound)
                
        }
                
        return nil
        
    }
    
}
