import os
import requests
from flask import Flask, request, Response
import config

app = Flask(__name__)

SF_TOKEN_URL   = config.SF_TOKEN_URL
SF_CLIENT_ID   = config.SF_CLIENT_ID
SF_CLIENT_SECRET = config.SF_CLIENT_SECRET
SF_BASE_URL    = config.SF_BASE_URL
SF_APEX_PATH   = config.SF_APEX_PATH

def get_salesforce_access_token():
    data = {
        "grant_type": "client_credentials",
        "client_id": SF_CLIENT_ID,
        "client_secret": SF_CLIENT_SECRET,
    }
    resp = requests.post(SF_TOKEN_URL, data=data, timeout=30)
    if resp.status_code != 200:
        app.logger.error("Error OAuth SF: %s - %s", resp.status_code, resp.text)
        raise RuntimeError(f"OAuth failed: {resp.status_code}")
    return resp.json()["access_token"]

@app.route("/docusignWebhook", methods=["POST"])
@app.route("/docusignWebhook/", methods=["POST"])
def docusign_webhook():
    # cuerpo y content-type que envía DocuSign (normalmente XML)
    raw_body = request.get_data()
    content_type = request.headers.get("Content-Type", "application/xml")

    app.logger.info("Webhook DocuSign recibido. Bytes: %s; CT: %s", len(raw_body), content_type)

    # Obtiene token y reenvía a Salesforce
    try:
        token = get_salesforce_access_token()
        sf_url = f"{SF_BASE_URL.rstrip('/')}{SF_APEX_PATH}"

        # reenviamos tal cual el body; pasamos content-type y algunos headers útiles
        forward_headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": content_type,
            # opcional: trazabilidad
            "X-Forwarded-For": request.headers.get("X-Forwarded-For", request.remote_addr or ""),
            "X-Docusign-Transmission-Id": request.headers.get("X-DocuSign-Transmission-Id", ""),
        }

        sf_resp = requests.post(sf_url, data=raw_body, headers=forward_headers, timeout=30)
        app.logger.info("Respuesta SF: %s %s", sf_resp.status_code, sf_resp.text[:500])

        return Response(sf_resp.content, status=sf_resp.status_code, content_type=sf_resp.headers.get("Content-Type", "text/plain"))

    except Exception as e:
        app.logger.exception("Fallo reenviando a SF")
        return Response(str(e), status=500, content_type="text/plain")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "8080")))