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

    set_tag1 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res1, :mytag, "test_val_1")
    set_tag2 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res2, :mytag, "test_val_2")
    set_tag3 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res2, :mytag, "test_val_2")
    set_tag4 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, res4, :my_another_tag, "another_val")
    set_tag5 = Ecto.Taggable.Api.set_tag(EctoIt.Repo, %TestModel{id: 100}, :bad_tag, "bad_tag")

    assert set_tag1 == %{id: 1}
    assert set_tag2 == %{id: 2}
    assert set_tag3 == :already_tagged
    assert set_tag4 == %{id: 3}
    assert set_tag5 == :id_not_exists

    bad_tag  = Ecto.Taggable.Api.search_tag(EctoIt.Repo, TestModel, :mytag2, "val_val")
    assert bad_tag == []

    [good_tag] = Ecto.Taggable.Api.search_tag(EctoIt.Repo, TestModel, :mytag, "test_val_1")
    assert good_tag.a == "test1"
    assert good_tag.b == 1
    assert good_tag.c == false
    assert good_tag.id == 1

    # test tag deletion
    good_tag = Ecto.Taggable.Api.drop_tag(EctoIt.Repo, %TestModel{id: 1}, :mytag, "test_val_1")
    assert good_tag == %{id: 1}
    [deleted_tag] = Ecto.Taggable.Api.search_tag(EctoIt.Repo, TestModel, :mytag, "test_val_2")

    assert deleted_tag.a == "test2"
    assert deleted_tag.b == 2
    assert deleted_tag.c == true
    assert deleted_tag.id == 2

    good_tag = Ecto.Taggable.Api.drop_tag(EctoIt.Repo, TestModel, :mytag, "test_val_2")
    bad_tag = Ecto.Taggable.Api.drop_tag(EctoIt.Repo, TestModel, :mytag, "test_val_2")

    assert good_tag = :ok
    assert bad_tag = []

    :ok = :application.stop(:ecto_it)
  end
end
