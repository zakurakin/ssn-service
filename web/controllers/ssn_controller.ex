defmodule SsnService.SsnController do

  use SsnService.Web, :controller

  def create(conn, _params) do
    request = conn.body_params |> IO.inspect(label: "Request body RAW MAP")

    case validate_request(request) |> IO.inspect(label: "Validation response") do
      {:ok, []} ->
        json conn, create_ssn(request)
      {:error, errors} ->
        json conn |> put_status(422), %{"error": errors}
      _ ->
        json conn |> put_status(500), %{"error": "unexpected error"}
    end
  end

  def create_ssn(json) do
#    step 1: check if request id is unique
    %{:result => :ok} |> IO.inspect(label: "create SSN response")
  end

  def validate_request(json) do
    required = [:id, :name, :state_code]
    errors = required
             |> Enum.map(fn key -> validate(key, json) end)
             |> Enum.filter(fn result -> result |> elem(0) == :error end)
             |> Enum.map(fn error -> error |> elem(1) end)

    case errors |> length() do
      0 ->
        {:ok, []}
      _ ->
        {:error, errors}
    end
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
  defp validate_name(name) when name |> byte_size > 3, do: {:ok, name}
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
  defp validate_state(state_code) do
    state = fetch_state(state_code)
    cond do
      #todo: simply check if exists in db?
      state.state_code == state_code -> {:ok, state_code}
      true -> {:error, %{"state_code": "invalid state"}}
    end
  end
  defp validate_state(_invalid), do: {:error, %{"state_code": "invalid state"}}

end
