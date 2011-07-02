RailsLatexDemo::Application.routes.draw do
  match 'latex_example' => "latex_example#index"
  match 'latex_example/barcode' => "latex_example#barcode"

  root :to => "latex_example#index"
end
