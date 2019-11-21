// MARK: - FirstResolvedElementIterator

struct FirstResolvedElementIterator<Element, Output> {
    
    var elements: [Element]
    
    var context: () -> PipelineContext<Output>
    
    mutating func next() -> Element? {
        
        let isValueResolved = (context().resolvedValue != nil)
        
        return isValueResolved ? nil : elements.removeFirst()
        
    }
    
}

// MARK: - IteratorProtocol

extension FirstResolvedElementIterator: IteratorProtocol { }
