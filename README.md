## Instalation guide

[Download MesloFont (powerlvl10k)](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)

Update packages:
```sh
sudo apt-get update
```

### Install dependecies:

basics:
```sh
sudo apt-get install zsh git
```

node:
```sh
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y gcc g++ make nodejs
```

yarn:
```sh
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
```

Install powerlevel10k:
```sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Install vim-plug:
```sh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Download this repository:
```sh
git clone git@github.com:arielonoriaga/Configurations.git .config
```

### Create symbolic links:

zsh:
```sh
ln -sf .config/.zshrc .zshrc
```

vim:
```sh
ln -sf .config/.vimrc .vimrc
```

p10k:
```sh
ln -sf .config/.p10k.zsh .p10k.zsh
```
