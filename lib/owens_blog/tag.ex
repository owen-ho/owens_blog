defmodule OwensBlog.Tag do
  @moduledoc """
  Tag struct for use in repo, used in linktag where user will tag a link with a relevant word or phrase like hashtags on Twitter
  """
  use Ecto.Schema
  alias OwensBlog.{Link, User, LinkTag}
  import Ecto.Changeset

  schema "tags" do
    field :title
    has_many :tagging, LinkTag
    many_to_many :users, User, join_through: LinkTag
    many_to_many :links, Link, join_through: LinkTag

    # inserts inserted_at and updated_at values
    timestamps()
  end

  def changeset(%OwensBlog.Tag{} = tag, attrs) do
    tag
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> unique_constraint([:title])
  end
end
