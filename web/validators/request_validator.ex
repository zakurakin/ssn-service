defmodule SsnService.RequestValidator do
  @moduledoc false

  alias SsnService.Repo
  import Ex2ms

  def validate_unique_id(request) do
    IO.inspect "validate_unique_id"
    #    if :ets.member(:users, %{"id" => id} = request) do
    if :ets.select(:users, select_user_record_by_id_fun(request["id"])) |> length() > 0 do
      {:error, %{"id": "should be unique"}}
    else
      {:ok, request["id"]}
    end
  end

  defp select_user_record_by_id_fun(rid) do
    fun do {%{:id => id}} = user_record when id == ^rid -> user_record end
  end

  def load_state(state_code) do
    with {:foo, result} when not is_nil(result) <- {:foo, Repo.get_by(SsnService.State, state_code: state_code)} do
      {:ok, result}
    else
      {:foo, nil} -> {:error, :not_found}
    end
  end

  def validate_request(json) do
    required = [:id, :name, :state_code]
    errors = required
             |> Enum.map(fn key -> validate(key, Map.get(json, Atom.to_string(key))) end)
             |> Enum.filter(fn result -> result |> elem(0) == :error end)
             |> Enum.map(fn error -> error |> elem(1) end)

    case errors |> length() do
      0 ->
        {:ok, []}
      _ ->
        {:error, errors}
    end
  end

  defp validate(:id, nil), do: {:error, %{"id": "is required"}}
  defp validate(:id, id) when id |> is_integer and id > 0, do: {:ok, id}
  defp validate(:id, _invalid), do: {:error, %{"id": "should be an integer, greater than 0"}}

  defp validate(:name, nil), do: {:error, %{"name": "is required"}}
  defp validate(:name, name) when name |> byte_size > 3, do: {:ok, name}
  defp validate(:name, _invalid), do: {:error, %{"name": "can't be less than 3"}}

  defp validate(:state_code, nil), do: {:error, %{"state_code": "is required"}}
  defp validate(:state_code, state_code) do
    with {:ok, state} <- load_state(state_code) |> IO.inspect(label: "State from DB"),
         {:ok, code} <- {:ok, state.code} do
      {:ok, code}
    else
      err ->
        {:error, %{"state_code": "invalid state"}}
    end
  end
  defp validate(:state_code, _invalid), do: {:error, %{"state_code": "invalid state"}}

end
