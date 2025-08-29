# 🏛️ Estonian e-Business Register API Demo App

An interactive Sinatra web application that demonstrates all features of the `ee_e_business_register` Ruby gem. This demo provides a user-friendly interface to test every API endpoint with real data.

## 🚀 Quick Start

### Prerequisites

- Ruby 3.0+
- Valid Estonian e-Business Register API credentials
- The `ee_e_business_register` gem (included locally)

### Installation

1. Navigate to the demo app directory:
```bash
cd demo_app
```

2. Install dependencies:
```bash
bundle install
```

3. Create a `.env` file with your API credentials:
```bash
cp .env.example .env
```

Edit `.env` and add your credentials:
```env
EE_API_USERNAME=your_username_here
EE_API_PASSWORD=your_password_here
EE_API_LANGUAGE=eng
EE_API_ENVIRONMENT=production
```

### Running the Application

Start the Sinatra server:
```bash
ruby app.rb
```

Or use the rackup command:
```bash
rackup -p 4567
```

For automatic reloading during development:
```bash
bundle exec rerun 'rackup -p 4567'
```

Visit http://localhost:4567 in your browser.

## ✨ Features

### Available Endpoints

The demo app provides web interfaces for all API endpoints:

#### Company Information
- **Find Company** - Look up company by 8-digit registry code
- **Search Companies** - Search by name or partial name
- **Detailed Company Data** - Get comprehensive company information

#### Financial Documents
- **Company Documents** - List all documents (articles, reports, etc.)
- **Annual Reports List** - View all filed annual reports
- **Annual Report Data** - Access detailed financial statements

#### Ownership & Management
- **Representation Rights** - See who can represent the company
- **Beneficial Owners** - Identify ultimate beneficial owners
- **Ownership Changes** - Track beneficial ownership changes over time

#### Reference Data
- **Classifiers** - Access legal forms, statuses, regions, and more

#### System Health
- **API Health & Status** - Monitor rate limits, circuit breaker, and security features

## 📊 Sample Companies for Testing

Use these real Estonian companies for testing:

- **Swedbank AS**: `10060701` (Major bank)
- **Bolt Operations OÜ**: `14532901` (Technology/Transport)
- **Wise Europe SA**: `14041764` (FinTech)
- **Pipedrive OÜ**: `12433421` (Software/CRM)
- **Sorbeet Payments OÜ**: `16863232` (FinTech/Payments)

## 🛡️ Security Features

The demo app includes all enterprise security features:

- ✅ **Rate Limiting** - Estonian API compliance (50k/day, 1 concurrent)
- ✅ **Input Sanitization** - XXE/XSS prevention
- ✅ **Circuit Breaker** - Automatic failure recovery
- ✅ **Structured Logging** - JSON audit trails
- ✅ **Request Retry** - Exponential backoff

Monitor these features in real-time at `/health`.

## 🎨 User Interface

The demo app features:

- Clean, responsive design
- Form validation for all inputs
- Error handling with user-friendly messages
- Sample data and tips for each endpoint
- Real-time security status monitoring
- Color-coded badges for statuses

## 📝 Code Structure

```
demo_app/
├── app.rb                  # Main Sinatra application
├── config.ru              # Rack configuration
├── Gemfile                # Ruby dependencies
├── .env.example           # Environment variables template
├── README.md              # This file
└── views/
    ├── layout.erb         # HTML layout template
    ├── index.erb          # Home page
    ├── company/           # Company-related views
    │   ├── find.erb
    │   ├── result.erb
    │   ├── search.erb
    │   ├── search_results.erb
    │   ├── detailed.erb
    │   └── detailed_result.erb
    ├── documents/         # Document views
    ├── reports/           # Financial report views
    ├── representation/    # Representation rights views
    ├── owners/           # Beneficial owner views
    ├── classifiers/      # Reference data views
    └── health/           # System health views
```

## 🔧 Configuration Options

### Environment Variables

- `EE_API_USERNAME` - Your API username (required)
- `EE_API_PASSWORD` - Your API password (required)
- `EE_API_LANGUAGE` - Response language: `eng` or `est` (default: `eng`)
- `EE_API_ENVIRONMENT` - API environment: `production` or `test` (default: `production`)

### Security Configuration

The app automatically enables all security features:

```ruby
config.rate_limiting_enabled = true
config.sanitization_enabled = true
config.circuit_breaker_enabled = true
```

## 🧪 Testing the API

### Basic Workflow

1. Start at the home page to see all available endpoints
2. Choose "Find Company" to look up a specific company
3. Enter a registry code (e.g., `10060701` for Swedbank)
4. View the results and navigate to related data
5. Try "Search Companies" to find multiple companies
6. Check "Health" to monitor API status and limits

### Advanced Testing

- Test rate limiting by making multiple rapid requests
- Trigger circuit breaker by using invalid credentials
- Monitor security features in real-time at `/health`
- Export financial data from annual reports
- Track beneficial ownership changes over time

## 🚦 Troubleshooting

### Common Issues

**"Authentication failed" error:**
- Verify your credentials in `.env`
- Ensure you have an active API contract with RIK
- Check if using correct environment (production/test)

**"Rate limit exceeded" error:**
- Check current usage at `/health`
- Wait for daily reset (midnight UTC)
- Estonian API allows max 50,000 queries/day

**"Circuit breaker open" error:**
- Multiple failures triggered protection
- Wait 2 minutes for automatic recovery
- Check `/health` for current state

**Empty or missing data:**
- Some companies may have limited public data
- Try different registry codes
- Ensure company is active (status 'R')

## 📚 Resources

- [ee_e_business_register Gem Documentation](https://github.com/your-username/ee_e_business_register)
- [Estonian e-Business Register Official Site](https://ariregister.rik.ee/)
- [API Documentation (Estonian)](https://ariregister.rik.ee/help)
- [Get API Credentials](https://www.rik.ee/en/e-business-register/open-data-api)

## 📄 License

This demo application is part of the ee_e_business_register gem and is available under the MIT License.

## 📞 Support

For support, please contact:
- **Email**: angelos@sorbet.ee
- **Company**: [Sorbeet Payments OÜ](https://sorbet.ee)
- **GitHub Issues**: [Report bugs or request features](https://github.com/your-username/ee_e_business_register/issues)

---

Developed with ❤️ by [Sorbeet Payments OÜ](https://sorbet.ee) in Estonia 🇪🇪