#
# Create the ELB (Elastic Load Balancer)
#
resource "aws_lb" "webservers" {
  name                  = var.ec2.lb.webservers.name
  internal              = false
  load_balancer_type    = "application"
  security_groups       = var.ec2.lb.webservers.security_groups
  subnets               = var.ec2.lb.webservers.subnets

  tags = {
    Name        = var.ec2.lb.webservers.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
# Create the elb target group
#
resource "aws_lb_target_group" "webservers_http" {
  name      = var.ec2.lb.webservers.http_target_group.name
  port      = 80
  protocol  = "HTTP"
  vpc_id    = var.vpc

  tags = {
    Name        = var.ec2.lb.webservers.http_target_group.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}


#
# Create the load_balancer port listener
#
resource "aws_lb_listener" "webservers_http" {
  load_balancer_arn = aws_lb.webservers.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type                = "forward"
    target_group_arn    = aws_lb_target_group.webservers_http.arn
  }

  tags = {
    Name        = var.ec2.lb.webservers.http_lb_listener.name
    managedby   = local.managed_by
    Candidate   = var.candidate
  }
}

#
# Attached the target_group with the autoscaling
#
resource "aws_autoscaling_attachment" "webservers_http" {
  autoscaling_group_name    = aws_autoscaling_group.webservers.id
  lb_target_group_arn       = aws_lb_target_group.webservers_http.arn
}
