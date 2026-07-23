resource "aws_key_pair" "brkim_key" {
  key_name   = "brkim-key"
  public_key = file(var.ssh_public_key_path)
}
