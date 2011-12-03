Usage
=====

    invalidator = CloudfrontInvalidator.new('<AWS key>', '<AWS secret>', '<CF distribution id>')
    invalidator.invalidate('/images/rails.png', '/images/example.jpg')
    invalidator.list()
    invalidator.list_detail()

or, from the command line:

`cloudfront-invalidator invalidate aws_key aws_secret distribution_id /images/rails.png /images/example.jpg`
`cloudfront-invalidator list aws_key aws_secret distribution_id`
`cloudfront-invalidator list_detail aws_key aws_secret distribution_id`
