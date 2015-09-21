defmodule Ecto.Taggable do
  use Ecto.Model
  schema "not-used-schema" do
    field :name, :string
    field :value, :string
    field :model, :string
    field :tag_id, :integer
  end
end
