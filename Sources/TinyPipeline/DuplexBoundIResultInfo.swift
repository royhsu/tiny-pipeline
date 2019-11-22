// MARK: - DuplexBoundResultInfo

typealias DuplexBoundResultInfo<Success, Failure: Error> = [Duplex.ID: Result<Success, Failure>]
