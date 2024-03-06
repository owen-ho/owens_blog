defmodule OwensBlog.Blog.Post do
  @moduledoc """
  Used by blog.ex, uses NimblePublisher library to load data from a markdown file to be displayed on the website as a blog
  """
  @enforce_keys [:id, :author, :title, :body, :description, :tags, :date, :published]
  defstruct [:id, :author, :title, :body, :description, :tags, :date, :published]

  def build(filename, attrs, body) do
    [year, month_day_id] = filename |> Path.rootname() |> Path.split() |> Enum.take(-2)
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")
    struct!(__MODULE__, [id: id, date: date, body: body] ++ Map.to_list(attrs))
  end
end
