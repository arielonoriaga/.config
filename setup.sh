sudo apt-get update
sudo add-apt-repository ppa:lazygit-team/release

curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io zsh gcc g++ make nodejs xclip ripgrep lazygit yarn ca-certificates curl gnupg lsb-release jq

# node
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# symbolic links
ln -sf ~/.config/.fzf.zsh .fzf.zsh
ln -sf ~/.config/.p10k.zsh .p10k.zsh
ln -sf ~/.config/.vimrc .vimrc
ln -sf ~/.config/.zshrc .zshrc
sudo ln -sf ~/.config/journald.conf /etc/systemd/journald.conf

# lazydocker
mkdir ~/temporals/
cd ~/temporals/

LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
mkdir lazydocker-temp

tar xf lazydocker.tar.gz -C ~/temporals/lazydocker-temp

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage

git clone --depth 1 https://github.com/junegunn/fzf.git

cd ~

chown ${USER}:${USER} temporals --recursive

sudo mv ~/temporals/lazydocker-temp/lazydocker /usr/local/bin
lazydocker --version

sudo mv ~/temporals/nvim.appimage /usr/bin/nvim
~/temporals/fzf/install --all

rm -Rf ~/temporals/

# zsh plugins
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

#reload terminal
source ~/.zshrc

echo 'Setup complete!'
