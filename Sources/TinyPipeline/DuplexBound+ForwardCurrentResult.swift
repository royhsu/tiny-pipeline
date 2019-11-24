// MARK: - ForwardCurrentResult

import TinyCombine

/// Try to forward the current result from the given context. Only fallback to target bound when the context
/// remains unresolved.
/// - parameter context: the current context.
/// - parameter fallback: the target bound for fall-backing.
func forwardCurrentResult<Success, Failure>(
    context: DuplexBoundContext<Success, Failure>,
    fallback: @escaping Duplex<Success, Failure>.Bound
)
-> Duplex<Success, Failure>.Bound {
    
    guard let currentResult = context.finalResult else { return fallback }
    
    return { _, _ in Future { $0(currentResult) }.eraseToAnyPublisher() }
        
}
