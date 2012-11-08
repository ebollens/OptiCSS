## OptiCSS

This optimizer is a WORK IN PROGRESS and is NOT intended for production use at 
this time.

Sample usage for the optimizer:

```ruby
require 'Optimizer'

OptiCSS::Optimizer.new 'styles.src.css' do
  
  strategy :RedundancyRemoval
  save 'styles.css'
  
end
```
