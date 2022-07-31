.rs.restartR()
rm(list = ls())

# Borrowed from devtools:
# https://github.com/hadley/devtools/blob/ba7a5a4abd8258c52cb156e7b26bb4bf47a79f0b/R/utils.r#L44
is_installed <- function(pkg, version = 0) {
  installed_version <- tryCatch(utils::packageVersion(pkg), error = function(e) NA)
  !is.na(installed_version) && installed_version >= version
}

# Borrowed and adapted from devtools:
# https://github.com/hadley/devtools/blob/ba7a5a4abd8258c52cb156e7b26bb4bf47a79f0b/R/utils.r#L74
ensure_installed <- function(pkg) {
  if (!is_installed(pkg)) {
    msg <- paste0(sQuote(pkg), " must be installed for this functionality.")
    if (interactive()) {
      message(msg, "\nWould you like to install it?")
      if (menu(c("Yes", "No")) == 1) {
        install.packages(pkg)
      } else {
        stop(msg, call. = FALSE)
      }
    } else {
      stop(msg, call. = FALSE)
    }
  }
}

#------------------------------------------------------------------
# INITIAL PROJECT SETUP ---------------------------------------
#------------------------------------------------------------------
# This initial setup will ensure that you have all required
# R packages installed for use with the RanitidineCancerRisk
# package. If you are running this in an environment where
# there is no access to the Internet please see the sections
# below marked "offline setup step".
#------------------------------------------------------------------
#------------------------------------------------------------------
ensure_installed("renv")

projectFolder <- "/Users/cyanover/temp/IbdCharacterization" 
if (!dir.exists(projectFolder)) {
  dir.create(projectFolder)
}
setwd(projectFolder)

# Download the lock file:
if (!file.exists("renv.lock")) {
  download.file("https://raw.githubusercontent.com/ohdsi-studies/IbdCharacterization/master/renv.lock", "renv.lock")
}

#------------------------------------------------------------------
# OPTIONAL: If you want to change where renv stores the
# R packages you can specify the RENV_PATHS_ROOT. Please
# refer to https://rstudio.github.io/renv/articles/renv.html#cache
# for more details
#------------------------------------------------------------------
Sys.setenv("RENV_PATHS_ROOT" = file.path(projectFolder, "/renv"))

#------------------------------------------------------------------
# OFFLINE SETUP STEP: If you want to have the entire contents of
# the renv R packages local to your project so that you may copy
# it to another computer, please uncomment the line below and
# specify the RENV_PATHS_CACHE location which should be your project
# folder.
#------------------------------------------------------------------
Sys.setenv("RENV_PATHS_CACHE"=projectFolder)

# Build the local library:
renv::restore()

# When not in RStudio, you'll need to restart R now
library(IbdCharacterization)

# -------------------------------------------------------------
# END Initial Project Setup
# -------------------------------------------------------------