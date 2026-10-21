## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
ops <- mutator::mutation_operators()
head(ops[, c("id", "family", "default", "example")])

