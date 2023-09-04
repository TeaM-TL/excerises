variable "myip" {
  type    = string
  default = "1.1.1.1/32" # change this default IP or set TF_VAR_myip environment variable
}

variable "domain" {
  type    = string
  default = "vps-server.eu.org"
}
