Usage
=====

`
invalidator = CloudfrontInvalidator.new('<AWS key>', '<AWS secret>', '<CF distribution id>')  
invalidator.invalidate('/images/rails.png')  
invalidator.list()  
invalidator.list_detail()  
`
