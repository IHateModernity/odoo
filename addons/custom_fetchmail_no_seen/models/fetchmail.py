from odoo import models
import imaplib

class FetchmailServer(models.Model):
    _inherit = "fetchmail.server"

    def _fetch_mails(self):
        for server in self:
            imap_conn = server.connect()
            try:
                imap_conn.select(server.folder or "INBOX", readonly=True)

                typ, data = imap_conn.search(None, "UNSEEN")
                for num in data[0].split():
                    typ, msg_data = imap_conn.fetch(num, "(BODY.PEEK[])")
                    msg = msg_data[0][1]
                    self.env["mail.thread"].with_context(
                        fetchmail_server_id=server.id,
                        server_type="imap",
                    ).message_process(
                        server.object_id.model or "mail.thread",
                        msg,
                        save_original=server.original,
                        strip_attachments=not server.attach,
                    )
            finally:
                try:
                    imap_conn.close()
                except Exception:
                    pass
                imap_conn.logout()
