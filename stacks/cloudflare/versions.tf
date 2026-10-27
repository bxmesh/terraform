terraform {
  required_version = "1.13.2"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.28.1"
    }
  }

  # State in its own R2 bucket in the owner's account (O80), locked with OpenTofu's lockfile, which
  # needs R2's conditional writes (T24). The bucket is made by hand before the first apply (O30).
  # Its key pair comes from the environment: GitHub's environment secrets in CI, the keychain on
  # the owner's laptop (tofu.sh).
  backend "s3" {
    bucket = "bxmesh-tofu-state"
    key    = "terraform.tfstate"
    region = "auto"
    endpoints = {
      s3 = "https://a4bcb99cdf5a071a4c78f941a5b91f6f.r2.cloudflarestorage.com"
    }
    use_lockfile                = true
    use_path_style              = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }

  # The state holds the tunnel's token and external-dns's token, so it's encrypted before it
  # leaves the machine, with a passphrase the owner chose (O80).
  encryption {
    key_provider "pbkdf2" "passphrase" {
      passphrase = var.state_passphrase
    }
    method "aes_gcm" "passphrase" {
      keys = key_provider.pbkdf2.passphrase
    }
    state {
      method   = method.aes_gcm.passphrase
      enforced = true
    }
    plan {
      method   = method.aes_gcm.passphrase
      enforced = true
    }
  }
}

# Signs in with CLOUDFLARE_API_TOKEN from the environment: the apply token in CI's `main`
# environment, the read-only one in `plan`.
provider "cloudflare" {}
