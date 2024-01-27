resource "aws_sqs_queue" "terraform_queue" {
  name                        = "felipe-tomazelli-123.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}