# F-Secure to Bitwarden

A simple Ruby script that converts F-Secure ID Protection (formerly F-Secure Key) password exports (JSON) to Bitwarden JSON.

To run, you'll need an [installation of Ruby](https://www.ruby-lang.org/en/documentation/installation/). Only tested with Ruby 2.7.0.

Then, clone this repo and run:
```sh
ruby ftb.rb path/to/your/fsecure/exported.json
```

Limited configuration is available in `config.json`.

Several assumptions are made about card expiry formats.

Information about Bitwarden JSON schema is [here](https://bitwarden.com/help/article/condition-bitwarden-import/#for-your-personal-vault-1).