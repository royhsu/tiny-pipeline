// MARK: - DuplexBoundConnection

import TinyCombine

final class DuplexBoundConnection<Success, Failure> where Failure: Error {

    /// The current connected inbound/outbound stream of duplex.
    private(set) var currentBoundStream: AnyCancellable?
    
    /// Storage for duplex bounds.
    private(set) var boundResultInfo: DuplexBoundResultInfo<Success, Failure> = [:]
    
    /// Connect to the given stream and automatically disconnect on
    /// completion (either .finished or .failure).
    /// - parameter bound: the target bound of duplex.
    /// - parameter duplexID: the duplex id of the given bound.
    /// - parameter onDisconnect: the disconnect handler.
    func autoconnect<Bound>(
        to bound: Bound,
        duplexID: Duplex.ID,
        onDisconnect disconnect: @escaping () -> Void
    )
    where
        Bound: Publisher,
        Bound.Output == Success,
        Bound.Failure == Failure {
        
        precondition(currentBoundStream == nil)
            
        currentBoundStream = bound.sink(
            receiveCompletion: { completion in
              
                defer {
                    
                    self.currentBoundStream = nil
                    
                    disconnect()
                    
                }
                
                switch completion {
                    
                case .finished: break
                    
                case let .failure(error):
                    
                    self.boundResultInfo[duplexID] = .failure(error)
            
                }
                
            },
            receiveValue: { value in
                
                self.boundResultInfo[duplexID] = .success(value)
                
            }
        )

    }
    
}
