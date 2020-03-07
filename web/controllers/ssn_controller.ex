defmodule SsnService.SsnController do
  import SsnService.RequestValidator
  alias SsnService.ErrorView

  use SsnService.Web, :controller

  def create(conn, request) do
    case validate_request(request) do
      {:ok, []} ->
        with :ok <- validate_unique_id(request),
             {:ok, user_record} <- create_user_record(request),
             :ok <- store_user_record(user_record) do
          render(conn, "ssn.json", user_record)
        else
          {:error, error} ->
            conn
            |> put_status(422)
            |> put_view(ErrorView)
            |> render("422.json", error: error)
        end

      {:error, errors} ->
        conn
        |> put_status(422)
        |> put_view(ErrorView)
        |> render("422.json", errors: errors)

      _ ->
        conn
        |> put_status(500)
        |> put_view(ErrorView)
        |> render("500.json")
    end
  end

  def store_user_record(user_record) do
    if :ets.insert(:users, {user_record}) do
      :ok
    else
      {:error, %{"error" => "Failed to store SSN record"}}
    end
  end

  def create_user_record(json) do
    with {:ok, request_id} <- generate_request_id(),
         {:ok, security_number} <- generate_ssn(request_id, json["state_code"]) do
      {:ok,
       %{
         id: json["id"],
         name: json["name"],
         security_number: security_number,
         request_id: request_id
       }}
    else
      _err -> {:error, %{"error" => "Failed to create user record"}}
    end
  end

  def generate_request_id do
    {:ok, :ets.info(:users, :size) + 1}
  end

  def generate_ssn(request_id, state_code) do
    with {:ok, state} <- load_state(state_code),
         {:ok, week_number} <- {:ok, Timex.now() |> Timex.iso_triplet() |> elem(1)} do
      {:ok, "#{state.code}-#{format(week_number, 2)}-#{format(request_id, 4)}"}
    else
      _err -> {:error, %{"error" => "Failed to create SSN"}}
    end
  end

  def format(num, amount) do
    num
    |> Integer.to_string()
    |> String.pad_leading(amount, "0")
  end
end
