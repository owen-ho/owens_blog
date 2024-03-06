defmodule OwensBlog.Link do
  @moduledoc """
  Link struct for use in repo, stores the url of link and whatever places it gets referred in
  """
  alias OwensBlog.{LinkTag, Bookmark, Tag, User}
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :url
    has_many(:bookmarks, Bookmark)
    has_many(:taggings, LinkTag)
    many_to_many(:tags, Tag, join_through: LinkTag)
    many_to_many(:users, User, join_through: LinkTag)

    timestamps()
  end

  def changeset(%OwensBlog.Link{} = link, attrs) do
    link
    |> cast(attrs, [:url])
    |> validate_required([:url])
    |> unique_constraint(:url)
  end
end
