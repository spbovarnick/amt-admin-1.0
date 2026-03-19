module RevalidatesNextCache
  extend ActiveSupport::Concern

  included do
    after_commit :publish_next_revalidation, on: [:create, :update, :destroy]
  end

  private

  def publish_next_revalidation
    return if previous_changes.except("updated_at").blank?

    payload = NextRevalidation::Registry.for(self)

    Rails.logger.info(
      "Revalidation callback model=#{self.class.name} id=#{id} payload=#{payload.inspect}"
    )

    NextRevalidation::Publisher.call(tags: payload[:tags], paths: payload[:paths])
  rescue => e
    Rails.logger.error(
      "publish_next_revalidation failed model=#{self.class.name} id=#{id} error=#{e.class}: #{e.message}"
    )
    nil
  end
end