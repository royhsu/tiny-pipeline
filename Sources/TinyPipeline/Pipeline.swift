// MARK: - Pipeline

import TinyCombine

/// Pipeline process duplexes one by one and passing corresponding context between them.
/// The idea is quite similiar to channel pipeline in SwiftNIO.
/// See the following link for more detailed explanation. [How to understand InboundIn InboundOut OutboundOut OutboundIn names](https://forums.swift.org/t/how-to-understand-inboundin-inboundout-outboundout-outboundin-names/30989/5)
public final class Pipeline<Output, Failure> where Failure: Error {
    
    private let inboundConnection = DuplexBoundConnection<Output, Failure>()
    
    private let outboundConnection = DuplexBoundConnection<Output, Failure>()
    
    private let elements: AnyBidirectionalCollection<Duplex<Output, Failure>>
    
    private lazy var future = Future<Output, Failure> { [weak self] promise in
        
        self?.processRemainingDuplexes(completion: promise)
        
    }
    
    public init<C>(_ elements: C)
    where
        C: BidirectionalCollection,
        C.Element == Duplex<Output, Failure> {
        
        guard !elements.isEmpty else {
            
            preconditionFailure("Must contains at least one duplex.")
            
        }
        
        guard Set(elements.map { $0.id }).count == elements.count else {
            
            preconditionFailure("Duplex id must be unique.")
            
        }
        
        self.elements = AnyBidirectionalCollection(elements)
        
    }
    
    private func processRemainingDuplexes(
        completion: @escaping (Result<Output, Failure>) -> Void
    ) {
        
        if let (id, bound, kind) = nextDuplex() {

            let connection: DuplexBoundConnection<Output, Failure>
            
            switch kind {
                
            case .inbound: connection = inboundConnection
                
            case .outbound: connection = outboundConnection
                
            }
            
            connection.autoconnect(
                to: bound,
                duplexID: id,
                onDisconnect: {

                    self.processRemainingDuplexes(completion: completion)
                    
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
    
    private func nextDuplex()
    -> (id: DuplexID, bound: AnyPublisher<Output, Failure>, kind: DuplexBoundKind)? {
        
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
            
        if let nextOutboundDuplex = elements.last(
            where: { !resolvedOutboundDuplexIDs.contains($0.id) }
        ) {
            
            let isBeginningOfOutbounds = (outboundConnection.boundContext.finalResultID == nil)
            
            let outbound = nextOutboundDuplex.outbound(
                nextOutboundDuplex.id,
                isBeginningOfOutbounds
                    ? inboundConnection.boundContext // The first outbound relies on the result from the last inbound.
                    : outboundConnection.boundContext
            )
            
            return (nextOutboundDuplex.id, outbound, .outbound)
                
        }
                
        return nil
        
    }
    
}

// MARK: - Publisher

extension Pipeline: Publisher {

    public func receive<S>(_ subscriber: S)
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure { future.receive(subscriber) }

}
