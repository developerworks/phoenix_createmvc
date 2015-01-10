defmodule Mix.Tasks.Phoenix.Createmvc do
  use Mix.Task

  import Mix.Generator
  import Mix.Utils, only: [camelize: 1, underscore: 1]
  import Mix.Project

  @shortdoc "Create phoenix model/view/controller/templates"

  @moduledoc """
  Create a new mvc scaffold in your `app/web` foulder

  ## Exmaple:

      mix phoenix.createmvc controller_name

  This mix task will create :

  - A controller at `web/controller/{$controller_name}_controller.ex`
  - A model at `web/model/{$controller_name}.ex`
  - A view at `web/view/{$controller_name}.html.eex`

  in your application directory.

  The variable `${controller_name}` will be replaced by `controller_name` argument
  in the command line.
  """

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    {opts, argv, _} = OptionParser.parse(argv, strict: [dev: :boolean])
    run(argv, opts)
  end

  def run([name], _opts) do
    IO.puts "phoenix.createmvc: Creating a '#{name}' controller/view"
    params = [application_name: config[:app], controller_name: name]
    do_generate(params)
  end

  def run(_, _opts) do
    Mix.raise """
    phoenix.create expects controller name

        mix phenix.create controller_name
    """
  end


  defp do_generate(params) do

    if File.exists?(Path.join(application_path,".editorconfig")) === false do
      create_file ".editorconfig", editorconfig_text
      IO.puts """

      It seems like not `.editorconfig` exists in you project root directory, created for you.
      If the `.editorconfig` default configuration is not suitable for you, you can overwrite it in child directory
      """
    end

    phoenix_web_path = Path.join(application_path, "/web")
    semanticui_path  = Path.join(application_path, "/priv/static/semanticui")
    assigns = [
        application_name: camelize(Atom.to_string(params[:application_name])),
        controller_name: camelize(params[:controller_name]),
        application: params[:application_name],
        controller: params[:controller_name],
        model_name: params[:controller_name]
    ]
    if File.dir?(semanticui_path) do
      File.rm_rf!(semanticui_path)
      IO.puts "Deleting directory #{semanticui_path}"
    end
    # If someone do not use the default _build dir and location?
    # How to get application root dir?
    if File.dir?(phoenix_web_path) === true do

      name = assigns[:controller]
      # Create model/view/controller files
      # If there is a new db adapter, add it to if condition
      if config[:deps][:ecto] !== nil do
        create_file "web/models/#{name}.ex", model_template(assigns)
      else
        IO.puts """

        Depencency ecto is not in your mix.exs file, you shoud add it into deps in your mix.exs file,
        and re-run `mix phoenix.createmvc name`
        """
      end
      create_file "web/views/#{name}_view.ex", view_template(assigns)
      create_file "web/controllers/#{name}_controller.ex", controller_template(assigns)
      # Create templates for controller actions
      create_directory "web/templates/#{name}"
      create_file "web/templates/#{name}/index.html.eex", action_index_template(assigns)
      create_file "web/templates/#{name}/create.html.eex", action_index_template(assigns)
      create_file "web/templates/#{name}/edit.html.eex", action_index_template(assigns)
      create_file "web/templates/#{name}/show.html.eex", action_index_template(assigns)

      # Copy semantic ui files
      source = Path.join(application_path, "/deps/phoenix_createmvc/priv/static/ui")
      destination = Path.join(application_path, "/priv/static/ui")

      if File.dir?(destination) === false do
        File.cp_r!(source, destination, fn(_, destination) ->
          IO.puts "copying file to #{destination}"
        end)
      end

      # Copy google fonts to local file system for china
      fonts_source = Path.join(application_path, "/deps/phoenix_createmvc/priv/static/googlefonts")
      fonts_destination = Path.join(application_path, "/priv/static/googlefonts")

      if File.dir?(fonts_destination) === false do
        File.cp_r!(fonts_source, fonts_destination, fn(_, destination) ->
          IO.puts "copying file to #{destination}"
        end)
      end



      # Copy layout
      #layout_source = Path.join(application_path, "/deps/phoenix_createmvc/priv/templates/application.html.eex")
      #layout_destination = Path.join(application_path, "/web/templates/layout/application.html.eex")

    else
      Mix.raise """
      #{phoenix_web_path} folder does not exists.

      This project is a phoenix project create with:

          `mix phoenix.new` ?
      """
    end
  end

  defp application_path do
    Path.dirname(Path.dirname(build_path))
  end

  #defp t(name) do
  #  {:ok, binary} = File.read(Path.join(application_path, "/deps/phoenix_createmvc/templates/#{name}.html.eex"))
  #  binary
  #end

  embed_text :editorconfig, """
  root = true
  [*]
  indent_style = space
  indent_size = 2
  end_of_line = lf
  charset = utf-8
  trim_trailing_whitespace = true
  insert_final_newline = true

  [*.md]
  trim_trailing_whitespace = false

  [*.eex]
  indent_style = space
  indent_size = 2

  [*.ex]
  indent_style = space
  indent_size = 2
  """

  # embed_template is a macro, could not pass runtime function `t/1`
  embed_template :action_index, """
  <div class="model" id="<%= @application_name%>_<%= @controller_name%>">
    <table class="ui table">
      <thead>
      <tr>
        <th>Name</th>
        <th>Registration Date</th>
        <th>E-mail address</th>
        <th>Premium Plan</th>
      </tr>
      </thead>
      <tbody>
      <tr>
        <td>John Lilki</td>
        <td>September 14, 2013</td>
        <td>jhlilk22@yahoo.com</td>
        <td>No</td>
      </tr>
      <tr>
        <td>Jamie Harington</td>
        <td>January 11, 2014</td>
        <td>jamieharingonton@yahoo.com</td>
        <td>Yes</td>
      </tr>
      <tr>
        <td>Jill Lewis</td>
        <td>May 11, 2014</td>
        <td>jilsewris22@yahoo.com</td>
        <td>Yes</td>
      </tr>
      </tbody>
    </table>
  </div>
  """
  embed_template :action_create, """
  """
  embed_template :action_edit, """
  """


  embed_template :controller, """
  defmodule <%= @application_name%>.<%= @controller_name%>Controller do
    use Phoenix.Controller

    plug :action

    @items_per_page 15

    @doc \"\"\"
    List rows by page
    \"\"\"
    def index(req, %{"page" => page}) do
      render req, "index.html"
    end

    def index(req, %{}) do
      index(req, %{"page" => "1"})
    end

    @doc \"\"\"
    Show an item
    \"\"\"
    def show(req, params) do
      if(params[:id] !== nil) do
        render req, "show.html"
      else
        render req, "404.html"
      end
    end

    @doc \"\"\"
    Edit an item
    \"\"\"
    def edit(req, params) do
      if(params[:id] !== nil) do
        render req, "edit.html"
      else
        render req, "404.html"
      end
    end

    @doc \"\"\"
    Search action, if have search conditions, matching the following first function, otherwise the second.
    \"\"\"
    def search(req, params) do
      if params !== nil do
        render req, "search.html"
      end
    end
  end
  """

  embed_template :model, """
  defmodule <%= @application_name%>.<%= @controller_name%> do
    use Ecto.Model

    schema "<%= @model_name%>" do
    end
  end
  """

  embed_template :view, """
  defmodule <%= @application_name%>.<%= @controller_name%>View do
    use <%= @application_name%>.View
  end
  """
end
