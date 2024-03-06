defmodule OwensBlog.Plugs.CustomSecureBrowserHeaders do
  @moduledoc """
  Custom SCP headers using nonce to make sure stuff like inline styles/script in live view dashboard doesn't break
  Done with help of this link:
  https://francis.chabouis.fr/posts/csp-nonce-with-phoenix/#:~:text=Nonce%20basics,-The%20LiveDashboard%20gives&text=When%20the%20server%20sends%20the,In%20the%20CSP%20headers.
  """
  def init(options), do: options

  defp generate_nonce(size \\ 10),
    do: size |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)

  def call(conn, _opts) do
    # a random string is generated
    nonce = generate_nonce()

    # csp_headers = csp_headers(Mix.env(), nonce)
    csp_headers = csp_headers(nonce)

    conn
    # the nonce is saved in the connection assigns
    # ensures that csp_nonce_value can also be read in live pages
    |> Plug.Conn.put_session(:csp_nonce_value, nonce)
    |> Plug.Conn.assign(:csp_nonce_value, nonce)
    |> Phoenix.Controller.put_secure_browser_headers(csp_headers)
  end

  @doc """
  This function only applies content security policies regardless of environment.
  This is to prevent unwanted issues loading images/code/font/styles in prod which are not encountered in dev
  """
  def csp_headers(nonce) do
    csp_content =
      "default-src 'self' 'nonce-#{nonce}' data:;img-src 'self' 'nonce-#{nonce}' data: blob: https://minio.monklun.home https://minio.monklun.buzz http://192.168.1.1:9002;"

    %{
      "content-security-policy" => csp_content
    }
  end

  @doc """
  This function only applies content security policies to prod and disables them for test and dev
  Only use this function when app gets too big it is no longer feasible to create nonces for each inline script/style/etc.
  """
  def csp_headers(app_env, nonce) do
    csp_content =
      case app_env do
        :prod ->
          # the nonce is put in the CSP header content
          "default-src 'self' 'nonce-#{nonce}' data; img-src https:;"

        _ ->
          nil
      end

    case csp_content do
      nil ->
        %{}

      csp_content ->
        %{
          "content-security-policy" => csp_content
        }
    end
  end
end
