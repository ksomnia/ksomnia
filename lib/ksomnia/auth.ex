defmodule Ksomnia.Auth do
  alias Ksomnia.Repo
  alias Ksomnia.User

  def verify_user(%{"email" => email, "password" => password}) do
    if user = Repo.get_by(User, email: email) do
      Argon2.verify_pass(password, user.encrypted_password)
      {:ok, user}
    else
      Argon2.no_user_verify()
      :error
    end
  end
end
