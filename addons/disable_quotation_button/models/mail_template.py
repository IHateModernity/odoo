from odoo import models

class MailTemplate(models.Model):
    _inherit = 'mail.template'

    def _replace_view_button(self, body_html):
        """
        Убираем <div> с кнопкой View Document Online
        """
        import re
        return re.sub(
            r'<div[^>]*class="o_mail_notification[^>]*>.*?</div>',
            '',
            body_html,
            flags=re.DOTALL
        )

    def generate_email(self, res_ids, fields=None, **kwargs):
        multi_mode = True
        if isinstance(res_ids, int):
            res_ids = [res_ids]
            multi_mode = False

        result = super().generate_email(res_ids, fields=fields, **kwargs)
        if not isinstance(result, list):
            result = [result]

        for item in result:
            if 'body_html' in item:
                item['body_html'] = self._replace_view_button(item['body_html'])

        return result if multi_mode else result[0]
