#!/usr/bin/env sh

script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_vimrcpath="${script_dir}"/.vimrc
home_vimrcpath=~/.vimrc
actual_home_vimrcpath=$home_vimrcpath
backup_home_vimrcpath=${home_vimrcpath}.old

which readlink >/dev/null
if [ $? -ne 0 ]; then
  actual_home_vimrcpath=$(readlink "${actual_home_vimrcpath}")
fi

if [ ! "${actual_home_vimrcpath}" -ef "${script_vimrcpath}" ]; then
  source_line="source ${script_vimrcpath}"
  diff -q "${home_vimrcpath}" "${script_vimrcpath}" >/dev/null
  if [ $? -ne 0 ]; then
    grep "${source_line}" "${home_vimrcpath}" >/dev/null
    if [ $? -ne 0 ]; then
      echo 'Backing up .vimrc'
      cp "${home_vimrcpath}" "${backup_home_vimrcpath}"

      if [ ! -e ~/.vim/bundle/Vundle.vim ]; then
        echo 'Installing Vundle - https://github.com/VundleVim/Vundle.vim'
        git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
      fi

      echo 'Installing Vim plugins'
      echo 'set nocompatible              " be iMproved, required
    filetype off                  " required

    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    ' > "${script_dir}"/vimrctemp
      grep "Plugin '" "${backup_home_vimrcpath}" >> "${script_dir}"/vimrctemp
      echo 'call vundle#end()
    ' >> "${script_dir}"/vimrctemp

      vim +PluginInstall +qall -u "${script_dir}"/vimrctemp

      rm "${script_dir}"/vimrctemp

      echo 'Updating .vimrc'
      echo "${source_line}" | cat - "${backup_home_vimrcpath}" > "${actual_home_vimrcpath}"
    else
      echo 'Your .vimrc appears to source the repository .vimrc file already.'
    fi
  else
    echo 'Your .vimrc file is identical to the one in this git repository.'
    echo 'Replacing it with one that sources this git repository.'
    rm "${home_vimrcpath}"
    echo "${source_line}" >"${home_vimrcpath}"
  fi
else
  echo '.vimrc already pointing at this git repository.'
fi

