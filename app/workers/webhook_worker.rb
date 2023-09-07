require 'http.rb'

class WebhookWorker
  include Sidekiq::Worker

  def perform(event_id)
    begin
      event = WebhookEvent.find event_id
      return if event.nil?

      endpoint = event.webhook_endpoint
      return if endpoint.nil?

      response = HTTP.timeout(30)
        .headers(
          'User-Agent' => 'rails_webhook_system/1.0',
          'Content-Type' => 'application/json',
        )
        .post(
          "https://webhook.site/c5ddc08f-882d-4333-8929-3d96eafdff23",
          body: {
            event: event.event,
            payload: event.payload,
          }.to_json
        )
      
      event.update(response: {
        headers: response.headers.to_h,
        code: response.code.to_i,
        body: response.body.to_s,
      })
      
      raise StandardError unless response.status.success?    
    rescue HTTP::TimeoutError
      event.update(response: { error: 'TIMEOUT_ERROR' })
    end
  end
end