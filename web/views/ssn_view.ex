defmodule SsnService.SsnView do
  use SsnService.Web, :view

  def render("ssn.json", user_record) do
    Map.take(user_record, [:request_id, :security_number])
  end
end
