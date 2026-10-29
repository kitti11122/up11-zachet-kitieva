from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel, QLineEdit, QPushButton, QMessageBox
from PySide6.QtCore import Qt

class LoginWindow(QWidget):
    def __init__(self, db):
        super().__init__()
        self.db = db
        self.setWindowTitle("Авторизация - Косметик-Про")
        self.resize(300, 280)
        self.setStyleSheet("background-color: #FFFFFF; font-family: Calibri; color: black;")

        layout = QVBoxLayout()
        

        layout.addSpacing(30)


        title = QLabel("Вход в систему Косметик-Про")
        title.setStyleSheet("font-size: 16px; font-weight: bold; color: #70B2AF;")
        title.setAlignment(Qt.AlignCenter)
        layout.addWidget(title)

        layout.addSpacing(20)
        layout.addWidget(QLabel("Логин:"))
        
        self.login_input = QLineEdit()
        self.login_input.setPlaceholderText("Введите логин")
        self.login_input.setStyleSheet("""
            QLineEdit {
                background-color: #FFFFFF; color: black; 
                border: 1px solid #70B2AF; border-radius: 4px; padding: 6px;
            }
        """)
        layout.addWidget(self.login_input)

        layout.addSpacing(10)
        self.login_button = QPushButton("Войти")
        self.login_button.setStyleSheet("""
            QPushButton { background-color: #70B2AF; color: white; font-weight: bold; padding: 8px; border-radius: 4px; }
            QPushButton:hover { background-color: #5a9c99; }
        """)
        self.login_button.clicked.connect(self.check_login)
        layout.addWidget(self.login_button)

        self.guest_button = QPushButton("Войти как гость")
        self.guest_button.setStyleSheet("""
            QPushButton { background-color: #D2F6E7; color: black; font-weight: bold; padding: 8px; border-radius: 4px; border: 1px solid #70B2AF; }
            QPushButton:hover { background-color: #bce8d5; }
        """)
        self.guest_button.clicked.connect(self.login_as_guest)
        layout.addWidget(self.guest_button)

        layout.addStretch() # Прижимает всё вверх
        self.setLayout(layout)

    def check_login(self):
        login = self.login_input.text().strip()
        if not login:
            QMessageBox.warning(self, "Ошибка", "Введите логин")
            return

        conn = self.db.get_connection()
        if conn is None:
            QMessageBox.critical(self, "Ошибка БД", "Нет подключения к БД")
            return

        try:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT u.user_id, u.role_id, u.last_name, u.first_name, u.middle_name, r.name 
                FROM users u
                JOIN roles r ON u.role_id = r.role_id
                WHERE u.login = %s
            """, (login,))
            result = cursor.fetchone()
            cursor.close()
            self.db.release_connection(conn)

            if result is None:
                QMessageBox.warning(self, "Ошибка", "Неверный логин")
            else:
                user_id = result[0]
                role_id = result[1]
                full_name = f"{result[2] or ''} {result[3] or ''} {result[4] or ''}".strip()
                role_name = result[5]

                from main import MainWindow
                self.main_window = MainWindow(self.db, role_id=role_id, full_name=full_name, user_id=user_id, role_name=role_name)
                self.main_window.show()
                self.close()
                
        except Exception as e:
            QMessageBox.critical(self, "Ошибка БД", f"Произошла ошибка: {e}")
            if conn:
                self.db.release_connection(conn)

    def login_as_guest(self):
        from main import MainWindow
        self.main_window = MainWindow(self.db, role_id=None, full_name="Гость", user_id=None, role_name="Гость")
        self.main_window.show()
        self.close()