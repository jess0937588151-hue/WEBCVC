# StockFlow Pro 測試版

這是一個可先上傳到 GitHub 的 **多店登入庫存叫貨系統前端測試版**。

## 已完成功能
- 主帳號登入後維護貨物清單
- 設定現有庫存與安全庫存
- 分店帳號登入後依貨物清單填寫需求數量
- 主帳號依公式自動計算建議叫貨量
- 手機版響應式畫面
- PWA 安裝能力（可加到 Android 手機桌面）
- JSON 匯入 / 匯出，方便後續接後端

## 測試帳號
- admin / admin123
- taipei01 / store123
- taichung01 / store123
- kaohsiung01 / store123

## 計算邏輯
建議叫貨量 = max(各店需求總和 + 安全庫存 - 現有庫存, 0)

## 直接使用方式
1. 將整個資料夾上傳到 GitHub Repository
2. 用 GitHub Pages 或任何靜態主機部署
3. 開啟 `index.html` 即可測試

## 建議正式版技術升級
### 路線 A：保留 Web/PWA 架構
- 前端：React / Next.js / Vue
- 後端：Supabase / Firebase / Node.js API
- 權限：JWT + Role-based access control
- 資料庫：PostgreSQL
- 報表：Excel / CSV 匯出

### 路線 B：要同時支援 Web 與 APK
- 前端：Ionic React + Capacitor 或 Flutter
- Web：同一套程式可上線網站
- Android：可輸出 APK / AAB
- GitHub Actions：自動建置測試版

## 建議下一步
1. 先確認流程與欄位設計
2. 確認主帳號與分店的實際資料結構
3. 再升級成正式版雲端資料庫系統
4. 最後接 GitHub Actions 與 APK 打包流程
