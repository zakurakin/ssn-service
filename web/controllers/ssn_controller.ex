defmodule SsnService.SsnController do

  use SsnService.Web, :controller

  def create(conn, _params) do
    json = conn.body_params
           |> IO.inspect(label: "Request body RAW MAP")

    #    IO.inspect validate(:id, json)
    #    IO.inspect validate(:name, json)
    #    IO.inspect validate(:state_code, json)

    required = [:id, :name, :state_code]

    errors = required
             |> Enum.map(fn k -> validate(k, json) end)
             |> Enum.filter(fn res -> res |> elem(0) == :error end)
             |> Enum.map(fn err -> err |> elem(1) end)


    IO.inspect errors

    res = %{"error": errors}

    json conn, res
  end

  defp validate(:id, rq) do
    val = Map.get(rq, Atom.to_string(:id))
    IO.puts "validating:#{:id} #{val}"
    validate_id(val)
  end

  #todo: validate if unique on save & return error if not
  defp validate_id(nil), do: {:error, %{"id": "is required"}}
  defp validate_id(id) when id |> is_integer and id > 0, do: {:ok, id}
  defp validate_id(_invalid), do: {:error, %{"id": "should be an integer, greater than 0"}}

  defp validate(:name, rq) do
    val = Map.get(rq, Atom.to_string(:name))
    IO.puts "validating:#{:name} #{val}"
    validate_name(val)
  end

  defp validate_name(nil), do: {:error, %{"name": "is required"}}
  defp validate_name(name) when name
                                |> byte_size > 3, do: {:ok, name}
  defp validate_name(_invalid), do: {:error, %{"name": "can't be less than 3"}}

  defp validate(:state_code, rq) do
    val = Map.get(rq, Atom.to_string(:state_code))
    IO.puts "validating:#{:state_code} #{val}"
    validate_state(val)
  end

  def fetch_state(state_code) do
    Repo.get_by(SsnService.State, state_code: state_code)
    |> IO.inspect(label: "Fetched state")
  end

  defp validate_state(nil), do: {:error, %{"state_code": "is required"}}
  #  defp validate_state(state_code) when state_code |> fetch_state, do: {}
  defp validate_state(state_code) do
    state = fetch_state(state_code)
    cond do
      state.state_code == state_code -> {:ok, state_code}
      true -> {:error, %{"state_code": "invalid state"}}
    end
  end
  #  defp validate_state(state_code) do
  #    with {:ok, state} <- fetch_state(state_code) do
  #      {:ok, state.state_code == state_code}
  #    else
  #      :error -> {:error, {:state_code, "invalid state"}}
  #    end
  #  end
  defp validate_state(_invalid), do: {:error, %{"state_code": "invalid state"}}

end
