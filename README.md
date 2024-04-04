# OwensBlog

This repo is a copy of my primary development/production repo where I do my development so I can showcase to the public without disclosing my keys.

My production version of this website can be found [here](https://live-view-resume.fly.dev/), where I run this Elixir project on a fly.io instance which automatically scales down to 0 when no users are on the site, which might take a while to load if you are the first person to visit in a while.

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
