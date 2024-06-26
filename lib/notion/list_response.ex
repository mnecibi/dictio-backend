defmodule Dictio.Notion.ListResponse do
  alias Dictio.Notion.{ListResponse, Word}

  @moduledoc """
  API Response struct representing a list of objects.
  """

  @type t :: %ListResponse{
          body: map(),
          results: Word.t(),
          headers: Keyword.t(),
          success: boolean(),
          has_more: boolean(),
          next_cursor: binary | nil
        }
  defstruct [:success, :body, :results, :headers, :has_more, :next_cursor]

  @doc """
  Build a list response object from a raw client response.
  """
  @spec build(%{body: map(), headers: Keyword.t()}) :: ListResponse.t()
  def build(%{body: body = %{"results" => results}, headers: headers}) do
    %ListResponse{success: true, body: body, results: results, headers: headers}
    |> set_response_values
  end

  defp set_response_values(response = %ListResponse{body: body}) do
    %{
      response
      | has_more: Map.get(body, "has_more", false),
        next_cursor: Map.get(body, "next_cursor")
    }
  end
end
