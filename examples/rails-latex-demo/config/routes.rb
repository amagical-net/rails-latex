Rails.application.routes.draw do
  get 'latex_example' => "latex_example#index"
  get 'latex_example/barcode' => "latex_example#barcode"
  get 'latex_example/barcode_as_string' => "latex_example#barcode_as_string"

  root :to => "latex_example#index"
end
