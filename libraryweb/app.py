from flask import Flask, render_template, request, redirect, url_for, flash
import pymysql

app = Flask(__name__)
app.secret_key = 'your_secret_key_here'

# 数据库连接配置
def get_db_connection():
    return pymysql.connect(
        host='localhost',
        user='root',
        password='ccwl542288',
        database='librarydb',
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/add_book', methods=['GET', 'POST'])
def add_book():
    conn = get_db_connection()
    cursor = conn.cursor()
    if request.method == 'POST':
        title = request.form['title']
        author_id = request.form['author_id']
        type_id = request.form['type_id']
        publisher_id = request.form['publisher_id']
        publish_year = request.form['publish_year']
        isbn = request.form['isbn']
        price = request.form['price']

        cursor.execute("""
            INSERT INTO Books (Title, AuthorID, TypeID, PublisherID, PublishYear, ISBN, Price)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (title, author_id, type_id, publisher_id, publish_year, isbn, price))
        book_id = cursor.lastrowid
        cursor.execute("""
            INSERT INTO BookCopies (BookID, Location, Status)
            VALUES (%s, %s, 'Available')
        """, (book_id, '默认位置'))
        conn.commit()
        flash('新书添加成功')
        return redirect(url_for('index'))
    return render_template('add_book.html')

@app.route('/register_reader', methods=['GET', 'POST'])
def register_reader():
    conn = get_db_connection()
    cursor = conn.cursor()
    if request.method == 'POST':
        name = request.form['name']
        gender = request.form['gender']
        phone = request.form['phone']
        address = request.form['address']
        email = request.form['email']

        cursor.execute("""
            INSERT INTO Readers (Name, Gender, Phone, Address, Email, CreatedAt)
            VALUES (%s, %s, %s, %s, %s, CURDATE())
        """, (name, gender, phone, address, email))
        conn.commit()
        flash('读者注册成功')
        return redirect(url_for('index'))
    return render_template('register_reader.html')

@app.route('/borrow_book', methods=['GET', 'POST'])
def borrow_book():
    conn = get_db_connection()
    cursor = conn.cursor()
    if request.method == 'POST':
        reader_id = request.form['reader_id']
        copy_id = request.form['copy_id']

        cursor.execute("SELECT Status FROM BookCopies WHERE CopyID = %s", (copy_id,))
        result = cursor.fetchone()
        if not result:
            flash('副本不存在')
        elif result['Status'] != 'Available':
            flash(f"副本不可借，当前状态为：{result['Status']}")
        else:
            cursor.execute("""
                INSERT INTO BorrowRecords (ReaderID, CopyID, BorrowDate, DueDate)
                VALUES (%s, %s, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY))
            """, (reader_id, copy_id))
            cursor.execute("UPDATE BookCopies SET Status = 'Borrowed' WHERE CopyID = %s", (copy_id,))
            conn.commit()
            flash('借阅成功')
            return redirect(url_for('index'))
    return render_template('borrow_book.html')

@app.route('/return_book', methods=['GET', 'POST'])
def return_book():
    conn = get_db_connection()
    cursor = conn.cursor()
    if request.method == 'POST':
        borrow_id = request.form['borrow_id']
        cursor.execute("SELECT ReturnDate, CopyID, DueDate FROM BorrowRecords WHERE BorrowID = %s", (borrow_id,))
        result = cursor.fetchone()
        if not result:
            flash('借阅记录不存在')
        elif result['ReturnDate']:
            flash('该图书已归还')
        else:
            cursor.execute("""
                UPDATE BorrowRecords SET ReturnDate = CURDATE() WHERE BorrowID = %s
            """, (borrow_id,))
            cursor.execute("UPDATE BookCopies SET Status = 'Available' WHERE CopyID = %s", (result['CopyID'],))
            cursor.execute("SELECT DATEDIFF(CURDATE(), %s) AS days_overdue", (result['DueDate'],))
            overdue = cursor.fetchone()['days_overdue']
            if overdue > 0:
                cursor.execute("""
                    INSERT INTO Fines (BorrowID, FineAmount, Paid) VALUES (%s, %s, 0)
                """, (borrow_id, overdue * 0.5))
            conn.commit()
            flash('归还成功')
            return redirect(url_for('index'))
    return render_template('return_book.html')

@app.route('/unreturned_books')
def unreturned_books():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT br.BorrowID, br.ReaderID, b.Title, bc.CopyID, br.BorrowDate, br.DueDate
        FROM BorrowRecords br
        JOIN BookCopies bc ON br.CopyID = bc.CopyID
        JOIN Books b ON bc.BookID = b.BookID
        WHERE br.ReturnDate IS NULL
        ORDER BY br.DueDate ASC
    """)
    books = cursor.fetchall()
    return render_template('unreturned_books.html', books=books)

@app.route('/fines', methods=['GET', 'POST'])
def fines():
    conn = get_db_connection()
    cursor = conn.cursor()
    fines_list = []
    reader_id = None
    if request.method == 'POST':
        reader_id = request.form['reader_id']
        cursor.execute("""
            SELECT f.FineID, f.FineAmount, f.Paid, f.PaymentDate, br.ReaderID
            FROM Fines f
            JOIN BorrowRecords br ON f.BorrowID = br.BorrowID
            WHERE br.ReaderID = %s
        """, (reader_id,))
    else:
        cursor.execute("""
            SELECT f.FineID, f.FineAmount, f.Paid, f.PaymentDate, br.ReaderID
            FROM Fines f
            JOIN BorrowRecords br ON f.BorrowID = br.BorrowID
        """)
    fines_list = cursor.fetchall()
    return render_template('fines.html', fines=fines_list, reader_id=reader_id)

@app.route('/pay_fine/<int:fine_id>', methods=['POST'])
def pay_fine(fine_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE Fines SET Paid = 1, PaymentDate = CURDATE() WHERE FineID = %s
    """, (fine_id,))
    conn.commit()
    flash('罚款已缴纳')
    return redirect(url_for('fines'))

@app.route('/reservations', methods=['GET', 'POST'])
def reservations():
    conn = get_db_connection()
    cursor = conn.cursor()
    reservations_list = []
    reader_id = None
    if request.method == 'POST':
        reader_id = request.form['reader_id']
        cursor.execute("""
            SELECT ReservationID, ReaderID, CopyID, ReservationDate, Status
            FROM Reservations
            WHERE ReaderID = %s
        """, (reader_id,))
    else:
        cursor.execute("""
            SELECT ReservationID, ReaderID, CopyID, ReservationDate, Status
            FROM Reservations
        """)
    reservations_list = cursor.fetchall()
    return render_template('reservations.html', reservations=reservations_list, reader_id=reader_id)

if __name__ == '__main__':
    app.run(debug=True)
