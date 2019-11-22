import XCTest

#if !canImport(ObjectiveC)

public func allTests() -> [XCTestCaseEntry] {
    
    [
        testCase(FirstResolvedElementIteratorTests.allTests),
        testCase(DuplexBoundConnectionTests.allTests),
        testCase(PipelineTests.allTests),
    ]
    
}

#endif
