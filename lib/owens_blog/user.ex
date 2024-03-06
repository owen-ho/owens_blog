defmodule OwensBlog.User do
  @moduledoc """
  User struct for use in repo
  """
  alias OwensBlog.{Bookmark, Link, LinkTag, Tag}
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    # field :id, :id, primary_key: true < this code is done automatically
    field :about
    field :birth_date, :date, virtual: true
    field :email
    field :username
    field :phone_num
    has_many :bookmarks, Bookmark
    has_many :bookmarked_links, through: [:bookmarks, :link]
    has_many :link_tags, LinkTag
    many_to_many :tagged_links, Link, join_through: LinkTag
    many_to_many :tags, Tag, join_through: LinkTag

    # inserts inserted_at and updated_at values
    timestamps()
  end

  def changeset(%OwensBlog.User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :about, :email, :birth_date, :phone_num])
    |> validate_required([:username, :email, :birth_date, :phone_num])
    |> validate_length(:username, min: 3)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> validate_change(:birth_date, &older_than_13/2)
  end

  def older_than_13(:birth_date, %Date{} = birth_date) do
    {year, month, date} = Date.to_erl(Date.utc_today())
    {:ok, min_date} = Date.from_erl({year - 13, month, date})

    case Date.compare(min_date, birth_date) do
      :lt -> [birth_date: "Must be over 13 years old"]
      _ -> []
    end
  end
end
