RailsLatexDemo::Application.routes.draw do
  match 'latex_example' => "latex_example#index"
  match 'latex_example/barcode' => "latex_example#barcode"
  match 'latex_example/barcode_as_string' => "latex_example#barcode_as_string"

  root :to => "latex_example#index"
end
