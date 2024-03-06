defmodule OwensBlog.Bookmark do
  @moduledoc """
  Bookmark struct for use in repo, stores each user's bookmarked link and the title they use to indentify that specific link
  """
  alias OwensBlog.{Link, User}
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookmarks" do
    field :title
    belongs_to :link, Link
    belongs_to :user, User

    timestamps()
  end

  def changeset(%OwensBlog.Bookmark{} = bookmark, attrs) do
    bookmark
    |> cast(attrs, [:title, :link_id, :user_id])
    |> validate_required([:title, :link_id, :user_id])
    |> unique_constraint([:link_id, :user_id])
  end
end
