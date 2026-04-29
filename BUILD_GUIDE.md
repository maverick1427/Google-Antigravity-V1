# 🚀 Build & Deployment Guide: PAFWA Inventory EXE

This guide will walk you through creating your professional standalone software.

## 1. Prerequisites
You must have **Node.js** installed on your computer. 
- Download it here: [https://nodejs.org/](https://nodejs.org/) (Choose the "LTS" version).

## 2. Installation
Open your terminal (PowerShell or Command Prompt) and navigate to your project folder:
```powershell
# Navigate to the folder (Already there in most cases)
cd "c:\Users\A Khan\OneDrive\Desktop\PAFWA Inventory Software\Google Antigravity V1"

# Install the software engine
npm install
```

## 3. Running for Testing
You can run the software as an app without building it first:
```powershell
npm start
```

## 4. Building the EXE (Standalone Software)
To create a single `.exe` file that you can take anywhere:
```powershell
npm run build
```
- After the command finishes, look for a new folder named `dist`.
- Inside `dist`, you will find **PAFWA Inventory.exe**.
- This file is **portable**—you can put it on a USB and run it on any Windows computer.
- **Data Location**: A folder named `pafwa-data` will be created automatically in the same folder as your EXE. This folder contains your local database and settings. Keep it with your EXE to keep your data.

## 5. Using the Offline-First Feature
- **Work Offline**: You can add items, make sales, and view reports even if the internet is disconnected.
- **Sync**: When you have internet again, click the **🔄 Sync with Cloud** button in the sidebar. This will upload all your offline work to Supabase and download any updates from other devices.

## 6. Supabase Setup
Ensure your Supabase project has the tables defined in `schema.sql`. The software will automatically connect and sync once you enter your URL and Key in the software's Settings.
