import imaplib
import email
import re
import requests
import sys

# ======================
# KONFIGURASI (Gunakan Environment Variables jika memungkinkan)
# ======================
EMAIL = "irfan151110@gmail.com"
APP_PASSWORD = "grqpjrpltehrvizy"
BOT_TOKEN = "7024176173:AAFdUIi6_o3LirxUu1ITl9dElsOFpqpiCE8"
CHAT_ID = "5645537022"

def check_billing():
    try:
        # LOGIN IMAP
        mail = imaplib.IMAP4_SSL("imap.gmail.com")
        mail.login(EMAIL, APP_PASSWORD)
        mail.select("inbox")

        # Cari email dari MyRepublic
        status, messages = mail.search(None, '(FROM "no-reply@myrepublic.net.id")')
        email_ids = messages[0].split()

        if not email_ids:
            print("Tidak ada email dari MyRepublic ditemukan.")
            return

        latest_id = email_ids[-1]
        status, msg_data = mail.fetch(latest_id, "(RFC822)")
        msg = email.message_from_bytes(msg_data[0][1])
        subject = msg["subject"]

        # AMBIL HTML
        html = ""
        if msg.is_multipart():
            for part in msg.walk():
                if part.get_content_type() == "text/html":
                    html += part.get_payload(decode=True).decode(errors="ignore")
        else:
            html = msg.get_payload(decode=True).decode(errors="ignore")

        # HAPUS TAG HTML & CLEANING
        text = re.sub('<[^<]+?>', ' ', html)
        text = re.sub(r'\s+', ' ', text)

        # PARSING DATA
        # Mencari nama (asumsi format email MyRepublic standar)
        nama_match = re.search(r"Yth\.?\s+([^,]+)", text)
        id_pelanggan = re.search(r"ID Pelanggan\s*(\d+)", text)
        invoice = re.search(r"Invoice Number\s*(\d+)", text)
        jatuh_tempo = re.search(r"Tanggal Jatuh Tempo\s*([\d\w\s]+?)(?=\s+TOTAL|\s+Jumlah)", text)
        tagihan = re.search(r"TOTAL\s*([\d\.,]+)", text)

        res_nama = nama_match.group(1).strip() if nama_match else "IRFAN FAJARRIZKI"
        res_id = id_pelanggan.group(1) if id_pelanggan else "-"
        res_inv = invoice.group(1) if invoice else "-"
        res_tgl = jatuh_tempo.group(1).strip() if jatuh_tempo else "-"
        res_total = "Rp " + tagihan.group(1) if tagihan else "-"
        
        status_bayar = "🔴 BELUM DIBAYAR"
        if any(word in subject for word in ["Payment", "Diterima", "Paid", "Berhasil"]):
            status_bayar = "🟢 SUDAH DIBAYAR"

        pesan = (
            f"🌐 *TAGIHAN MyRepublic*\n\n"
            f"👤 *Nama* : {res_nama}\n"
            f"🆔 *ID Pelanggan* : {res_id}\n"
            f"📄 *Invoice* : {res_inv}\n"
            f"⏰ *Jatuh Tempo* : {res_tgl}\n"
            f"💰 *Total Tagihan*: {res_total}\n\n"
            f"💳 *Status* : {status_bayar}\n\n"
            f"📌 *Subject*: {subject}"
        )

        # KIRIM KE TELEGRAM
        url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
        requests.post(url, data={
            "chat_id": CHAT_ID,
            "text": pesan,
            "parse_mode": "Markdown"
        })

        mail.logout()
        print("Notifikasi berhasil dikirim.")

    except Exception as e:
        print(f"Terjadi kesalahan: {e}")

if __name__ == "__main__":
    check_billing()