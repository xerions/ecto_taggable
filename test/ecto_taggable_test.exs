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

    {:ok, res1} = EctoIt.Repo.insert(%TestModel{a: "test1", b: 1, c: false})
    {:ok, res2} = EctoIt.Repo.insert(%TestModel{a: "test2", b: 2, c: true})
    {:ok, res3} = EctoIt.Repo.insert(%TestModel{a: "test3", b: 3, c: false})
    {:ok, res4} = EctoIt.Repo.insert(%TestModel{a: "test4", b: 4, c: true})

    set_tag1 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res1, :mytag)
    set_tag2 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res2, :mytag)
    set_tag3 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res2, :mytag)
    set_tag4 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res4, :my_another_tag)
    set_tag5 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, %TestModel{id: 100}, :bad_tag)

    #assert set_tag1 == :ok
    assert set_tag2 == :ok
    assert set_tag3 == :already_tagged
    assert set_tag4 == :ok
    assert set_tag5 == :id_not_exists

    bad_tag  = Ecto.Taggable.Api.search_tag(EctoIt.Repo, TestModel, :mytag2)
    [good_tag1, good_tag2] = Ecto.Taggable.Api.search_tag(EctoIt.Repo, TestModel, :mytag)

    assert bad_tag == []

    assert good_tag1.a == "test1"
    assert good_tag1.b == 1
    assert good_tag1.c == false
    assert good_tag1.id == 1

    assert good_tag2.a == "test2"
    assert good_tag2.b == 2
    assert good_tag2.c == true
    assert good_tag2.id == 2

    # test tag deletion
    good_tag = Ecto.Taggable.Api.drop_tag(EctoIt.Repo, TestModel, :mytag)
    deleted_tag = Ecto.Taggable.Api.search_tag(EctoIt.Repo, TestModel, :mytag)

    assert good_tag == :ok
    assert bad_tag == []
    :ok = :application.stop(:ecto_it)
  end
end
