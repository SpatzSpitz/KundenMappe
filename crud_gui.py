import os
import sqlite3
import tkinter as tk
from tkinter import ttk, messagebox

SCHEMA_FILE = 'geraete_datenbank_schema.sql'
SEED_FILE = 'geraete_datenbank_seed.sql'
DB_FILE = 'geraete.db'


def initialize_db():
    """Create the database from schema and seed if it doesn't exist."""
    if not os.path.exists(DB_FILE):
        conn = sqlite3.connect(DB_FILE)
        with open(SCHEMA_FILE, 'r', encoding='utf-8') as f:
            conn.executescript(f.read())
        with open(SEED_FILE, 'r', encoding='utf-8') as f:
            conn.executescript(f.read())
        conn.commit()
        conn.close()


def get_tables(conn):
    cur = conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
    return [row[0] for row in cur.fetchall()]


def get_columns(conn, table):
    cur = conn.execute(f"PRAGMA table_info({table})")
    cols = [row[1] for row in cur.fetchall()]
    cur = conn.execute(f"PRAGMA table_info({table})")
    pk_cols = [row[1] for row in cur.fetchall() if row[5] > 0]
    return cols, pk_cols


def fetch_all(conn, table):
    cur = conn.execute(f"SELECT * FROM {table}")
    rows = cur.fetchall()
    return rows


class RecordWindow(tk.Toplevel):
    def __init__(self, master, conn, table, columns, pk_cols, data=None, callback=None):
        super().__init__(master)
        self.conn = conn
        self.table = table
        self.columns = columns
        self.pk_cols = pk_cols
        self.data = data
        self.callback = callback
        self.entries = {}
        self.title('Datensatz bearbeiten' if data else 'Datensatz erstellen')

        for i, col in enumerate(columns):
            tk.Label(self, text=col).grid(row=i, column=0, sticky='e')
            entry = tk.Entry(self, width=40)
            entry.grid(row=i, column=1, padx=5, pady=2)
            if data:
                val = data[i]
                entry.insert(0, '' if val is None else str(val))
            self.entries[col] = entry

        tk.Button(self, text='Speichern', command=self.save).grid(row=len(columns), column=0, pady=5)
        tk.Button(self, text='Abbrechen', command=self.destroy).grid(row=len(columns), column=1, pady=5)

    def save(self):
        values = [self.entries[c].get() or None for c in self.columns]
        placeholders = ','.join('?' for _ in self.columns)
        if self.data is None:
            self.conn.execute(f"INSERT INTO {self.table} ({','.join(self.columns)}) VALUES ({placeholders})", values)
        else:
            set_clause = ','.join(f"{c}=?" for c in self.columns)
            where_clause = ' AND '.join(f"{c}=?" for c in self.pk_cols)
            pk_values = [self.entries[c].get() for c in self.pk_cols]
            self.conn.execute(
                f"UPDATE {self.table} SET {set_clause} WHERE {where_clause}",
                values + pk_values
            )
        self.conn.commit()
        if self.callback:
            self.callback()
        self.destroy()


class App(tk.Tk):
    def __init__(self):
        super().__init__()
        initialize_db()
        self.conn = sqlite3.connect(DB_FILE)
        self.title('Geräte Datenbank GUI')

        self.table_var = tk.StringVar()
        self.tables = get_tables(self.conn)
        if self.tables:
            self.table_var.set(self.tables[0])
        tk.OptionMenu(self, self.table_var, *self.tables, command=lambda _: self.load_table()).pack(fill='x')

        self.tree = ttk.Treeview(self, show='headings')
        self.tree.pack(fill='both', expand=True)
        self.tree.bind('<Double-1>', self.edit_record)

        btn_frame = tk.Frame(self)
        btn_frame.pack(fill='x')
        tk.Button(btn_frame, text='Neu', command=self.new_record).pack(side='left')
        tk.Button(btn_frame, text='Löschen', command=self.delete_record).pack(side='left')

        self.load_table()

    def load_table(self):
        table = self.table_var.get()
        self.columns, self.pk_cols = get_columns(self.conn, table)
        self.tree.delete(*self.tree.get_children())
        self.tree['columns'] = self.columns
        for col in self.columns:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=120, anchor='w')
        for row in fetch_all(self.conn, table):
            self.tree.insert('', 'end', values=row)

    def new_record(self):
        RecordWindow(self, self.conn, self.table_var.get(), self.columns, self.pk_cols, callback=self.load_table)

    def edit_record(self, event):
        item = self.tree.focus()
        if not item:
            return
        data = self.tree.item(item, 'values')
        RecordWindow(self, self.conn, self.table_var.get(), self.columns, self.pk_cols, data=data, callback=self.load_table)

    def delete_record(self):
        item = self.tree.focus()
        if not item:
            return
        data = self.tree.item(item, 'values')
        if messagebox.askyesno('Löschen', 'Datensatz wirklich löschen?'):
            where_clause = ' AND '.join(f"{c}=?" for c in self.pk_cols)
            pk_indices = [self.columns.index(c) for c in self.pk_cols]
            pk_values = [data[i] for i in pk_indices]
            self.conn.execute(f"DELETE FROM {self.table_var.get()} WHERE {where_clause}", pk_values)
            self.conn.commit()
            self.load_table()


def main():
    app = App()
    app.mainloop()


if __name__ == '__main__':
    main()
