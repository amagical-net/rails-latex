RailsLatexDemo::Application.routes.draw do
  match 'latex_example' => "latex_example#index"

  root :to => "latex_example#index"
end
