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
      request = %{"id" => 1, "name" => "John", "state_code" => "TN"}

      response_body = request |>
        get_create_ssn_response(200)

      assert response_body == expected
    end

    test "Creates, and responds with a newly created second user record if attributes are valid with incremented ID" do

      expected = %{"request_id" => 2, "security_number" => "001-#{Timex.now() |> Timex.iso_triplet() |> elem(1)}-0002"}

      response_body = %{"id" => 1, "name" => "John", "state_code" => "TN"} |> get_create_ssn_response(200)
      response_body = %{"id" => 10, "name" => "Julia", "state_code" => "TX"} |> get_create_ssn_response(200)

      assert response_body == expected
    end

#    test "Returns an error and does not create a user if attributes are invalid"
  end

  defp get_create_ssn_response(request, exp_code) do
    build_conn
    |> post("/api/v1/ssn", request)
    |> response(exp_code)
    |> Poison.decode!
    |> IO.inspect(label: "resp")
  end

end
