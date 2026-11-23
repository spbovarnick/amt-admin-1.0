require "test_helper"
require "minitest/mock"

class AppsignalErrorReportingTest < ActiveSupport::TestCase
  class FailingHttp
    attr_accessor :use_ssl

    def request(*)
      raise Errno::ECONNREFUSED
    end
  end

  setup do
    @reported = []
    @item = ArchiveItem.create!(title: "Test item", medium: "audio")
  end

  def capturing_reports(&block)
    Appsignal.stub(:report_error, ->(e) { @reported << e }, &block)
  end

  def with_env(vars)
    previous = vars.keys.index_with { |k| ENV[k] }
    vars.each { |k, v| ENV[k] = v }
    yield
  ensure
    previous.each { |k, v| ENV[k] = v }
  end

  def attach_audio
    @item.content_files.attach(
      io: StringIO.new("not really audio"), filename: "clip.mp3",
      content_type: "audio/mpeg", identify: false
    )
  end

  test "publisher reports a failed request and still returns nil" do
    with_env("TARGET_DB" => "production", "NEXT_PROD_URL" => "https://example.test", "REVALIDATE_SECRET" => "s") do
      Net::HTTP.stub(:new, FailingHttp.new) do
        capturing_reports do
          assert_nil NextRevalidation::Publisher.call(tags: ["people"])
        end
      end
    end

    assert_equal [Errno::ECONNREFUSED], @reported.map(&:class)
  end

  test "publisher reports nothing when revalidation is not configured" do
    with_env("TARGET_DB" => nil, "REVALIDATE_SECRET" => nil) do
      capturing_reports { assert_nil NextRevalidation::Publisher.call(tags: ["people"]) }
    end

    assert_empty @reported
  end

  test "revalidation callback reports an error raised before publishing" do
    NextRevalidation::Registry.stub(:for, ->(_) { raise ArgumentError, "bad payload" }) do
      capturing_reports { assert_nil @item.send(:publish_next_revalidation) }
    end

    assert_equal ["bad payload"], @reported.map(&:message)
  end

  test "id3 extraction reports a failure per file and keeps going" do
    attach_audio
    attach_audio
    @item.content_files.each { |f| f.blob.update!(metadata: f.blob.metadata.except("id3")) }

    @item.stub(:parse_id3_tag, ->(_) { raise RuntimeError, "corrupt tag" }) do
      capturing_reports { @item.extract_id3_tags! }
    end

    assert_equal ["corrupt tag", "corrupt tag"], @reported.map(&:message)
  end

  test "id3 extraction reports nothing for items without files" do
    capturing_reports { @item.extract_id3_tags! }

    assert_empty @reported
  end

  [ExportArchiveItemsCsvJob, WeeklyCsvSnapshotJob].each do |job_class|
    test "#{job_class.name} reports a failed file url and writes it into the row" do
      attach_audio
      job = job_class.new

      row = job.stub(:blob_url, ->(_) { raise KeyError, "S3_BUCKET missing" }) do
        capturing_reports { job.send(:generate_csv_row, @item) }
      end

      assert_includes row, "Error: S3_BUCKET missing"
      assert_equal ["S3_BUCKET missing"], @reported.map(&:message)
    end

    test "#{job_class.name} reports nothing for an item without files" do
      job = job_class.new

      capturing_reports { job.send(:generate_csv_row, @item) }

      assert_empty @reported
    end
  end
end
