provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "ap-south-1"
  region = "ap-south-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "source-bucket" {
  provider = aws.ap-south-1
  bucket   = var.source_bucket_name
  force_destroy = true

}


resource "aws_s3_bucket_versioning" "source"{
provider = aws.ap-south-1
bucket = aws_s3_bucket.source-bucket.id

versioning_configuration {
status = "Enabled"
}

}

resource "aws_s3_bucket" "destination-bucket" {
  provider = aws.us-east-1
  bucket   = "${var.destination_bucket_name}-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "destination" {
provider = aws.us-east-1
bucket = aws_s3_bucket.destination-bucket.id

versioning_configuration{
status = "Enabled"
}

}


resource "aws_s3_bucket_replication_configuration" "replication" {
bucket = aws_s3_bucket.source-bucket.id
#role = "arn:aws:iam::013623161468:role/s3-replica-role"
role     = aws_iam_role.replication_role.arn


rule {

id = "replication-all"
status = "Enabled"

filter {
prefix = ""
}

destination {
bucket = aws_s3_bucket.destination-bucket.arn
storage_class = "STANDARD"
}
  delete_marker_replication {
      status = "Enabled"  # or "Disabled"
    }
}

}
	
