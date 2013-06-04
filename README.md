## OptiCSS

This optimizer is a WORK IN PROGRESS and is NOT intended for production use at 
this time.

Sample usage (using a strategy that does not work at this time):

```ruby
require 'Optimizer'

OptiCSS::Optimizer.new 'styles.src.css' do
  
  strategy :RedundancyRemoval
  save 'styles.css'
  
end
```

Alternate save methodology provided for CSS splitting:

```ruby
require 'Optimizer'

OptiCSS::Optimizer.new 'styles.src.css' do
  
  split_save 'styles.css'
  
end
```
