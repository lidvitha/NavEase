from flask import Flask, request, jsonify, session

app = Flask(__name__)
app.secret_key = "your_secret_key"  # Required for session handling

# Default admin credentials
DEFAULT_USERNAME = "admin"
DEFAULT_PASSWORD = "admin"

@app.route('/api/login', methods=['POST'])
def login():
    """
    Endpoint for admin login.
    Expects JSON input: {"username": "admin", "password": "admin"}
    """
    data = request.json  # Expecting JSON input
    username = data.get('username')
    password = data.get('password')

    if username == DEFAULT_USERNAME and password == DEFAULT_PASSWORD:
        session['admin_logged_in'] = True
        return jsonify({
            "message": "Login successful! Navigating to the dashboard.",
            "status": "success"
        }), 200
    else:
        return jsonify({
            "message": "Invalid credentials. Unable to navigate to the dashboard.",
            "status": "error"
        }), 401

@app.route('/api/dashboard', methods=['GET'])
def dashboard():
    """
    Protected endpoint for the admin dashboard.
    Only accessible after successful login.
    """
    if not session.get('admin_logged_in'):
        return jsonify({
            "message": "Unauthorized access. Please log in to navigate further.",
            "status": "error"
        }), 403
    return jsonify({
        "message": "Welcome to the Admin Navigation Dashboard!",
        "status": "success"
    }), 200

@app.route('/api/logout', methods=['POST'])
def logout():
    """
    Endpoint to log out the admin.
    Clears the session and invalidates access.
    """
    if session.get('admin_logged_in'):
        session.pop('admin_logged_in', None)
        return jsonify({
            "message": "Logout successful! Navigation reset.",
            "status": "success"
        }), 200
    return jsonify({
        "message": "No active session found. Unable to log out.",
        "status": "error"
    }), 400

@app.errorhandler(404)
def not_found(e):
    """
    Custom error handler for 404 errors.
    """
    return jsonify({
        "message": "Navigation error: Resource not found.",
        "status": "error"
    }), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
