defmodule SsnService.SsnControllerTest do
  use SsnService.ConnCase
  use ExUnit.Case

  alias SsnService.Repo, as: Repo

  setup do

    [%{state_code: "TN", code: "003"}, %{state_code: "AZ", code: "002"}, %{state_code: "TX", code: "001"}]
    |> Enum.each(
         fn state ->
           Repo.insert(SsnService.State.changeset(%SsnService.State{}, state))
         end
       )

    on_exit fn ->
      :ets.delete_all_objects(:users)
    end

    :ok
  end

  describe "create/2" do
    test "Creates, and responds with a newly created user record if attributes are valid" do

      expected = %{"request_id" => 1, "security_number" => "003-#{Timex.now() |> Timex.iso_triplet() |> elem(1)}-0001"}

      response_body = %{"id" => 1, "name" => "John", "state_code" => "TN"} |>
        get_create_ssn_response(200)

      assert response_body == expected
    end

    test "Creates, and responds with a newly created second user record if attributes are valid with incremented ID" do

      expected = %{"request_id" => 2, "security_number" => "001-#{Timex.now() |> Timex.iso_triplet() |> elem(1)}-0002"}

      %{"id" => 1, "name" => "John", "state_code" => "TN"} |> get_create_ssn_response(200)
      response_body = %{"id" => 10, "name" => "Julia", "state_code" => "TX"} |> get_create_ssn_response(200)

      assert response_body == expected
    end

    test "Returns an error if id in the request is not unique" do
      expected = %{"error" => [%{"id" => "should be unique"}]}

      %{"id" => 1, "name" => "John", "state_code" => "TN"} |> get_create_ssn_response(200)
      response_body = %{"id" => 1, "name" => "Julia", "state_code" => "TX"} |> get_create_ssn_response(422)

      assert response_body == expected
    end

    test "Returns an error if name in the request is not valid" do
      expected = %{"error" => [%{"name" => "can't be less than 3"}]}

      response_body = %{"id" => 1, "name" => "Jo", "state_code" => "TN"} |> get_create_ssn_response(422)

      assert response_body == expected
    end

    test "Returns an error if state_code in the request is not valid" do
      expected = %{"error" => [%{"state_code" => "invalid state"}]}

      response_body = %{"id" => 1, "name" => "John", "state_code" => "MS"} |> get_create_ssn_response(422)

      assert response_body == expected
    end

    test "Returns an error if name is not valid, id is missing" do
      expected = %{"error" => [%{"id" => "is required"}, %{"name" => "can't be less than 3"}]}

      response_body = %{"name" => "Jo", "state_code" => "TN"} |> get_create_ssn_response(422)

      assert response_body == expected
    end
  end

  defp get_create_ssn_response(request, exp_code) do
    build_conn
    |> post("/api/v1/ssn", request)
    |> response(exp_code)
    |> Poison.decode!
    |> IO.inspect(label: "resp")
  end

end
