defmodule Dictio.Notion.Word do

  def build(word) do
    %{
      "id" => fetch_id(word),
      "definition1" => fetch_property_text("definition1", word),
      "definition2" => fetch_property_text("definition2", word),
      "definition3" => fetch_property_text("definition3", word),
      "state" => fetch_property_text("state", word),
      "origin" => fetch_property_text("origin", word),
      "etymologie" => fetch_property_text("etymologie", word),
      "notes" => fetch_property_text("notes", word),
      "figure" => fetch_property_text("figure", word),
      "wikitionnaire" => fetch_property_text("wikitionnaire", word),
      "word" => fetch_word_text(word)
    }
  end

  defp fetch_word_text(%{"properties" => %{"word" => %{ "title" => [%{ "plain_text" => word}]}}}), do: word
  defp fetch_word_text(_), do: ""

  defp fetch_rich_text(%{ "rich_text" => [%{ "plain_text" => rich_text}]}), do: rich_text
  defp fetch_rich_text(_), do: ""

  defp fetch_property_text(property, word) do
    word
    |> Map.get("properties")
    |> Map.get(property)
    |> fetch_rich_text
  end

  defp fetch_id(%{"id" => id}) do
    id
  end
  defp fetch_id(_), do: ""
end
