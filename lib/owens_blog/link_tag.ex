defmodule OwensBlog.LinkTag do
  @moduledoc """
  Link tag struct for use in repo, stores the transaction done by a user which tags a link
  """
  alias OwensBlog.{Link, Tag, User}
  use Ecto.Schema
  import Ecto.Changeset

  schema "link_tags" do
    belongs_to(:link, Link)
    belongs_to(:tag, Tag)
    belongs_to(:user, User)
    # field :link_id, :id
    # field :tag_id, :id
    # field :user_id, :id

    timestamps()
  end

  def changeset(%OwensBlog.LinkTag{} = link_tag, attrs) do
    link_tag
    |> cast(attrs, [:link_id, :tag_id, :user_id])
    |> validate_required([:link_id, :tag_id, :user_id])
    |> unique_constraint([:link_id, :tag_id, :user_id])
  end
end
