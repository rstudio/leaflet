# Check files that should be cleaned (ignoring directories)
needs_cleaned <- system("git clean -xf --dry-run")

if (length(needs_cleaned)) {
  stop(
    "There are untracked files in the repo. Please run",
    "`git clean -xf --dry-run` to see what will be removed. ",
    "Add --force to force removal of untracked files."
  )
}
