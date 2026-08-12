# import ecr and s3 resources to the main line 
# I created ecr and s3 early, so now i need to import them here
import {
  to = module.ecr.aws_ecr_repository.this["qr-code-api"]
  id = "qr-code-api"
}

# import {
#   to = module.ecr.aws_ecr_repository.this["qr-code-frontend"]
#   id = "qr-code-frontend"
# }

import {
  to = module.s3.aws_s3_bucket.app
  id = "qr-app-s3-bucket"
}