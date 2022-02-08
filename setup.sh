sudo apt-get update

sudo apt-get install -y zsh gcc g++ make nodejs xclip

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# yarn
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get install yarn

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# nvim requirements
sudo apt-get install ripgrep

# symbolic links
ln -sf .config/.zshrc .zshrc
ln -sf .config/.vimrc .vimrc
ln -sf .config/.p10k.zsh .p10k.zsh

# lazydocker
mkdir temporals/
cd temporals/

LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"

mkdir lazydocker-temp

tar xf lazydocker.tar.gz -C ~/temporals/lazydocker-temp

mv ~/temporals/lazydocker-temp/lazydocker /usr/local/bin
lazydocker --version

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage

mv ~/temporals/nvim.appimage /usr/bin/nvim

cd ~

rm -Rf ~/temporals/

#lazygit
sudo add-apt-repository ppa:lazygit-team/daily
sudo apt-get update
sudo apt-get install lazygit

#reload terminal
source ~/.zshrc

echo 'Setup complete!'
