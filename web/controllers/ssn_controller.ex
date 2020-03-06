defmodule SsnService.SsnController do

  import SsnService.RequestValidator

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
            json conn |> put_status(422), %{"error": [err |> elem(1)]}
        end

      {:error, errors} ->
        json conn |> put_status(422), %{"error": errors}

      _ ->
        json conn |> put_status(500), %{"error": [%{"description": "unexpected error"}]}
    end
  end

  def create_response(user_record) do
    {:ok, %{"security_number": user_record.security_number, "request_id": user_record.request_id}}
  end

  def store_user_record(user_record) do
    if :ets.insert(:users, {user_record}) do
      {:ok, nil}
    else
      {:error, %{"error": "Failed to store SSN record"}}
    end
  end

  def create_user_record(json) do
    with {:ok, id} <- {:ok, json["id"]} |> IO.inspect(label: "st5"),
         {:ok, name} <- {:ok, json["name"]} |> IO.inspect(label: "st6"),
         {:ok, request_id} <- generate_request_id() |> IO.inspect(label: "st7"),
         {:ok, security_number} <- generate_ssn(request_id, json["state_code"]) |> IO.inspect(label: "st8")
      do
      {:ok, %{id: id, name: name, security_number: security_number, request_id: request_id}}
    else
      err -> {:error, %{"error": "Failed to create user record"}}
    end

  end

  def generate_request_id do
    IO.inspect "get_request_id"
    {:ok, :ets.info(:users, :size) + 1}
  end

  def generate_ssn(request_id, state_code) do
    IO.inspect "generate_ssn"

    with {:ok, state} <- state_code |> load_state() |> IO.inspect(label: "st9"),
         {:ok, week_number} <- {:ok, Timex.now() |> Timex.iso_triplet() |> elem(1)} |> IO.inspect(label: "st10")
      do
        {:ok, "#{state.code}-#{week_number |> format(2, "0")}-#{request_id |> format(4, "0")}"} |> IO.inspect(label: "st11")
    else
      err -> {:error, %{"error": "Failed to create SSN"}}
    end
  end

  def format(num, amount, fill) do
    num |> Integer.to_string |> String.pad_leading(amount, fill)
  end

end
