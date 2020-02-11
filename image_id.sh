#!/usr/bin/bash
aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-?.?.????????.?-x86_64-gp2' 'Name=state,Values=available' --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' --output text
