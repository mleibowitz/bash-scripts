FROM alpine:latest

RUN apk add -U --no-cache \
    # NeoVim for text editing
    neovim \
    # Git for version control
    git \
    # bash, zsh, and tmux for terminal
    # bash is required for tpm to work
    bash \
    zsh \
    tmux \
    # Useful tools
    openssh-client \
    ncurses \
    curl \
    jq \
    less \
    coreutils \
    bind-tools \
    xsel

# Set Timezone
RUN apk add tzdata && \
    cp /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    echo "America/Chicago" > /etc/timezone && \
    apk del tzdata

ENV HOME=/home/me

# Configure text editor - vim!
RUN curl -fLo ${HOME}/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Consult the vimrc file to see what's installed
COPY vimrc ${HOME}/.config/nvim/init.vim
# Clone the git repos of Vim plugins
WORKDIR ${HOME}/.config/nvim/plugged/
RUN git clone --depth=1 https://github.com/ctrlpvim/ctrlp.vim && \
    git clone --depth=1 https://github.com/tpope/vim-fugitive && \
    git clone --depth=1 https://github.com/godlygeek/tabular && \
    git clone --depth=1 https://github.com/plasticboy/vim-markdown && \
    git clone --depth=1 https://github.com/vim-airline/vim-airline && \
    git clone --depth=1 https://github.com/vim-airline/vim-airline-themes && \
    git clone --depth=1 https://github.com/vim-syntastic/syntastic && \
    git clone --depth=1 https://github.com/frazrepo/vim-rainbow && \
    git clone --depth=1 https://github.com/airblade/vim-gitgutter && \
    git clone --depth=1 https://github.com/ekalinin/Dockerfile.vim.git && \
    git clone --depth=1 https://github.com/junegunn/seoul256.vim
# Install the plugins
RUN nvim --headless +PlugInstall +qall

WORKDIR ${HOME}

# Copy git config over
COPY gitconfig ${HOME}/.gitconfig

# Setup my $SHELL
ENV SHELL=/bin/zsh
# Install oh-my-zsh
RUN sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
RUN mkdir -p ${HOME}/.oh-my-zsh/custom/themes && \
    mkdir -p ${HOME}/.oh-my-zsh/custom/plugins
RUN wget https://gist.githubusercontent.com/xfanwu/18fd7c24360c68bab884/raw/f09340ac2b0ca790b6059695de0873da8ca0c5e5/xxf.zsh-theme -O ${HOME}/.oh-my-zsh/custom/themes/xxf.zsh-theme
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.oh-my-zsh/plugins/zsh-autosuggestions
# Copy ZSh config
COPY zshrc ${HOME}/.zshrc

# Install TMUX
COPY tmux.conf ${HOME}/.tmux.conf
RUN git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm && \
    ${HOME}/.tmux/plugins/tpm/bin/install_plugins

# Entrypoint script creates a user called `me` and `chown`s everything
COPY entrypoint.sh /bin/entrypoint.sh

# Set working directory to /project
WORKDIR /project

# Default entrypoint, can be overridden
CMD ["/bin/entrypoint.sh"]