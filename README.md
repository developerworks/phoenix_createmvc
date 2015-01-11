Phoenix MVCT Generator is a task that is used to generate files for your model/view/controller/templates

## Get started

![mix help](http://developerworks.github.io/assets/elixir/D4329902-946A-4286-9E10-E56C7E28D991.png)

![mix phoenix.createmvc](http://developerworks.github.io/assets/elixir/F8AB6ADD-C247-4B96-B0C6-B7FE92FFF3E3.png)

1. Add `phoenix_createmvc` to deps 
    ```
    defp deps do
      [
        {:phoenix, "~> 0.7.2"},
        {:cowboy, "~> 1.0"},
        {:phoenix_createmvc, github: "developerworks/phoenix_createmvc"}
      ]  
    end
    ```
2. `mix deps.get`
3. `mix deps.compile`
4. Execute `mix phoenix.createmvc user` will generate a user controller/views/templates
5. If you want to generate model skeleton, `ecto` should be added to deps

TODO:

- Add model generation
