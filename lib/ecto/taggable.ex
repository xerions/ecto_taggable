defmodule Ecto.Taggable.Api do
  import Ecto.Query

  @spec set_tag(Ecto.Repo.t, Ecto.Model.t, atom) :: :id_not_exists | :ok | :not_found
  def set_tag(repo, model, tagname) do
    check_model(model)
    tag_field = find_taggable_assoc(model, model.__struct__.__schema__(:associations))
    case repo.all(from c in model.__struct__, where: c.id == ^model.id, preload: [^tag_field]) do
      [] ->
        :id_not_exists
      [result] ->
        case Map.fetch(result, tag_field) do
          :error ->
            insert_tag(repo, tag_field, tagname, model)
          {:ok, tag_list} ->
            add_tag_if_not_exists(repo, tag_field, tag_list, model, tagname)
        end
    end
  end

  @spec search_tag(Ecto.Repo.t, Ecto.Model.t, atom) :: [Ecto.Model.t]
  def search_tag(repo, model, tagname) do
    tag_field = find_taggable_assoc(model, model.__schema__(:associations))
    (from t in model, join: tags in assoc(t, ^tag_field), where: tags.name == ^(tagname |> Atom.to_string)) |> repo.all
  end

  @spec drop_tag(Ecto.Repo.t, Ecto.Model.t, atom) :: :ok | :not_found
  def drop_tag(repo, model, tagname) do
    tag_field = find_taggable_assoc(model, model.__schema__(:associations))
    case (from t in model, join: tags in assoc(t, ^tag_field), where: tags.name == ^(tagname |> Atom.to_string), preload: [^tag_field]) |> repo.all do
      [] ->
        :not_found
      result ->
        for record <- result do
          repo.delete!(record.tags |> Enum.at(0))
        end
        :ok
    end
  end

  @doc false
  defp insert_tag(repo, tag_field, tagname, model) do
    new_tag = Ecto.Model.build(model, tag_field)
    new_tag = %{new_tag | tag_id: model.id, name: tagname |> to_string, model: model.__struct__ |> Atom.to_string}
    repo.insert(new_tag)
    :ok
  end

  @doc false
  defp add_tag_if_not_exists(repo, tag_field, [], model, tagname) do
    insert_tag(repo, tag_field, tagname, model)
  end

  @doc false
  defp add_tag_if_not_exists(repo, tag_field, [tag | tag_list], model, tagname) do
    case (tag.name |> String.to_atom) == tagname do
      true ->
        :already_tagged
      false ->
        add_tag_if_not_exists(repo, tag_field, tag_list, model, tagname)
    end
  end

  @doc false
  defp check_model(model) do
    case Map.fetch(model, :id) do
      :error ->
        raise ArgumentError, "set_tag: model must contain :id"
      _ ->
        :ok
    end
  end

  @doc false
  defp find_taggable_assoc(_model, []) do
    raise ArgumentError, "set_tag: given model does not have Ecto.Taggable association"
  end

  defp find_taggable_assoc(model, [assoc | assocs]) do
    association = case is_atom(model) do
                    false ->
                      model.__struct__.__schema__(:association, assoc)
                    _ ->
                      model.__schema__(:association, assoc)
                  end

    case association.related do
      :'Elixir.Ecto.Taggable' ->
        association.field
      _ ->
        find_taggable_assoc(model, assocs)
    end
  end
end
