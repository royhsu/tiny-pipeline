// MARK: - DuplexBound_ForwardCurrentResultTests

import Combine
import XCTest

@testable import TinyPipeline

final class DuplexBound_ForwardCurrentResultTests: XCTestCase {
    
    func testForwardCurrentResult() {
        
        let didForwardCurrentResult = expectation(description: "Did forward the current result.")

        var resolvedContext = DuplexBoundContext<Int, Error>()
        
        resolvedContext.updateResult(.success(-3), id: DuplexID())
           
        let bound = forwardCurrentResult(
            context: resolvedContext,
            fallback: { _, _ in
               
                Future { $0(.success(1)) }.eraseToAnyPublisher()
               
            }
        )
        
        let stream = bound(DuplexID(), resolvedContext)
            .sink(
                receiveCompletion: { completion in
                   
                    switch completion {
                       
                    case .finished: break
                       
                    case let .failure(error): XCTFail("\(error)")
                       
                    }
                   
                },
                receiveValue: { value in
                   
                    defer { didForwardCurrentResult.fulfill() }
                   
                    XCTAssertEqual(value, -3)
                   
                }
            )
        
        waitForExpectations(timeout: 10.0)
        
    }
    
    func testFallbackToBoundWhenResultIsStillUnresolved() {
        
        let didFallbackToTargetBound = expectation(description: "Did fallback to target bound.")
        
        let unresolvedContext = DuplexBoundContext<Int, Error>()
        
        let bound = forwardCurrentResult(
            context: unresolvedContext,
            fallback: { _, _ in
                
                Future { $0(.success(1)) }.eraseToAnyPublisher()
                
            }
        )
        
        let stream = bound(DuplexID(), unresolvedContext)
            .sink(
                receiveCompletion: { completion in
                    
                    switch completion {
                        
                    case .finished: break
                        
                    case let .failure(error): XCTFail("\(error)")
                        
                    }
                    
                },
                receiveValue: { value in
                    
                    defer { didFallbackToTargetBound.fulfill() }
                    
                    XCTAssertEqual(value, 1)
                    
                }
            )
     
        waitForExpectations(timeout: 10.0)
        
    }
    
}
