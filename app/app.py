from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "CD funcionando con Flask!"

@app.route("/health")
def health():
    return {"status":"ok"}

@app.route("/cicd")
def cicd():
    return "CI/CD funcionando"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
