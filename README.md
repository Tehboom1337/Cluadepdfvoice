# UPC Voice Lookup & Inventory Manager

An iOS app that uses voice commands and Google's Gemini AI to look up product information by UPC codes and manage inventory.

## Features

- 🎤 **Voice-Powered UPC Input** - Speak UPC codes naturally using iOS Speech Recognition
- 🤖 **AI Assistant** - Google Gemini AI for natural language commands and product insights
- 📦 **Product Lookup** - Automatic product information retrieval from UPC databases
- 📊 **Inventory Management** - Track quantities, locations, and notes for all products
- 📤 **CSV Export** - Export inventory to CSV for use in Excel or other tools
- 🔍 **Smart Search** - Search inventory by product name, UPC, or category

## Screenshots

[Add screenshots of your app here]

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Active internet connection
- Google Gemini API Key (free tier available)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/Tehboom1337/Cluadepdfvoice.git
cd Cluadepdfvoice
```

### 2. Open in Xcode

```bash
open UPCVoiceApp.xcodeproj
```

Or open Xcode and select File > Open > UPCVoiceApp folder

### 3. Configure Bundle Identifier

1. Select the project in Xcode's navigator
2. Under "Signing & Capabilities", change the bundle identifier to your own
3. Select your development team

### 4. Get API Keys

#### Google Gemini API Key (Required for AI features)

1. Visit [Google AI Studio](https://ai.google.dev/)
2. Sign in with your Google account
3. Click "Get API Key"
4. Create a new API key for Gemini
5. Copy the API key

**Note:** The free tier includes:
- 60 requests per minute
- 1,500 requests per day
- No credit card required

#### UPC Database API (Already configured)

The app uses [UPCitemdb.com](https://www.upcitemdb.com/)'s trial API by default, which allows:
- 100 requests per day
- No API key required for trial

For production use, you can sign up for a free API key at UPCitemdb.com for increased limits.

### 5. Run the App

1. Select a simulator or connected iOS device
2. Press Cmd+R or click the Run button
3. Grant microphone and speech recognition permissions when prompted

### 6. Configure the App

1. Open the app and go to the Settings tab
2. Enter your Google Gemini API key
3. Tap "Save API Key"
4. Grant microphone permission if not already granted

## Usage

### Voice Commands

#### Scanning UPCs

Tap the microphone button and speak the UPC code clearly:

```
"zero seven two one six five zero zero zero one two three"
```

**Tips for best recognition:**
- Speak each digit individually
- Use "zero" instead of "oh"
- Pause briefly between digit groups
- Speak at a moderate pace

#### Natural Language Commands

Once you have a product displayed:

```
"Add to inventory"
"Add five to inventory"
"How many do we have?"
"What is this product?"
```

### Manual UPC Entry

You can also type UPC codes directly:
1. Enter the 8, 12, or 13 digit code
2. Tap the search button
3. View product details

### Managing Inventory

#### Adding Items
1. Look up a product by UPC
2. Tap on the product card to view details
3. Set quantity, location, and notes
4. Tap "Add to Inventory"

#### Viewing Inventory
1. Go to the Inventory tab
2. Swipe left on items for quick actions:
   - **Green +**: Add 1 to quantity
   - **Orange -**: Remove 1 from quantity
   - **Red trash**: Delete item

#### Exporting Inventory
1. Go to Inventory tab
2. Tap the menu icon (three dots)
3. Select "Export CSV"
4. Share or save the file

## Architecture

### Project Structure

```
UPCVoiceApp/
├── Models/
│   ├── Product.swift              # Product data model
│   └── InventoryItem.swift        # Inventory item model
├── Services/
│   ├── VoiceRecognitionService.swift   # iOS Speech Recognition
│   ├── GeminiAIService.swift          # Google Gemini AI integration
│   ├── UPCLookupService.swift         # UPC product lookup
│   └── InventoryManager.swift         # Inventory management & persistence
├── ViewModels/
│   └── MainViewModel.swift        # Main app coordinator
├── Views/
│   ├── ContentView.swift          # Main tab interface
│   ├── ProductDetailView.swift    # Product details & add to inventory
│   ├── InventoryListView.swift    # Inventory list & management
│   └── SettingsView.swift         # App settings
└── Info.plist                     # App configuration & permissions
```

### Key Technologies

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for state management
- **Speech Framework** - iOS speech recognition
- **AVFoundation** - Audio input handling
- **URLSession** - Networking for API calls
- **UserDefaults** - Local data persistence

## API Information

### Google Gemini API

The app uses Google's Gemini Pro model for:
- Natural language command interpretation
- Product analysis and insights
- Inventory suggestions

**Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent`

**Documentation:** [Google AI Documentation](https://ai.google.dev/docs)

### UPC Lookup API

Default: UPCitemdb.com
**Endpoint:** `https://api.upcitemdb.com/prod/trial/lookup`

Alternative APIs (configurable in code):
- Barcode Lookup API
- UPC Database

## Troubleshooting

### Voice Recognition Not Working

1. Check Settings > Privacy & Security > Microphone
2. Ensure UPC Voice has microphone permission
3. Check Settings > Privacy & Security > Speech Recognition
4. Restart the app

### API Errors

**"Rate limit exceeded"**
- UPCitemdb trial: Wait until next day or upgrade
- Gemini: Wait 60 seconds between batches

**"Product not found"**
- Try manual entry with product details
- Verify UPC code is correct
- Some products may not be in the database

### Voice Commands Not Recognized

1. Ensure Gemini API key is configured
2. Check internet connection
3. Speak more clearly and slowly
4. Use manual entry as fallback

## Privacy & Data

- All data is stored locally on your device
- API keys are stored securely in UserDefaults
- Voice data is processed by Apple's Speech Recognition
- Product lookups require internet connection
- No user data is collected or shared

## Future Enhancements

- [ ] Barcode camera scanning
- [ ] Multiple inventory locations
- [ ] Low stock alerts
- [ ] Price tracking history
- [ ] Share inventory with team
- [ ] Dark mode support
- [ ] iPad optimization
- [ ] Offline mode with cached products

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available under the MIT License.

## Support

For issues, questions, or suggestions:
- Create an issue on GitHub
- Contact: [your-email@example.com]

## Acknowledgments

- Google Gemini AI for natural language processing
- UPCitemdb.com for product database
- Apple's Speech Recognition framework

---

Made with ❤️ for efficient inventory management
