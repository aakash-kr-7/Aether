import firebase_admin
from firebase_admin import credentials, firestore
import json

# Load credentials and initialize app
cred = credentials.Certificate("firebase_credentials.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

# Load insights from file
with open("aether_insights.json", "r", encoding="utf-8") as f:
    insights = json.load(f)

# Upload each insight
for insight in insights:
    db.collection("insights_repository").add(insight)

print("✅ Upload complete. All insights added to 'insights_repository'")
