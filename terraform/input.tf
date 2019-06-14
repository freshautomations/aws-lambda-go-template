variable link_prefix {
  type        = "string"
  default     = "staging"
  description = "Identifier token from config.toml"
}

variable lambda_timeout {
  type = "string"
  default = "2"
  description = "Lambda timeout value"
}

