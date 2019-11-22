// MARK: - DuplexBoundConnectionTests

import TinyCombine
import XCTest

@testable import TinyPipeline

final class DuplexBoundConnectionTests: XCTestCase {
    
    func testInitialize() {
        
        let connection = DuplexBoundConnection<Int, Error>()
        
        XCTAssertNil(connection.currentBoundStream)
        
        XCTAssert(connection.boundResultInfo.isEmpty)
        
    }
    
    func testAutoconnectToDuplexBound() {
        
        let didDisconnectDuplexBound = expectation(description: "Did disconnect from duplex bound.")
        
        let connection = DuplexBoundConnection<Int, Error>()
        
        let id = Duplex.ID()
        
        connection.autoconnect(
            to: Future { $0(.success(1)) },
            duplexID: id,
            onDisconnect: {
                
                defer { didDisconnectDuplexBound.fulfill() }
                
                XCTAssertNil(connection.currentBoundStream)
                
                do {
                
                    let value = try connection.boundResultInfo[id]?.get()
                
                    XCTAssertEqual(value, 1)
                    
                }
                catch { XCTFail("\(error)") }
                
            }
        )
        
        waitForExpectations(timeout: 10.0)
        
    }
    
}

extension DuplexBoundConnectionTests {
    
    static var allTests = [
        ("testInitialize", testInitialize),
        ("testAutoconnectToDuplexBound", testAutoconnectToDuplexBound),
    ]
    
}