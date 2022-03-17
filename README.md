
# quickview

<!-- badges: start -->
<!-- badges: end -->

The goal of quickview is to quickly inspect your data in a View tab of RStudio. Unlike the default inspector (F2), quickview shows the result of the current selection or the result of the current line.

Additionally, quickview allows to open your data in your favorite software. Currently dataframes, matrices and vectors with more than one element will be open with your default CSV viewer. Vector of length one will be open directly in your default text editor.

Finally quickview provides a quick command to open your working directory directly with your file manager. This action is available in the RStudio file manager, but cannot be easily called with a keyboard shortcut.

*Features*

 - Run complete active line(s) or current selection
 - Works with pipes

## Installation

You can install quickview from GitHub with remotes:

``` r
remotes::install_github("fkeck/quickview")
```
Restart RStudio. That's it.

Then you will probably want to assign keyboard shortcuts to the quickview commands. In RStudio use Tools > Addins > Browse Addins > Keyboard shortcuts.

### Suggested shortcuts

I use Ctrl + Backspace (for View tab, see example below), F11 (to open the data) and F12 (for the working directory).

![](man/graphics/shortcuts.png)


## Examples

### View data in the RStudio viewtab

This example shows how quickview can be used to view data in the View tab and demonstrate the support for selection and pipes.

![](inst/screencast_qv.gif)


### Open data with an external software

Here are some example of R commands and how you may expect their result to be opened in external software:

``` r
#### DATAFRAMES ####

# A dataframe [a table with row and column names in spreadsheet]
iris

# A tibble [a table with row and column names in spreadsheet]
tibble::as_tibble(iris)

#### VECTORS ####

# A character vector [a 1-column table in spreadsheet]
LETTERS

# A numeric vector [a 1-column table in spreadsheet]
1:30

# A named vector [a 2-columns table in spreadsheet]
setNames(1:10, LETTERS[1:10])

# A logical vector [a 1-column table in spreadsheet]
c(TRUE, FALSE, TRUE)

# A factor [a 1-column table in spreadsheet]
factor(rep(LETTERS[1:5], 2))

# A character vector of length 1 [text editor]
stringi::stri_rand_lipsum(1)

# A numeric vector of length 1 [text editor]
pi

#### MATRICES ####

# A numeric matrix [a table in spreadsheet]
matrix(sample(1:9, 100, replace = TRUE), nrow = 10, ncol = 10)

# A numeric matrix with names [a table with row and column names in spreadsheet]
matrix(sample(1:9, 100, replace = TRUE), nrow = 10, ncol = 10,
       dimnames = list(LETTERS[1:10], letters[1:10]))

#### ARRAYS ####

# A 1D-array [a 1-column table in spreadsheet]
array(1:10, 10)

# A 1D-array with names [a 2-columns table in spreadsheet]
array(1:10, 10, dimnames = list(LETTERS[1:10]))

# An 2D-array [a table in spreadsheet]
array(1:100, c(10, 10))

# A 2D-array with names [a table with row and column names in spreadsheet]
array(1:100, c(10, 10), dimnames = list(LETTERS[1:10], letters[1:10]))

#### OTHERS ####

# A list [a table with row and column names in spreadsheet]
list(c("A", "B"), list(2, 3))

# html coercible to character (and not to dataframe) [Text editor]
xml2::read_html("http://had.co.nz")

# zoo object coercible to dataframe [Spreadsheet]
zoo::as.zoo(ts(rnorm(5), start = 1981, freq = 12))
```
