// MARK: - Duplex

import Combine

public struct Duplex<Success, Failure> where Failure: Error {
    
    public typealias Bound = (DuplexID, DuplexBoundContext<Success, Failure>) -> AnyPublisher<Success, Failure>
    
    public var id: DuplexID
    
    public var inbound: Bound
    
    public var outbound: Bound

}

extension Duplex {
    
    public init(inbound: @escaping Bound, outboud: @escaping Bound) {
        
        self.init(id: DuplexID(), inbound: inbound, outbound: outboud)
        
    }
    
}

