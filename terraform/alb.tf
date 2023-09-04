resource "aws_alb" "wordpress" {
  name     = "wordpress"
  internal = false

  security_groups = [
    aws_security_group.internal.id,
    aws_security_group.out.id,
    aws_security_group.web.id
  ]

  subnets = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "black_hole" {
  name     = "black-hole"
  port     = 9 # Discard_Protocol
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.wordpress.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    order = 1
    type  = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "80"
      protocol    = "HTTP"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.wordpress.arn
  port              = 80
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-TLS-1-1-2017-01"
  # certificate_arn   = aws_acm_certificate.wordpress.arn

  default_action {
    target_group_arn = aws_lb_target_group.black_hole.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group" "wordpress" {
  name     = "wordpress"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
}

resource "aws_alb_target_group_attachment" "wordpress" {
  target_group_arn = aws_alb_target_group.wordpress.arn
  target_id        = aws_instance.wordpress.id
}

resource "aws_alb_listener_rule" "wordpress" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 120

  action {
    target_group_arn = aws_alb_target_group.wordpress.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [
        "wordpress.${var.domain}",
        "*.wordpress.${var.domain}"
      ]
    }
  }
}