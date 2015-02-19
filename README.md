Usage
=====

    invalidator = CloudfrontInvalidator.new(AWS_KEY, AWS_SECRET, CF_DISTRIBUTION_ID)
    list = %w[
      index.html
      favicon.ico
    ]
    invalidator.invalidate(list) do |status,time|   # Block is optional.
      invalidator.list                              # Or invalidator.list_detail
      puts "Complete after < #{time.to_f.ceil} seconds." if status == "Complete"
    end

A command line utility is also included.

    $ cloudfront-invalidator invalidate $AWS_KEY $AWS_SECRET $DISTRIBUTION_ID index.html favicon.ico
    $ cloudfront-invalidator list $AWS_KEY $AWS_SECRET $DISTRIBUTION_ID
    $ cloudfront-invalidator list_detail $AWS_KEY $AWS_SECRET $DISTRIBUTION_ID

Amazon IAM Policy
=================

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "cloudfront:CreateInvalidation",
            "cloudfront:GetInvalidation",
            "cloudfront:ListInvalidations"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }

Authors
=======

* Reid M Lynch
* Jacob Elder
