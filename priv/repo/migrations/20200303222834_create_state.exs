defmodule SsnService.Repo.Migrations.CreateState do
  use Ecto.Migration

  def change do
    create table(:states) do
      add :state_code, :string
      add :code, :string
      timestamps
    end
    create unique_index(:states, [:state_code])
  end
end
