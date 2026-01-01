# Install dependencies

## HomeBrew

```
brew install dotnet
brew install ollama
brew install pkl-lsp
brew install prettier
brew install prettierd
brew install --cask claude-code
```

### Environment variables (.zshrc)

```
export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
```

## NeoVim

```
:MasonInstall angular-language-server
:MasonInstall typescript-language-server
:MasonInstall llm-ls
:DapInstall js
```

## netcoredbg (compilation for arm-based Mac)

```
brew install make cmake
cd ~/git
git clone https://github.com/Samsung/netcoredbg.git
cd netcoredb
rm -rf build src/debug/netcoredbg/bin bin
mkdir build
cd build
CC=clang CXX=clang++ cmake ..
make
make install
```
