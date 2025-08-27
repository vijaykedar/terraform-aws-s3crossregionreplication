output "source_bucket_name" {
value = "Your Source bucket Name is ${aws_s3_bucket.source-bucket.bucket}"
}

output "source_destination_name" { 
value = "Your Destination bucket Name is ${aws_s3_bucket.destination-bucket.bucket}"
}
