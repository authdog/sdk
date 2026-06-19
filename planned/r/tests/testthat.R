# This file is part of the standard setup for testthat.
# It is automatically run when testthat is loaded, unless testthat is already
# running. This makes sure that testing functions (such as expect_equal())
# are available during package development.

if (requireNamespace("testthat", quietly = TRUE)) {
  testthat::test_check("authdog")
} else {
  message("testthat not available")
}
