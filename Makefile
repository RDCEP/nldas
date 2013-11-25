tangle: nldas.org
	emacs --quick --batch \
	  --file=nldas.org -f org-babel-tangle 2>&1 \
	  | grep tangle
	rsync -arq tangle/ scripts 
	chmod ug+x scripts/*.{R,sh}

# TODO check for symlink existence.  This only needs to happen once per clone.

# ln -fs ../../git-hooks/pre-commit .git/hooks/pre-commit
