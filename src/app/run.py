import sys
import os
from PySide6.QtWidgets import QApplication


os.chdir(os.path.join(os.path.dirname(__file__), '..', '..'))


from database import Database
from login_window import LoginWindow

if __name__ == "__main__":
    app = QApplication(sys.argv)
    

    db = Database()
    

    window = LoginWindow(db)
    window.show()
    
    sys.exit(app.exec())