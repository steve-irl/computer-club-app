from fastapi import FastAPI, Request, Form
from fastapi.responses import RedirectResponse
from fastapi.templating import Jinja2Templates
import mysql.connector
import math

app = FastAPI()
templates = Jinja2Templates(directory="templates")

def get_db():
    return mysql.connector.connect(
        host="db",
        user="club_user",
        password="userclub",
        database="computer_club"
    )

@app.get("/")
def index(request: Request):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    # Получаем все ПК + информацию об активной сессии, если стол занят
    cursor.execute("""
        SELECT 
            s.id, s.number, s.status, 
            h.name AS hall_name, h.price_coefficient,
            p.cpu, p.gpu, p.ram_gb,
            sess.id AS active_session_id,
            sess.start_time AS session_start,
            c.full_name AS active_client_name,
            c.deposit_balance AS active_client_balance,
            t.name AS active_tariff_name,
            t.price AS active_tariff_price,
            COALESCE((SELECT SUM(total_price) FROM orders WHERE session_id = sess.id), 0) AS bar_total
        FROM seats s
        JOIN halls h ON s.hall_id = h.id
        JOIN pc_specs p ON s.pc_id = p.id
        LEFT JOIN sessions sess ON s.id = sess.seat_id AND sess.status = 'active'
        LEFT JOIN clients c ON sess.client_id = c.id
        LEFT JOIN tariffs t ON sess.tariff_id = t.id
        ORDER BY s.number ASC
    """)
    seats = cursor.fetchall()

    # Форматируем время старта в строку для передачи в JS
    for seat in seats:
        if seat["session_start"]:
            seat["session_start_str"] = seat["session_start"].strftime("%Y-%m-%d %H:%M:%S")
        else:
            seat["session_start_str"] = ""

    cursor.execute("SELECT * FROM tariffs")
    tariffs = cursor.fetchall()

    cursor.execute("SELECT id, full_name, deposit_balance FROM clients")
    clients = cursor.fetchall()

    cursor.close()
    conn.close()

    return templates.TemplateResponse("index.html", {
        "request": request,
        "seats": seats,
        "tariffs": tariffs,
        "clients": clients
    })

@app.post("/start-session")
def start_session(
    seat_id: int = Form(...),
    client_id: int = Form(...),
    tariff_id: int = Form(...)
):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO sessions (start_time, status, seat_id, tariff_id, client_id) VALUES (NOW(), 'active', %s, %s, %s)",
        (seat_id, tariff_id, client_id)
    )
    cursor.execute("UPDATE seats SET status = 'occupied' WHERE id = %s", (seat_id,))

    conn.commit()
    cursor.close()
    conn.close()
    return RedirectResponse(url="/", status_code=303)

@app.post("/finish-session")
def finish_session(session_id: int = Form(...)):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    # 1. Фиксируем время окончания сессии
    cursor.execute("UPDATE sessions SET end_time = NOW() WHERE id = %s", (session_id,))

    # 2. Получаем данные для расчёта стоимости
    cursor.execute("""
        SELECT 
            s.client_id, s.seat_id,
            t.price AS tariff_price,
            h.price_coefficient,
            GREATEST(1, CEIL(TIMESTAMPDIFF(MINUTE, s.start_time, s.end_time) / 60.0)) AS hours_played,
            COALESCE((SELECT SUM(total_price) FROM orders WHERE session_id = s.id), 0) AS bar_cost
        FROM sessions s
        JOIN tariffs t ON s.tariff_id = t.id
        JOIN seats st ON s.seat_id = st.id
        JOIN halls h ON st.hall_id = h.id
        WHERE s.id = %s
    """, (session_id,))
    info = cursor.fetchone()

    if info:
        time_cost = float(info["tariff_price"]) * float(info["price_coefficient"]) * int(info["hours_played"])
        total_cost = round(time_cost + float(info["bar_cost"]), 2)

        # 3. Завершаем сессию, списываем деньги с баланса и освобождаем ПК
        cursor.execute("UPDATE sessions SET status = 'finished' WHERE id = %s", (session_id,))
        cursor.execute("UPDATE clients SET deposit_balance = deposit_balance - %s WHERE id = %s", (total_cost, info["client_id"]))
        cursor.execute("UPDATE seats SET status = 'available' WHERE id = %s", (info["seat_id"],))

    conn.commit()
    cursor.close()
    conn.close()
    return RedirectResponse(url="/", status_code=303)
