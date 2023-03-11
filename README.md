# Certificate Authority (CA) Generator and SSH Key Pair Signing

These are different shell scripts that create SSH key pairs and sign them using a certificate authority (CA). Clients connecting to an SSH server host can be verified using the generated keys signed by the CA. Modify the variables in the scripts with your relevant information, then run the scripts in a terminal to utilize them. The scripts will automatically create the SSH key pairs and sign them using the CAs. When connecting to an SSH server host, clients can use the produced keys to authenticate themselves.

## Usage

1. Clone this repository.
2. You'll have to edit the files directly to change their settings.
3. Execute the file `./generate_xxxx_pair.sh` in its respective directory.
4. The SSH key pairs will be automatically generated by the scripts and signed with the CAs.
5. Ensure that the clients trust the host CA public key and the servers trust the client CA cert.
6. Load the client private key and cert to the ssh-agent.

## License

This project is licensed under the [MIT License](LICENSE.txt).
