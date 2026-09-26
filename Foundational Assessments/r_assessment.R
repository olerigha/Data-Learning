# F1
# generates a Fibonacci sequence

fibseq <- function(n) {

# handle edge cases
  if (n <= 0) return(integer(0))


# needed for when n is sufficently large
  fib <- if (n <= 45) integer(n) else numeric(n)
  
  fib[1] <- 1L
  if (n >= 2) fib[2] <- 1L
  if (n > 2) {
    for (i in 3:n) {
      fib[i] <- fib[i-1] + fib[i-2]
    }
  }
  return(fib)
}

# F2
# 

elcheck <- function(x,y){

    # Null or empty X
    if (is.null(x) || length(x) == 0) return(integer(0))
    
    # Null or empty Y 
    if (is.null(y) || length(y) == 0) return(rep(0L, length(x)))
    
    
    # Initialize
    result <- integer(length(x))


    # Check element by element, for each x if it matches corresponding position in y
    for (i in seq_along(x)) {
        if (i <= length(y)) {
            xi <- x[i]
            yi <- y[i]

            # Comparisons involing NAs
            if (is.na(xi) && is.na(yi)) {
                result[i] <- 1L
            } else if (is.na(xi) || is.na(yi)) {
                result[i] <- 0L
            } else if (is.numeric(xi) && is.numeric(yi)) {
                result[i] <- as.integer(xi == yi)   # as.integer gives integer
            } else {
                result[i] <- as.integer(as.character(xi) == as.character(yi))
            }
        } else {
            result[i] <- 0L
        }
    }
    return(result)
}

# F3

topingredients <- function(file) {
  # Read
  if (grepl("\\.csv$", file, ignore.case = TRUE)) {
    data <- read.csv(file, stringsAsFactors = FALSE)
  } else {
    data <- tryCatch(
      read.csv(file, stringsAsFactors = FALSE),
      error = function(e) {
        read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
      }
    )
  }
  
  names(data) <- tolower(trimws(names(data)))
  
  if (!"ingredients" %in% names(data)) {
    return(data.frame(name = character(0), count = integer(0),
                      stringsAsFactors = FALSE))
  }
  
  ings <- data$ingredients
  ings <- ings[!is.na(ings)]
  if (length(ings) == 0) {
    return(data.frame(name = character(0), count = integer(0),
                      stringsAsFactors = FALSE))
  }
  

  all_ings <- unlist(lapply(ings, function(s) {
    parts <- trimws(tolower(unlist(strsplit(s, ",\\s*"))))
    parts[parts != ""]
  }))
  
  if (length(all_ings) == 0) {
    return(data.frame(name = character(0), count = integer(0),
                      stringsAsFactors = FALSE))
  }
  
  counts <- table(all_ings)
  df <- data.frame(name = names(counts),
                   count = as.integer(counts),
                   stringsAsFactors = FALSE)
  
  df <- df[order(-df$count, df$name), ]
  rownames(df) <- NULL
  df <- df[seq_len(min(3, nrow(df))), , drop = FALSE]
  rownames(df) <- NULL
  
  return(df)
}