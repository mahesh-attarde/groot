#! /bin/bash
# git add
gitau(){
    git add -u $@
}
gita(){
    git add $@
}
# Git Restore
gitrst(){
    git restore $@
}

gits(){
    git status $@
}

# Git Difference
gitdif(){
    git diff $@
}
# branch
## Git Checkout new branch
gitckt(){
    git checkout -b $1
}

## Git switch and create new branch
gitswc() {
    git switch -c $1
}

# LOG
gitl(){
  git log --pretty="%C(Yellow)%h  %C(reset)%ad (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s" --date=short  $@
}

# Git Gt exisitng remote branch in local
git_get_remote_branch() {
    $remote_name=$1
    $branch_name=$2
    git fetch $remote_name $branch_name
    git branch $branch_name FETCH_HEAD
    git checkout $branch_name
}

git_push_local_branch_to_remote() {
    $branch_name=$1
    $remote_name=$2
    git push -u $remote_name $branch_name
}

## Saving Work on stash
git_save() {
    git stash save $1
}

git_show_saved() {
    git stash list
}

git_load_saved() {
    git stash apply $1
}

git_bkp_untracked() {
    git ls-files --others --exclude-standard -z | xargs -0 tar rvf  $1.zip
}

## Git Search
git_search_in_branches() {
    git rev-list --all | xargs git grep -F $key
}

## Git search commit for user
# git  log --author="Mahesh Attarde" --since="2018-01-01"  --grep="Supports" --oneline
git_search_grep_user() {
 usermention=$1 # "Co-authored-by: Boe Jlo <boe.jlo@lol.com>"
 git log --grep=$usermention
}

## Git files
git_add_ccpp_files(){
    git diff-index --name-only @ -- \*.cpp | xargs git add
    git diff-index --name-only @ -- \*.c | xargs git add
    git diff-index --name-only @ -- \*.h | xargs git add
}
git_files_in_commit() {
    git show --name-only $1 | grep -v "^$" | grep -v "^commit" | grep -v "^Author:" | grep -v "^Date:"
}
git_test_files() {
    git show --name-only $1  | grep "/test/"
}