# My Neovim Config

## Introduction 

This is my Neovim Config based on the [LazyVim Starter template](https://github.com/LazyVim/starter).
This is for my Angular development with maybe few others languages

## Installation

Like the LazyVim Starter template, installation is basic.

### Linux

- Make a backup of your current config
```
```
```
# required
mv ~/.config/nvim{,.bak}

# optional but recommended
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
```


- Clone the repo

```
git clone https://github.com/rotagraziosi/nvim-config.git ~/.config/nvim
```

- (Optional) Remove the `.git` folder if you want to set your own repo

```
rm -rf ~/.config/nvim/.git
```

```
```
```
```

### Windows


- Make a backup of your current config
```
```
```
# required
Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak

# optional but recommended
Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak
```


- Clone the repo

```
git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA\nvim
```

- (Optional) Remove the `.git` folder if you want to set your own repo

```
Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force
```

