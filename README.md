# StockFlow Pro Flutter 商用版原始碼

這是一套使用 Flutter 製作的 **多店登入庫存叫貨系統完整版專案檔**，可作為 Web 與 Android 共用的商用級基礎。

## 已完成內容
- 主帳號登入 / 分店帳號登入
- 主帳號新增與管理貨品主檔
- 主帳號新增分店帳號
- 分店依貨品清單填寫需求數量
- 主帳號查看各店回報總覽
- 依安全庫存自動計算建議叫貨量
- 深色商用儀表板版型
- Flutter Web 與 Android 專案結構
- GitHub Actions：Web 部署與 Android APK 建置範本
- 本機持久化儲存（SharedPreferences）
- 內建示範資料（assets/seed/seed_data.json）

## 內建測試帳號
- admin / admin123
- taipei01 / store123
- taichung01 / store123
- kaohsiung01 / store123

## 建議叫貨公式
建議叫貨量 = max(各店需求總和 + 安全庫存 - 現有庫存, 0)

## 本機執行
```bash
flutter pub get
flutter run -d chrome
```

## Android APK
```bash
flutter build apk --release
```

## 若你要重新生成平台資料夾
如果你的 Flutter 版本與專案模板差異較大，可在專案根目錄執行：
```bash
flutter create .
```
這會重新補齊平台相關預設檔，再保留目前 `lib/`、`assets/` 與工作流程設定。

## GitHub Actions
- `.github/workflows/build-android.yml`：建置 APK
- `.github/workflows/deploy-web.yml`：部署 Flutter Web 到 GitHub Pages

## 建議下一步
1. 接入 Firebase / Supabase 做真正雲端同步
2. 加入權限分級與操作紀錄
3. 增加報表匯出、Excel 匯入匯出
4. 加入供應商採購單與審核流程
