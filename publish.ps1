cd _site
git add *
git commit -m "update"
git push
Start-Process -Path "http://burnaftercoding.github.io/"