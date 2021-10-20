#!/bin/bash
mod="module_name"
terraform plan -target=module.$mod -out deploy-history/$mod.out && terraform apply deploy-history/$mod.out