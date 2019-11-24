// MARK: - ForwardCurrentResult

import TinyCombine

func forwardCurrentResult<Success, Failure>(
    context: DuplexBoundContext<Success, Failure>,
    fallback: @escaping Duplex<Success, Failure>.Bound
)
-> Duplex<Success, Failure>.Bound {
    
    guard let currentResult = context.finalResult else { return fallback }
    
    return { _, _ in Future { $0(currentResult) }.eraseToAnyPublisher() }
        
}
