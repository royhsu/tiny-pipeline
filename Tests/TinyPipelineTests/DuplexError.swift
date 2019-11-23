// MARK: - DuplexError

@testable import TinyPipeline

struct DuplexError {
    
    var id: DuplexID
    
}

// MARK: - Error

extension DuplexError: Error { }

// MARK: - Equatable

extension DuplexError: Equatable { }
