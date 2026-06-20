# Hướng dẫn đẩy project lên GitHub

## 1. Đổi tên thư mục cục bộ

**Cách 1: Dùng File Explorer**

1. Mở `C:\Users\ADMIN\Downloads`
2. Right-click trên folder `test_Project` → **Rename**
3. Đổi thành `BookStoreApp`
4. Nhấn Enter

**Cách 2: Dùng Terminal (đóng VS Code trước)**

```bash
# CMD (Windows Command Prompt)
cd C:\Users\ADMIN\Downloads
ren test_Project BookStoreApp

# Hoặc dùng PowerShell
Rename-Item 'test_Project' 'BookStoreApp'
```

## 2. Tạo repository trên GitHub

1. Đăng nhập vào [GitHub.com](https://github.com)
2. Click **+ New** (góc trên cùng)
3. Điền thông tin:
   - **Repository name**: `BookStoreApp`
   - **Description**: FPT Book Store eCommerce Platform built with Jakarta EE and SQL Server
   - **Visibility**: Public (để CV dễ nhìn)
   - **README**: Không chọn (đã có sẵn)
   - **License**: MIT
4. Click **Create Repository**

## 3. Khởi tạo Git cục bộ

Mở Terminal trong VS Code hoặc Command Prompt:

```bash
# Di chuyển vào folder project
cd C:\Users\ADMIN\Downloads\BookStoreApp

# Khởi tạo git repository
git init

# Thêm remote repository
git remote add origin https://github.com/YOUR_USERNAME/BookStoreApp.git

# Xem branch mặc định (nên là main)
git branch -M main

# Thêm tất cả file
git add .

# Commit lần đầu
git commit -m "Initial commit: BookStoreApp - FPT Book Store eCommerce Platform"

# Push lên GitHub (lần đầu)
git push -u origin main
```

## 4. Xác thực GitHub (lần đầu)

Lần đầu push, GitHub sẽ yêu cầu xác thực. Có 2 cách:

### **Cách A: Personal Access Token (Khuyến Nghị)**

1. Đăng nhập GitHub → Settings → Developer settings → Personal access tokens
2. Click **Generate new token**
3. Điền:
   - **Note**: "Git command line"
   - **Expiration**: 90 days hoặc tùy chọn
   - **Scopes**: Chọn `repo`
4. Click **Generate token** → Copy token
5. Khi Git yêu cầu password, dán token này

### **Cách B: GitHub CLI**

```bash
# Cài GitHub CLI (nếu chưa có)
# Từ: https://cli.github.com

# Xác thực
gh auth login
# Chọn: HTTPS, Authenticate with token, dán token của bạn

# Push
git push -u origin main
```

### **Cách C: SSH Key**

```bash
# Tạo SSH key (nếu chưa có)
ssh-keygen -t ed25519 -C "email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Thêm vào GitHub: Settings → SSH and GPG keys → New SSH key
# Paste key, click Add

# Test connection
ssh -T git@github.com

# Push với SSH
git push -u origin main
```

## 5. Cập nhật README.md

Chỉnh sửa phần author:

```markdown
## 👤 Author

**Your Name**

- 🔗 GitHub: [@yourusername](https://github.com/yourusername)
- 💼 LinkedIn: [Your LinkedIn Profile](https://linkedin.com/in/yourprofile)
- 📧 Email: your.email@example.com
```

## 6. Commit thêm (nếu có thay đổi)

```bash
# Xem trạng thái
git status

# Thêm file cụ thể
git add src/java/model/Book.java

# Hoặc thêm tất cả
git add .

# Commit
git commit -m "Update Book model with author and edition fields"

# Push lên GitHub
git push
```

## 7. Cấu trúc commit (Conventional Commits)

Các prefix phổ biến:

```
feat:   Add new feature
fix:    Fix bug
docs:   Update documentation
style:  Code style (formatting, semicolons, etc)
refactor: Refactor code without changing functionality
test:   Add or update tests
chore:  Update dependencies, build scripts, etc
```

**Ví dụ:**

```bash
git commit -m "feat: Add book search with category filter"
git commit -m "fix: Handle null author gracefully in detail page"
git commit -m "docs: Add installation guide to README"
git commit -m "refactor: Extract BookDAO method for better maintainability"
```

## 8. Tạo .gitignore đúng cách

✅ File `.gitignore` đã được tạo sẵn

Nó sẽ loại bỏ:

- Build artifacts (`build/`, `dist/`)
- IDE files (`.vscode/`, `.idea/`)
- Credentials (`.env`)
- Local config files

**Cẩn thận:** Đừng commit file lớn hoặc sensitive:

- Passwords, API keys
- Build output (>100MB)
- Node_modules, .gradle, etc

## 9. Kiểm tra trước khi push

```bash
# Xem log commit
git log --oneline

# Xem diff (thay đổi chưa commit)
git diff

# Xem status
git status

# Xem branch
git branch -a
```

## 10. Thiết lập GitHub Pages (tuỳ chọn)

Để tạo landing page cho project:

1. Settings → Pages
2. Source: Deploy from a branch
3. Branch: main, folder: / (root)
4. Save

Sau vài phút, project sẽ có trang web tại:

```
https://yourusername.github.io/BookStoreApp
```

## 📊 File/Folder Nên Đẩy

✅ **Đẩy lên:**

- `src/` - Source code
- `web/` - JSP views
- `nbproject/` - Project config
- `build.xml`, `pom.xml` - Build scripts
- `README.md`, `LICENSE` - Documentation
- `.gitignore` - Git config

❌ **Không nên đẩy:**

- `build/` - Compiled files
- `dist/` - Distribution files
- `.vscode/private/` - Personal settings
- `*.class`, `*.jar` - Binary files (lớn)
- `.env` - Sensitive data

## 🎯 GitHub CV Checklist

- ✅ Project name: `BookStoreApp` (chuyên nghiệp)
- ✅ README.md: Chi tiết, hình ảnh minh họa (suggested)
- ✅ LICENSE: MIT hoặc Apache 2.0
- ✅ .gitignore: Loại bỏ file không cần
- ✅ Commit messages: Rõ ràng, có ý nghĩa
- ✅ Code quality: Comments, SOLID principles
- ✅ Documentation: Cài đặt, sử dụng, contribute
- ✅ Git history: Multiple commits, không all-in-one

## 🚀 Ví Dụ Full Flow

```bash
# 1. Di chuyển vào folder
cd C:\Users\ADMIN\Downloads\BookStoreApp

# 2. Khởi tạo Git
git init
git remote add origin https://github.com/yourname/BookStoreApp.git
git branch -M main

# 3. Thêm tất cả
git add .

# 4. Commit lần đầu
git commit -m "Initial commit: BookStoreApp eCommerce platform"

# 5. Push lên GitHub
git push -u origin main

# Xong! Repository của bạn giờ đã sẵn sàng
```

## 📞 Troubleshooting

### "fatal: remote origin already exists"

```bash
git remote remove origin
git remote add origin https://github.com/yourname/BookStoreApp.git
```

### "Permission denied (publickey)"

Kiểm tra SSH keys:

```bash
ssh -T git@github.com
```

### "Updates were rejected because the tip of your current branch is behind"

```bash
git pull origin main
git push origin main
```

### File quá lớn (>100MB)

- Xóa file khỏi git history: `git rm --cached filename`
- Thêm vào `.gitignore`
- Commit: `git commit -m "Remove large files"`

---

✨ **Lưu ý Cuối**: GitHub sẽ là phần quan trọng của CV của bạn cho lập trình viên. Hãy chắc chắn:

1. Code sạch, có comment
2. README chi tiết
3. Commit history có ý nghĩa
4. Không có sensitive data

Chúc bạn thành công!
