## ----setup, include = FALSE---------------------------------------------------
library(mutator)

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----example-package----------------------------------------------------------
pkg <- file.path(tempdir(), "tinyclamp")
unlink(pkg, recursive = TRUE)

dir.create(file.path(pkg, "R"), recursive = TRUE)
dir.create(file.path(pkg, "tests", "testthat"), recursive = TRUE)

writeLines(c(
  "Package: tinyclamp",
  "Title: A Tiny Example Package",
  "Version: 0.0.1",
  "Authors@R: person('A', 'User', email = 'a@example.org', role = c('aut', 'cre'))",
  "Description: A small package created to demonstrate mutation testing.",
  "License: MIT",
  "Encoding: UTF-8",
  "Suggests: testthat",
  "Config/testthat/edition: 3"
), file.path(pkg, "DESCRIPTION"))

writeLines("export(clamp)", file.path(pkg, "NAMESPACE"))

writeLines(c(
  "clamp <- function(x, lower = 0, upper = 10) {",
  "  if (x < lower) return(lower)",
  "  if (x > upper) return(upper)",
  "  x",
  "}"
), file.path(pkg, "R", "clamp.R"))

writeLines(c(
  "library(testthat)",
  "library(tinyclamp)",
  "test_check('tinyclamp')"
), file.path(pkg, "tests", "testthat.R"))

writeLines(c(
  "test_that('clamp handles values inside and below the interval', {",
  "  expect_equal(clamp(5), 5)",
  "  expect_equal(clamp(-2), 0)",
  "})"
), file.path(pkg, "tests", "testthat", "test-clamp.R"))

## ----baseline-tests-----------------------------------------------------------
testthat::test_local(pkg, reporter = "summary")

## ----run-mutator--------------------------------------------------------------
set.seed(4)
result <- mutate_package(
  pkg,
  cores = 1,
  max_mutants = 2,
  timeout_seconds = 10,
  coverage_guided = FALSE
)

## ----inspect-results----------------------------------------------------------
data.frame(
  mutation = vapply(
    result$package_mutants,
    function(x) x$mutation_loc$details,
    character(1)
  ),
  status = unname(unlist(result$test_results)),
  row.names = NULL
)

result$summary[c("generated", "tested", "killed", "survived", "mutation_score")]

## ----improve-tests------------------------------------------------------------
writeLines(c(
  "test_that('clamp handles all parts of the interval', {",
  "  expect_equal(clamp(5), 5)",
  "  expect_equal(clamp(-2), 0)",
  "  expect_equal(clamp(12), 10)",
  "})"
), file.path(pkg, "tests", "testthat", "test-clamp.R"))

set.seed(4)
improved_result <- mutate_package(
  pkg,
  cores = 1,
  max_mutants = 2,
  timeout_seconds = 10,
  coverage_guided = FALSE
)

unname(unlist(improved_result$test_results))
improved_result$summary[c("killed", "survived", "mutation_score")]

## ----cleanup, include = FALSE-------------------------------------------------
unlink(pkg, recursive = TRUE)

