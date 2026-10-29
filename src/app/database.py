from psycopg2 import pool
import psycopg2

class Database:
    def __init__(self):
        try:
            self.connection_pool = pool.SimpleConnectionPool(
                1, 10,
                host="localhost",
                port=5432,
                database="cosmetic_pro_db", 
                user="postgres",
                password="123" 
            )
            if self.connection_pool:
                print("Пул соединений успешно создан")
        except (Exception, psycopg2.Error) as error:
            print(f"Ошибка при подключении к БД: {error}")
            self.connection_pool = None

    def get_connection(self):
        if self.connection_pool:
            return self.connection_pool.getconn()
        return None

    def release_connection(self, conn):
        if self.connection_pool:
            self.connection_pool.putconn(conn)

    def close_all(self):
        if self.connection_pool:
            self.connection_pool.closeall()