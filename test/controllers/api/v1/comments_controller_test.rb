require "test_helper"
require "minitest/mock"

class Api::V1::CommentsControllerTest < ActionDispatch::IntegrationTest
  PARAMS = { title: "Item", id: 1, uid: "000-001", first_name: "A", last_name: "B",
             email_addy: "a@example.test", subject: "Hi", comment: "Nice" }.freeze

  setup { @reported = [] }

  def post_comment(params = PARAMS)
    Appsignal.stub(:report_error, ->(e) { @reported << e }) do
      post api_v1_comments_path, params: params
    end
  end

  test "sends the email without reporting anything" do
    post_comment

    assert_response :success
    assert_empty @reported
  end

  test "still succeeds with no params at all" do
    post_comment({})

    assert_response :success
    assert_empty @reported
  end

  test "reports a mailer failure and returns a 500" do
    ArchiveCommentMailer.stub(:comment_email, ->(*) { raise Net::SMTPFatalError, "smtp down" }) do
      post_comment
    end

    assert_response :internal_server_error
    assert_equal "smtp down", response.parsed_body["error"]
    assert_equal [Net::SMTPFatalError], @reported.map(&:class)
  end
end
