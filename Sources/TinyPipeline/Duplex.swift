// MARK: - Duplex

struct Duplex<Success, Failure> where Failure: Error {
    
    var id: DuplexID
    
    var inbound: (DuplexBoundContext<Success, Failure>) -> Future<Success, Failure>

    var outbound: (DuplexBoundContext<Success, Failure>) -> Future<Success, Failure>

}
