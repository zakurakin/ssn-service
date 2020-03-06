defmodule SsnService.State do
  use SsnService.Web, :model
  @derive {Jason.Encoder, except: [:__meta__]}
  schema "states" do
    field :state_code, :string
    field :code, :string
    timestamps()
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:state_code, :code])
    |> unique_constraint(:state_code)
  end
end
