defmodule OwensBlog.Repo do
  use Ecto.Repo,
    otp_app: :owens_blog,
    adapter: Ecto.Adapters.Postgres
end
