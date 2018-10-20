# cloud-shell

This is tooling to provide a fast and convenient way to spin up a shell in the cloud.

## Features

- Custom shell image with [Packer](https://www.packer.io) and [Ansible](https://www.ansible.com/)
- Easily customise the image with additional [Ansible Galaxy](https://galaxy.ansible.com/) roles
- Edit files on the remote machine using [rmate for TextMate 2](https://github.com/sclukey/rmate-python)
- Forward local ssh key for use with git 

## Build

The image must first be built and stored in the desired GCP zone.

**Prerequisites:**
- [gcloud](https://cloud.google.com/sdk/gcloud/) must be installed and set to an account with the `roles/owner` role.
- Ansible must be installed. See [here](https://docs.ansible.com/ansible/2.5/installation_guide/intro_installation.html) for full installation instructions.
  - Mac OSX: `brew install ansible`

**Build the image:**
1. Edit [cloud-shell.cfg](cloud-shell.cfg) and set your GCP project ID and zone. Other configuration is optional.
    ```bash
    PROJECT_ID="cloud-shell-215704"
    ZONE="asia-northeast1-a"
    ```

2. Execute the following script to create a Google Cloud service account for Packer. It will be created with the `compute.instanceAdmin.v1` and `iam.serviceAccountUser` roles.
    ```bash
    ./create_packer_service_account.sh
    ```

3. (Optional) Customise the shell image by, for example, adding [Ansible Galaxy](https://galaxy.ansible.com/) roles.

4. Prepare the required ansible roles locally.
    ```bash
    ansible-galaxy install -r requirements.yml
    ```

5. Build and store the image in GCP.
    ```bash
    ./build.sh
    ```

## Usage

Launch a shell:
```bash
./cloud-shell.sh up
```

SSH to the virtual machine:
```
./cloud-shell.sh ssh
```

Delete the virtual machine:
```
./cloud-shell.sh down
```

## rmate

The default image comes with `rmate` installed allowing editing of files on the remote machine.
On your local machine you need to have an extension/plugin for your editor that supports Textmate's 'rmate' feature. Here are a couple of options:

- Visual Studio Code: [Remote VSCode](https://github.com/rafaelmaiolla/remote-vscode)
- Sublime Text: [RemoteSubl](https://github.com/randy3k/RemoteSubl)

#### Usage with Remote VSCode

1. Install the `Remote VSCode` extension.
2. Open the command palette (CTRL+P for Windows and CMD+P for Mac) then execute the `>Remote: Start Server` command.
3. SSH to the remote machine with `./cloud-shell.sh ssh`
4. Open remote files in Visual Studio Code with the command `rmate my-file.txt`

## SSH Agent Forwarding

This will allow use of your local SSH keys by the remote machine.
For example, if you have an SSH key that you have authorised access to your GitHub account it will be usable on the remote machine.

Add the following configuration to `~/.ssh/config` if you would like your local ssh key to be forwarded to the remote host.
The `<ip address>` is the IP of the virtual machine displayed after executing `./cloud-shell.sh up`.
```
Host <ip address>
 ForwardAgent yes
```

Once connected via ssh test the connection to GitHub:
```bash
ssh -T git@github.com
```

## Known Issues

The following error message when building is due to the [Too many SSH keys](https://www.packer.io/docs/provisioners/ansible.html#too-many-ssh-keys) issue.
```
googlecompute: fatal: [default]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: Warning: Permanently added '[127.0.0.1]:54452' (RSA) to the list of known hosts.\r\nReceived disconnect from 127.0.0.1 port 54452:2: too many authentication failures\r\nAuthentication failed.\r\n", "unreachable": true}
```
It can be fixed by clearing all keys from your ssh-agent.
```
$ ssh-add -D
```

## License

MIT License - see the [LICENSE](LICENSE) file for details
