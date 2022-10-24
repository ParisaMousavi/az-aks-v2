# Push changes in Azure DevOps Repo & GitHub
```
git remote set-url --add --push origin https://p-moosavinezhad@dev.azure.com/p-moosavinezhad/az-iac/_git/az-aks-v2

git remote set-url --add --push origin https://github.com/ParisaMousavi/az-aks-v2.git
```

# Create a new tag
```
git tag -a <year.month.day> -m "description"

git push origin <year.month.day>

```