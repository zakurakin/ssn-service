defmodule SsnService.SsnController do

  import Ex2ms

  use SsnService.Web, :controller

  def create(conn, _params) do
    request = conn.body_params |> IO.inspect(label: "Request body RAW MAP")

    case validate_request(request) |> IO.inspect(label: "Validation response") do
      {:ok, []} ->

        with {:ok, id} <- validate_unique_id(request) |> IO.inspect(label: "st1"),
             {:ok, user_record} <- create_user_record(request) |> IO.inspect(label: "st2"),
             {:ok, nil} <- store_user_record(user_record) |> IO.inspect(label: "st3"),
             {:ok, response} <- create_response(user_record) |> IO.inspect(label: "st3.1")
          do
          json conn, response
        else
          err ->
            json conn |> put_status(422), %{"error": err |> elem(1)}
        end

      {:error, errors} ->
        json conn |> put_status(422), %{"error": errors}

      _ ->
        json conn |> put_status(500), %{"error": "unexpected error"}
    end
  end

  def create_response(user_record) do
    {:ok, %{"security_number" => user_record.security_number, "request_id" => user_record.request_id}}
  end

  def store_user_record(user_record) do
    if :ets.insert(:users, {user_record}) do
      {:ok, nil}
    else
      {:error, %{"error" => "Failed to store SSN record"}}
    end
  end

  def create_user_record(json) do
    with {:ok, id} <- {:ok, json["id"]} |> IO.inspect(label: "st5"),
         {:ok, name} <- {:ok, json["name"]} |> IO.inspect(label: "st6"),
         {:ok, request_id} <- get_request_id() |> IO.inspect(label: "st7"),
         {:ok, security_number} <- generate_ssn(request_id, json["state_code"]) |> IO.inspect(label: "st8")
      do
      {:ok, %{id: id, name: name, security_number: security_number, request_id: request_id}}
    else
      err -> {:error, %{"error" => "Failed to create user record"}}
    end

  end

  def get_request_id do
    IO.inspect "get_request_id"
    {:ok, :ets.info(:users, :size) + 1}
  end

  def generate_ssn(request_id, state_code) do
    IO.inspect "generate_ssn"

    with {:ok, state} <- {:ok, Repo.get_by(SsnService.State, state_code: state_code)} |> IO.inspect(label: "st9"),
         {:ok, week_number} <- {:ok, Timex.now() |> Timex.iso_triplet() |> elem(1)} |> IO.inspect(label: "st10")
      do
        {:ok, "#{state.code}-#{week_number |> format(2, "0")}-#{request_id |> format(4, "0")}"} |> IO.inspect(label: "st11")
    else
      err -> {:error, %{"error" => "Failed to create SSN"}}
    end
  end

  def format(num, amount, fill) do
    num |> Integer.to_string |> String.pad_leading(amount, fill)
  end

  defp validate_unique_id(request) do
    IO.inspect "validate_unique_id"
#    if :ets.member(:users, %{"id" => id} = request) do
    if :ets.select(:users, select_user_record_by_id_fun(request["id"])) |> length() > 0 do
      {:error, %{"id": "should be unique"}}
    else
      {:ok, request["id"]}
    end
  end

  def select_user_record_by_id_fun(rid) do
    fun do {%{:id => id}} = user_record when id == ^rid -> user_record end
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

  def load_state(state_code) do
    with {:foo, result} when not is_nil(result) <- {:foo, Repo.get_by(SsnService.State, state_code: state_code)} do
      {:ok, result}
    else
      {:foo, nil} -> {:error, :not_found}
    end
  end

end
