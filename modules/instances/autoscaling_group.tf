resource "aws_autoscaling_group" "webservers" {
  desired_capacity     = var.ec2.autoscaling_group.webservers.desired_capacity
  min_size             = var.ec2.autoscaling_group.webservers.min_size
  max_size             = var.ec2.autoscaling_group.webservers.max_size
  #vpc_zone_identifier  = [aws_subnet.the_private[0].id, aws_subnet.the_private[1].id]
  #vpc_zone_identifier = tolist([aws_subnet.the_private.*.id])
  vpc_zone_identifier = var.ec2.autoscaling_group.webservers.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.webservers.id
    version = "$Latest"
  }
}

