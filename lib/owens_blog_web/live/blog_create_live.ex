defmodule OwensBlogWeb.BlogCreateLive do
  @moduledoc """
  Create blog live controller
  """
  require Logger
  alias OwensBlog.Services.AwsS3
  use OwensBlogWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    %{"csp_nonce_value" => csp_nonce_value} = session
    socket = allow_upload(socket, :post, accept: ~w(.md))

    {:ok,
     assign(
       socket,
       page_title: " | Create Post",
       uploaded_files: [],
       upload_form: to_form(%{}),
       new_post_form: to_form(%{}),
       tagsInput: "",
       csp_nonce_value: csp_nonce_value,
       post_id: UUID.uuid4(),
       image_url: "https://minio.monklun.home/live-view-resume/blog/Picture1.png"
     )}
  end

  @impl true
  def handle_event(
        "create_post",
        %{
          "title" => title,
          "author" => author,
          "tags" => tags,
          "description" => description,
          "body" => body
        },
        socket
      ) do
    case Regex.match?(~r/^[a-zA-Z\s]+$/, tags) || tags == "" do
      false ->
        {:noreply, socket |> put_flash(:error, "Tags can only be separated with spaces")}

      true ->
        dest = generate_post_file_path(%{id: socket.assigns.post_id})

        file_content = """
        %{
          title: "#{title}",
          author: "#{author}",
          tags: ~w(#{tags}),
          description: "#{description}",
          published: true,
        }
        ---
        #{body}
        """

        File.write!(dest, file_content)
        {:noreply, socket |> push_navigate(to: "/blog/#{socket.assigns.post_id}")}
    end
  end

  @impl true
  def handle_event("create_post", _params, socket) do
    dest = generate_post_file_path(%{id: socket.assigns.post_id})

    uploaded_files =
      consume_uploaded_entries(socket, :post, fn %{path: path}, _entry ->
        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        File.cp!(path, dest)
        {:ok, dest}
      end)

    {:noreply,
     update(socket, :uploaded_files, &(&1 ++ uploaded_files))
     |> push_navigate(to: "/blog/#{socket.assigns.post_id}")}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("drag-drop-image-upload", %{"type" => type}, socket)
      # image/jpg is not a MIME type
      when type not in ["image/png", "image/jpeg", "image/gif", "image/webp"] do
    {:reply, %{valid: false},
     socket
     |> put_flash(
       :error,
       "'#{type}' files are not supported! Please upload a png, jpg, jpeg or gif."
     )}
  end

  @impl true
  def handle_event("drag-drop-image-upload", %{"size" => size}, socket)
      when size > 8_000_000 do
    {:reply, %{valid: false}, socket |> put_flash(:error, "Only images up to 8 MB are supported")}
  end

  @impl true
  def handle_event("drag-drop-image-upload", %{"file" => file}, socket)
      when file == %{} do
    {:reply, %{valid: true}, socket}
  end

  @impl true
  def handle_event("drag-drop-image-upload", %{"file" => image_bytes, "type" => type}, socket) do
    "image/" <> extension = type
    {:ok, binary_file} = Base.decode64(image_bytes)
    image_path = "blog/#{socket.assigns.post_id}/#{UUID.uuid4()}.#{extension}"

    s3_config = Application.get_env(:ex_aws, :s3)
    image = AwsS3.put_object(s3_config[:bucket], image_path, binary_file)

    case image do
      {:ok, _} ->
        image_url =
          "#{s3_config[:scheme]}#{s3_config[:host]}:#{s3_config[:port]}/#{s3_config[:bucket]}/#{image_path}"

        {:reply, %{image_url: image_url}, socket}

      {:error, _} ->
        {:reply, %{}, socket}
    end

    # {:reply, %{image_url: image_url}, socket}
    # {:noreply, socket |> assign(image_url: "data:image/png;base64," <> image_bytes)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :post, ref)}
  end

  defp to_double_digit(number) do
    number
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  defp generate_post_file_path(%{id: id}) do
    sg_now = DateTime.utc_now() |> DateTime.add(8, :hour)

    Path.join(
      "priv/posts/#{sg_now.year}/",
      Path.basename("#{to_double_digit(sg_now.month)}-#{to_double_digit(sg_now.day)}-#{id}.md")
    )
  end

  # defp base64_to_file(input) do
  #   Base.decode64(input)
  # end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
