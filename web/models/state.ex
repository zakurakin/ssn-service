defmodule SsnService.State do
  use SsnService.Web, :model
  schema "states" do
    field :state_code, :string
    field :code, :string
    timestamps
  end
end
