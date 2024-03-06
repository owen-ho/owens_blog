# OwensBlog

This repo is a copy of my primary development/production repo where I do my development so I can showcase to the public without disclosing my keys.

My production version of this website can be found at https://www.monklun.buzz/, where I run this Elixir project in a Docker container with a Postgres instace and a MinIO instance for storage of images in a local version of S3 buckets (the Postgres instance is completely unnecessary, I only wired it up so I could learn how to use Elixir's Ecto CRUD operations).

## Key features
- Uploading
	- Drag and drop to upload image
	- Via markdown file or form
- Webhook for automated deployment
- Will document rest soon!

## TODOS
- Should really start writing tests
- Session token & auth for retrieving images from S3

## Quick Start
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
