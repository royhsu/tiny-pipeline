// MARK: - Pipeline

#warning("TODO: [Priority: high] need a timeout / counter mechanism to opt-in finite execution. default is infinite.")
#warning("TODO: [Priority: high] event callbacks for resolved by current handler & resolved by next handler.")
struct Pipeline<Output> {
    
    var elementContainers: [ElementContainer]
    
    init(elements: [Element]) {
        
        self.elementContainers = zip(elements.indices, elements)
            .map(ElementContainer.init)
        
    }
    
}

extension Pipeline {
    
    #warning("TODO: [Priority: high] should replace resolvedByElementKind with resolvedByElementID.")
    typealias ResolvingHandler = Future<(resolvedByElementKind: ElementKind, output: Output), PipelineError>
    
    /// Resolve first by the current handler, if it fails, then fallbacks to the next handler.
    ///
    /// - Returns: A new handler that chains the current and next handler.
    static func resolveCurrentElementHandler(
        _ currentElementHandler: @escaping Future<Output, PipelineError>,
        ifFailureThenTryNextElementHandler nextElementHandler: @escaping Future<Output, PipelineError>
    )
    -> ResolvingHandler {
        
         { promise in

            currentElementHandler { currentResult in

                do { try promise(.success((.current, currentResult.get()))) }
                catch {

                    nextElementHandler { nextResult in
                        
                        promise(nextResult.map { (.next, $0) })
                        
                    }

                }

            }

        }
        
    }
    
    static func resolvingHandler(
        _ resolvingHandler: @escaping ResolvingHandler,
        didResolve: ((ElementKind) -> Future<Void, PipelineError>)?
    )
    -> Future<Output, PipelineError> {
        
        { promise in
            
            resolvingHandler { resolvedResult in
                
                do {
                    
                    let content = try resolvedResult.get()
                
                    guard let didResolveHandler = didResolve?(content.resolvedByElementKind) else {
                        
                        promise(.success(content.output))
                        
                        return
                        
                    }
                        
                    didResolveHandler { eventResult in
                        
                        do {
                            
                            _ = try eventResult.get()
                            
                            promise(.success(content.output))
                            
                        }
                        catch { promise(.failure(error as! PipelineError)) }
                        
                    }
                    
                }
                catch { promise(.failure(error as! PipelineError)) }
                
            }
            
        }
        
    }
    
    private static func handleOnResolve(
        kind: ElementKind,
        ForCurrentElement currentElement: Element,
        nextElement: Element
    )
    -> Future<Void, PipelineError> {
        
        { promise in

            switch kind {
                
            case .current:
                
                guard let currentElementOnResolveHandler = currentElement._onResolve?(.current) else {
                    
                    promise(.success(()))
                    
                    return
                    
                }
                
                currentElementOnResolveHandler(promise)
                
            case .next:
                
                if let nextElementOnResolveHandler = nextElement._onResolve?(.current) {
                    
                    nextElementOnResolveHandler { _ in
                        
                        guard let currentElementOnResolveHandler = currentElement._onResolve?(.next) else {
                            
                            promise(.success(()))
                            
                            return
                            
                        }
                        
                        currentElementOnResolveHandler(promise)
                        
                    }
                    
                }
                else {
                    
                    guard let currentElementOnResolveHandler = currentElement._onResolve?(.next) else {
                        
                        promise(.success(()))
                        
                        return
                        
                    }
                    
                    currentElementOnResolveHandler(promise)
                    
                }
                
            }
            
        }
        
    }
    
    func execute(completion: Promise<Output, PipelineError>? = nil) {
        
        let defaultHandler: Future<Output, PipelineError> = { promise in
            
            promise(.failure(.unhandledPipeline))
            
        }
                
        let startElement: Element? = nil
        
        let finalElement = elementContainers
            .reduce(startElement) { currentElement, nextElementContainer in
                
                guard let currentElement = currentElement else {
                    
                    return nextElementContainer.element
                    
                }
                
                let resolvingHandler = Self.resolveCurrentElementHandler(
                    currentElement.handler,
                    ifFailureThenTryNextElementHandler: nextElementContainer.element.handler
                )

                let newElement = Element(
                    handler: Self.resolvingHandler(
                        resolvingHandler,
                        didResolve: { kind in
                        
                            Self.handleOnResolve(
                                kind: kind,
                                ForCurrentElement: currentElement,
                                nextElement: nextElementContainer.element
                            )
                            
                        }
                    )
                )
            
            return newElement
            
        }
        
        (finalElement?.handler ?? defaultHandler) { completion?($0) }
        
    }
    
}

// MARK: - Future

typealias Future<Output, Failure: Error> = (@escaping Promise<Output, Failure>) -> Void

typealias Promise<Output, Failure: Error> = (Result<Output, Failure>) -> Void

// MARK: - Element

extension Pipeline {
    
    enum ElementKind {
        
        case current, next
        
    }
    
    struct Element {
        
        private(set) var _onResolve: ((ElementKind) -> Future<Void, PipelineError>)?
        
        var handler: Future<Output, PipelineError>
        
        func onResolve(
            perform: @escaping (ElementKind) -> Future<Void, PipelineError>
        )
        -> Element {
            
            var element = self
            
            element._onResolve = perform
            
            return element
            
        }
        
    }
    
    struct ElementContainer {
        
        /// Equivalent to index of the element.
        var id: Int
        
        var element: Element
        
    }
    
}

// MARK: - PipelineError

enum PipelineError: Error {
    
    case unhandledPipeline
    
    /// Failure from element.
    case elementFailure(Error)
    
}
