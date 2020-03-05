defmodule SsnService.State do
  use SsnService.Web, :model
  @derive {Jason.Encoder, except: [:__meta__]}
  schema "states" do
    field :state_code, :string
    field :code, :string
    timestamps
  end
end
