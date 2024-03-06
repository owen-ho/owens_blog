# import = type everthing in that module
import Ecto.Query
# alias = no need to type whole module before using its function/struct
alias Ecto.Adapters.SQL
alias OwensBlog.Repo

links_to_insert = [
  [
    url: "https://alchemist.camp",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    url: "https://reactor.am",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    url: "https://indiehackers.com",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ]
]

users_to_insert = [
  [
    username: "alice",
    email: "alice@example.com",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    username: "bob",
    email: "bob@example.com",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    username: "alchemist",
    email: "alchemist.camp@gmail.com",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ]
]

bookmarks_to_insert = [
  [
    title: "The Petite Prince",
    user_id: 1,
    link_id: 1,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    title: "Alchemist Camp",
    user_id: 2,
    link_id: 2,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    title: "Reactor Podcast",
    user_id: 2,
    link_id: 3,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    title: "Elixir tutorial site",
    user_id: 1,
    link_id: 2,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ]
]

tags_to_insert = [
  [
    title: "Business",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    title: "Community",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    title: "Elixir",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    title: "Podcast",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    title: "Projects",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    title: "Resource",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ]
]

link_tags_to_insert = [
  [
    link_id: 1,
    user_id: 1,
    tag_id: 3,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    link_id: 2,
    user_id: 2,
    tag_id: 1,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    link_id: 2,
    user_id: 2,
    tag_id: 4,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    link_id: 1,
    user_id: 3,
    tag_id: 5,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ],
  [
    link_id: 2,
    user_id: 3,
    tag_id: 5,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  ]
]

# Fill database with some initial data
Repo.insert_all("users", users_to_insert, returning: [:id, :username])
Repo.insert_all("links", links_to_insert, returning: [:id, :url])
Repo.insert_all("bookmarks", bookmarks_to_insert)
Repo.insert_all("tags", tags_to_insert)
Repo.insert_all("link_tags", link_tags_to_insert)

Repo.query("select * from users")

get_user2 = from u in "users", where: u.id == 2, select: u.username

get_bob = from u in "user", where: u.username == "bob", select: u.id

Repo.one(get_user2)
Ecto.Adapters.SQL.explain(OwensBlog.Repo, :all, get_bob) |> IO.puts()
Repo.one(get_bob)
Repo.all(get_bob)

sam = %User{
  username: "sam",
  email: "sam@example.com",
  about:
    "asjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjdasjd"
}

Repo.insert(sam)

sam_query = from User, where: [username: "sam"]
Repo.update_all(sam_query, set: [email: "sam@gmail.com"])

# get user with id 1
Repo.get(User, 1)
# use bang(!) to receive error if no user with id 1
Repo.get!(User, 1)

# if id not known, use get_by to use username/any other field to find
Repo.get_by(Bookmark, %{title: "Alchemist Camp"})

# calculate something i.e. :avg | :count | :max | :min | :sum
agg_query = from b in Bookmark, where: b.link_id = 1
Repo.aggregate(agg_query, :count, :id)

# Repo.preload()

# Naming of migrations: create = make new table, add = add new field to one of the existing tables
# Remember to update the allowed_params in the table schema's changeset to include new field

# MAKING CHANGESET: 2 METHODS
# 1(takes fewer args): change(%User{username: "abc"}) (doesn't need allowed_params)
# 2(takes more args):  cast(%User{}, %{username: "abc}, [:username, :email, :other_allowed_attrs])
# THEN COMMIT TO REPO WITH Repo.insert or Repo.update (create or modify existing record)
