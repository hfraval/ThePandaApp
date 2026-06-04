final class UpdateRatingProcessor: SearchFilterEventProcessor<SearchFilterEvents.RatingDidUpdate> {
    override func update(_ query: inout SearchQuery, for event: SearchFilterEvents.RatingDidUpdate) {
        query.minimumRating = event.minimumRating
    }
}
