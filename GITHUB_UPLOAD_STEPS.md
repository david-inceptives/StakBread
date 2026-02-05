# GitHub par Stakbread upload karne ke steps

## 1. GitHub par naya repo banao
- https://github.com/new par jao
- Repo name: `Stakbread` (ya jo naam chaho)
- Create repository click karo
- Jo URL mile (e.g. `https://github.com/YOUR_USERNAME/Stakbread.git`) copy karo

## 2. Terminal se ye commands chalao (apne repo URL se replace karo)

```bash
cd /Users/imac/Desktop/Stakbread

# Saari files add karo
git add .

# Pehla commit
git commit -m "Initial commit - StakBread app"

# Remote add karo (YOUR_GITHUB_URL ko apne repo URL se replace karo)
git remote add origin https://github.com/YOUR_USERNAME/Stakbread.git

# Branch name set (agar GitHub par main chahiye)
git branch -M main

# GitHub par push
git push -u origin main
```

## IDE me "Remote" kahan milega
- **Git** menu → **GitHub** sub-menu → wahan "Share project on GitHub" ya "Push" ho sakta hai
- Ya **View → Tool Windows → Git** open karo → left side **Remotes** section
- Pehli baar remote add karne ke liye terminal use karna sabse easy hai
