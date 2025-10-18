# ZamanBank Setup Guide

## 🚀 Quick Start

### 1. Start the Backend (Docker)
```bash
# Navigate to the project directory
cd /Users/aiaulymabduohapova/Desktop/ZamanBankFull/BackendHackNU

# Start Docker containers
docker-compose up -d

# Wait for containers to be ready (about 30 seconds)
```

### 2. Populate Database with Sample Data
```bash
# Run the population script
./populate_data.sh
```

### 3. Verify Backend is Running
- Open your browser and go to: http://localhost:8000/swagger/
- You should see the API documentation
- Test the login endpoint: http://localhost:8000/api/users/login/

### 4. Test with iOS App
- Open the iOS project in Xcode
- Build and run the app
- Use one of the test accounts to login

## 🔑 Test Accounts

| Email | Password | Type | Description |
|-------|----------|------|-------------|
| `aiaulym@example.com` | `password123` | Adult | Main test account |
| `john@example.com` | `password123` | Adult | Secondary adult account |
| `alice@example.com` | `password123` | Child | Child account for testing |

## 📊 Sample Data Created

### Financial Data:
- **Current Balance**: $1,200.00
- **Income Transactions**: 4 transactions ($3,200 total)
- **Expense Transactions**: 5 transactions ($2,000 total)

### Goals:
- **Vacation to Europe**: $5,000 (60% complete)
- **New Laptop**: $1,500 (80% complete)
- **Emergency Fund**: $3,000 (25% complete)
- **College Fund**: $10,000 (15% complete)
- **Bicycle**: $300 (100% complete)

### Transactions:
- **Income**: Salary, Freelance, Investment, Allowance
- **Expenses**: Rent, Groceries, Utilities, Entertainment, School Supplies

## 🛠️ Troubleshooting

### If Docker containers fail to start:
```bash
# Check Docker status
docker-compose ps

# View logs
docker-compose logs

# Restart containers
docker-compose down
docker-compose up -d
```

### If database population fails:
```bash
# Check if containers are running
docker-compose ps

# Run population script manually
docker-compose exec web python populate_database.py
```

### If iOS app can't connect:
1. Verify backend is running: http://localhost:8000/swagger/
2. Check network settings in iOS app
3. Ensure you're using the correct test accounts

## 📱 iOS App Testing

1. **Login Test**: Use any of the test accounts
2. **Data Loading**: Check if financial data loads correctly
3. **Navigation**: Test all 4 tabs (Home, Chat, Voice, Account)
4. **Error Handling**: Test with wrong credentials

## 🔧 Development Commands

```bash
# View container logs
docker-compose logs -f web

# Access database directly
docker-compose exec db psql -U postgres -d hacknu_db

# Run Django shell
docker-compose exec web python manage.py shell

# Create new migrations
docker-compose exec web python manage.py makemigrations

# Apply migrations
docker-compose exec web python manage.py migrate
```

## 📋 API Endpoints

- **Login**: `POST /api/users/login/`
- **Users**: `GET /api/users/`
- **Finance**: `GET /api/finance/`
- **Goals**: `GET /api/goals/`
- **Transactions From**: `GET /api/transaction-from/`
- **Transactions To**: `GET /api/transaction-to/`
- **Savings**: `GET /api/savings/`

## 🎯 Next Steps

1. Test the complete user flow
2. Verify data is loading correctly
3. Test error handling scenarios
4. Check authentication flow
5. Test all API endpoints

Your ZamanBank app is now ready for testing! 🎉
