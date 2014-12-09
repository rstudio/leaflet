uspop2000 <- read.csv('data-raw/uspop2000.csv', fileEncoding = 'UTF-8',
  stringsAsFactors = FALSE, encoding = "UTF-8")
devtools::use_data(uspop2000, overwrite = TRUE)

# enc <- Encoding(uspop2000$City)
# uspop2000$City[enc == "UTF-8"]
