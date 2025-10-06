# Test Database Setup

# After setting up PostgreSQL, run this to test:
psql -U postgres -d hackathon -c "SELECT email, name FROM users WHERE email='demo@demo.com';"

# Expected output:
#     email     |   name    
# --------------+-----------
#  demo@demo.com | Demo User
# (1 row)

# Then test the backend login again:
# cd "d:\Hackathon\New co"
# powershell -Command "Invoke-RestMethod -Uri 'http://localhost:3003/api/login' -Method Post -InFile 'test-login.json' -ContentType 'application/json'"

# Should return:
# {"token":"...","user":{"id":1,"email":"demo@demo.com","name":"Demo User"}}