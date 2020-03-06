defmodule SsnService.RequestValidator do
  @moduledoc false

  alias SsnService.Repo
  import Ex2ms

  def validate_unique_id(request) do
    if :ets.select(:users, select_user_record_by_id_fun(request["id"])) |> length() > 0 do
      {:error, %{"id": "should be unique"}}
    else
      :ok
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
    required = ["id", "name", "state_code"]
    errors = required
             |> Enum.map(fn key -> validate(key, Map.get(json, key)) end)
             |> Enum.filter(fn {result, _} -> result == :error end)
             |> Enum.map(fn {:error, error} -> error end)

    if Enum.empty?(errors) do
      {:ok, []}
    else
      {:error, errors}
    end
  end

  defp validate("id", nil), do: {:error, %{"id": "is required"}}
  defp validate("id", id) when is_integer(id) and id > 0, do: {:ok, id}
  defp validate("id", _invalid), do: {:error, %{"id": "should be an integer, greater than 0"}}

  defp validate("name", nil), do: {:error, %{"name": "is required"}}
  defp validate("name", name) when byte_size(name) > 3, do: {:ok, name}
  defp validate("name", _invalid), do: {:error, %{"name": "can't be less than 3"}}

  defp validate("state_code", nil), do: {:error, %{"state_code": "is required"}}
  defp validate("state_code", state_code) do
    with {:ok, state} <- load_state(state_code) do
      {:ok, state.code}
    else
      _err ->
        {:error, %{"state_code": "invalid state"}}
    end
  end
  defp validate("state_code", _invalid), do: {:error, %{"state_code": "invalid state"}}

end
