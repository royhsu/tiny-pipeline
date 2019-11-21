// MARK: - FirstResolvedElementIteratorTests

import XCTest

@testable import TinyPipeline

final class FirstResolvedElementIteratorTests: XCTestCase {
    
    func testGetNextElementWhenValueIsStillMissing() {
        
        var iterator = FirstResolvedElementIterator(
            elements: [ 1, 2 ],
            context: { PipelineContext<Void>(resolvedValue: nil) }
        )
        
        XCTAssertEqual(iterator.next(), 1)
        
    }
    
    func testSkipRestOfElementsWhenValueGetsResolved() {
        
        var iterator = FirstResolvedElementIterator(
            elements: [ 1, 2 ],
            context: { PipelineContext(resolvedValue: ()) }
        )
        
        XCTAssertEqual(iterator.next(), nil)
        
    }
    
}

extension FirstResolvedElementIteratorTests {
    
    static var allTests = [
        ("testGetNextElementWhenValueIsStillMissing", testGetNextElementWhenValueIsStillMissing),
        ("testSkipRestOfElementsWhenValueGetsResolved", testSkipRestOfElementsWhenValueGetsResolved),
    ]
    
}
