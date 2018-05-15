devtools::install()
cat("\n")

message("Removing ./docs/libs folder")
unlink("docs/libs", recursive = TRUE)
cat("\n")

system("cd docs; make clean; make;")
