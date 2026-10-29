import os
import sys
from PySide6.QtWidgets import (QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, 
                               QLabel, QPushButton, QComboBox, QLineEdit, QScrollArea, 
                               QMessageBox, QDialog, QTableWidget, QTableWidgetItem, QListWidget, QInputDialog)
from PySide6.QtGui import QPixmap, QIcon
from PySide6.QtCore import Qt
from datetime import date

def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

def calculate_discount(old_price, new_price):
    if old_price == 0: return 0
    return (old_price - new_price) / old_price * 100

def calculate_price_with_discount(product_id, base_price, cursor):
    cursor.execute("""
        SELECT COUNT(*) FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        WHERE oi.stock_item_id IN (SELECT stock_item_id FROM stock_items WHERE product_id = %s)
        AND o.order_date >= CURRENT_DATE - INTERVAL '1 month'
    """, (product_id,))
    orders_count = cursor.fetchone()[0]
    return float(base_price) * 0.75 if orders_count == 0 else float(base_price)


class ProductDetailDialog(QDialog):
    def __init__(self, product_data, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Карточка товара")
        self.resize(600, 500)
        self.setStyleSheet("background-color: #FFFFFF; color: black; font-family: Calibri;")
        
        prod_id, name, category, manufacturer, composition, description, base_price, new_price, image_path, total_qty = product_data
        
        layout = QVBoxLayout()
        img_label = QLabel()
        img_label.setFixedSize(200, 200)
        img_label.setStyleSheet("border: none; background-color: #f0f0f0;")
        img_path = resource_path(f"resources/{image_path}") if image_path else resource_path("resources/picture.png")
        if not os.path.exists(img_path): img_path = resource_path("resources/picture.png")
        pixmap = QPixmap(img_path)
        if not pixmap.isNull(): 
            img_label.setPixmap(pixmap.scaled(200, 200, Qt.KeepAspectRatio, Qt.SmoothTransformation))
        
        top_layout = QHBoxLayout()
        top_layout.addWidget(img_label)
        
        info_layout = QVBoxLayout()
        title = QLabel(f"<b>{manufacturer} | {name}</b>")
        title.setStyleSheet("font-size: 18px; color: black;")
        info_layout.addWidget(title)
        info_layout.addWidget(QLabel(f"<b>Категория:</b> {category}"))
        info_layout.addWidget(QLabel(f"<b>В наличии:</b> {total_qty} шт."))
        info_layout.addWidget(QLabel(f"<b>Цена:</b> {new_price:.2f} ₽"))
        if base_price != new_price:
            info_layout.addWidget(QLabel(f"<s>Старая цена: {base_price} ₽</s>"))
        info_layout.addStretch()
        top_layout.addLayout(info_layout)
        layout.addLayout(top_layout)
        
        layout.addWidget(QLabel("<b>Описание:</b>"))
        layout.addWidget(QLabel(description))
        layout.addWidget(QLabel("<b>Состав:</b>"))
        layout.addWidget(QLabel(composition))
        
        close_btn = QPushButton("Закрыть")
        close_btn.setStyleSheet("background-color: #70B2AF; color: white; padding: 5px;")
        close_btn.clicked.connect(self.close)
        layout.addWidget(close_btn)
        self.setLayout(layout)


class CartDialog(QDialog):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.setWindowTitle("Корзина")
        self.resize(600, 500)
        self.setStyleSheet("background-color: #FFFFFF; color: black;")

        layout = QVBoxLayout()
        self.list_widget = QListWidget()
        layout.addWidget(self.list_widget)
        
        self.total_label = QLabel("Итого: 0 ₽")
        self.total_label.setStyleSheet("font-weight: bold; font-size: 16px; color: black;")
        layout.addWidget(self.total_label)

        btn_layout = QHBoxLayout()
        self.remove_btn = QPushButton("Удалить выбранный товар")
        self.remove_btn.setStyleSheet("background-color: #ff8080; color: black; padding: 5px;")
        self.remove_btn.clicked.connect(self.remove_item)
        btn_layout.addWidget(self.remove_btn)

        self.checkout_btn = QPushButton("Оформить заказ")
        self.checkout_btn.setStyleSheet("background-color: #70B2AF; color: white; padding: 5px;")
        self.checkout_btn.clicked.connect(self.checkout)
        btn_layout.addWidget(self.checkout_btn)
        
        cancel_btn = QPushButton("Отмена")
        cancel_btn.setStyleSheet("background-color: #ccc; color: black; padding: 5px;")
        cancel_btn.clicked.connect(self.close)
        btn_layout.addWidget(cancel_btn)
        
        layout.addLayout(btn_layout)
        self.setLayout(layout)
        self.update_cart_view()

    def update_cart_view(self):
        self.list_widget.clear()
        total = 0
        for i, item in enumerate(self.parent.cart):
            self.list_widget.addItem(f"[{i+1}] {item['name']} - {item['price']:.2f} ₽")
            total += item['price']
        self.total_label.setText(f"Итого: {total:.2f} ₽")

    def remove_item(self):
        selected_row = self.list_widget.currentRow()
        if selected_row == -1:
            QMessageBox.warning(self, "Ошибка", "Выберите товар для удаления.")
            return
        del self.parent.cart[selected_row]
        self.update_cart_view()
        self.parent.update_cart_btn()

    def checkout(self):
        if not self.parent.cart:
            QMessageBox.warning(self, "Ошибка", "Корзина пуста!")
            return
            
        conn = self.parent.db.get_connection()
        cursor = conn.cursor()
        try:
            for item in self.parent.cart:
                cursor.execute("SELECT quantity FROM stock_items WHERE stock_item_id = %s", (item['stock_item_id'],))
                if cursor.fetchone()[0] < 1:
                    QMessageBox.warning(self, "Ошибка", f"Товара '{item['name']}' не хватает на складе.")
                    return

            cursor.execute("INSERT INTO orders (order_date, user_id) VALUES (%s, %s) RETURNING order_id", (date.today(), self.parent.user_id))
            order_id = cursor.fetchone()[0]

            for item in self.parent.cart:
                cursor.execute("""
                    INSERT INTO order_items (order_id, stock_item_id, quantity, unit_price) 
                    VALUES (%s, %s, %s, %s)
                """, (order_id, item['stock_item_id'], 1, item['price']))
                cursor.execute("UPDATE stock_items SET quantity = quantity - 1 WHERE stock_item_id = %s", (item['stock_item_id'],))

            conn.commit()
            QMessageBox.information(self, "Успех", "Заказ оформлен!")
            self.parent.cart.clear()
            self.parent.update_cart_btn()
            self.parent.load_products()
            self.close()
        except Exception as e:
            conn.rollback()
            QMessageBox.critical(self, "Ошибка", f"Не удалось оформить заказ: {e}")
        finally:
            cursor.close()
            self.parent.db.release_connection(conn)


class OrderDetailDialog(QDialog):
    def __init__(self, db, order_id, parent=None):
        super().__init__(parent)
        self.db = db
        self.order_id = order_id
        self.setWindowTitle(f"Состав заказа №{order_id}")
        self.resize(700, 400)
        self.setStyleSheet("background-color: #FFFFFF; color: black;")

        layout = QVBoxLayout()
        self.table = QTableWidget()
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels(["Товар", "Производитель", "Кол-во", "Цена за ед.", "Сумма"])
        layout.addWidget(self.table)
        
        self.total_label = QLabel("Итого: 0 ₽")
        self.total_label.setStyleSheet("font-weight: bold; font-size: 16px; color: black;")
        layout.addWidget(self.total_label)
        
        close_btn = QPushButton("Закрыть")
        close_btn.setStyleSheet("background-color: #70B2AF; color: white; padding: 5px;")
        close_btn.clicked.connect(self.close)
        layout.addWidget(close_btn)
        
        self.setLayout(layout)
        self.load_details()

    def load_details(self):
        conn = self.db.get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute("""
                SELECT p.name, p.manufacturer, oi.quantity, oi.unit_price, (oi.quantity * oi.unit_price) as total
                FROM order_items oi
                JOIN stock_items si ON oi.stock_item_id = si.stock_item_id
                JOIN products p ON si.product_id = p.product_id
                WHERE oi.order_id = %s
            """, (self.order_id,))
            items = cursor.fetchall()
            
            self.table.setRowCount(len(items))
            grand_total = 0
            for row, item in enumerate(items):
                self.table.setItem(row, 0, QTableWidgetItem(str(item[0])))
                self.table.setItem(row, 1, QTableWidgetItem(str(item[1])))
                self.table.setItem(row, 2, QTableWidgetItem(str(item[2])))
                self.table.setItem(row, 3, QTableWidgetItem(f"{item[3]} ₽"))
                self.table.setItem(row, 4, QTableWidgetItem(f"{item[4]} ₽"))
                grand_total += item[4]
            
            self.total_label.setText(f"Итого: {grand_total:.2f} ₽")
        except Exception as e:
            QMessageBox.critical(self, "Ошибка", f"Не удалось загрузить состав: {e}")
        finally:
            cursor.close()
            self.db.release_connection(conn)


class OrdersDialog(QDialog):
    def __init__(self, db, parent=None):
        super().__init__(parent)
        self.db = db
        self.parent = parent
        self.setWindowTitle("Список заказов")
        self.resize(850, 500)
        self.setStyleSheet("background-color: #FFFFFF; color: black;")
        layout = QVBoxLayout()
        
        self.table = QTableWidget()
        self.table.setColumnCount(4)
        self.table.setHorizontalHeaderLabels(["ID Заказа", "Дата", "Клиент", "Сумма"])
        layout.addWidget(self.table)
        
        btn_layout = QHBoxLayout()
        

        self.view_btn = QPushButton("Посмотреть состав")
        self.view_btn.setStyleSheet("background-color: #70B2AF; color: white; padding: 5px; font-weight: bold;")
        self.view_btn.clicked.connect(self.view_order)
        btn_layout.addWidget(self.view_btn)


        if self.parent.role_id in [1, 2]:
            self.edit_date_btn = QPushButton("Редактировать дату")
            self.edit_date_btn.setStyleSheet("background-color: #f0ad4e; color: black; padding: 5px; font-weight: bold;")
            self.edit_date_btn.clicked.connect(self.edit_date)
            btn_layout.addWidget(self.edit_date_btn)

        self.delete_btn = QPushButton("Удалить выбранный заказ")
        self.delete_btn.setStyleSheet("background-color: #ff8080; color: black; padding: 5px; font-weight: bold;")
        self.delete_btn.clicked.connect(self.delete_order)
        btn_layout.addWidget(self.delete_btn)
        
        layout.addLayout(btn_layout)
        self.setLayout(layout)
        self.load_orders()

    def load_orders(self):
        conn = self.db.get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute("""
                SELECT o.order_id, o.order_date, u.last_name || ' ' || u.first_name as client_name, SUM(oi.quantity * oi.unit_price) as total
                FROM orders o JOIN users u ON o.user_id = u.user_id JOIN order_items oi ON o.order_id = oi.order_id
                GROUP BY o.order_id, o.order_date, u.last_name, u.first_name ORDER BY o.order_date DESC
            """)
            orders = cursor.fetchall()
            self.table.setRowCount(len(orders))
            for row, order in enumerate(orders):
                self.table.setItem(row, 0, QTableWidgetItem(str(order[0])))
                self.table.setItem(row, 1, QTableWidgetItem(str(order[1])))
                self.table.setItem(row, 2, QTableWidgetItem(str(order[2])))
                self.table.setItem(row, 3, QTableWidgetItem(f"{order[3]} ₽"))
        except Exception as e:
            QMessageBox.critical(self, "Ошибка", f"Не удалось загрузить заказы: {e}")
        finally:
            cursor.close()
            self.db.release_connection(conn)

    def view_order(self):
        selected_row = self.table.currentRow()
        if selected_row == -1:
            QMessageBox.warning(self, "Ошибка", "Выберите заказ для просмотра.")
            return
        order_id = self.table.item(selected_row, 0).text()
        dialog = OrderDetailDialog(self.db, order_id, self)
        dialog.exec()

    def edit_date(self):
        selected_row = self.table.currentRow()
        if selected_row == -1:
            QMessageBox.warning(self, "Ошибка", "Выберите заказ для редактирования.")
            return

        order_id = self.table.item(selected_row, 0).text()
        current_date = self.table.item(selected_row, 1).text()

        new_date, ok = QInputDialog.getText(self, "Редактирование даты", 
                                            f"Введите новую дату для заказа №{order_id} (ГГГГ-ММ-ДД):", 
                                            text=current_date)
        
        if ok and new_date:
            conn = self.db.get_connection()
            cursor = conn.cursor()
            try:
                cursor.execute("UPDATE orders SET order_date = %s WHERE order_id = %s", (new_date, order_id))
                conn.commit()
                QMessageBox.information(self, "Успех", "Дата заказа изменена!")
                self.load_orders()
            except Exception as e:
                conn.rollback()
                QMessageBox.critical(self, "Ошибка", f"Не удалось изменить дату: {e}")
            finally:
                cursor.close()
                self.db.release_connection(conn)

    def delete_order(self):
        selected_row = self.table.currentRow()
        if selected_row == -1:
            QMessageBox.warning(self, "Ошибка", "Выберите заказ для удаления.")
            return

        order_id = self.table.item(selected_row, 0).text()
        reply = QMessageBox.question(self, "Подтверждение", f"Вы уверены, что хотите удалить заказ №{order_id}?", QMessageBox.Yes | QMessageBox.No)
        if reply == QMessageBox.Yes:
            conn = self.db.get_connection()
            cursor = conn.cursor()
            try:
                cursor.execute("DELETE FROM orders WHERE order_id = %s", (order_id,))
                conn.commit()
                QMessageBox.information(self, "Успех", "Заказ удален!")
                self.load_orders()
            except Exception as e:
                conn.rollback()
                QMessageBox.critical(self, "Ошибка", f"Не удалось удалить: {e}")
            finally:
                cursor.close()
                self.db.release_connection(conn)

class MainWindow(QMainWindow):
    def __init__(self, db, role_id=None, full_name="", user_id=None, role_name=""):
        super().__init__()
        self.db = db
        self.role_id = role_id
        self.full_name = full_name
        self.user_id = user_id 
        self.role_name = role_name
        self.cart = [] 
        
        self.setWindowTitle("Косметик-Про - Каталог")
        self.resize(1100, 800)
        
        if os.path.exists(resource_path("resources/icon.ico")):
            self.setWindowIcon(QIcon(resource_path("resources/icon.ico")))
            
        self.setup_ui()
        self.load_categories()
        self.load_products()

    def setup_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        central_widget.setStyleSheet("background-color: #FFFFFF; color: black;")
        main_layout = QVBoxLayout(central_widget)
        
        self.setStyleSheet("""
            QMainWindow { background-color: #FFFFFF; font-family: Calibri; }
            QPushButton { background-color: #70B2AF; color: white; border-radius: 4px; padding: 6px; font-weight: bold; }
            QComboBox, QLineEdit { padding: 4px; border: 1px solid #ccc; color: black; background-color: white; }
            QLabel { color: black; } 
        """)

        header_layout = QHBoxLayout()
        logo_label = QLabel()
        logo_path = resource_path("resources/logo.png")
        if os.path.exists(logo_path):
            logo_label.setPixmap(QPixmap(logo_path).scaled(150, 50, Qt.KeepAspectRatio))
        header_layout.addWidget(logo_label)
        header_layout.addStretch()
        
        if self.role_id in [1, 2]:
            self.orders_button = QPushButton("Заказы")
            self.orders_button.clicked.connect(self.open_orders)
            header_layout.addWidget(self.orders_button)

        if self.role_id in [1, 2, 3]:
            self.cart_button = QPushButton("Корзина (0)")
            self.cart_button.clicked.connect(self.open_cart)
            header_layout.addWidget(self.cart_button)

        display_name = f"ФИО: {self.full_name} ({self.role_name})"
        name_label = QLabel(display_name)
        name_label.setStyleSheet("font-weight: bold; font-size: 14px; color: black;")
        header_layout.addWidget(name_label)

        self.logout_button = QPushButton("Выход")
        self.logout_button.clicked.connect(self.logout)
        header_layout.addWidget(self.logout_button)

        header_widget = QWidget()
        header_widget.setLayout(header_layout)
        header_widget.setStyleSheet("background-color: #D2F6E7;")
        main_layout.addWidget(header_widget)

        self.filter_layout = QHBoxLayout()
        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Поиск по названию...")
        self.search_input.textChanged.connect(self.load_products)
        self.filter_layout.addWidget(self.search_input)

        self.filter_combo = QComboBox()
        self.filter_combo.addItem("Все категории")
        self.filter_combo.currentIndexChanged.connect(self.load_products)
        self.filter_layout.addWidget(self.filter_combo)

        self.sort_combo = QComboBox()
        self.sort_combo.addItems(["По возрастанию", "По убыванию"])
        self.sort_combo.currentIndexChanged.connect(self.load_products)
        self.filter_layout.addWidget(self.sort_combo)

        main_layout.addLayout(self.filter_layout)

        if self.role_id is None:
            self.search_input.hide()
            self.filter_combo.hide()
            self.sort_combo.hide()

        self.scroll = QScrollArea()
        self.scroll.setWidgetResizable(True)
        self.catalog_widget = QWidget()
        self.catalog_widget.setStyleSheet("background-color: #FFFFFF;")
        self.catalog_layout = QVBoxLayout(self.catalog_widget)
        self.scroll.setWidget(self.catalog_widget)
        main_layout.addWidget(self.scroll)

    def load_categories(self):
        conn = self.db.get_connection()
        if conn:
            cursor = conn.cursor()
            try:
                cursor.execute("SELECT DISTINCT c.name FROM categories c JOIN products p ON c.category_id = p.subcategory_id ORDER BY c.name")
                for cat in cursor.fetchall():
                    self.filter_combo.addItem(cat[0])
            except Exception as e:
                print(f"Ошибка категорий: {e}")
            finally:
                cursor.close()
                self.db.release_connection(conn)

    def load_products(self):
        search = self.search_input.text().strip()
        category = self.filter_combo.currentText()
        sort_order = "ASC" if self.sort_combo.currentText() == "По возрастанию" else "DESC"

        for i in reversed(range(self.catalog_layout.count())): 
            widget = self.catalog_layout.itemAt(i).widget()
            if widget: widget.setParent(None)

        conn = self.db.get_connection()
        if not conn: return
        cursor = conn.cursor()
        try:
            query = """
                SELECT p.product_id, p.name, c.name as category, p.manufacturer, p.composition, p.description,
                       p.base_price, p.image_path, COALESCE(SUM(si.quantity), 0) AS total_quantity
                FROM products p LEFT JOIN categories c ON p.subcategory_id = c.category_id
                LEFT JOIN stock_items si ON p.product_id = si.product_id
                WHERE (p.name ILIKE %s OR p.description ILIKE %s)
            """
            params = [f"%{search}%", f"%{search}%"]
            if category != "Все категории":
                query += " AND c.name = %s"
                params.append(category)
            query += " GROUP BY p.product_id, c.name ORDER BY p.base_price " + sort_order
            cursor.execute(query, tuple(params))
            for product in cursor.fetchall():
                self.catalog_layout.addWidget(self.create_card(product, cursor))
        except Exception as e:
            print(f"Ошибка товаров: {e}")
        finally:
            cursor.close()
            self.db.release_connection(conn)

    def create_card(self, product, cursor):
        prod_id, name, category, manufacturer, composition, description, base_price, image_path, total_qty = product
        
        new_price = calculate_price_with_discount(prod_id, base_price, cursor)
        discount = calculate_discount(float(base_price), new_price)

        card = QWidget()
        card_layout = QHBoxLayout()
        
        base_style = "QWidget { border: 1px solid #ccc; margin-bottom: 5px; background-color: #FFFFFF; color: black; } QLabel { color: black; }"
        blue_style = "QWidget { border: 1px solid #ccc; margin-bottom: 5px; background-color: #ADD8E6; color: black; } QLabel { color: black; }"
        red_style = "QWidget { border: 1px solid #ccc; margin-bottom: 5px; background-color: #ff8080; color: black; } QLabel { color: black; }"
        
        if total_qty == 0: card.setStyleSheet(blue_style) 
        elif 0 < total_qty <= 3: card.setStyleSheet(red_style)  
        else: card.setStyleSheet(base_style) 

        img_label = QLabel()
        img_label.setFixedSize(100, 100)
        img_label.setStyleSheet("border: none; background-color: #f0f0f0;")
        
        img_path = resource_path(f"resources/{image_path}") if image_path else resource_path("resources/picture.png")
        if not os.path.exists(img_path): img_path = resource_path("resources/picture.png")
        
        pixmap = QPixmap(img_path)
        if pixmap.isNull(): 
            img_label.setText("НЕТ ФОТО")
            img_label.setAlignment(Qt.AlignCenter)
        else: 
            img_label.setPixmap(pixmap.scaled(100, 100, Qt.KeepAspectRatio, Qt.SmoothTransformation))
        card_layout.addWidget(img_label)

        text_layout = QVBoxLayout()
        title = QLabel(f"<b>{manufacturer} | {name}</b>")
        title.setStyleSheet("font-size: 14px; color: black; border: none;")
        text_layout.addWidget(title)
        cat_label = QLabel(f"Категория: {category}")
        cat_label.setStyleSheet("color: #333; border: none;")
        text_layout.addWidget(cat_label)
        qty_label = QLabel(f"В наличии: {total_qty} шт.")
        qty_label.setStyleSheet("color: black; border: none;")
        text_layout.addWidget(qty_label)
        
        if composition:
            comp_label = QLabel(f"Состав: {composition[:60]}...")
            comp_label.setStyleSheet("color: #555; font-size: 12px; border: none;")
            text_layout.addWidget(comp_label)
        card_layout.addLayout(text_layout)

        right_layout = QVBoxLayout()
        right_layout.setAlignment(Qt.AlignTop | Qt.AlignRight)
        
        if discount > 0:
            old_lbl = QLabel(f"<s>{base_price} ₽</s>")
            old_lbl.setStyleSheet("color: red; font-size: 14px; border: none;")
            right_layout.addWidget(old_lbl)
            new_lbl = QLabel(f"{new_price:.2f} ₽")
            if discount > 15: 
                new_lbl.setStyleSheet("font-weight: bold; font-size: 18px; color: #2E8B57; border: none;")
            else: 
                new_lbl.setStyleSheet("font-weight: bold; font-size: 18px; color: black; border: none;")
            right_layout.addWidget(new_lbl)
        else:
            old_lbl = QLabel(f"<b>{base_price} ₽</b>")
            old_lbl.setStyleSheet("font-size: 18px; color: black; border: none;")
            right_layout.addWidget(old_lbl)

        btn_layout = QHBoxLayout()
        detail_btn = QPushButton("Подробнее")
        detail_btn.setStyleSheet("background-color: #ccc; color: black; padding: 4px; font-size: 12px;")
        p_data = (prod_id, name, category, manufacturer, composition, description, base_price, new_price, image_path, total_qty)
        detail_btn.clicked.connect(lambda checked, d=p_data: self.show_details(d))
        btn_layout.addWidget(detail_btn)

        if self.role_id in [1, 2, 3] and total_qty > 0:
            buy_btn = QPushButton("В корзину")
            buy_btn.setStyleSheet("background-color: #70B2AF; color: white; padding: 4px; font-size: 12px;")
            buy_btn.clicked.connect(lambda checked, p_id=prod_id, p_price=new_price, p_name=name, p_qty=total_qty: self.add_to_cart(p_id, p_price, p_name, p_qty))
            btn_layout.addWidget(buy_btn)

        right_layout.addLayout(btn_layout)
        card_layout.addLayout(right_layout)
        card.setLayout(card_layout)
        return card

    def show_details(self, product_data):
        dialog = ProductDetailDialog(product_data, self)
        dialog.exec()

    def add_to_cart(self, product_id, price, name, available_qty):
        in_cart_count = sum(1 for item in self.cart if item['name'] == name)
        if in_cart_count >= available_qty:
            QMessageBox.warning(self, "Ошибка", f"На складе только {available_qty} шт. Вы уже добавили максимальное количество.")
            return
            
        conn = self.db.get_connection()
        if not conn: return
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT stock_item_id FROM stock_items WHERE product_id = %s AND quantity > 0 LIMIT 1", (product_id,))
            stock_item = cursor.fetchone()
            if not stock_item:
                QMessageBox.warning(self, "Ошибка", "Нет в наличии!")
                return
            
            self.cart.append({
                "stock_item_id": stock_item[0],
                "price": price,
                "name": name
            })
            self.update_cart_btn()
            QMessageBox.information(self, "Успех", f"Товар '{name}' добавлен в корзину!")
        except Exception as e:
            QMessageBox.critical(self, "Ошибка", f"Не удалось добавить: {e}")
        finally:
            cursor.close()
            self.db.release_connection(conn)

    def update_cart_btn(self):
        if hasattr(self, 'cart_button'):
            self.cart_button.setText(f"Корзина ({len(self.cart)})")

    def open_cart(self):
        dialog = CartDialog(self)
        dialog.exec()

    def open_orders(self):
        dialog = OrdersDialog(self.db, self)
        dialog.exec()

    def logout(self):
        reply = QMessageBox.question(self, 'Выход', 'Вы уверены, что хотите выйти?', QMessageBox.Yes | QMessageBox.No)
        if reply == QMessageBox.Yes:
            from login_window import LoginWindow
            self.login_window = LoginWindow(self.db)
            self.login_window.show()
            self.close()