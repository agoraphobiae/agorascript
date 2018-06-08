#!/bin/bash
# requires git to exist
# symlinks vimrc, bash_profile, tmux_conf

if hash apt-get 2>/dev/null; then
	# neovim
	sudo add-apt-repository -y ppa:neovim-ppa/unstable
	# tmux
	sudo add-apt-repository -y ppa:pi-rho/dev
	sudo apt-get update

	sudo apt-get install --assume-yes git curl vim tmux autojump htop cmake cgdb xclip zsh
	sudo apt-get install --assume-yes neovim python-dev python-pip python3-dev python3-pip
	sudo apt-get install -y python-software-properties software-properties-common
	sudo apt-get install -y tmux=2.0-1~ppa1~t
fi
mkdir ~/git
if [ -d ~/git/dotfiles ]; then
	# dotfiles already set up?
	echo "~/git/dotfiles already exists! Delete and start fresh?"

	select yn in "Yes" "No"; do
	    case $yn in
		Yes ) rm -rf ~/git/dotfiles; break;;
		No ) echo "Ok. exiting..."; exit;;
	    esac
	done
fi
mkdir ~/git/dotfiles
git clone https://github.com/phorust/dotfiles.git ~/git/dotfiles

function setup_ssh {
	ssh-keygen
	echo "======= COPY BELOW THIS LINE FOR SETTING UP THIS KEY (on github) ======="
	cat ~/.ssh/id_rsa.pub
	echo "======= COPY ABOVE THIS LINE FOR SETTING UP THIS KEY (on github) ======="
}
echo "Generate an ssh-key?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) setup_ssh; break;;
        No ) echo "Ok. You may need to update the git remote in ~/git/dotfiles if later you want to commit."; break;;
    esac
done
if [ -f ~/.ssh/id_rsa.pub ]; then
    cd ~/git/dotfiles && git remote set-url origin git@github.com:phorust/dotfiles.git
fi

# set up oh-my-zsh and extra zsh stuff
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
# set up extra vim stuff
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qall
# set up extra tmux stuff
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# now, lets hook up our actual dotfiles
if [ -L ~/.tmux.conf ]; then
    mv ~/.tmux.conf ~/.tmux.conf.prephorust
fi
ln -s ~/git/dotfiles/tmux.conf ~/.tmux.conf
echo -e "\n# KL\nsource ~/git/dotfiles/bash_profile" >> ~/.bash_profile
if [ -L ~/.vimrc ]; then
    mv ~/.vimrc ~/.vimrc.prephorust
fi
ln -s ~/git/dotfiles/vimrc ~/.vimrc
mkdir -p ~/.config/nvim
ln -s ~/git/dotfiles/init.vim ~/.config/nvim/init.vim
if [ -L ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.prephorust
fi
ln -s ~/git/dotfiles/zshrc ~/.zshrc
if [ -L ~/.zshenv ]; then
    mv ~/.zshenv ~/.zshenv.prephorust
fi
ln -s ~/git/dotfiles/zshenv ~/.zshenv


# get git helpers
mkdir ~/bin
cd ~/bin && curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o git-prompt.sh
cd ~/bin && curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o git-completion.bash
cd ~/bin && curl -X GET https://raw.githubusercontent.com/holman/spark/master/spark -o spark
cd ~/bin && curl https://raw.githubusercontent.com/felipec/git-remote-hg/master/git-remote-hg -o git-remote-hg
chmod +x ~/bin/*


read -d '' reattachscript <<- EOF
#!/bin/bash
# For non-OS X systems, a placeholder for the program from
# https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard
exec \$@
EOF
# run leek when opening a terminal window
read -d '' tmuxattachscript <<- EOF
#!/bin/bash
if [ -z "\$TMUX" ]; then tmux -2 attach -t base || tmux -2 new -s base; fi
EOF
if [[ "$(uname)" == Darwin* ]]; then
    # get brew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew doctor
    # for compiling YCM
    brew install cmake
    # for better git
    brew install git
    # node
    brew install node
    # htop > top
    brew install htop-osx
    # for YCM python
    brew install python
    # brew link --overwrite python # don't link or YCM compile wont work
    brew install python3
    brew link --overwrite python3
    # for j
    brew install autojump
    # for mosh
    brew install mobile-shell
    # for tmux
    brew install tmux
    # for tmux-yank and other fancy fancies
    brew install reattach-to-user-namespace
    # for battery in tmux statusline
    brew tap Goles/battery
    brew install battery
    # for glorious debugging, except gdb on mac sucks
    brew install cgdb
    # nvim has THREADS welcome to 2004
    brew tap neovim/neovim
    brew install --HEAD neovim

    # make keys repeat properly
    defaults write -g ApplePressAndHoldEnabled -bool false
    # just kidding, i'll set the minimum allowed because 10/1 is way too fast
    defaults write -g InitialKeyRepeat -int 15 # normal minimum is 15 (225 ms)
    defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)
else
    echo "$reattachscript" > ~/bin/reattach-to-user-namespace
    chmod +x ~/bin/reattach-to-user-namespace
fi
echo "$tmuxattachscript" > ~/bin/leek
chmod +x ~/bin/leek


# echo post-install stuff
echo "************** INSTALL COMPLETE **************"
echo "you're also going to want:"
echo "Alfred"
echo "MacVim / alias mvim"
echo "Seil / capslock remap"
echo "iTerm2 / zsh"
echo "ShiftIt (beta)"
echo "Dropbox"
echo "Sublime 3"
echo "Spotify / Chrome / Vox"
echo "compile YCM"
echo "sign your gdb for cgdb"
echo "NOTE: FOR KEYBOARD CHANGES TO WORK CORRECTLY, LOG OUT AND BACK IN"
