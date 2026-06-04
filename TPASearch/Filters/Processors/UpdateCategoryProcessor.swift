final class UpdateCategoryProcessor: SearchFilterEventProcessor<SearchFilterEvents.CategoryDidUpdate> {
    override func update(_ query: inout SearchQuery, for event: SearchFilterEvents.CategoryDidUpdate) {
        query.category = event.category
    }
}
