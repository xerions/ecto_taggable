defmodule TestModel do
  use Ecto.Schema
  schema "ecto_taggable_test_table" do
    field :a, :string
    field :b, :integer
    field :c, :boolean
    has_many :tags, {"test_model_tags", Ecto.Taggable}, [foreign_key: :tag_id]
  end
end
 
defmodule EctoTaggableTest do
  use ExUnit.Case

  test "ecto_taggable test" do
    :ok = :application.start(:ecto_it)
    Ecto.Migration.Auto.migrate(EctoIt.Repo, TestModel)
    Ecto.Migration.Auto.migrate(EctoIt.Repo, Ecto.Taggable, [for: TestModel])

    EctoIt.Repo.insert(%TestModel{a: "test1", b: 1, c: true})
    res2 = EctoIt.Repo.insert(%TestModel{a: "test2", b: 2, c: true})
    res3 = EctoIt.Repo.insert(%TestModel{a: "test3", b: 3, c: false})
    EctoIt.Repo.insert(%TestModel{a: "test4", b: 4, c: true})

    # test set/search tags
    set_tag1 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res2, :mytag)
    set_tag2 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res2, :mytag)
    set_tag3 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res3, :my_another_tag)
    set_tag4 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, %TestModel{id: 100}, :bad_tag)

    assert set_tag1 == :ok
    assert set_tag2 == :already_tagged
    assert set_tag3 == :ok
    assert set_tag4 == :id_not_exists

    bad_tag  = Ecto.Taggable.Api.search_tag(EctoIt.Repo, TestModel, :mytag2)
    [good_tag] = Ecto.Taggable.Api.search_tag(EctoIt.Repo, TestModel, :mytag)

    assert bad_tag == []
    assert good_tag.a == "test2"
    assert good_tag.b == 2
    assert good_tag.c == true
    assert good_tag.id == 2

    # test tag deletion
    good_tag = Ecto.Taggable.Api.drop_tag(EctoIt.Repo, TestModel, :mytag)
    bad_tag  = Ecto.Taggable.Api.search_tag(EctoIt.Repo, TestModel, :mytag)

    assert good_tag == :ok
    assert bad_tag == []

    :ok = :application.stop(:ecto_it)
  end
end
