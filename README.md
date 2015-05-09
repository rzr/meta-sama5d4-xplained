Subject: meta-sama5d4-xplained
URL: https://github.com/rzr/meta-sama5d4-xplained
Contact: https://dockr.eurogiciel.fr/blogs/embedded/qtwayland-sama5d4-xplained/

## USAGE ##

  url="https://github.com/rzr/meta-sama5d4-xplained"
  branch="dizzy"
  basename=$(basename -- "$url")
  git clone "$url" -b "$branch" && make demo V=1 -C "${basename}"

