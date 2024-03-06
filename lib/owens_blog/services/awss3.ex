defmodule OwensBlog.Services.AwsS3 do
  @moduledoc """
  Retrieves and uploads images or other files to S3/local minio bucket
  """
  def put_object(bucket, filename, binary_file, opts \\ []) do
    ExAws.S3.put_object(bucket, filename, binary_file, opts)
    |> ExAws.request()
  end

  def delete_object(bucket, filename) do
    ExAws.S3.delete_object(bucket, filename)
    |> ExAws.request()
  end

  def presigned_url(
        method,
        bucket,
        filename,
        config \\ ExAws.Config.new(:s3),
        opts \\ [expires_in: 7200]
      ) do
    {:ok, url} = ExAws.S3.presigned_url(config, method, bucket, filename, opts)
    url
  end
end
