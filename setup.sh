sudo apt-get update
sudo add-apt-repository ppa:lazygit-team/daily


curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update

sudo apt-get install -y zsh gcc g++ make nodejs xclip ripgrep lazygit yarn

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

# symbolic links
ln -sf .config/.fzf.zsh .fzf.zsh
ln -sf .config/.p10k.zsh .p10k.zsh
ln -sf .config/.vimrc .vimrc
ln -sf .config/.zshrc .zshrc

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

git clone --depth 1 https://github.com/junegunn/fzf.git
~/temporals/fzf/install --all

cd ~

rm -Rf ~/temporals/

#reload terminal
source ~/.zshrc

echo 'Setup complete!'
