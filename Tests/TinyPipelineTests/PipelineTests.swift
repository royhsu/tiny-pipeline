// MARK: - PipelineTests

import TinyCombine
import XCTest

@testable import TinyPipeline

final class PipelineTests: XCTestCase {
    
    func testSinkPipeline() {
        
        let e = expectation(description: "")
        
        let id1 = DuplexID()
        
        let pipeline = Pipeline<Int, Error>(
            [
                Duplex(
                    id: id1,
                    inbound: { id, context in // get value.
                        
                        return Future { $0(.success(3)) }

                    },
                    outbound: { id, context in // square value.
                        
                        return Future { promise in
                            
                            do {
                            
                                let finalResult = try XCTUnwrap(context.finalResult)
                                
                                let value = try finalResult.get()
                                
                                promise(.success(value * value))
                                
                            }
                            catch { promise(.failure(error)) }
                            
                        }

                    }
                ),
            ]
        )
        
        pipeline.execute { result in
            
            defer { e.fulfill() }
            
            do {
            
                let value = try result.get()

                XCTAssertEqual(value, 9)
                
            }
            catch { XCTFail("\(error)") }
            
        }

//        let stream = pipeline.sink(
//            receiveCompletion: { completion in
//
//                switch completion {
//
//                case .finished: break
//
//                case let .failure(error): XCTFail("\(error)")
//
//                }
//
//            },
//            receiveValue: { value in XCTAssertEqual(value, 1) }
//        )

        waitForExpectations(timeout: 10.0)
        
    }
    
}

