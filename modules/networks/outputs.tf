output "the_vpc" {
  value = aws_vpc.the_vpc.id
}

output "the_public_subnets" {
  value = [aws_subnet.the_public.*.id]
}

output "the_private_subnets" {
  value = [aws_subnet.the_private.*.id]
}

output "http_https_lb_sg" {
  value = aws_security_group.http_https_lb.id
}

output "bastion_sg" {
  value = aws_security_group.bastion.id
}

output "webserver_sg" {
  value = aws_security_group.webserver.id
}
