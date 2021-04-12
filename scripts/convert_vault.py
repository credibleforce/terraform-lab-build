#!/usr/bin/env python3

import sys
import yaml
import argparse
from ansible.parsing.vault import VaultLib
from ansible.cli import CLI
from ansible import constants as C
from ansible.parsing.dataloader import DataLoader
from ansible.parsing.yaml.dumper import AnsibleDumper
from ansible.parsing.yaml.loader import AnsibleLoader
from ansible.parsing.yaml.objects import AnsibleVaultEncryptedUnicode

"""
This script reads a yaml file and dumps it back while encrypting
the values but keeping the keys plaintext. To convert an ansible
vault file format into yaml you can do:
    ansible-vault decrypt --output - vault | \
        python ./convert_vault.py > new-vault
"""


def encrypt_string(decrypted_secret, vault_pass_file, vault_id):
    """
    Encrypts string
    """
    loader = DataLoader()
    vault_secret = CLI.setup_vault_secrets(
        loader=loader,
        vault_ids=C.DEFAULT_VAULT_IDENTITY_LIST,
        vault_password_files=[vault_pass_file]
    )
    vault = VaultLib(vault_secret)
    return AnsibleVaultEncryptedUnicode(
            vault.encrypt(decrypted_secret,
                          vault_id=vault_id))


def encrypt_dict(d, vault_pass_file, vault_id):
    for key in d:
        value = d[key]
        if isinstance(value, str):
            d[key] = encrypt_string(value, vault_pass_file, vault_id)
        elif isinstance(value, list):
            for item in value:
                encrypt_dict(item, vault_pass_file, vault_id)
        elif isinstance(value, dict):
            encrypt_dict(value, vault_pass_file, vault_id)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input-file',
                        help='File to read from',
                        default='-')
    parser.add_argument('--vault-id',
                        help='Vault id used for the encryption',
                        default=None)
    parser.add_argument('--vault-pass-file',
                        help='Vault password file used for the encryption',
                        default=None)
    args = parser.parse_args()
    in_file = sys.stdin if args.input_file == '-' else open(args.input_file)
    d = yaml.load(in_file, Loader=AnsibleLoader)
    vault_pass_file=args.vault_pass_file
    vault_id=args.vault_id

    encrypt_dict(d, vault_pass_file, vault_id)

    print(yaml.dump(d, Dumper=AnsibleDumper))


if __name__ == "__main__":
    main()
