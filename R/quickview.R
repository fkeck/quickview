
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

  if(getOption("quickview.print", default = "default") == "default") {
    msg <- strsplit(block, split = "\n")[[1]]
    if(length(msg) > 12) {
      msg <- paste(msg[1:12], collapse = "\n")
      msg <- paste(msg, " ...")
    } else {
      msg <- paste(msg, collapse = "\n")
    }
    msg <- paste0("\033[90m", msg, "\033[39m")
    msg_header <- paste0("\033[40m\033[37m\033[1m",
                         "            QuickView            ",
                         "\033[22m\033[39m\033[49m")
    msg <- paste("\n", msg_header, "\n\n", msg, "\n\n")
  }
  cat(msg)

  comm <- paste0('View(', block, ')')
  eval(parse(text = comm))

}


# Find blocks of code in a character vector returned by
# rstudioapi::getActiveDocumentContext()$content
detect_com <- function(x){

  regex_op <- "(\\+|-|\\*|/|\\^|%|:|\\$|@|%|<|>|=|!|&|\\||~|,) *$"
  debt_par <- cumsum(sapply(x, stringr::str_count, pattern = "\\(") - sapply(x, stringr::str_count, pattern = "\\)"))
  debt_sqb <- cumsum(sapply(x, stringr::str_count, pattern = "\\[") - sapply(x, stringr::str_count, pattern = "\\]"))

  blocks <- vector("integer", length(x))
  k <- 1L
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


