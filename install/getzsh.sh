#! /bin/bash
# sudo apt install -y zsh
# chsh -s /usr/bin/zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc
sudo apt-get install fonts-powerline
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k
sed -i 's/ZSH_THEME="agnoster"/ZSH_THEME="powerlevel10k/powerlevel10k"/g' ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/esc/conda-zsh-completion ~/.oh-my-zsh/custom/plugins/conda-zsh-completion
sed -i 's/^plugins=(\(.*\))/plugins=(\1 colored-man-pages zsh-autosuggestions zsh-syntax-highlighting conda-zsh-completion)/' ~/.zshrc
