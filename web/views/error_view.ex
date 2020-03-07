defmodule SsnService.ErrorView do
  use SsnService.Web, :view

  def render("422.json", %{error: error}) do
    %{"error" => [error]}
  end

  def render("422.json", %{errors: errors}) do
    %{"error" => errors}
  end

  def render("500.json", _) do
    %{"error" => [%{"description" => "unexpected error"}]}
  end
end
