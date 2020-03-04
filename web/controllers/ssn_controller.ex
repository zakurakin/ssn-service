defmodule SsnService.SsnController do

  use SsnService.Web, :controller

  def index(conn, _params) do

#    why do we can't parse JSON RQ BODY which is a MAP %{"id": 1, "name": "John", "state_code": "TN"}
#    it has to be converted to JSON String "{\"state_code\":\"TN\",\"name\":\"John\",\"id\":1}"
    json = Poison.encode!(conn.body_params)
           |> IO.inspect(label: "Request body JSON String")

    rq = Poison.decode!(json, as: %SsnService.Request{})
         |> IO.inspect(label: "Decoded RQ")

    res = rq
    json conn, res
  end
end
