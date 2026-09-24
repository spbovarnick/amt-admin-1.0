require "test_helper"

class ApiArchiveItemsSearchTest < ActionDispatch::IntegrationTest
  QUERY = "Calvin Walker Band"

  setup do
    # Items that only match through the group name. Created first, so an
    # unordered query tends to return them ahead of the title match.
    12.times do |i|
      ArchiveItem.create!(
        title: "Rehearsal photo #{i}",
        medium: "photo",
        search_comm_groups: QUERY
      )
    end

    @title_match = ArchiveItem.create!(
      title: "#{QUERY} - Live at Portland State University Cassette",
      medium: "audio",
      search_comm_groups: QUERY
    )
  end

  test "an exact title match is the first result" do
    get "/api/v1/archive_items/search", params: { q: QUERY, limit: 1, offset: 0 }

    assert_response :success
    assert_equal [@title_match.id], response.parsed_body.map { |item| item["id"] }
  end

  test "paging returns each match exactly once" do
    ids = (0..12).flat_map do |offset|
      get "/api/v1/archive_items/search", params: { q: QUERY, limit: 1, offset: offset }
      response.parsed_body.map { |item| item["id"] }
    end

    assert_equal ArchiveItem.pluck(:id).sort, ids.sort
  end
end
