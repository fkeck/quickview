
#' Open datasets in a View tab
#'
#' @keywords internal
#' @importFrom rstudioapi getActiveDocumentContext
#' @importFrom stringr str_count
#'
#' @name quickview
"_PACKAGE"


#' Open datasets in a View tab
#'
#' @export
#'
quickview <- function() {
  context <- rstudioapi::getActiveDocumentContext()

  if (identical(context$selection[[1]]$range$start,
                context$selection[[1]]$range$end)) {

    active_row <- context$selection[[1]]$range$start["row"]

    if(grepl("^ *$", context$contents[active_row])){
      return(invisible(0L))
    }

    context_com <- detect_com(context$contents)
    block_id <- context_com[active_row]
    block <- context$contents[context_com == block_id]
    block <- paste(block, collapse = "\n")

  } else {
    block <- context$selection[[1]]$text
  }

  comm <- paste0('View(', block, ')')
  cat("\n", block, "\n")
  eval(parse(text = comm))

}



# Find blocks of code in a character vector returned by rstudioapi::getActiveDocumentContext()$content
detect_com <- function(x){
  regex_op <- "(\\+|-|\\*|/|\\^|%|:|\\$|@|%|<|>|=|!|&|\\||~|,) *$"
  debt_par <- cumsum(sapply(x, stringr::str_count, pattern = "\\(") - sapply(x, stringr::str_count, pattern = "\\)"))
  debt_sqb <- cumsum(sapply(x, stringr::str_count, pattern = "\\[") - sapply(x, stringr::str_count, pattern = "\\]"))

  blocks <- vector("integer", length(x))
  k <- 1
  for(i in seq_along(blocks)){
    if(debt_par[i] != 0 || debt_sqb[i] != 0 || grepl(regex_op, x[i]) || grepl("^ *$", x[i]) ) {
      blocks[i] <- k
    } else {
      blocks[i] <- k
      k <- k + 1L
    }
  }
  return(blocks)
}


