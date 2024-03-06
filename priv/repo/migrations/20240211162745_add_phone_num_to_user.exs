defmodule OwensBlog.Repo.Migrations.AddPhoneNumToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:phone_num, :string)
    end

    create unique_index(:users, [:email, :username, :phone_num])
  end
end
