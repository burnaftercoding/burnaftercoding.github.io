cd _site
git add *
git rm $(git ls-files --deleted) 
git commit -m "update"
git push
Start-Process -Path "http://burnaftercoding.github.io/"