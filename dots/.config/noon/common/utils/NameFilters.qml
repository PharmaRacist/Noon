pragma Singleton
import QtQuick

Singleton {
    property list<string> all: ["*"]
    property list<string> audio: ["*.mp3", "*.flac", "*.ogg", "*.wav", "*.m4a", "*.aac", "*.wma", "*.opus"]
    property list<string> picture: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif", "*.bmp", "*.svg"]
    property list<string> video: ["*.mp4", "*.mov", "*.m4v", "*.avi", "*.mkv", "*.webm"]
    property list<string> executable: ["*.exe", "*.sh"]
    property list<string> document: ["*.txt", "*.md", "*.log", "*.json", "*.xml", "*.yaml", "*.yml", "*.ini", "*.conf", "*.cfg", "*.pdf", "*.doc", "*.docx", "*.txt", "*.rtf", "*.odt", "*.xls", "*.xlsx", "*.ppt", "*.pptx", "*.csv"]
    property list<string> archive: ["*.zip", "*.tar", "*.gz", "*.bz2", "*.xz", "*.7z", "*.rar", "*.tar.gz", "*.tar.bz2", "*.tar.xz"]
}
