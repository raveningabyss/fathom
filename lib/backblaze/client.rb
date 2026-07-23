require 'aws-sdk-s3'

module Backblaze
  class Client
    def initialize
      @client = Aws::S3::Client.new(
        access_key_id: credentials.access_key_id,
        secret_access_key: credentials.secret_access_key,
        region: credentials.region,
        endpoint: credentials.endpoint_url,
        force_path_style: true
      )
    end

    def presigned_upload_url(key:, expires_in: 300)
      Aws::S3::Presigner.new(client: @client).presigned_url(
        :put_object,
        bucket: credentials.bucket,
        key: key
      )
    end

    def delete_object(key:)
      @client.delete_object(bucket: credentials.bucket, key: key)
    end

    def public_url(key)
      "https://#{credentials.bucket}.s3.#{credentials.region}.backblazeb2.com/#{key}"
    end

    private

    def credentials
      @credentials ||= Rails.application.credentials.backblaze
    end
  end
end
