defmodule LodgingWeb.BusinessView do
  use LodgingWeb, :view

  def has_error(form, field) do
    error_tag(form, field) != []
  end
end
