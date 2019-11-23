// MARK: - DuplexBoundContext

struct DuplexBoundContext<Success, Failure> where Failure: Error {
      
    private(set) var resultInfo = DuplexBoundResultInfo<Success, Failure>()
    
    /// You can use this to get the final result.
    private(set) var finalResultID: DuplexID?
    
    /// Update and reflect the final result.
    /// - parameter result: The result for a duplex.
    /// - parameter id: The id of duplex which produces the given result.
    mutating func updateResult(
        _ result: Result<Success, Failure>,
        id: DuplexID
    ) {
        
        finalResultID = id
        
        resultInfo[id] = result
        
    }
    
}

extension DuplexBoundContext {
    
    var finalResult: Result<Success, Failure>? {
        
        guard let finalResultID = finalResultID else { return nil }
        
        return resultInfo[finalResultID]
        
    }
    
}
