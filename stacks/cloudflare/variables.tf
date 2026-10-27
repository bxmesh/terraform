variable "state_passphrase" {
  description = "Encrypts this repo's state and plans. From the owner's keychain, through tofu.sh."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.state_passphrase) >= 16
    error_message = "The state passphrase must be at least 16 characters (OpenTofu's pbkdf2 minimum)."
  }
}
