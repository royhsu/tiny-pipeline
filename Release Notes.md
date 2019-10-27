# Release Notes

commit: 00fcb3b5ced78cbc42da9da5af6ab1234d846d74

### Known issues
- The current implementation uses element kind for indicating which element resolves the pipeline, and it's not ideal abstraction. We should replace element kind with resolved element id and current element id for onResolve(perform:) event. By making this change, we can easily know whether the current element is the actual one resolves the pipeline by comparing their element ids. (High priority)

### Others
- We might want to re-implement with TinyReducible for reducing the complexity of codebase. Not sure if it's worth to do so. (Low priority)