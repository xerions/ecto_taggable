EctoTaggable
============

`ecto_taggable` allows to tag any row of an `ecto` model.

For example you have model:

```elixir
defmodule MyModel do
  use Ecto.Model
  schema "user" do
    field :name, :string
    field :old,  :integer
    has_many :tags, {"test_model_tags", Ecto.Taggable}, [foreign_key: :tag_id] # foreign_key: tag_id is necessarily
  end
end
```

You can migrate this model and related `tags` model to the database with [ecto_migrate](https://github.com/xerions/ecto_migrate):

```elixir
Ecto.Migration.Auto.migrate(EctoIt.Repo, MyModel)
Ecto.Migration.Auto.migrate(EctoIt.Repo, Ecto.Taggable, [for: MyModel])
```

Insert data in the database and set tag on this data:

```elixir
my_model1 = repo.insert(%MyModel{name: "foo", old: 20})
my_model2 =repo.insert(%MyModel{name: "bar", old: 25})
Ecto.Taggable.set_tag(repo, my_model2 :tag_name)
```

`ecto_taggable` provides ability to search tag with:

```elixir
Ecto.Taggable.search_tag(repo, MyModel, :tag_name) % ==> %MyModel{name: "bar", ...}
```

and delete tag with:

```elixir
Ecto.Taggable.Api.drop_tag(EctoIt.Repo, MyModel, :tag_name)
```
