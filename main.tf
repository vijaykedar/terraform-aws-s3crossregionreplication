provider "aws" {
  alias  = "source"
  region = var.region_source_bucket

}


provider "aws" {
  alias  = "destination"
  region = var.region_destination_bucket

}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "source-bucket" {
  provider = aws.source
  bucket   = "${var.source_bucket_name}-${random_id.suffix.hex}"
  force_destroy = true

}


resource "aws_s3_bucket_versioning" "source"{
provider = aws.source
bucket = aws_s3_bucket.source-bucket.id

versioning_configuration {
status = "Enabled"
}
 depends_on = [
    aws_s3_bucket.source-bucket
  ]
}

resource "aws_s3_bucket" "destination-bucket" {
  provider = aws.destination
  bucket   = "${var.destination_bucket_name}-${random_id.suffix.hex}"
  force_destroy = true
depends_on = [
    aws_s3_bucket_versioning.source                        
  ]
}

resource "aws_s3_bucket_versioning" "destination" {
provider = aws.destination
bucket = aws_s3_bucket.destination-bucket.id

versioning_configuration{
status = "Enabled"
}
 depends_on = [
    aws_s3_bucket.destination-bucket
  ]


}


resource "aws_s3_bucket_replication_configuration" "replication" {
bucket = aws_s3_bucket.source-bucket.id
#role = "arn:aws:iam::013623161468:role/s3-replica-role"
role     = aws_iam_role.replication_role.arn
provider = aws.source

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

depends_on = [
    aws_s3_bucket_versioning.destination
  ]

}
	
